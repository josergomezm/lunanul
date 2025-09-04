import 'dart:async';

import 'subscription_service.dart';
import 'subscription_error_handler.dart';
import 'network_connectivity_service.dart';
import '../models/subscription_status.dart';
import '../models/subscription_product.dart';
import '../models/subscription_errors.dart';
import '../models/subscription_event.dart';
import '../models/enums.dart';

/// Enhanced subscription service with comprehensive error handling and recovery
class ResilientSubscriptionService implements SubscriptionService {
  ResilientSubscriptionService({
    required SubscriptionService baseService,
    SubscriptionErrorHandler? errorHandler,
    NetworkConnectivityService? connectivityService,
  }) : _baseService = baseService,
       _errorHandler = errorHandler ?? SubscriptionErrorHandler(),
       _connectivityService = connectivityService {
    _initializeConnectivityMonitoring();
  }

  final SubscriptionService _baseService;
  final SubscriptionErrorHandler _errorHandler;
  final NetworkConnectivityService? _connectivityService;

  /// Stream controller for enhanced status updates
  final StreamController<SubscriptionStatus> _statusController =
      StreamController<SubscriptionStatus>.broadcast();

  /// Subscription to connectivity changes
  StreamSubscription<ConnectivityInfo>? _connectivitySubscription;

  /// Subscription to base service status updates
  StreamSubscription<SubscriptionStatus>? _baseStatusSubscription;

  /// Whether the service has been disposed
  bool _disposed = false;

  /// Last known connectivity status
  ConnectivityInfo? _lastConnectivityInfo;

  /// Whether we're currently in offline mode
  bool _isOfflineMode = false;

  void _initializeConnectivityMonitoring() {
    if (_connectivityService != null) {
      _connectivitySubscription = _connectivityService.connectivityStream
          .listen(
            _handleConnectivityChange,
            onError: (error) {
              // ignore: avoid_print
              print('Connectivity monitoring error: $error');
            },
          );
    }

    // Forward base service status updates with error handling
    _baseStatusSubscription = _baseService.subscriptionStatusStream().listen(
      (status) {
        _errorHandler.cacheSubscriptionStatus(status);
        if (!_disposed) {
          _statusController.add(status);
        }
      },
      onError: (error) {
        _handleStatusStreamError(error);
      },
    );
  }

  void _handleConnectivityChange(ConnectivityInfo info) {
    _lastConnectivityInfo = info;

    final wasOffline = _isOfflineMode;
    _isOfflineMode = info.isDisconnected;

    // If we just came back online, refresh subscription status
    if (wasOffline && info.isConnected) {
      _refreshStatusAfterReconnection();
    }
  }

  void _handleStatusStreamError(dynamic error) {
    if (_disposed) return;

    SubscriptionException subscriptionError;
    if (error is SubscriptionException) {
      subscriptionError = error;
    } else {
      subscriptionError = SubscriptionException.unknown(
        'Status stream error',
        error,
      );
    }

    // Try to provide fallback status
    if (_errorHandler.shouldContinueOperation(subscriptionError)) {
      final fallbackStatus = _errorHandler.getFallbackStatus();
      _statusController.add(fallbackStatus);
    }
  }

  Future<void> _refreshStatusAfterReconnection() async {
    try {
      // Wait a bit for connection to stabilize
      await Future.delayed(const Duration(seconds: 2));

      if (!_disposed) {
        await refreshSubscriptionStatus();
      }
    } catch (e) {
      // Ignore errors during automatic refresh
      // ignore: avoid_print
      print('Failed to refresh status after reconnection: $e');
    }
  }

  @override
  Future<SubscriptionStatus> getSubscriptionStatus() async {
    if (_disposed) throw StateError('Service has been disposed');

    // Check connectivity first
    await _checkConnectivityIfNeeded();

    final result = await _errorHandler.handleStatusRetrieval(
      () => _baseService.getSubscriptionStatus(),
    );

    if (result.success && result.data != null) {
      return result.data!;
    }

    // If we have a cached status and should continue operation, use it
    if (_errorHandler.shouldContinueOperation(result.error!)) {
      final fallbackStatus = _errorHandler.getFallbackStatus();
      return fallbackStatus;
    }

    throw result.error!;
  }

