import 'enums.dart';

/// Defines usage limits and restrictions for different subscription tiers
class UsageLimits {
  // Private constructor to prevent instantiation
  UsageLimits._();

  /// Monthly usage limits for free tier features
  static const Map<String, int> monthlyLimits = {
    'manual_interpretations': 5,
    'readings': 3,
    'daily_card_views': -1, // -1 = unlimited
    'ai_readings': -1, // -1 = unlimited for all tiers
  };

  /// Tier-specific spread restrictions
  static const Map<SubscriptionTier, List<SpreadType>> tierSpreads = {
    SubscriptionTier.seeker: [SpreadType.singleCard, SpreadType.threeCard],
    SubscriptionTier.mystic: SpreadType.values,
    SubscriptionTier.oracle: SpreadType.values,
  };

  /// Tier-specific guide restrictions
  static const Map<SubscriptionTier, List<GuideType>> tierGuides = {
    SubscriptionTier.seeker: [
      GuideType.healer, // Lyra - The Compassionate Healer
      GuideType.mentor, // Kael - The Practical Strategist
    ],
    SubscriptionTier.mystic: GuideType.values,
    SubscriptionTier.oracle: GuideType.values,
  };

  /// Reading limits by tier (0 = unlimited)
  static const Map<SubscriptionTier, int> readingLimits = {
    SubscriptionTier.seeker: 3,
    SubscriptionTier.mystic: 0, // unlimited
    SubscriptionTier.oracle: 0, // unlimited
  };

  /// Manual interpretation limits by tier per month (0 = unlimited)
  static const Map<SubscriptionTier, int> manualInterpretationLimits = {
    SubscriptionTier.seeker: 5,
    SubscriptionTier.mystic: 0, // unlimited
    SubscriptionTier.oracle: 0, // unlimited
  };

  /// Get monthly limit for a specific feature
  static int getMonthlyLimit(String feature) {
    return monthlyLimits[feature] ?? 0;
  }

  /// Check if a feature has unlimited usage
  static bool isUnlimited(String feature) {
    final limit = getMonthlyLimit(feature);
    return limit == -1 || limit == 0;
  }

  /// Get available spreads for a tier
  static List<SpreadType> getAvailableSpreads(SubscriptionTier tier) {
    return tierSpreads[tier] ?? tierSpreads[SubscriptionTier.seeker]!;
  }

  /// Get available guides for a tier
  static List<GuideType> getAvailableGuides(SubscriptionTier tier) {
    return tierGuides[tier] ?? tierGuides[SubscriptionTier.seeker]!;
  }

  /// Get reading limit for a tier
  static int getReadingLimit(SubscriptionTier tier) {
    return readingLimits[tier] ?? readingLimits[SubscriptionTier.seeker]!;
  }

  /// Get manual interpretation limit for a tier
  static int getManualInterpretationLimit(SubscriptionTier tier) {
    return manualInterpretationLimits[tier] ??
        manualInterpretationLimits[SubscriptionTier.seeker]!;
  }

  /// Check if a tier has unlimited readings
  static bool hasUnlimitedReadings(SubscriptionTier tier) {
    return getReadingLimit(tier) == 0;
  }

  /// Check if a tier has unlimited manual interpretations
  static bool hasUnlimitedManualInterpretations(SubscriptionTier tier) {
    return getManualInterpretationLimit(tier) == 0;
  }

  /// Check if usage is within limits for a feature and tier
  static bool isWithinLimit(
    SubscriptionTier tier,
    String feature,
    int currentUsage,
  ) {
    final limit = _getTierLimit(tier, feature);
    if (limit == 0 || limit == -1) return true; // unlimited
    return currentUsage < limit;
  }

  /// Check if usage has reached the limit
  static bool hasReachedLimit(
    SubscriptionTier tier,
    String feature,
    int currentUsage,
  ) {
    return !isWithinLimit(tier, feature, currentUsage);
  }

  /// Get remaining usage for a feature and tier
  static int getRemainingUsage(
    SubscriptionTier tier,
    String feature,
    int currentUsage,
  ) {
    final limit = _getTierLimit(tier, feature);
    if (limit == 0 || limit == -1) return -1; // unlimited
    return (limit - currentUsage).clamp(0, limit);
  }

  /// Get usage percentage for a feature and tier
  static double getUsagePercentage(
    SubscriptionTier tier,
    String feature,
    int currentUsage,
  ) {
    final limit = _getTierLimit(tier, feature);
    if (limit == 0 || limit == -1) return 0.0; // unlimited
    return (currentUsage / limit).clamp(0.0, 1.0);
  }

  /// Check if user is approaching limit (80% or more)
  static bool isApproachingLimit(
    SubscriptionTier tier,
    String feature,
    int currentUsage,
  ) {
    final percentage = getUsagePercentage(tier, feature, currentUsage);
    return percentage >= 0.8;
  }

  /// Get tier-specific limit for a feature
  static int _getTierLimit(SubscriptionTier tier, String feature) {
    switch (feature) {
      case 'readings':
        return getReadingLimit(tier);
      case 'manual_interpretations':
        return getManualInterpretationLimit(tier);
      default:
        return getMonthlyLimit(feature);
    }
  }

  /// Get all features that have usage limits for a tier
  static List<String> getLimitedFeatures(SubscriptionTier tier) {
    final limitedFeatures = <String>[];

    if (getReadingLimit(tier) > 0) {
      limitedFeatures.add('readings');
    }

    if (getManualInterpretationLimit(tier) > 0) {
      limitedFeatures.add('manual_interpretations');
    }

    return limitedFeatures;
  }

  /// Check if a tier has any usage limits
  static bool hasUsageLimits(SubscriptionTier tier) {
    return getLimitedFeatures(tier).isNotEmpty;
  }

  /// Get usage limit summary for a tier
  static Map<String, int> getUsageLimitSummary(SubscriptionTier tier) {
    return {
      'readings': getReadingLimit(tier),
      'manual_interpretations': getManualInterpretationLimit(tier),
      'available_spreads': getAvailableSpreads(tier).length,
      'available_guides': getAvailableGuides(tier).length,
    };
  }
}
