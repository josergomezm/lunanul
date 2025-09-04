/// Enumeration of possible subscription-related errors
enum SubscriptionError {
  /// Network connectivity issues
  networkError('Network Error', 'Unable to connect to subscription services'),

  /// Platform-specific errors (App Store/Google Play)
  platformError('Platform Error', 'Error communicating with platform services'),

  /// Invalid or unknown product identifier
  invalidProduct(
    'Invalid Product',
    'The requested subscription product is not available',
  ),

  /// User cancelled the purchase flow
  purchaseCancelled(
    'Purchase Cancelled',
    'The subscription purchase was cancelled',
  ),

  /// Subscription has expired
  subscriptionExpired('Subscription Expired', 'Your subscription has expired'),

  /// Failed to verify subscription status
  verificationFailed(
    'Verification Failed',
    'Unable to verify subscription status',
  ),

  /// Payment method issues
  paymentFailed('Payment Failed', 'Payment could not be processed'),

  /// Subscription already exists
  alreadySubscribed(
    'Already Subscribed',
    'You already have an active subscription',
  ),

  /// Feature not available for current tier
  featureNotAvailable(
    'Feature Not Available',
    'This feature requires a subscription upgrade',
  ),

  /// Usage limit exceeded
  usageLimitExceeded(
    'Usage Limit Exceeded',
    'You have reached your monthly usage limit',
  ),

  /// Subscription restoration failed
  restorationFailed(
    'Restoration Failed',
    'Unable to restore previous subscriptions',
  ),

  /// Invalid subscription state
  invalidState('Invalid State', 'Subscription is in an invalid state'),

  /// Server-side validation error
  serverError('Server Error', 'Subscription server encountered an error'),

  /// Unknown or unexpected error
  unknown('Unknown Error', 'An unexpected error occurred');

  const SubscriptionError(this.title, this.description);

  /// Human-readable title for the error
  final String title;

  /// Detailed description of the error
  final String description;

  /// Check if this is a recoverable error
  bool get isRecoverable {
    switch (this) {
      case SubscriptionError.networkError:
      case SubscriptionError.platformError:
      case SubscriptionError.verificationFailed:
      case SubscriptionError.serverError:
        return true;
      case SubscriptionError.purchaseCancelled:
      case SubscriptionError.invalidProduct:
      case SubscriptionError.subscriptionExpired:
      case SubscriptionError.paymentFailed:
      case SubscriptionError.alreadySubscribed:
      case SubscriptionError.featureNotAvailable:
      case SubscriptionError.usageLimitExceeded:
      case SubscriptionError.restorationFailed:
      case SubscriptionError.invalidState:
      case SubscriptionError.unknown:
        return false;
    }
  }

  /// Check if this error should trigger a retry
  bool get shouldRetry {
    switch (this) {
      case SubscriptionError.networkError:
      case SubscriptionError.platformError:
      case SubscriptionError.verificationFailed:
      case SubscriptionError.serverError:
        return true;
      default:
        return false;
    }
  }

  /// Get user-friendly error message
  String get userMessage {
    switch (this) {
      case SubscriptionError.networkError:
        return 'Please check your internet connection and try again.';
      case SubscriptionError.platformError:
        return 'There was an issue with the app store. Please try again later.';
      case SubscriptionError.invalidProduct:
        return 'This subscription option is currently unavailable.';
      case SubscriptionError.purchaseCancelled:
        return 'Subscription purchase was cancelled.';
      case SubscriptionError.subscriptionExpired:
        return 'Your subscription has expired. Please renew to continue using premium features.';
      case SubscriptionError.verificationFailed:
        return 'Unable to verify your subscription. Please try again.';
      case SubscriptionError.paymentFailed:
        return 'Payment could not be processed. Please check your payment method.';
      case SubscriptionError.alreadySubscribed:
        return 'You already have an active subscription.';
      case SubscriptionError.featureNotAvailable:
        return 'This feature requires a subscription upgrade.';
      case SubscriptionError.usageLimitExceeded:
        return 'You have reached your monthly usage limit. Upgrade to continue.';
      case SubscriptionError.restorationFailed:
        return 'Unable to restore your previous subscriptions.';
      case SubscriptionError.invalidState:
        return 'Subscription is in an invalid state. Please contact support.';
      case SubscriptionError.serverError:
        return 'Server error occurred. Please try again later.';
      case SubscriptionError.unknown:
        return 'An unexpected error occurred. Please try again.';
    }
  }
}

