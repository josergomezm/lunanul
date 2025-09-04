import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/enums.dart';
import '../services/usage_tracking_service.dart';
import '../services/shared_preferences_usage_tracking_service.dart';

/// Provider for the usage tracking service
final usageTrackingServiceProvider = Provider<UsageTrackingService>((ref) {
  return SharedPreferencesUsageTrackingService();
});

/// Provider for current usage counts
final usageCountsProvider = FutureProvider<Map<String, int>>((ref) async {
  final service = ref.watch(usageTrackingServiceProvider);
  return service.getAllUsageCounts();
});

/// Provider for usage count of a specific feature
final featureUsageCountProvider = FutureProvider.family<int, String>((
  ref,
  feature,
) async {
  final service = ref.watch(usageTrackingServiceProvider);
  return service.getUsageCount(feature);
});

/// Provider for checking if a feature is within limits for a tier
final featureWithinLimitProvider =
    FutureProvider.family<bool, FeatureLimitCheck>((ref, check) async {
      final service = ref.watch(usageTrackingServiceProvider);
      return service.isWithinLimit(check.tier, check.feature);
    });

/// Provider for getting remaining usage for a feature and tier
final remainingUsageProvider = FutureProvider.family<int, FeatureLimitCheck>((
  ref,
  check,
) async {
  final service = ref.watch(usageTrackingServiceProvider);
  return service.getRemainingUsage(check.tier, check.feature);
});

/// Provider for checking if approaching limit for a feature and tier
final approachingLimitProvider = FutureProvider.family<bool, FeatureLimitCheck>(
  (ref, check) async {
    final service = ref.watch(usageTrackingServiceProvider);
    return service.isApproachingLimit(check.tier, check.feature);
  },
);

/// Provider for usage summary for a specific tier
final usageSummaryProvider =
    FutureProvider.family<Map<String, dynamic>, SubscriptionTier>((
      ref,
      tier,
    ) async {
      final service = ref.watch(usageTrackingServiceProvider);
      if (service is SharedPreferencesUsageTrackingService) {
        return service.getUsageSummary(tier);
      }
      return {};
    });

/// Provider for usage statistics
final usageStatisticsProvider = FutureProvider<Map<String, dynamic>>((
  ref,
) async {
  final service = ref.watch(usageTrackingServiceProvider);
  if (service is SharedPreferencesUsageTrackingService) {
    return service.getUsageStatistics();
  }
  return {};
});

/// Provider for checking if monthly reset is needed
final shouldResetMonthlyProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(usageTrackingServiceProvider);
  return service.shouldResetMonthlyUsage();
});

/// Provider for last reset date
final lastResetDateProvider = FutureProvider<DateTime?>((ref) async {
  final service = ref.watch(usageTrackingServiceProvider);
  return service.getLastResetDate();
});

/// State notifier for managing usage tracking operations
class UsageTrackingNotifier
    extends StateNotifier<AsyncValue<Map<String, int>>> {
  UsageTrackingNotifier(this._service) : super(const AsyncValue.loading()) {
    _loadUsageCounts();
  }

  final UsageTrackingService _service;

  /// Load current usage counts
  Future<void> _loadUsageCounts() async {
    try {
      final counts = await _service.getAllUsageCounts();
      state = AsyncValue.data(counts);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Increment usage for a feature and refresh state
  Future<void> incrementUsage(String feature) async {
    try {
      await _service.incrementUsage(feature);
      await _loadUsageCounts();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Set usage count for a feature and refresh state
  Future<void> setUsageCount(String feature, int count) async {
    try {
      await _service.setUsageCount(feature, count);
      await _loadUsageCounts();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Reset monthly usage and refresh state
  Future<void> resetMonthlyUsage() async {
    try {
      await _service.resetMonthlyUsage();
      await _loadUsageCounts();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Clear all usage data and refresh state
  Future<void> clearAllUsage() async {
    try {
      await _service.clearAllUsage();
      await _loadUsageCounts();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Check and reset monthly usage if needed
  Future<void> checkAndResetIfNeeded() async {
    try {
      final service = _service;
      if (service is SharedPreferencesUsageTrackingService) {
        await service.checkAndResetIfNeeded();
        await _loadUsageCounts();
      }
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Refresh usage counts
  Future<void> refresh() async {
    await _loadUsageCounts();
  }
}

/// Provider for the usage tracking state notifier
final usageTrackingNotifierProvider =
    StateNotifierProvider<UsageTrackingNotifier, AsyncValue<Map<String, int>>>((
      ref,
    ) {
      final service = ref.watch(usageTrackingServiceProvider);
      return UsageTrackingNotifier(service);
    });

/// Alias for backward compatibility with tests
final usageTrackingProvider = usageTrackingNotifierProvider;

/// Helper class for feature limit checks
class FeatureLimitCheck {
  const FeatureLimitCheck({required this.tier, required this.feature});

  final SubscriptionTier tier;
  final String feature;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FeatureLimitCheck &&
          runtimeType == other.runtimeType &&
          tier == other.tier &&
          feature == other.feature;

  @override
  int get hashCode => tier.hashCode ^ feature.hashCode;

  @override
  String toString() => 'FeatureLimitCheck(tier: $tier, feature: $feature)';
}

/// Extension methods for easier usage tracking
extension UsageTrackingRef on WidgetRef {
  /// Get usage count for a feature
  AsyncValue<int> getUsageCount(String feature) {
    return watch(featureUsageCountProvider(feature));
  }

  /// Check if feature is within limits
  AsyncValue<bool> isFeatureWithinLimit(SubscriptionTier tier, String feature) {
    return watch(
      featureWithinLimitProvider(
        FeatureLimitCheck(tier: tier, feature: feature),
      ),
    );
  }

  /// Get remaining usage for a feature
  AsyncValue<int> getRemainingUsage(SubscriptionTier tier, String feature) {
    return watch(
      remainingUsageProvider(FeatureLimitCheck(tier: tier, feature: feature)),
    );
  }

  /// Check if approaching limit for a feature
  AsyncValue<bool> isApproachingLimit(SubscriptionTier tier, String feature) {
    return watch(
      approachingLimitProvider(FeatureLimitCheck(tier: tier, feature: feature)),
    );
  }

  /// Get usage summary for a tier
  AsyncValue<Map<String, dynamic>> getUsageSummary(SubscriptionTier tier) {
    return watch(usageSummaryProvider(tier));
  }

  /// Increment usage for a feature
  Future<void> incrementUsage(String feature) {
    return read(usageTrackingNotifierProvider.notifier).incrementUsage(feature);
  }

  /// Reset monthly usage
  Future<void> resetMonthlyUsage() {
    return read(usageTrackingNotifierProvider.notifier).resetMonthlyUsage();
  }

  /// Check and reset if needed
  Future<void> checkAndResetUsageIfNeeded() {
    return read(usageTrackingNotifierProvider.notifier).checkAndResetIfNeeded();
  }
}
