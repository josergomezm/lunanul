import 'dart:async';
import 'dart:math';

import 'subscription_service.dart';
import '../models/subscription_status.dart';
import '../models/subscription_product.dart';
import '../models/subscription_errors.dart';
import '../models/subscription_event.dart';
import '../models/enums.dart';

/// Mock implementation of SubscriptionService for development and testing
///
/// This service simulates subscription behavior without requiring actual
/// platform integration. It provides realistic delays and can simulate
/// various error conditions for testing.
class MockSubscriptionService implements SubscriptionService {
  MockSubscriptionService({
    this.simulateNetworkDelay = true,
    this.networkDelayMs = 1000,
    this.errorRate = 0.0,
  }) : _statusController = StreamController<SubscriptionStatus>.broadcast() {
    _initializeMockData();
  }

  /// Whether to simulate network delays
  final bool simulateNetworkDelay;

  /// Network delay in milliseconds
  final int networkDelayMs;

  /// Error rate (0.0 to 1.0) for simulating failures
  final double errorRate;

  /// Test properties for controlling mock behavior
  bool shouldFail = false;
  bool mockPurchaseSuccess = true;
  bool mockRestoreSuccess = true;
  SubscriptionStatus? mockSubscriptionStatus;

  /// Current subscription status
  SubscriptionStatus _currentStatus = SubscriptionStatus.free();

  /// Available products
  late List<SubscriptionProduct> _availableProducts;

  /// Stream controller for status updates
  final StreamController<SubscriptionStatus> _statusController;

  /// Random number generator for simulating errors
  final Random _random = Random();

  /// Whether the service has been disposed
  bool _disposed = false;

  void _initializeMockData() {
    _availableProducts = SubscriptionProduct.getDefaultProducts();

    // Start with free tier
    _currentStatus = SubscriptionStatus.free();

    // Add initial status to stream
    Future.microtask(() {
      if (!_disposed) {
        _statusController.add(_currentStatus);
      }
    });
  }

  /// Simulate network delay if enabled
  Future<void> _simulateDelay() async {
    if (simulateNetworkDelay) {
      await Future.delayed(Duration(milliseconds: networkDelayMs));
    }
  }

  /// Check if we should simulate an error
  void _checkForSimulatedError() {
    if (errorRate > 0.0 && _random.nextDouble() < errorRate) {
      final errors = [
        SubscriptionError.networkError,
        SubscriptionError.platformError,
        SubscriptionError.verificationFailed,
      ];
      final error = errors[_random.nextInt(errors.length)];
      throw SubscriptionException(error);
    }
  }

  @override
  Future<SubscriptionStatus> getSubscriptionStatus() async {
    if (_disposed) throw StateError('Service has been disposed');

    if (shouldFail) {
      throw SubscriptionException(
        SubscriptionError.networkError,
        message: 'Mock service configured to fail',
      );
    }

    await _simulateDelay();
    _checkForSimulatedError();

    return mockSubscriptionStatus ?? _currentStatus;
  }

  @override
  Stream<SubscriptionStatus> subscriptionStatusStream() {
    if (_disposed) throw StateError('Service has been disposed');

    // Create a stream controller that emits current status first
    late StreamController<SubscriptionStatus> controller;
    controller = StreamController<SubscriptionStatus>(
      onListen: () {
        // Emit current status immediately
        controller.add(_currentStatus);
        // Then forward all future updates
        _statusController.stream.listen(
          controller.add,
          onError: controller.addError,
          onDone: controller.close,
        );
      },
    );

    return controller.stream;
  }

  @override
  Future<List<SubscriptionProduct>> getAvailableProducts() async {
    if (_disposed) throw StateError('Service has been disposed');

    await _simulateDelay();
    _checkForSimulatedError();

    return List.from(_availableProducts);
  }

