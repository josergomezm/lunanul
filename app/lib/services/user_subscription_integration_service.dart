import 'dart:developer' as developer;
import '../models/user.dart';
import '../models/enums.dart';
import 'mock_user_service.dart';
import 'subscription_service.dart';

/// Service to integrate user data with subscription system
class UserSubscriptionIntegrationService {
  UserSubscriptionIntegrationService({
    required MockUserService userService,
    required SubscriptionService subscriptionService,
  }) : _userService = userService,
       _subscriptionService = subscriptionService;

  final MockUserService _userService;
  final SubscriptionService _subscriptionService;

  /// Sync user subscription status with platform subscription
  Future<User> syncUserSubscription() async {
    try {
      // Get current user
      final user = await _userService.getCurrentUser();

      // Get platform subscription status
      final platformStatus = await _subscriptionService.getSubscriptionStatus();

      // Check if user's subscription status needs updating
      if (user.subscriptionStatus != platformStatus) {
        developer.log(
          'Syncing user subscription: ${user.subscriptionStatus.tier} -> ${platformStatus.tier}',
          name: 'UserSubscriptionIntegration',
        );

        // Update user with new subscription status
        final updatedUser = await _userService.updateSubscriptionStatus(
          platformStatus,
        );

        // Preserve user's usage counts if downgrading
        if (_isDowngrade(user.subscriptionStatus.tier, platformStatus.tier)) {
          final preservedStatus = platformStatus.copyWith(
            usageCounts: user.subscriptionStatus.usageCounts,
          );
          return await _userService.updateSubscriptionStatus(preservedStatus);
        }

        return updatedUser;
      }

      return user;
    } catch (error) {
      developer.log(
        'Failed to sync user subscription: $error',
        name: 'UserSubscriptionIntegration',
      );
      rethrow;
    }
  }

  /// Initialize user subscription data on app start
  Future<User> initializeUserSubscription() async {
    try {
      // Get current user
      final user = await _userService.getCurrentUser();

      // If user has no subscription data, initialize with platform status
      if (user.subscriptionStatus.tier == SubscriptionTier.seeker &&
          user.subscriptionStatus.lastUpdated.isBefore(
            DateTime.now().subtract(const Duration(hours: 1)),
          )) {
        return await syncUserSubscription();
      }

      return user;
    } catch (error) {
      developer.log(
        'Failed to initialize user subscription: $error',
        name: 'UserSubscriptionIntegration',
      );

      // Return user with default free subscription if initialization fails
      final user = await _userService.getCurrentUser();
      return user;
    }
  }

  /// Handle subscription purchase completion
  Future<User> handleSubscriptionPurchase(String productId) async {
    try {
      // Refresh platform subscription status
      await _subscriptionService.refreshSubscriptionStatus();

      // Sync user data with new subscription
      return await syncUserSubscription();
    } catch (error) {
      developer.log(
        'Failed to handle subscription purchase: $error',
        name: 'UserSubscriptionIntegration',
      );
      rethrow;
    }
  }

  /// Handle subscription restoration
  Future<User> handleSubscriptionRestoration() async {
    try {
      // Restore subscriptions on platform
      final restored = await _subscriptionService.restoreSubscriptions();

      if (restored) {
        // Sync user data with restored subscription
        return await syncUserSubscription();
      }

      // Return current user if no restoration needed
      return await _userService.getCurrentUser();
    } catch (error) {
      developer.log(
        'Failed to handle subscription restoration: $error',
        name: 'UserSubscriptionIntegration',
      );
      rethrow;
    }
  }

  /// Handle subscription expiration
  Future<User> handleSubscriptionExpiration() async {
    try {
      final user = await _userService.getCurrentUser();

      // Create expired subscription status
      final expiredStatus = user.subscriptionStatus.copyWith(
        tier: SubscriptionTier.seeker,
        isActive: true,
        expirationDate: null,
        platformSubscriptionId: null,
        lastUpdated: DateTime.now(),
      );

      // Update user with expired status
      return await _userService.updateSubscriptionStatus(expiredStatus);
    } catch (error) {
      developer.log(
        'Failed to handle subscription expiration: $error',
        name: 'UserSubscriptionIntegration',
      );
      rethrow;
    }
  }

