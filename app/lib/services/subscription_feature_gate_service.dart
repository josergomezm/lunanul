import '../models/enums.dart';
import '../models/subscription_status.dart';
import '../models/subscription_config.dart';
import '../models/feature_access.dart';
import 'feature_gate_service.dart';
import 'usage_tracking_service.dart';

/// Concrete implementation of FeatureGateService that integrates subscription tiers with usage tracking
class SubscriptionFeatureGateService implements FeatureGateService {
  SubscriptionFeatureGateService({
    required UsageTrackingService usageTrackingService,
    SubscriptionStatus? initialStatus,
  }) : _usageTrackingService = usageTrackingService,
       _currentStatus = initialStatus ?? SubscriptionStatus.free();

  final UsageTrackingService _usageTrackingService;
  SubscriptionStatus _currentStatus;

  // Feature key constants
  static const String spreadAccessFeature = 'spread_access';
  static const String guideAccessFeature = 'guide_access';
  static const String manualInterpretationFeature = 'manual_interpretations';
  static const String readingFeature = 'readings';
  static const String audioReadingFeature = 'audio_reading';
  static const String customizationFeature = 'customization';
  static const String earlyAccessFeature = 'early_access';
  static const String adFreeFeature = 'ad_free';

  @override
  Future<bool> canAccessFeature(String featureKey) async {
    final featureAccess = getFeatureAccess(_currentStatus.tier);

    switch (featureKey) {
      case spreadAccessFeature:
        return true; // All tiers have some spread access
      case guideAccessFeature:
        return true; // All tiers have some guide access
      case manualInterpretationFeature:
        return await _checkUsageLimit(
          'manual_interpretations',
          featureAccess.maxManualInterpretations,
        );
      case readingFeature:
        return await _checkUsageLimit('readings', featureAccess.maxReadings);
      case audioReadingFeature:
        return featureAccess.hasAudioReadings;
      case customizationFeature:
        return featureAccess.hasCustomization;
      case earlyAccessFeature:
        return featureAccess.hasEarlyAccess;
      case adFreeFeature:
        return featureAccess.isAdFree;
      default:
        return false;
    }
  }

  @override
  Future<bool> canPerformAction(String actionKey) async {
    // Check if the action is allowed without consuming usage
    return await canAccessFeature(actionKey);
  }

  @override
  FeatureAccess getFeatureAccess(SubscriptionTier tier) {
    return SubscriptionConfig.getFeatureAccess(tier);
  }

  @override
  Future<bool> canAccessSpread(SpreadType spread) async {
    final featureAccess = getFeatureAccess(_currentStatus.tier);
    return featureAccess.canAccessSpread(spread);
  }

  @override
  Future<bool> canAccessGuide(GuideType guide) async {
    final featureAccess = getFeatureAccess(_currentStatus.tier);
    return featureAccess.canAccessGuide(guide);
  }

  @override
  Future<bool> canPerformReading() async {
    final featureAccess = getFeatureAccess(_currentStatus.tier);
    return await _checkUsageLimit('readings', featureAccess.maxReadings);
  }

  @override
  Future<bool> canPerformManualInterpretation() async {
    final featureAccess = getFeatureAccess(_currentStatus.tier);
    return await _checkUsageLimit(
      'manual_interpretations',
      featureAccess.maxManualInterpretations,
    );
  }

  @override
  Future<bool> shouldShowAds() async {
    final featureAccess = getFeatureAccess(_currentStatus.tier);
    return !featureAccess.isAdFree;
  }

  @override
  Future<bool> canAccessAudioReadings() async {
    final featureAccess = getFeatureAccess(_currentStatus.tier);
    return featureAccess.hasAudioReadings;
  }

  @override
  Future<bool> canAccessCustomization() async {
    final featureAccess = getFeatureAccess(_currentStatus.tier);
    return featureAccess.hasCustomization;
  }

