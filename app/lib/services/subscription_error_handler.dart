import 'dart:async';
import 'dart:math';

import '../models/subscription_errors.dart';
import '../models/subscription_status.dart';

/// Configuration for retry behavior
class RetryConfig {
  const RetryConfig({
    this.maxRetries = 3,
    this.baseDelayMs = 1000,
    this.maxDelayMs = 30000,
    this.backoffMultiplier = 2.0,
    this.jitterFactor = 0.1,
  });

  /// Maximum number of retry attempts
  final int maxRetries;

  /// Base delay between retries in milliseconds
  final int baseDelayMs;

  /// Maximum delay between retries in milliseconds
  final int maxDelayMs;

  /// Multiplier for exponential backoff
  final double backoffMultiplier;

  /// Jitter factor to randomize delays (0.0 to 1.0)
  final double jitterFactor;

  /// Calculate delay for a specific retry attempt
  Duration calculateDelay(int attempt) {
    if (attempt <= 0) return Duration.zero;

    // Exponential backoff
    final baseDelay = baseDelayMs * pow(backoffMultiplier, attempt - 1);

    // Apply maximum delay limit
    final clampedDelay = baseDelay.clamp(
      baseDelayMs.toDouble(),
      maxDelayMs.toDouble(),
    );

    // Add jitter to prevent thundering herd
    final jitter = Random().nextDouble() * jitterFactor * clampedDelay;
    final finalDelay = clampedDelay + jitter;

    return Duration(milliseconds: finalDelay.round());
  }
}

/// Result of an error recovery attempt
class RecoveryResult<T> {
  const RecoveryResult({
    required this.success,
    this.data,
    this.error,
    this.fallbackUsed = false,
    this.retryCount = 0,
  });

  /// Whether the recovery was successful
  final bool success;

  /// The recovered data (if successful)
  final T? data;

  /// The final error (if unsuccessful)
  final SubscriptionException? error;

  /// Whether a fallback mechanism was used
  final bool fallbackUsed;

  /// Number of retries performed
  final int retryCount;

  /// Create a successful recovery result
  factory RecoveryResult.success(
    T data, {
    bool fallbackUsed = false,
    int retryCount = 0,
  }) {
    return RecoveryResult(
      success: true,
      data: data,
      fallbackUsed: fallbackUsed,
      retryCount: retryCount,
    );
  }

  /// Create a failed recovery result
  factory RecoveryResult.failure(
    SubscriptionException error, {
    int retryCount = 0,
  }) {
    return RecoveryResult(success: false, error: error, retryCount: retryCount);
  }
}

/// Comprehensive error handling and recovery service for subscriptions
class SubscriptionErrorHandler {
  SubscriptionErrorHandler({
    RetryConfig? retryConfig,
    this.enableFallbacks = true,
    this.enableGracefulDegradation = true,
  }) : _retryConfig = retryConfig ?? const RetryConfig();

  final RetryConfig _retryConfig;
  final bool enableFallbacks;
  final bool enableGracefulDegradation;

  /// Cached subscription status for fallback scenarios
  SubscriptionStatus? _cachedStatus;
  DateTime? _cacheTimestamp;

  /// Maximum age for cached status (in minutes)
  static const int _maxCacheAgeMinutes = 30;

  /// Execute an operation with comprehensive error handling and recovery
  Future<RecoveryResult<T>> executeWithRecovery<T>(
    Future<T> Function() operation, {
    T? Function()? fallback,
    String? operationName,
    bool enableRetry = true,
  }) async {
    int retryCount = 0;
    SubscriptionException? lastError;

    // Attempt the operation with retries
    while (retryCount <= (enableRetry ? _retryConfig.maxRetries : 0)) {
      try {
        final result = await operation();
        return RecoveryResult.success(result, retryCount: retryCount);
      } on SubscriptionException catch (e) {
        lastError = e;

        // Check if we should retry this error
        if (!e.shouldRetry || retryCount >= _retryConfig.maxRetries) {
          break;
        }

        retryCount++;

        // Wait before retrying
        final delay = _retryConfig.calculateDelay(retryCount);
        await Future.delayed(delay);

        // Log retry attempt (in a real app, use proper logging)
        // ignore: avoid_print
        print(
          'Retrying ${operationName ?? 'operation'} (attempt $retryCount) after ${delay.inMilliseconds}ms delay',
        );
      } catch (e) {
        // Convert non-subscription errors to subscription exceptions
        lastError = SubscriptionException.unknown(
          'Unexpected error in ${operationName ?? 'operation'}',
          e,
        );
        break;
      }
    }

    // If we reach here, all retries failed
    // Try fallback if available
    if (enableFallbacks && fallback != null) {
      try {
        final fallbackResult = fallback();
        if (fallbackResult != null) {
          return RecoveryResult.success(
            fallbackResult,
            fallbackUsed: true,
            retryCount: retryCount,
          );
        }
      } catch (e) {
        // Fallback failed, continue to return original error
        // ignore: avoid_print
        print('Fallback failed for ${operationName ?? 'operation'}: $e');
      }
    }

    return RecoveryResult.failure(
      lastError ?? SubscriptionException.unknown(),
      retryCount: retryCount,
    );
  }

  /// Handle subscription status retrieval with caching fallback
  Future<RecoveryResult<SubscriptionStatus>> handleStatusRetrieval(
    Future<SubscriptionStatus> Function() getStatus,
  ) async {
    return executeWithRecovery(
      getStatus,
      fallback: _getCachedStatus,
      operationName: 'subscription status retrieval',
    );
  }