/// Exception class for subscription-related errors
class SubscriptionException implements Exception {
  const SubscriptionException(
    this.error, {
    this.message,
    this.originalError,
    this.stackTrace,
  });

  /// The specific subscription error type
  final SubscriptionError error;

  /// Optional custom error message
  final String? message;

  /// Original error that caused this exception
  final dynamic originalError;

  /// Stack trace when the error occurred
  final StackTrace? stackTrace;

  /// Get the error message to display
  String get displayMessage => message ?? error.userMessage;

  /// Get the error title
  String get title => error.title;

  /// Get the error description
  String get description => error.description;

  /// Check if this is a recoverable error
  bool get isRecoverable => error.isRecoverable;

  /// Check if this error should trigger a retry
  bool get shouldRetry => error.shouldRetry;

  /// Create a network error exception
  factory SubscriptionException.networkError([String? message]) {
    return SubscriptionException(
      SubscriptionError.networkError,
      message: message,
    );
  }

  /// Create a platform error exception
  factory SubscriptionException.platformError([
    String? message,
    dynamic originalError,
  ]) {
    return SubscriptionException(
      SubscriptionError.platformError,
      message: message,
      originalError: originalError,
    );
  }

  /// Create an invalid product exception
  factory SubscriptionException.invalidProduct([String? productId]) {
    return SubscriptionException(
      SubscriptionError.invalidProduct,
      message: productId != null
          ? 'Product "$productId" is not available'
          : null,
    );
  }

  /// Create a purchase cancelled exception
  factory SubscriptionException.purchaseCancelled() {
    return const SubscriptionException(SubscriptionError.purchaseCancelled);
  }

  /// Create a subscription expired exception
  factory SubscriptionException.subscriptionExpired([
    DateTime? expirationDate,
  ]) {
    return SubscriptionException(
      SubscriptionError.subscriptionExpired,
      message: expirationDate != null
          ? 'Subscription expired on ${expirationDate.toLocal()}'
          : null,
    );
  }

  /// Create a verification failed exception
  factory SubscriptionException.verificationFailed([
    String? message,
    dynamic originalError,
  ]) {
    return SubscriptionException(
      SubscriptionError.verificationFailed,
      message: message,
      originalError: originalError,
    );
  }

  /// Create a payment failed exception
  factory SubscriptionException.paymentFailed([
    String? message,
    dynamic originalError,
  ]) {
    return SubscriptionException(
      SubscriptionError.paymentFailed,
      message: message,
      originalError: originalError,
    );
  }

  /// Create a feature not available exception
  factory SubscriptionException.featureNotAvailable(String feature) {
    return SubscriptionException(
      SubscriptionError.featureNotAvailable,
      message: 'Feature "$feature" requires a subscription upgrade',
    );
  }

  /// Create a usage limit exceeded exception
  factory SubscriptionException.usageLimitExceeded(String feature) {
    return SubscriptionException(
      SubscriptionError.usageLimitExceeded,
      message: 'Monthly limit exceeded for "$feature"',
    );
  }

  /// Create a restoration failed exception
  factory SubscriptionException.restorationFailed([
    String? message,
    dynamic originalError,
  ]) {
    return SubscriptionException(
      SubscriptionError.restorationFailed,
      message: message,
      originalError: originalError,
    );
  }

  /// Create a server error exception
  factory SubscriptionException.serverError([
    String? message,
    dynamic originalError,
  ]) {
    return SubscriptionException(
      SubscriptionError.serverError,
      message: message,
      originalError: originalError,
    );
  }

  /// Create an unknown error exception
  factory SubscriptionException.unknown([
    String? message,
    dynamic originalError,
  ]) {
    return SubscriptionException(
      SubscriptionError.unknown,
      message: message,
      originalError: originalError,
    );
  }

  @override
  String toString() {
    final buffer = StringBuffer('SubscriptionException: ${error.title}');

    if (message != null) {
      buffer.write(' - $message');
    }

    if (originalError != null) {
      buffer.write(' (Original: $originalError)');
    }

    return buffer.toString();
  }
}