  /// Increment usage and sync with user data
  Future<User> incrementUsageAndSync(String feature) async {
    try {
      // Increment usage in user service
      final updatedUser = await _userService.incrementUsage(feature);

      // Log usage for analytics
      developer.log(
        'Usage incremented for $feature: ${updatedUser.getUsageCount(feature)}',
        name: 'UserSubscriptionIntegration',
      );

      return updatedUser;
    } catch (error) {
      developer.log(
        'Failed to increment usage: $error',
        name: 'UserSubscriptionIntegration',
      );
      rethrow;
    }
  }

  /// Reset monthly usage and sync
  Future<User> resetUsageAndSync() async {
    try {
      // Reset usage in user service
      final updatedUser = await _userService.resetUsage();

      developer.log(
        'Monthly usage reset completed',
        name: 'UserSubscriptionIntegration',
      );

      return updatedUser;
    } catch (error) {
      developer.log(
        'Failed to reset usage: $error',
        name: 'UserSubscriptionIntegration',
      );
      rethrow;
    }
  }

  /// Update user preferences with subscription awareness
  Future<User> updateSubscriptionAwarePreferences(
    Map<String, dynamic> preferences,
  ) async {
    try {
      final user = await _userService.getCurrentUser();

      // Merge with subscription-aware preferences
      final subscriptionAwarePrefs = user.getSubscriptionAwarePreferences();
      final mergedPreferences = {...subscriptionAwarePrefs, ...preferences};

      return await _userService.updateUserProfile(
        preferences: mergedPreferences,
      );
    } catch (error) {
      developer.log(
        'Failed to update subscription-aware preferences: $error',
        name: 'UserSubscriptionIntegration',
      );
      rethrow;
    }
  }

  /// Check if tier change is a downgrade
  bool _isDowngrade(SubscriptionTier from, SubscriptionTier to) {
    const tierHierarchy = {
      SubscriptionTier.seeker: 0,
      SubscriptionTier.mystic: 1,
      SubscriptionTier.oracle: 2,
    };

    final fromLevel = tierHierarchy[from] ?? 0;
    final toLevel = tierHierarchy[to] ?? 0;

    return toLevel < fromLevel;
  }

  /// Validate subscription data consistency
  Future<bool> validateSubscriptionConsistency() async {
    try {
      final user = await _userService.getCurrentUser();
      final platformStatus = await _subscriptionService.getSubscriptionStatus();

      // Check if user and platform subscription match
      final isConsistent =
          user.subscriptionStatus.tier == platformStatus.tier &&
          user.subscriptionStatus.isActive == platformStatus.isActive;

      if (!isConsistent) {
        developer.log(
          'Subscription inconsistency detected: User(${user.subscriptionStatus.tier}) vs Platform(${platformStatus.tier})',
          name: 'UserSubscriptionIntegration',
        );
      }

      return isConsistent;
    } catch (error) {
      developer.log(
        'Failed to validate subscription consistency: $error',
        name: 'UserSubscriptionIntegration',
      );
      return false;
    }
  }

  /// Get subscription health status
  Future<Map<String, dynamic>> getSubscriptionHealth() async {
    try {
      final user = await _userService.getCurrentUser();
      final isConsistent = await validateSubscriptionConsistency();

      return {
        'isConsistent': isConsistent,
        'userTier': user.subscriptionStatus.tier.name,
        'isActive': user.subscriptionStatus.isActive,
        'isExpired': user.subscriptionStatus.isExpired,
        'lastUpdated': user.subscriptionStatus.lastUpdated.toIso8601String(),
        'usageCounts': user.subscriptionStatus.usageCounts,
      };
    } catch (error) {
      return {'isConsistent': false, 'error': error.toString()};
    }
  }
}
