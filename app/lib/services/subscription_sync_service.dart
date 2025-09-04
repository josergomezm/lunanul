import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

import 'subscription_service.dart';
import '../models/subscription_status.dart';
import '../models/subscription_errors.dart';
import '../models/enums.dart';

/// Service for synchronizing subscription status with platform services
///
/// Handles periodic verification, graceful expiration handling,
/// and subscription restoration for users switching devices.
class SubscriptionSyncService {
  SubscriptionSyncService({
    required SubscriptionService subscriptionService,
    this.syncIntervalMinutes = 60,
    this.maxRetryAttempts = 3,
    this.retryDelaySeconds = 5,
  }) : _subscriptionService = subscriptionService {
    _initialize();
  }

  final SubscriptionService _subscriptionService;

  /// How often to sync subscription status (in minutes)
  final int syncIntervalMinutes;

  /// Maximum retry attempts for failed sync operations
  final int maxRetryAttempts;

  /// Delay between retry attempts (in seconds)
  final int retryDelaySeconds;

  /// Timer for periodic synchronization
  Timer? _syncTimer;

  /// Stream controller for sync status updates
  final StreamController<SyncStatus> _syncStatusController =
      StreamController<SyncStatus>.broadcast();

  /// Current sync status
  SyncStatus _currentSyncStatus = SyncStatus.idle;

  /// Last successful sync timestamp
  DateTime? _lastSuccessfulSync;

  /// Whether the service has been disposed
  bool _disposed = false;

  /// Cached subscription status for offline scenarios
  SubscriptionStatus? _cachedStatus;

  /// Stream of sync status updates
  Stream<SyncStatus> get syncStatusStream => _syncStatusController.stream;

  /// Current sync status
  SyncStatus get currentSyncStatus => _currentSyncStatus;

  /// Last successful sync timestamp
  DateTime? get lastSuccessfulSync => _lastSuccessfulSync;

  void _initialize() {
    _loadCachedStatus();
    // Don't start periodic sync immediately in constructor
    // Let it be started manually or after a delay
  }

  /// Load cached subscription status from local storage
  Future<void> _loadCachedStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedJson = prefs.getString('cached_subscription_status');

      if (cachedJson != null) {
        final Map<String, dynamic> json = Map<String, dynamic>.from(
          // In a real app, you'd use proper JSON parsing
          // This is simplified for the mock implementation
          {},
        );
        _cachedStatus = SubscriptionStatus.fromJson(json);
      }

