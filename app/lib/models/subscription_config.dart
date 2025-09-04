import 'enums.dart';
import 'feature_access.dart';

/// Configuration class that defines subscription tier features and mappings
class SubscriptionConfig {
  // Private constructor to prevent instantiation
  SubscriptionConfig._();

  /// Static mapping of subscription tiers to their feature access
  static const Map<SubscriptionTier, FeatureAccess> tierFeatures = {
    SubscriptionTier.seeker: FeatureAccess(
      hasUnlimitedReadings: false,
      availableSpreads: [SpreadType.singleCard, SpreadType.threeCard],
      availableGuides: [GuideType.healer, GuideType.mentor],
      maxReadings: 3,
      maxManualInterpretations: 5,
      isAdFree: false,
      hasAudioReadings: false,
      hasAdvancedSpreads: false,
      hasCustomization: false,
      hasEarlyAccess: false,
    ),
    SubscriptionTier.mystic: FeatureAccess(
      hasUnlimitedReadings: true,
      availableSpreads: SpreadType.values,
      availableGuides: GuideType.values,
      maxReadings: 0, // 0 = unlimited
      maxManualInterpretations: 0, // 0 = unlimited
      isAdFree: true,
      hasAudioReadings: false,
      hasAdvancedSpreads: false,
      hasCustomization: false,
      hasEarlyAccess: false,
    ),
    SubscriptionTier.oracle: FeatureAccess(
      hasUnlimitedReadings: true,
      availableSpreads: SpreadType.values,
      availableGuides: GuideType.values,
      maxReadings: 0, // 0 = unlimited
      maxManualInterpretations: 0, // 0 = unlimited
      isAdFree: true,
      hasAudioReadings: true,
      hasAdvancedSpreads: true,
      hasCustomization: true,
      hasEarlyAccess: true,
    ),
  };

  /// Get feature access for a specific subscription tier
  static FeatureAccess getFeatureAccess(SubscriptionTier tier) {
    return tierFeatures[tier] ?? tierFeatures[SubscriptionTier.seeker]!;
  }

  /// Check if a tier has access to a specific spread type
  static bool canAccessSpread(SubscriptionTier tier, SpreadType spread) {
    final features = getFeatureAccess(tier);
    return features.canAccessSpread(spread);
  }

  /// Check if a tier has access to a specific guide
  static bool canAccessGuide(SubscriptionTier tier, GuideType guide) {
    final features = getFeatureAccess(tier);
    return features.canAccessGuide(guide);
  }

  /// Check if a tier is ad-free
  static bool isAdFree(SubscriptionTier tier) {
    return getFeatureAccess(tier).isAdFree;
  }

  /// Check if a tier has unlimited readings
  static bool hasUnlimitedReadings(SubscriptionTier tier) {
    return getFeatureAccess(tier).hasUnlimitedReadings;
  }

  /// Check if a tier has audio readings
  static bool hasAudioReadings(SubscriptionTier tier) {
    return getFeatureAccess(tier).hasAudioReadings;
  }

  /// Check if a tier has customization options
  static bool hasCustomization(SubscriptionTier tier) {
    return getFeatureAccess(tier).hasCustomization;
  }

  /// Check if a tier has early access to features
  static bool hasEarlyAccess(SubscriptionTier tier) {
    return getFeatureAccess(tier).hasEarlyAccess;
  }

  /// Get maximum readings for a tier (0 = unlimited)
  static int getMaxReadings(SubscriptionTier tier) {
    return getFeatureAccess(tier).maxReadings;
  }

  /// Get maximum manual interpretations per month for a tier (0 = unlimited)
  static int getMaxManualInterpretations(SubscriptionTier tier) {
    return getFeatureAccess(tier).maxManualInterpretations;
  }

  /// Get all available spreads for a tier
  static List<SpreadType> getAvailableSpreads(SubscriptionTier tier) {
    return getFeatureAccess(tier).availableSpreads;
  }

  /// Get all available guides for a tier
  static List<GuideType> getAvailableGuides(SubscriptionTier tier) {
    return getFeatureAccess(tier).availableGuides;
  }

  /// Check if a tier upgrade is required for a feature
  static bool requiresUpgrade(
    SubscriptionTier currentTier,
    SubscriptionTier requiredTier,
  ) {
    final tierOrder = [
      SubscriptionTier.seeker,
      SubscriptionTier.mystic,
      SubscriptionTier.oracle,
    ];

    final currentIndex = tierOrder.indexOf(currentTier);
    final requiredIndex = tierOrder.indexOf(requiredTier);

    return currentIndex < requiredIndex;
  }

  /// Get the minimum tier required for a specific spread
  static SubscriptionTier getMinimumTierForSpread(SpreadType spread) {
    for (final tier in SubscriptionTier.values) {
      if (canAccessSpread(tier, spread)) {
        return tier;
      }
    }
    return SubscriptionTier.oracle; // Fallback to highest tier
  }

  /// Get the minimum tier required for a specific guide
  static SubscriptionTier getMinimumTierForGuide(GuideType guide) {
    for (final tier in SubscriptionTier.values) {
      if (canAccessGuide(tier, guide)) {
        return tier;
      }
    }
    return SubscriptionTier.oracle; // Fallback to highest tier
  }

  /// Get recommended upgrade tier based on current tier
  static SubscriptionTier getRecommendedUpgrade(SubscriptionTier currentTier) {
    switch (currentTier) {
      case SubscriptionTier.seeker:
        return SubscriptionTier.mystic;
      case SubscriptionTier.mystic:
        return SubscriptionTier.oracle;
      case SubscriptionTier.oracle:
        return SubscriptionTier.oracle; // Already at highest tier
    }
  }
}