  /// Handle subscription purchase with user-friendly error messages
  Future<RecoveryResult<bool>> handlePurchase(
    Future<bool> Function() purchase,
    String productId,
  ) async {
    return executeWithRecovery(
      purchase,
      operationName: 'subscription purchase ($productId)',
      enableRetry: false, // Don't retry purchases to avoid double-charging
    );
  }

  /// Handle subscription restoration with fallback
  Future<RecoveryResult<bool>> handleRestoration(
    Future<bool> Function() restore,
  ) async {
    return executeWithRecovery(
      restore,
      operationName: 'subscription restoration',
    );
  }

  /// Handle subscription verification with graceful degradation
  Future<RecoveryResult<SubscriptionStatus>> handleVerification(
    Future<SubscriptionStatus> Function() verify,
  ) async {
    final result = await executeWithRecovery(
      verify,
      fallback: _getCachedStatus,
      operationName: 'subscription verification',
    );

    // If verification failed but we have cached status, use it
    if (!result.success && enableGracefulDegradation) {
      final cached = _getCachedStatus();
      if (cached != null) {
        return RecoveryResult.success(
          cached,
          fallbackUsed: true,
          retryCount: result.retryCount,
        );
      }
    }

    return result;
  }

  /// Cache subscription status for fallback scenarios
  void cacheSubscriptionStatus(SubscriptionStatus status) {
    _cachedStatus = status;
    _cacheTimestamp = DateTime.now();
  }

  /// Get cached subscription status if available and not too old
  SubscriptionStatus? _getCachedStatus() {
    if (_cachedStatus == null || _cacheTimestamp == null) {
      return null;
    }

    final age = DateTime.now().difference(_cacheTimestamp!);
    if (age.inMinutes > _maxCacheAgeMinutes) {
      // Cache is too old, clear it
      _cachedStatus = null;
      _cacheTimestamp = null;
      return null;
    }

    return _cachedStatus;
  }

  /// Check if cached status is available
  bool get hasCachedStatus => _getCachedStatus() != null;

  /// Get user-friendly error message for display
  String getUserFriendlyMessage(SubscriptionException error) {
    switch (error.error) {
      case SubscriptionError.networkError:
        return 'Please check your internet connection and try again. Your subscription status will be updated when connection is restored.';

      case SubscriptionError.platformError:
        return 'There was an issue connecting to the app store. Please try again in a few moments.';

      case SubscriptionError.verificationFailed:
        return 'Unable to verify your subscription status. You can continue using the app, and we\'ll try again automatically.';

      case SubscriptionError.purchaseCancelled:
        return 'Subscription purchase was cancelled. You can try again anytime from the subscription settings.';

      case SubscriptionError.paymentFailed:
        return 'Payment could not be processed. Please check your payment method and try again.';

      case SubscriptionError.subscriptionExpired:
        return 'Your subscription has expired. Renew now to continue enjoying premium features.';

      case SubscriptionError.restorationFailed:
        return 'Unable to restore previous subscriptions. If you believe this is an error, please contact support.';

      case SubscriptionError.serverError:
        return 'Our servers are experiencing issues. Please try again in a few minutes.';

      default:
        return error.error.userMessage;
    }
  }

  /// Get recovery suggestions for different error types
  List<String> getRecoverySuggestions(SubscriptionException error) {
    switch (error.error) {
      case SubscriptionError.networkError:
        return [
          'Check your internet connection',
          'Try switching between WiFi and mobile data',
          'Restart the app and try again',
        ];

      case SubscriptionError.platformError:
        return [
          'Restart the app and try again',
          'Check for app updates',
          'Try again in a few minutes',
        ];

      case SubscriptionError.verificationFailed:
        return [
          'The app will retry automatically',
          'Check your internet connection',
          'Restart the app if the issue persists',
        ];

      case SubscriptionError.paymentFailed:
        return [
          'Check your payment method',
          'Ensure sufficient funds are available',
          'Try a different payment method',
          'Contact your bank if needed',
        ];

      case SubscriptionError.restorationFailed:
        return [
          'Ensure you\'re signed in with the correct account',
          'Check that you have active subscriptions',
          'Try again in a few minutes',
          'Contact support if the issue persists',
        ];

      default:
        return [
          'Try again in a few minutes',
          'Restart the app if the issue persists',
          'Contact support if needed',
        ];
    }
  }

  /// Determine if the app should continue functioning despite the error
  bool shouldContinueOperation(SubscriptionException error) {
    switch (error.error) {
      case SubscriptionError.networkError:
      case SubscriptionError.platformError:
      case SubscriptionError.verificationFailed:
      case SubscriptionError.serverError:
        // These are temporary issues, app should continue with cached data
        return enableGracefulDegradation && hasCachedStatus;

      case SubscriptionError.subscriptionExpired:
        // App should continue but with free tier limitations
        return true;

      case SubscriptionError.purchaseCancelled:
      case SubscriptionError.paymentFailed:
      case SubscriptionError.restorationFailed:
        // These don't affect current app functionality
        return true;

      default:
        return false;
    }
  }

  /// Get fallback subscription status for graceful degradation
  SubscriptionStatus getFallbackStatus() {
    // Try cached status first
    final cached = _getCachedStatus();
    if (cached != null) {
      return cached;
    }

    // Fall back to free tier if no cached status
    return SubscriptionStatus.free();
  }

  /// Clear cached data
  void clearCache() {
    _cachedStatus = null;
    _cacheTimestamp = null;
  }

  /// Get cache age in minutes
  int? getCacheAgeMinutes() {
    if (_cacheTimestamp == null) return null;
    return DateTime.now().difference(_cacheTimestamp!).inMinutes;
  }

  /// Check if error handler is configured for production use
  bool get isProductionReady {
    return enableFallbacks &&
        enableGracefulDegradation &&
        _retryConfig.maxRetries > 0;
  }
}