      final lastSyncTimestamp = prefs.getInt('last_sync_timestamp');
      if (lastSyncTimestamp != null) {
        _lastSuccessfulSync = DateTime.fromMillisecondsSinceEpoch(
          lastSyncTimestamp,
        );
      }
    } catch (e) {
      // If we can't load cached status, start fresh
      _cachedStatus = null;
      _lastSuccessfulSync = null;
    }
  }

  /// Save subscription status to cache
  Future<void> _saveCachedStatus(SubscriptionStatus status) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'cached_subscription_status',
        status.toJson().toString(),
      );
      await prefs.setInt(
        'last_sync_timestamp',
        DateTime.now().millisecondsSinceEpoch,
      );

      _cachedStatus = status;
      _lastSuccessfulSync = DateTime.now();
    } catch (e) {
      // Cache save failed, but continue operation
    }
  }

  /// Start periodic subscription synchronization
  void startPeriodicSync() {
    if (_disposed) return;

    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(
      Duration(minutes: syncIntervalMinutes),
      (_) => _performSync(),
    );

    // Perform initial sync after a short delay
    Future.delayed(const Duration(milliseconds: 100), () => _performSync());
  }

  /// Perform subscription status synchronization
  Future<void> _performSync() async {
    if (_disposed) return;

    _updateSyncStatus(SyncStatus.syncing);

    try {
      await _syncWithRetry();
      _updateSyncStatus(SyncStatus.success);
    } catch (e) {
      _updateSyncStatus(SyncStatus.failed);

      // If sync fails, check if we need to handle expired subscriptions
      await _handlePotentialExpiration();
    }
  }

  /// Sync with retry logic
  Future<void> _syncWithRetry() async {
    int attempts = 0;
    Exception? lastError;

    while (attempts < maxRetryAttempts) {
      try {
        await _subscriptionService.refreshSubscriptionStatus();
        final status = await _subscriptionService.getSubscriptionStatus();

        // Check for expiration and handle gracefully
        if (status.isExpired && _cachedStatus?.isValid == true) {
          await _handleSubscriptionExpiration(status);
        }

        await _saveCachedStatus(status);
        return;
      } catch (e) {
        lastError = e is Exception ? e : Exception(e.toString());
        attempts++;

        if (attempts < maxRetryAttempts) {
          await Future.delayed(Duration(seconds: retryDelaySeconds * attempts));
        }
      }
    }

    throw lastError ??
        Exception('Sync failed after $maxRetryAttempts attempts');
  }

  /// Handle subscription expiration gracefully
  Future<void> _handleSubscriptionExpiration(
    SubscriptionStatus expiredStatus,
  ) async {
    try {
      // Create a gracefully downgraded status
      final downgradedStatus = SubscriptionStatus(
        tier: SubscriptionTier.seeker,
        isActive: true,
        expirationDate: null,
        platformSubscriptionId: null,
        usageCounts: expiredStatus.usageCounts, // Preserve usage counts
        lastUpdated: DateTime.now(),
      );

      // Save the downgraded status
      await _saveCachedStatus(downgradedStatus);

      // Emit expiration event
      _updateSyncStatus(SyncStatus.expired);
    } catch (e) {
      // If we can't handle expiration gracefully,
      // at least update the sync status
      _updateSyncStatus(SyncStatus.failed);
    }
  }

  /// Handle potential expiration when sync fails
  Future<void> _handlePotentialExpiration() async {
    if (_cachedStatus == null) return;

    // If we have a cached status and it's expired, downgrade gracefully
    if (_cachedStatus!.isExpired) {
      await _handleSubscriptionExpiration(_cachedStatus!);
    }
  }

  /// Update sync status and notify listeners
  void _updateSyncStatus(SyncStatus status) {
    if (_disposed) return;

    _currentSyncStatus = status;
    _syncStatusController.add(status);
  }

  /// Force an immediate synchronization
  Future<void> forceSyncNow() async {
    if (_disposed) throw StateError('Service has been disposed');

    await _performSync();
  }

  /// Attempt to restore subscriptions for users switching devices
  Future<RestoreResult> restoreSubscriptions() async {
    if (_disposed) throw StateError('Service has been disposed');

    _updateSyncStatus(SyncStatus.restoring);

    try {
      final restored = await _subscriptionService.restoreSubscriptions();

      if (restored) {
        // Refresh status after successful restoration
        await _subscriptionService.refreshSubscriptionStatus();
        final status = await _subscriptionService.getSubscriptionStatus();
        await _saveCachedStatus(status);

        _updateSyncStatus(SyncStatus.success);
        return RestoreResult.success;
      } else {
        _updateSyncStatus(SyncStatus.success);
        return RestoreResult.noSubscriptionsFound;
      }
    } catch (e) {
      _updateSyncStatus(SyncStatus.failed);

      if (e is SubscriptionException) {
        switch (e.error) {
          case SubscriptionError.networkError:
            return RestoreResult.networkError;
          case SubscriptionError.platformError:
            return RestoreResult.platformError;
          default:
            return RestoreResult.unknownError;
        }
      }

      return RestoreResult.unknownError;
    }
  }

  /// Get cached subscription status for offline scenarios
  SubscriptionStatus? getCachedStatus() {
    return _cachedStatus;
  }

  /// Check if sync is overdue
  bool get isSyncOverdue {
    if (_lastSuccessfulSync == null) return true;

    final timeSinceLastSync = DateTime.now().difference(_lastSuccessfulSync!);
    return timeSinceLastSync.inMinutes > (syncIntervalMinutes * 2);
  }

  /// Get time until next scheduled sync
  Duration? get timeUntilNextSync {
    if (_lastSuccessfulSync == null) return null;

    final nextSyncTime = _lastSuccessfulSync!.add(
      Duration(minutes: syncIntervalMinutes),
    );

    final now = DateTime.now();
    if (now.isAfter(nextSyncTime)) return Duration.zero;

    return nextSyncTime.difference(now);
  }

  /// Update sync interval (useful for testing or different sync strategies)
  void updateSyncInterval(int minutes) {
    if (minutes <= 0) {
      throw ArgumentError('Sync interval must be positive');
    }

    // Restart timer with new interval
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(
      Duration(minutes: minutes),
      (_) => _performSync(),
    );
  }

  /// Start automatic synchronization (call this after creating the service)
  void start() {
    startPeriodicSync();
  }

  /// Dispose of resources
  void dispose() {
    if (!_disposed) {
      _syncTimer?.cancel();
      _syncStatusController.close();
      _disposed = true;
    }
  }
}

/// Sync status enumeration
enum SyncStatus { idle, syncing, success, failed, expired, restoring }

/// Restore operation result
enum RestoreResult {
  success,
  noSubscriptionsFound,
  networkError,
  platformError,
  unknownError,
}

/// Extension for sync status display
extension SyncStatusExtension on SyncStatus {
  String get displayName {
    switch (this) {
      case SyncStatus.idle:
        return 'Idle';
      case SyncStatus.syncing:
        return 'Syncing';
      case SyncStatus.success:
        return 'Success';
      case SyncStatus.failed:
        return 'Failed';
      case SyncStatus.expired:
        return 'Expired';
      case SyncStatus.restoring:
        return 'Restoring';
    }
  }

  bool get isActive =>
      this == SyncStatus.syncing || this == SyncStatus.restoring;
  bool get isError => this == SyncStatus.failed;
  bool get isSuccess => this == SyncStatus.success;
}

/// Extension for restore result display
extension RestoreResultExtension on RestoreResult {
  String get displayMessage {
    switch (this) {
      case RestoreResult.success:
        return 'Subscriptions restored successfully';
      case RestoreResult.noSubscriptionsFound:
        return 'No subscriptions found to restore';
      case RestoreResult.networkError:
        return 'Network error during restoration';
      case RestoreResult.platformError:
        return 'Platform error during restoration';
      case RestoreResult.unknownError:
        return 'Unknown error during restoration';
    }
  }

  bool get isSuccess => this == RestoreResult.success;
  bool get isError =>
      this != RestoreResult.success &&
      this != RestoreResult.noSubscriptionsFound;
}
