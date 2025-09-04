import '../models/subscription_status.dart';
import '../models/subscription_product.dart';
import '../models/subscription_errors.dart';
import '../models/subscription_event.dart';

/// Abstract interface for subscription management and platform integration
abstract class SubscriptionService {
  /// Get the current subscription status for the user
  ///
  /// Returns the user's current subscription tier, active status,
  /// expiration date, and usage counts.
  ///
  /// Throws [SubscriptionException] if unable to retrieve status.
  Future<SubscriptionStatus> getSubscriptionStatus();

  /// Get a stream of subscription status updates
  ///
  /// Provides real-time updates when subscription status changes,
  /// such as when a purchase completes or subscription expires.
  Stream<SubscriptionStatus> subscriptionStatusStream();

  /// Get all available subscription products for purchase
  ///
  /// Returns a list of subscription products available on the current
  /// platform (App Store/Google Play) with pricing and feature information.
  ///
  /// Throws [SubscriptionException] if unable to load products.
  Future<List<SubscriptionProduct>> getAvailableProducts();

  /// Purchase a subscription product
  ///
  /// Initiates the platform-specific purchase flow for the given [productId].
  /// Returns true if the purchase was successful, false if cancelled.
  ///
  /// Throws [SubscriptionException] for purchase errors.
  Future<bool> purchaseSubscription(String productId);

  /// Restore previous subscriptions
  ///
  /// Attempts to restore any previous subscriptions associated with
  /// the user's platform account (Apple ID/Google Account).
  /// Returns true if any subscriptions were restored.
  ///
  /// Throws [SubscriptionException] if restoration fails.
  Future<bool> restoreSubscriptions();

  /// Refresh subscription status from platform
  ///
  /// Forces a refresh of subscription status from the platform services
  /// to ensure the local status is up-to-date.
  ///
  /// Throws [SubscriptionException] if unable to refresh.
  Future<void> refreshSubscriptionStatus();

  /// Check if a specific product is available for purchase
  ///
  /// Verifies that the given [productId] is available on the current
  /// platform and can be purchased.
  Future<bool> isProductAvailable(String productId);

  /// Get subscription information for a specific product
  ///
  /// Returns detailed information about a subscription product,
  /// including current pricing from the platform.
  ///
  /// Throws [SubscriptionException] if product is not found.
  Future<SubscriptionProduct?> getProductInfo(String productId);

  /// Cancel the current subscription
  ///
  /// Initiates the platform-specific cancellation flow.
  /// Note: This typically redirects to platform settings rather
  /// than immediately cancelling the subscription.
  Future<void> cancelSubscription();

  /// Check if subscription management is available
  ///
  /// Returns true if the user can manage their subscription
  /// (view status, cancel, modify) through the platform.
  Future<bool> canManageSubscription();

  /// Open platform subscription management
  ///
  /// Opens the platform-specific subscription management interface
  /// (App Store/Google Play subscription settings).
  Future<void> openSubscriptionManagement();

  /// Dispose of any resources used by the service
  ///
  /// Cleans up streams, listeners, and other resources.
  /// Should be called when the service is no longer needed.
  void dispose();

  /// Verify subscription status with platform (for synchronization)
  ///
  /// Performs a deep verification of subscription status with the platform
  /// services to ensure local status is accurate. This is more thorough
  /// than refreshSubscriptionStatus and may take longer.
  ///
  /// Throws [SubscriptionException] if verification fails.
  Future<SubscriptionStatus> verifySubscriptionStatus();

  /// Check if subscription verification is supported
  ///
  /// Returns true if the platform supports subscription verification.
  /// Some platforms or configurations may not support this feature.
  Future<bool> supportsVerification();

  /// Get subscription history (if available)
  ///
  /// Returns a list of subscription events/changes if the platform
  /// provides this information. May be empty if not supported.
  Future<List<SubscriptionEvent>> getSubscriptionHistory();

  /// Check for pending subscription changes
  ///
  /// Returns true if there are pending subscription changes that
  /// haven't been processed yet (e.g., pending cancellations).
  Future<bool> hasPendingChanges();
}
