import '../models/enums.dart';

/// Abstract service for tracking feature usage and enforcing limits
abstract class UsageTrackingService {
  /// Get current usage count for a specific feature
  Future<int> getUsageCount(String feature);

  /// Increment usage count for a specific feature
  Future<void> incrementUsage(String feature);

  /// Get all current usage counts
  Future<Map<String, int>> getAllUsageCounts();

  /// Reset monthly usage counts (called at the start of each month)
  Future<void> resetMonthlyUsage();

  /// Check if usage is within limits for the current subscription tier
  Future<bool> isWithinLimit(SubscriptionTier tier, String feature);

  /// Check if usage has reached the limit for the current subscription tier
  Future<bool> hasReachedLimit(SubscriptionTier tier, String feature);

  /// Get remaining usage for a feature based on current subscription tier
  Future<int> getRemainingUsage(SubscriptionTier tier, String feature);

  /// Get usage percentage for a feature based on current subscription tier
  Future<double> getUsagePercentage(SubscriptionTier tier, String feature);

  /// Check if user is approaching limit (80% or more) for a feature
  Future<bool> isApproachingLimit(SubscriptionTier tier, String feature);

  /// Get the last reset date for monthly usage
  Future<DateTime?> getLastResetDate();

  /// Set the last reset date for monthly usage
  Future<void> setLastResetDate(DateTime date);

  /// Check if monthly usage should be reset based on current date
  Future<bool> shouldResetMonthlyUsage();

  /// Clear all usage data (for testing or user data reset)
  Future<void> clearAllUsage();

  /// Get usage history for analytics (optional implementation)
  Future<Map<String, List<int>>> getUsageHistory();

  /// Set usage count for a specific feature (for testing or data migration)
  Future<void> setUsageCount(String feature, int count);
}