  @override
  Future<bool> canAccessEarlyAccess() async {
    final featureAccess = getFeatureAccess(_currentStatus.tier);
    return featureAccess.hasEarlyAccess;
  }

  @override
  Future<SubscriptionStatus> getCurrentSubscriptionStatus() async {
    return _currentStatus;
  }

  @override
  Future<void> updateSubscriptionStatus(SubscriptionStatus status) async {
    _currentStatus = status;
  }

  @override
  Future<Map<String, dynamic>> getUsageInfo(String feature) async {
    final featureAccess = getFeatureAccess(_currentStatus.tier);
    final currentUsage = await _usageTrackingService.getUsageCount(feature);

    int? limit;
    switch (feature) {
      case 'manual_interpretations':
        limit = featureAccess.maxManualInterpretations;
        break;
      case 'readings':
        limit = featureAccess.maxReadings;
        break;
      default:
        limit = null;
    }

    // If limit is 0, it means unlimited
    final isUnlimited = limit == 0;
    final remaining = isUnlimited
        ? -1
        : (limit! - currentUsage).clamp(0, limit);
    final percentage = isUnlimited
        ? 0.0
        : (currentUsage / limit!).clamp(0.0, 1.0);

    return {
      'current': currentUsage,
      'limit': isUnlimited ? null : limit,
      'remaining': isUnlimited ? null : remaining,
      'percentage': percentage,
      'unlimited': isUnlimited,
      'approaching_limit': !isUnlimited && percentage >= 0.8,
      'reached_limit': !isUnlimited && limit != null && currentUsage >= limit,
    };
  }

  @override
  Future<Map<String, dynamic>> getAllUsageInfo() async {
    final featureAccess = getFeatureAccess(_currentStatus.tier);
    final result = <String, dynamic>{};

    // Get usage info for limited features
    if (featureAccess.maxManualInterpretations > 0) {
      result['manual_interpretations'] = await getUsageInfo(
        'manual_interpretations',
      );
    }

    if (featureAccess.maxReadings > 0) {
      result['readings'] = await getUsageInfo('readings');
    }

    return result;
  }

  @override
  Future<UpgradeRequirement?> getUpgradeRequirement(String featureKey) async {
    final featureAccess = getFeatureAccess(_currentStatus.tier);

    switch (featureKey) {
      case audioReadingFeature:
        if (!featureAccess.hasAudioReadings) {
          return UpgradeRequirement(
            requiredTier: SubscriptionTier.oracle,
            reason: UpgradeReason.premiumFeature,
            featureName: 'Audio Readings',
          );
        }
        break;

      case customizationFeature:
        if (!featureAccess.hasCustomization) {
          return UpgradeRequirement(
            requiredTier: SubscriptionTier.oracle,
            reason: UpgradeReason.premiumFeature,
            featureName: 'Customization',
          );
        }
        break;

      case earlyAccessFeature:
        if (!featureAccess.hasEarlyAccess) {
          return UpgradeRequirement(
            requiredTier: SubscriptionTier.oracle,
            reason: UpgradeReason.premiumFeature,
            featureName: 'Early Access',
          );
        }
        break;

      case adFreeFeature:
        if (!featureAccess.isAdFree) {
          return UpgradeRequirement(
            requiredTier: SubscriptionTier.mystic,
            reason: UpgradeReason.tierRestriction,
            featureName: 'Ad-Free Experience',
          );
        }
        break;

      case manualInterpretationFeature:
        if (featureAccess.maxManualInterpretations > 0) {
          final currentUsage = await _usageTrackingService.getUsageCount(
            'manual_interpretations',
          );
          if (currentUsage >= featureAccess.maxManualInterpretations) {
            return UpgradeRequirement(
              requiredTier: SubscriptionTier.mystic,
              reason: UpgradeReason.usageLimit,
              featureName: 'Manual Interpretations',
              currentUsage: currentUsage,
              usageLimit: featureAccess.maxManualInterpretations,
            );
          }
        }
        break;

      case readingFeature:
        if (featureAccess.maxReadings > 0) {
          final currentUsage = await _usageTrackingService.getUsageCount(
            'readings',
          );
          if (currentUsage >= featureAccess.maxReadings) {
            return UpgradeRequirement(
              requiredTier: SubscriptionTier.mystic,
              reason: UpgradeReason.usageLimit,
              featureName: 'Readings',
              currentUsage: currentUsage,
              usageLimit: featureAccess.maxReadings,
            );
          }
        }
        break;
    }

    return null; // No upgrade required
  }