  @override
  Future<bool> purchaseSubscription(String productId) async {
    if (_disposed) throw StateError('Service has been disposed');

    if (shouldFail) {
      throw SubscriptionException(
        SubscriptionError.networkError,
        message: 'Mock service configured to fail',
      );
    }

    if (!mockPurchaseSuccess) {
      throw SubscriptionException.purchaseCancelled();
    }

    await _simulateDelay();
    _checkForSimulatedError();

    // Find the product
    final product = _availableProducts
        .where((p) => p.id == productId)
        .firstOrNull;

    if (product == null) {
      throw SubscriptionException.invalidProduct(productId);
    }

    // Simulate user cancellation 20% of the time (only if not overridden)
    if (mockPurchaseSuccess && _random.nextDouble() < 0.2) {
      throw SubscriptionException.purchaseCancelled();
    }

    // Simulate payment failure 5% of the time (only if not overridden)
    if (mockPurchaseSuccess && _random.nextDouble() < 0.05) {
      throw SubscriptionException.paymentFailed();
    }

    // Check if already subscribed to same or higher tier
    if (_currentStatus.tier.index >= product.tier.index &&
        _currentStatus.isValid) {
      throw SubscriptionException(
        SubscriptionError.alreadySubscribed,
        message: 'Already subscribed to ${_currentStatus.tier.displayName}',
      );
    }

    // Simulate successful purchase
    final expirationDate = DateTime.now().add(
      product.period == 'yearly'
          ? const Duration(days: 365)
          : const Duration(days: 30),
    );

    _currentStatus = SubscriptionStatus(
      tier: product.tier,
      isActive: true,
      expirationDate: expirationDate,
      platformSubscriptionId:
          'mock_${product.id}_${DateTime.now().millisecondsSinceEpoch}',
      usageCounts: {},
      lastUpdated: DateTime.now(),
    );

    // Notify listeners
    _statusController.add(_currentStatus);

    return true;
  }

  @override
  Future<bool> restoreSubscriptions() async {
    if (_disposed) throw StateError('Service has been disposed');

    if (shouldFail) {
      throw SubscriptionException(
        SubscriptionError.networkError,
        message: 'Mock service configured to fail',
      );
    }

    if (!mockRestoreSuccess) {
      throw SubscriptionException.restorationFailed();
    }

    await _simulateDelay();
    _checkForSimulatedError();

    // Simulate restoration failure 10% of the time (only if not overridden)
    if (mockRestoreSuccess && _random.nextDouble() < 0.1) {
      throw SubscriptionException.restorationFailed();
    }

    // Simulate finding a previous subscription 30% of the time
    if (_random.nextDouble() < 0.3) {
      final tiers = [SubscriptionTier.mystic, SubscriptionTier.oracle];
      final tier = tiers[_random.nextInt(tiers.length)];

      _currentStatus = SubscriptionStatus(
        tier: tier,
        isActive: true,
        expirationDate: DateTime.now().add(const Duration(days: 15)),
        platformSubscriptionId:
            'restored_${tier.name}_${DateTime.now().millisecondsSinceEpoch}',
        usageCounts: {},
        lastUpdated: DateTime.now(),
      );

      _statusController.add(_currentStatus);
      return true;
    }

    // No subscriptions to restore
    return false;
  }

  @override
  Future<void> refreshSubscriptionStatus() async {
    if (_disposed) throw StateError('Service has been disposed');

    await _simulateDelay();
    _checkForSimulatedError();

    // Check if subscription has expired
    if (_currentStatus.isExpired) {
      _currentStatus = _currentStatus.copyWith(
        isActive: false,
        lastUpdated: DateTime.now(),
      );
      _statusController.add(_currentStatus);
    }
  }

  @override
  Future<bool> isProductAvailable(String productId) async {
    if (_disposed) throw StateError('Service has been disposed');

    await _simulateDelay();

    return _availableProducts.any((p) => p.id == productId);
  }

  @override
  Future<SubscriptionProduct?> getProductInfo(String productId) async {
    if (_disposed) throw StateError('Service has been disposed');

    await _simulateDelay();
    _checkForSimulatedError();

    return _availableProducts.where((p) => p.id == productId).firstOrNull;
  }

  @override
  Future<void> cancelSubscription() async {
    if (_disposed) throw StateError('Service has been disposed');

    await _simulateDelay();

    // In a real implementation, this would redirect to platform settings
    // For mock, we'll just mark as cancelled but keep active until expiration
    if (_currentStatus.tier != SubscriptionTier.seeker) {
      // Subscription remains active until expiration date
      // This simulates platform behavior where cancellation doesn't
      // immediately revoke access
    }
  }

  @override
  Future<bool> canManageSubscription() async {
    if (_disposed) throw StateError('Service has been disposed');

    return _currentStatus.tier != SubscriptionTier.seeker &&
        _currentStatus.isActive;
  }

  @override
  Future<void> openSubscriptionManagement() async {
    if (_disposed) throw StateError('Service has been disposed');

    // In a real implementation, this would open platform-specific
    // subscription management (App Store/Google Play settings)
    // For mock, we'll just simulate the action
    await _simulateDelay();
  }