  @override
  Stream<SubscriptionStatus> subscriptionStatusStream() {
    if (_disposed) throw StateError('Service has been disposed');

    // Create a stream that provides current status first, then updates
    late StreamController<SubscriptionStatus> controller;
    controller = StreamController<SubscriptionStatus>(
      onListen: () async {
        // Try to emit current status first
        try {
          final status = await getSubscriptionStatus();
          if (!controller.isClosed) {
            controller.add(status);
          }
        } catch (e) {
          // If we can't get current status, the stream will still provide updates
        }

        // Forward all future updates
        _statusController.stream.listen(
          (status) {
            if (!controller.isClosed) {
              controller.add(status);
            }
          },
          onError: (error) {
            if (!controller.isClosed) {
              controller.addError(error);
            }
          },
          onDone: () {
            if (!controller.isClosed) {
              controller.close();
            }
          },
        );
      },
    );

    return controller.stream;
  }

  @override
  Future<List<SubscriptionProduct>> getAvailableProducts() async {
    if (_disposed) throw StateError('Service has been disposed');

    await _checkConnectivityIfNeeded();

    final result = await _errorHandler.executeWithRecovery(
      () => _baseService.getAvailableProducts(),
      fallback: () => SubscriptionProduct.getDefaultProducts(),
      operationName: 'get available products',
    );

    if (result.success && result.data != null) {
      return result.data!;
    }

    throw result.error!;
  }

  @override
  Future<bool> purchaseSubscription(String productId) async {
    if (_disposed) throw StateError('Service has been disposed');

    // Ensure we're online for purchases
    await _ensureConnectivity();

    final result = await _errorHandler.handlePurchase(
      () => _baseService.purchaseSubscription(productId),
      productId,
    );

    if (result.success && result.data != null) {
      return result.data!;
    }

    throw result.error!;
  }

  @override
  Future<bool> restoreSubscriptions() async {
    if (_disposed) throw StateError('Service has been disposed');

    await _ensureConnectivity();

    final result = await _errorHandler.handleRestoration(
      () => _baseService.restoreSubscriptions(),
    );

    if (result.success && result.data != null) {
      return result.data!;
    }

    throw result.error!;
  }

  @override
  Future<void> refreshSubscriptionStatus() async {
    if (_disposed) throw StateError('Service has been disposed');

    await _checkConnectivityIfNeeded();

    final result = await _errorHandler.executeWithRecovery(
      () => _baseService.refreshSubscriptionStatus(),
      operationName: 'refresh subscription status',
    );

    if (!result.success) {
      // If refresh fails but we should continue operation, don't throw
      if (!_errorHandler.shouldContinueOperation(result.error!)) {
        throw result.error!;
      }
    }
  }

  @override
  Future<bool> isProductAvailable(String productId) async {
    if (_disposed) throw StateError('Service has been disposed');

    await _checkConnectivityIfNeeded();

    final result = await _errorHandler.executeWithRecovery(
      () => _baseService.isProductAvailable(productId),
      fallback: () {
        // Fallback: check if product exists in default products
        final defaultProducts = SubscriptionProduct.getDefaultProducts();
        return defaultProducts.any((p) => p.id == productId);
      },
      operationName: 'check product availability',
    );

    if (result.success && result.data != null) {
      return result.data!;
    }

    throw result.error!;
  }

  @override
  Future<SubscriptionProduct?> getProductInfo(String productId) async {
    if (_disposed) throw StateError('Service has been disposed');

    await _checkConnectivityIfNeeded();

    final result = await _errorHandler.executeWithRecovery(
      () => _baseService.getProductInfo(productId),
      fallback: () {
        // Fallback: return default product info
        final defaultProducts = SubscriptionProduct.getDefaultProducts();
        return defaultProducts.where((p) => p.id == productId).firstOrNull;
      },
      operationName: 'get product info',
    );

    if (result.success) {
      return result.data;
    }

    throw result.error!;
  }

  @override
  Future<void> cancelSubscription() async {
    if (_disposed) throw StateError('Service has been disposed');

    await _ensureConnectivity();

    final result = await _errorHandler.executeWithRecovery(
      () => _baseService.cancelSubscription(),
      operationName: 'cancel subscription',
    );

    if (!result.success) {
      throw result.error!;
    }
  }

  @override
  Future<bool> canManageSubscription() async {
    if (_disposed) throw StateError('Service has been disposed');

    final result = await _errorHandler.executeWithRecovery(
      () => _baseService.canManageSubscription(),
      fallback: () {
        // Fallback: check if we have a cached active subscription
        final cached = _errorHandler.getFallbackStatus();
        return cached.tier != SubscriptionTier.seeker && cached.isActive;
      },
      operationName: 'check subscription management availability',
    );

    if (result.success && result.data != null) {
      return result.data!;
    }

    // If we can't determine, assume false for safety
    return false;
  }