  @override
  Future<bool> validateAndConsumeUsage(String actionKey) async {
    final canPerform = await canPerformAction(actionKey);
    if (!canPerform) {
      return false;
    }

    // Consume usage for actions that have limits
    switch (actionKey) {
      case manualInterpretationFeature:
        await _usageTrackingService.incrementUsage('manual_interpretations');
        break;
      case readingFeature:
        await _usageTrackingService.incrementUsage('readings');
        break;
      // Other actions don't consume usage
    }

    return true;
  }

  /// Check if usage is within limits for a feature
  Future<bool> _checkUsageLimit(String usageKey, int maxUsage) async {
    // If maxUsage is 0, it means unlimited
    if (maxUsage == 0) return true;

    final currentUsage = await _usageTrackingService.getUsageCount(usageKey);
    return currentUsage < maxUsage;
  }

  /// Get upgrade requirement for a specific spread type
  Future<UpgradeRequirement?> getUpgradeRequirementForSpread(
    SpreadType spread,
  ) async {
    final canAccess = await canAccessSpread(spread);
    if (canAccess) return null;

    final requiredTier = SubscriptionConfig.getMinimumTierForSpread(spread);
    return UpgradeRequirement(
      requiredTier: requiredTier,
      reason: UpgradeReason.tierRestriction,
      featureName: spread.displayName,
    );
  }

  /// Get upgrade requirement for a specific guide type
  Future<UpgradeRequirement?> getUpgradeRequirementForGuide(
    GuideType guide,
  ) async {
    final canAccess = await canAccessGuide(guide);
    if (canAccess) return null;

    final requiredTier = SubscriptionConfig.getMinimumTierForGuide(guide);
    return UpgradeRequirement(
      requiredTier: requiredTier,
      reason: UpgradeReason.tierRestriction,
      featureName: '${guide.guideName} (${guide.title})',
    );
  }

  /// Check if automatic monthly reset is needed and perform it
  Future<void> checkAndPerformMonthlyReset() async {
    if (await _usageTrackingService.shouldResetMonthlyUsage()) {
      await _usageTrackingService.resetMonthlyUsage();
    }
  }

  /// Get comprehensive feature access summary
  Future<Map<String, dynamic>> getFeatureAccessSummary() async {
    final featureAccess = getFeatureAccess(_currentStatus.tier);
    final usageInfo = await getAllUsageInfo();

    return {
      'tier': _currentStatus.tier.name,
      'tier_display_name': _currentStatus.tier.displayName,
      'is_active': _currentStatus.isActive,
      'is_valid': _currentStatus.isValid,
      'features': {
        'unlimited_readings': featureAccess.hasUnlimitedReadings,
        'available_spreads': featureAccess.availableSpreads
            .map((s) => s.name)
            .toList(),
        'available_guides': featureAccess.availableGuides
            .map((g) => g.name)
            .toList(),
        'ad_free': featureAccess.isAdFree,
        'audio_readings': featureAccess.hasAudioReadings,
        'customization': featureAccess.hasCustomization,
        'early_access': featureAccess.hasEarlyAccess,
      },
      'usage': usageInfo,
      'subscription_status': {
        'expiration_date': _currentStatus.expirationDate?.toIso8601String(),
        'platform_id': _currentStatus.platformSubscriptionId,
        'last_updated': _currentStatus.lastUpdated.toIso8601String(),
      },
    };
  }
}