  @override
  Future<SubscriptionStatus> verifySubscriptionStatus() async {
    if (_disposed) throw StateError('Service has been disposed');

    await _simulateDelay();
    _checkForSimulatedError();

    // Simulate more thorough verification
    await Future.delayed(Duration(milliseconds: networkDelayMs ~/ 2));

    // Check if subscription has expired during verification
    if (_currentStatus.isExpired && _currentStatus.isActive) {
      _currentStatus = _currentStatus.copyWith(
        isActive: false,
        lastUpdated: DateTime.now(),
      );
      _statusController.add(_currentStatus);
    }

    return _currentStatus;
  }

  @override
  Future<bool> supportsVerification() async {
    if (_disposed) throw StateError('Service has been disposed');

    // Mock service always supports verification
    return true;
  }

  @override
  Future<List<SubscriptionEvent>> getSubscriptionHistory() async {
    if (_disposed) throw StateError('Service has been disposed');

    await _simulateDelay();
    _checkForSimulatedError();

    // Generate mock subscription history
    final events = <SubscriptionEvent>[];

    if (_currentStatus.tier != SubscriptionTier.seeker) {
      // Add purchase event
      events.add(
        SubscriptionEvent(
          type: SubscriptionEventType.purchased,
          timestamp: DateTime.now().subtract(const Duration(days: 15)),
          tier: _currentStatus.tier,
          expirationDate: _currentStatus.expirationDate,
          platformTransactionId: _currentStatus.platformSubscriptionId,
        ),
      );

      // Randomly add other events
      if (_random.nextDouble() < 0.3) {
        events.add(
          SubscriptionEvent(
            type: SubscriptionEventType.renewed,
            timestamp: DateTime.now().subtract(const Duration(days: 5)),
            tier: _currentStatus.tier,
            expirationDate: _currentStatus.expirationDate,
            platformTransactionId: _currentStatus.platformSubscriptionId,
          ),
        );
      }
    }

    return events;
  }

  @override
  Future<bool> hasPendingChanges() async {
    if (_disposed) throw StateError('Service has been disposed');

    await _simulateDelay();

    // Randomly simulate pending changes
    return _random.nextDouble() < 0.1;
  }

  @override
  void dispose() {
    if (!_disposed) {
      _statusController.close();
      _disposed = true;
    }
  }

  // Additional mock-specific methods for testing

  /// Set the current subscription status (for testing)
  void setMockSubscriptionStatus(SubscriptionStatus status) {
    if (_disposed) throw StateError('Service has been disposed');

    _currentStatus = status;
    _statusController.add(_currentStatus);
  }

  /// Simulate subscription expiration (for testing)
  void simulateExpiration() {
    if (_disposed) throw StateError('Service has been disposed');

    if (_currentStatus.tier != SubscriptionTier.seeker) {
      _currentStatus = _currentStatus.copyWith(
        expirationDate: DateTime.now().subtract(const Duration(days: 1)),
        isActive: false,
        lastUpdated: DateTime.now(),
      );
      _statusController.add(_currentStatus);
    }
  }

  /// Add usage to current status (for testing)
  void addMockUsage(String feature, int count) {
    if (_disposed) throw StateError('Service has been disposed');

    final newUsageCounts = Map<String, int>.from(_currentStatus.usageCounts);
    newUsageCounts[feature] = (newUsageCounts[feature] ?? 0) + count;

    _currentStatus = _currentStatus.copyWith(
      usageCounts: newUsageCounts,
      lastUpdated: DateTime.now(),
    );
    _statusController.add(_currentStatus);
  }

  /// Reset to free tier (for testing)
  void resetToFreeTier() {
    if (_disposed) throw StateError('Service has been disposed');

    _currentStatus = SubscriptionStatus.free();
    _statusController.add(_currentStatus);
  }

  /// Set error rate for testing error conditions
  /// Note: This creates a new instance since errorRate is final
  MockSubscriptionService withErrorRate(double rate) {
    if (rate < 0.0 || rate > 1.0) {
      throw ArgumentError('Error rate must be between 0.0 and 1.0');
    }

    return MockSubscriptionService(
      simulateNetworkDelay: simulateNetworkDelay,
      networkDelayMs: networkDelayMs,
      errorRate: rate,
    );
  }

  /// Get current status without async (for testing)
  SubscriptionStatus get currentStatus => _currentStatus;

  /// Check if service is disposed
  bool get isDisposed => _disposed;
}
