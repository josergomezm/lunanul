import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/subscription_sync_service.dart';
import '../models/subscription_status.dart';
import 'subscription_provider.dart';

/// Provider for the subscription sync service
final subscriptionSyncServiceProvider = Provider<SubscriptionSyncService>((
  ref,
) {
  final subscriptionService = ref.watch(subscriptionServiceProvider);

  final syncService = SubscriptionSyncService(
    subscriptionService: subscriptionService,
    syncIntervalMinutes: 60, // Sync every hour
    maxRetryAttempts: 3,
    retryDelaySeconds: 5,
  );

  // Start the sync service
  syncService.start();

  return syncService;
});

/// State notifier for managing sync status
class SubscriptionSyncNotifier extends StateNotifier<SyncStatus> {
  SubscriptionSyncNotifier(this._syncService) : super(SyncStatus.idle) {
    _initialize();
  }

  final SubscriptionSyncService _syncService;

  void _initialize() {
    // Listen to sync status changes
    _syncService.syncStatusStream.listen((status) {
      if (mounted) {
        state = status;
      }
    });
  }

  /// Force an immediate synchronization
  Future<void> forceSyncNow() async {
    await _syncService.forceSyncNow();
  }

  /// Attempt to restore subscriptions
  Future<RestoreResult> restoreSubscriptions() async {
    return await _syncService.restoreSubscriptions();
  }

  /// Update sync interval
  void updateSyncInterval(int minutes) {
    _syncService.updateSyncInterval(minutes);
  }

  /// Get cached subscription status
  SubscriptionStatus? getCachedStatus() {
    return _syncService.getCachedStatus();
  }

  /// Check if sync is overdue
  bool get isSyncOverdue => _syncService.isSyncOverdue;

  /// Get time until next sync
  Duration? get timeUntilNextSync => _syncService.timeUntilNextSync;

  /// Get last successful sync time
  DateTime? get lastSuccessfulSync => _syncService.lastSuccessfulSync;
}

/// Provider for the subscription sync state notifier
final subscriptionSyncProvider =
    StateNotifierProvider<SubscriptionSyncNotifier, SyncStatus>((ref) {
      final syncService = ref.watch(subscriptionSyncServiceProvider);
      return SubscriptionSyncNotifier(syncService);
    });

/// Provider for checking if sync is in progress
final isSyncInProgressProvider = Provider<bool>((ref) {
  final syncStatus = ref.watch(subscriptionSyncProvider);
  return syncStatus.isActive;
});

/// Provider for checking if sync has failed
final hasSyncFailedProvider = Provider<bool>((ref) {
  final syncStatus = ref.watch(subscriptionSyncProvider);
  return syncStatus.isError;
});

/// Provider for checking if subscription has expired
final hasSubscriptionExpiredProvider = Provider<bool>((ref) {
  final syncStatus = ref.watch(subscriptionSyncProvider);
  return syncStatus == SyncStatus.expired;
});

/// Provider for sync status display message
final syncStatusMessageProvider = Provider<String>((ref) {
  final syncStatus = ref.watch(subscriptionSyncProvider);
  final syncNotifier = ref.read(subscriptionSyncProvider.notifier);

  switch (syncStatus) {
    case SyncStatus.idle:
      final timeUntilNext = syncNotifier.timeUntilNextSync;
      if (timeUntilNext != null && timeUntilNext > Duration.zero) {
        final minutes = timeUntilNext.inMinutes;
        return 'Next sync in ${minutes}m';
      }
      return 'Ready to sync';

    case SyncStatus.syncing:
      return 'Syncing subscription status...';

    case SyncStatus.success:
      final lastSync = syncNotifier.lastSuccessfulSync;
      if (lastSync != null) {
        final ago = DateTime.now().difference(lastSync);
        if (ago.inMinutes < 1) {
          return 'Synced just now';
        } else if (ago.inHours < 1) {
          return 'Synced ${ago.inMinutes}m ago';
        } else {
          return 'Synced ${ago.inHours}h ago';
        }
      }
      return 'Sync successful';

    case SyncStatus.failed:
      if (syncNotifier.isSyncOverdue) {
        return 'Sync overdue - check connection';
      }
      return 'Sync failed - will retry';

    case SyncStatus.expired:
      return 'Subscription expired';

    case SyncStatus.restoring:
      return 'Restoring subscriptions...';
  }
});

/// Provider for checking if manual sync is available
final canManualSyncProvider = Provider<bool>((ref) {
  final syncStatus = ref.watch(subscriptionSyncProvider);
  return !syncStatus.isActive;
});

/// Extension methods for easier sync access
extension SubscriptionSyncRef on WidgetRef {
  /// Get current sync status
  SyncStatus get syncStatus => read(subscriptionSyncProvider);

  /// Check if sync is in progress
  bool get isSyncInProgress => read(isSyncInProgressProvider);

  /// Check if sync has failed
  bool get hasSyncFailed => read(hasSyncFailedProvider);

  /// Check if subscription has expired via sync
  bool get hasSubscriptionExpiredViaSync =>
      read(hasSubscriptionExpiredProvider);

  /// Get sync status message
  String get syncStatusMessage => read(syncStatusMessageProvider);

  /// Check if manual sync is available
  bool get canManualSync => read(canManualSyncProvider);

  /// Force sync now
  Future<void> forceSyncNow() {
    return read(subscriptionSyncProvider.notifier).forceSyncNow();
  }

  /// Restore subscriptions
  Future<RestoreResult> restoreSubscriptions() {
    return read(subscriptionSyncProvider.notifier).restoreSubscriptions();
  }

  /// Update sync interval
  void updateSyncInterval(int minutes) {
    read(subscriptionSyncProvider.notifier).updateSyncInterval(minutes);
  }

  /// Get cached subscription status
  SubscriptionStatus? getCachedSubscriptionStatus() {
    return read(subscriptionSyncProvider.notifier).getCachedStatus();
  }
}