  @override
  Future<void> openSubscriptionManagement() async {
    if (_disposed) throw StateError('Service has been disposed');

    await _ensureConnectivity();

    final result = await _errorHandler.executeWithRecovery(
      () => _baseService.openSubscriptionManagement(),
      operationName: 'open subscription management',
    );

    if (!result.success) {
      throw result.error!;
    }
  }

  @override
  Future<SubscriptionStatus> verifySubscriptionStatus() async {
    if (_disposed) throw StateError('Service has been disposed');

    await _checkConnectivityIfNeeded();

    final result = await _errorHandler.handleVerification(
      () => _baseService.verifySubscriptionStatus(),
    );

    if (result.success && result.data != null) {
      return result.data!;
    }

    // If verification fails but we should continue operation, use fallback
    if (_errorHandler.shouldContinueOperation(result.error!)) {
      return _errorHandler.getFallbackStatus();
    }

    throw result.error!;
  }

  @override
  Future<bool> supportsVerification() async {
    if (_disposed) throw StateError('Service has been disposed');

    try {
      return await _baseService.supportsVerification();
    } catch (e) {
      // If we can't determine, assume true for safety
      return true;
    }
  }

  @override
  Future<List<SubscriptionEvent>> getSubscriptionHistory() async {
    if (_disposed) throw StateError('Service has been disposed');

    await _checkConnectivityIfNeeded();

    final result = await _errorHandler.executeWithRecovery(
      () => _baseService.getSubscriptionHistory(),
      fallback: () => <SubscriptionEvent>[],
      operationName: 'get subscription history',
    );

    if (result.success && result.data != null) {
      return result.data!;
    }

    throw result.error!;
  }

  @override
  Future<bool> hasPendingChanges() async {
    if (_disposed) throw StateError('Service has been disposed');

    final result = await _errorHandler.executeWithRecovery(
      () => _baseService.hasPendingChanges(),
      fallback: () => false,
      operationName: 'check pending changes',
    );

    if (result.success && result.data != null) {
      return result.data!;
    }

    // If we can't determine, assume false for safety
    return false;
  }

  /// Check connectivity if we have a connectivity service
  Future<void> _checkConnectivityIfNeeded() async {
    if (_connectivityService != null && _lastConnectivityInfo == null) {
      try {
        _lastConnectivityInfo = await _connectivityService
            .getConnectivityStatus();
        _isOfflineMode = _lastConnectivityInfo!.isDisconnected;
      } catch (e) {
        // Ignore connectivity check errors
      }
    }
  }

  /// Ensure we have connectivity for operations that require it
  Future<void> _ensureConnectivity() async {
    await _checkConnectivityIfNeeded();

    if (_isOfflineMode) {
      throw SubscriptionException.networkError(
        'This operation requires an internet connection',
      );
    }
  }

  @override
  void dispose() {
    if (!_disposed) {
      _connectivitySubscription?.cancel();
      _baseStatusSubscription?.cancel();
      _statusController.close();
      _baseService.dispose();
      _connectivityService?.dispose();
      _disposed = true;
    }
  }

  // Additional methods for enhanced functionality

  /// Get user-friendly error message for the last error
  String getLastErrorMessage(SubscriptionException error) {
    return _errorHandler.getUserFriendlyMessage(error);
  }

  /// Get recovery suggestions for an error
  List<String> getRecoverySuggestions(SubscriptionException error) {
    return _errorHandler.getRecoverySuggestions(error);
  }

  /// Check if the service is currently in offline mode
  bool get isOfflineMode => _isOfflineMode;

  /// Check if cached subscription data is available
  bool get hasCachedData => _errorHandler.hasCachedStatus;

  /// Get the age of cached data in minutes
  int? get cacheAgeMinutes => _errorHandler.getCacheAgeMinutes();

  /// Clear cached data
  void clearCache() {
    _errorHandler.clearCache();
  }

  /// Get current connectivity information
  ConnectivityInfo? get connectivityInfo => _lastConnectivityInfo;

  /// Check if service is disposed
  bool get isDisposed => _disposed;

  /// Force a connectivity check
  Future<ConnectivityInfo?> checkConnectivity() async {
    if (_connectivityService != null) {
      try {
        _lastConnectivityInfo = await _connectivityService
            .performConnectivityTest();
        _isOfflineMode = _lastConnectivityInfo!.isDisconnected;
        return _lastConnectivityInfo;
      } catch (e) {
        return null;
      }
    }
    return null;
  }
}
