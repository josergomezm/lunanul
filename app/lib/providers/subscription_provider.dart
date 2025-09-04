import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/subscription_status.dart';
import '../models/enums.dart';
import '../services/subscription_service.dart';
import '../services/mock_subscription_service.dart';
import '../services/subscription_sync_service.dart';

/// Provider for the subscription service
final subscriptionServiceProvider = Provider<SubscriptionService>((ref) {
  return MockSubscriptionService();
});

/// State notifier for managing subscription status
class SubscriptionNotifier
    extends StateNotifier<AsyncValue<SubscriptionStatus>> {
  SubscriptionNotifier(this._subscriptionService, [this._syncService])
    : super(const AsyncValue.loading()) {
    _initialize();
  }

  final SubscriptionService _subscriptionService;
  final SubscriptionSyncService? _syncService;

  /// Initialize the subscription status
  Future<void> _initialize() async {
    try {
      // Try to get cached status first if sync service is available
      SubscriptionStatus? cachedStatus;
      if (_syncService != null) {
        cachedStatus = _syncService.getCachedStatus();
      }

      // If we have cached status, use it initially
      if (cachedStatus != null) {
        state = AsyncValue.data(cachedStatus);
      }

      // Then get fresh status
      final status = await _subscriptionService.getSubscriptionStatus();
      state = AsyncValue.data(status);

      // Listen to subscription status changes
      _subscriptionService.subscriptionStatusStream().listen(
        (status) {
          if (mounted) {
            state = AsyncValue.data(status);
          }
        },
        onError: (error, stackTrace) {
          if (mounted) {
            // If we have cached status and there's an error, fall back to cached
            if (_syncService != null) {
              final cached = _syncService.getCachedStatus();
              if (cached != null) {
                state = AsyncValue.data(cached);
                return;
              }
            }
            state = AsyncValue.error(error, stackTrace);
          }
        },
      );

      // Listen to sync status for expiration handling
      if (_syncService != null) {
        _syncService.syncStatusStream.listen((syncStatus) {
          if (syncStatus == SyncStatus.expired && mounted) {
            // Force refresh when sync detects expiration
            _handleExpiredSubscription();
          }
        });
      }
    } catch (error, stackTrace) {
      // Try to fall back to cached status
      if (_syncService != null) {
        final cached = _syncService.getCachedStatus();
        if (cached != null) {
          state = AsyncValue.data(cached);
          return;
        }
      }
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Refresh subscription status from platform
  Future<void> refreshStatus() async {
    try {
      state = const AsyncValue.loading();
      await _subscriptionService.refreshSubscriptionStatus();
      final status = await _subscriptionService.getSubscriptionStatus();
      state = AsyncValue.data(status);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Purchase a subscription
  Future<bool> purchaseSubscription(String productId) async {
    try {
      final success = await _subscriptionService.purchaseSubscription(
        productId,
      );
      if (success) {
        // Refresh status after successful purchase
        await refreshStatus();
      }
      return success;
    } catch (error) {
      // Don't update state on purchase errors, let the UI handle them
      rethrow;
    }
  }

  /// Restore previous subscriptions
  Future<bool> restoreSubscriptions() async {
    try {
      final restored = await _subscriptionService.restoreSubscriptions();
      if (restored) {
        // Refresh status after successful restoration
        await refreshStatus();
      }
      return restored;
    } catch (error) {
      // Don't update state on restore errors, let the UI handle them
      rethrow;
    }
  }

  /// Update subscription status manually (for testing or external updates)
  void updateStatus(SubscriptionStatus status) {
    state = AsyncValue.data(status);
  }

  /// Increment usage for a feature
  Future<void> incrementUsage(String feature) async {
    final currentState = state;
    if (currentState is AsyncData<SubscriptionStatus>) {
      final updatedStatus = currentState.value.incrementUsage(feature);
      state = AsyncValue.data(updatedStatus);
    }
  }

  /// Reset monthly usage
  Future<void> resetUsage() async {
    final currentState = state;
    if (currentState is AsyncData<SubscriptionStatus>) {
      final updatedStatus = currentState.value.resetUsage();
      state = AsyncValue.data(updatedStatus);
    }
  }

  /// Handle expired subscription gracefully
  Future<void> _handleExpiredSubscription() async {
    final currentState = state;
    if (currentState is AsyncData<SubscriptionStatus>) {
      final currentStatus = currentState.value;

      // Create a gracefully downgraded status
      final downgradedStatus = SubscriptionStatus(
        tier: SubscriptionTier.seeker,
        isActive: true,
        expirationDate: null,
        platformSubscriptionId: null,
        usageCounts: currentStatus.usageCounts, // Preserve usage counts
        lastUpdated: DateTime.now(),
      );

      state = AsyncValue.data(downgradedStatus);
    }
  }

  /// Verify subscription status with platform
  Future<void> verifyStatus() async {
    try {
      state = const AsyncValue.loading();
      final status = await _subscriptionService.verifySubscriptionStatus();
      state = AsyncValue.data(status);
    } catch (error, stackTrace) {
      // Fall back to cached status if available
      if (_syncService != null) {
        final cached = _syncService.getCachedStatus();
        if (cached != null) {
          state = AsyncValue.data(cached);
          return;
        }
      }
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

/// Provider for the subscription state notifier
final subscriptionProvider =
    StateNotifierProvider<SubscriptionNotifier, AsyncValue<SubscriptionStatus>>(
      (ref) {
        final service = ref.watch(subscriptionServiceProvider);
        return SubscriptionNotifier(service);
      },
    );

/// Alias for backward compatibility with tests
final subscriptionStatusProvider = subscriptionProvider;

/// Provider for current subscription tier
final currentTierProvider = Provider<SubscriptionTier>((ref) {
  final subscriptionAsync = ref.watch(subscriptionProvider);
  return subscriptionAsync.when(
    data: (status) => status.tier,
    loading: () =>
        SubscriptionTier.seeker, // Default to free tier while loading
    error: (error, stackTrace) =>
        SubscriptionTier.seeker, // Default to free tier on error
  );
});

/// Provider for current subscription status (synchronous access)
final currentSubscriptionStatusProvider = Provider<SubscriptionStatus?>((ref) {
  final subscriptionAsync = ref.watch(subscriptionProvider);
  return subscriptionAsync.when(
    data: (status) => status,
    loading: () => null,
    error: (error, stackTrace) => null,
  );
});

/// Provider for checking if subscription is active
final isSubscriptionActiveProvider = Provider<bool>((ref) {
  final subscriptionAsync = ref.watch(subscriptionProvider);
  return subscriptionAsync.when(
    data: (status) => status.isValid,
    loading: () => false,
    error: (error, stackTrace) => false,
  );
});

/// Provider for checking if subscription is expired
final isSubscriptionExpiredProvider = Provider<bool>((ref) {
  final subscriptionAsync = ref.watch(subscriptionProvider);
  return subscriptionAsync.when(
    data: (status) => status.isExpired,
    loading: () => false,
    error: (error, stackTrace) => false,
  );
});

/// Provider for subscription expiration date
final subscriptionExpirationProvider = Provider<DateTime?>((ref) {
  final subscriptionAsync = ref.watch(subscriptionProvider);
  return subscriptionAsync.when(
    data: (status) => status.expirationDate,
    loading: () => null,
    error: (error, stackTrace) => null,
  );
});

/// Provider for usage counts
final usageCountsProvider = Provider<Map<String, int>>((ref) {
  final subscriptionAsync = ref.watch(subscriptionProvider);
  return subscriptionAsync.when(
    data: (status) => status.usageCounts,
    loading: () => {},
    error: (error, stackTrace) => {},
  );
});

/// Provider for specific feature usage count
final featureUsageProvider = Provider.family<int, String>((ref, feature) {
  final usageCounts = ref.watch(usageCountsProvider);
  return usageCounts[feature] ?? 0;
});

/// Provider for checking if user is on free tier
final isFreeUserProvider = Provider<bool>((ref) {
  final tier = ref.watch(currentTierProvider);
  return tier == SubscriptionTier.seeker;
});

/// Provider for checking if user is on paid tier
final isPaidUserProvider = Provider<bool>((ref) {
  final tier = ref.watch(currentTierProvider);
  return tier != SubscriptionTier.seeker;
});

/// Provider for checking if user is on specific tier
final isOnTierProvider = Provider.family<bool, SubscriptionTier>((
  ref,
  targetTier,
) {
  final currentTier = ref.watch(currentTierProvider);
  return currentTier == targetTier;
});

/// Provider for checking if user has at least a specific tier
final hasAtLeastTierProvider = Provider.family<bool, SubscriptionTier>((
  ref,
  minimumTier,
) {
  final currentTier = ref.watch(currentTierProvider);

  // Define tier hierarchy: seeker < mystic < oracle
  const tierHierarchy = {
    SubscriptionTier.seeker: 0,
    SubscriptionTier.mystic: 1,
    SubscriptionTier.oracle: 2,
  };

  final currentLevel = tierHierarchy[currentTier] ?? 0;
  final minimumLevel = tierHierarchy[minimumTier] ?? 0;

  return currentLevel >= minimumLevel;
});

/// Extension methods for easier subscription access
extension SubscriptionRef on WidgetRef {
  /// Get current subscription tier
  SubscriptionTier get currentTier => read(currentTierProvider);

  /// Get current subscription status
  SubscriptionStatus? get currentSubscriptionStatus =>
      read(currentSubscriptionStatusProvider);

  /// Check if subscription is active
  bool get isSubscriptionActive => read(isSubscriptionActiveProvider);

  /// Check if subscription is expired
  bool get isSubscriptionExpired => read(isSubscriptionExpiredProvider);

  /// Check if user is on free tier
  bool get isFreeUser => read(isFreeUserProvider);

  /// Check if user is on paid tier
  bool get isPaidUser => read(isPaidUserProvider);

  /// Check if user is on specific tier
  bool isOnTier(SubscriptionTier tier) => read(isOnTierProvider(tier));

  /// Check if user has at least a specific tier
  bool hasAtLeastTier(SubscriptionTier tier) =>
      read(hasAtLeastTierProvider(tier));

  /// Get usage count for a feature
  int getUsageCount(String feature) => read(featureUsageProvider(feature));

  /// Get all usage counts
  Map<String, int> get usageCounts => read(usageCountsProvider);

  /// Purchase a subscription
  Future<bool> purchaseSubscription(String productId) {
    return read(subscriptionProvider.notifier).purchaseSubscription(productId);
  }

  /// Restore subscriptions
  Future<bool> restoreSubscriptions() {
    return read(subscriptionProvider.notifier).restoreSubscriptions();
  }

  /// Refresh subscription status
  Future<void> refreshSubscriptionStatus() {
    return read(subscriptionProvider.notifier).refreshStatus();
  }

  /// Increment usage for a feature
  Future<void> incrementUsage(String feature) {
    return read(subscriptionProvider.notifier).incrementUsage(feature);
  }

  /// Reset monthly usage
  Future<void> resetUsage() {
    return read(subscriptionProvider.notifier).resetUsage();
  }
}
