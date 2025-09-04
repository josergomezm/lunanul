import '../models/enums.dart';
import '../models/subscription_status.dart';
import '../models/feature_access.dart';

/// Abstract service for controlling access to features based on subscription tier and usage limits
abstract class FeatureGateService {
  /// Check if a user can access a specific feature
  Future<bool> canAccessFeature(String featureKey);

  /// Check if a user can perform a specific action (with usage tracking)
  Future<bool> canPerformAction(String actionKey);

  /// Get the feature access configuration for the current subscription tier
  FeatureAccess getFeatureAccess(SubscriptionTier tier);

  /// Check if a user can access a specific spread type
  Future<bool> canAccessSpread(SpreadType spread);

  /// Check if a user can access a specific guide
  Future<bool> canAccessGuide(GuideType guide);

  /// Check if a user can perform a reading
  Future<bool> canPerformReading();

  /// Check if a user can perform a manual interpretation
  Future<bool> canPerformManualInterpretation();

  /// Check if a user should see ads
  Future<bool> shouldShowAds();

  /// Check if a user can access audio readings
  Future<bool> canAccessAudioReadings();

  /// Check if a user can access customization features
  Future<bool> canAccessCustomization();

  /// Check if a user can access early access features
  Future<bool> canAccessEarlyAccess();

  /// Get the current subscription status
  Future<SubscriptionStatus> getCurrentSubscriptionStatus();

  /// Update the subscription status (called when subscription changes)
  Future<void> updateSubscriptionStatus(SubscriptionStatus status);

  /// Get usage information for a specific feature
  Future<Map<String, dynamic>> getUsageInfo(String feature);

  /// Get all usage information for the current tier
  Future<Map<String, dynamic>> getAllUsageInfo();

  /// Check if an upgrade is required for a specific feature
  Future<UpgradeRequirement?> getUpgradeRequirement(String featureKey);

  /// Validate and consume usage for an action (returns true if allowed and consumed)
  Future<bool> validateAndConsumeUsage(String actionKey);
}

/// Information about upgrade requirements for blocked features
class UpgradeRequirement {
  const UpgradeRequirement({
    required this.requiredTier,
    required this.reason,
    required this.featureName,
    this.currentUsage,
    this.usageLimit,
  });

  /// The minimum subscription tier required
  final SubscriptionTier requiredTier;

  /// Reason why upgrade is required
  final UpgradeReason reason;

  /// Human-readable name of the feature
  final String featureName;

  /// Current usage count (for usage-based restrictions)
  final int? currentUsage;

  /// Usage limit (for usage-based restrictions)
  final int? usageLimit;

  /// Check if this is a usage-based restriction
  bool get isUsageBased => reason == UpgradeReason.usageLimit;

  /// Check if this is a tier-based restriction
  bool get isTierBased => reason == UpgradeReason.tierRestriction;
}

/// Reasons why an upgrade might be required
enum UpgradeReason {
  /// Feature is not available in current tier
  tierRestriction,

  /// Usage limit has been reached for current tier
  usageLimit,

  /// Feature requires premium subscription
  premiumFeature,
}
