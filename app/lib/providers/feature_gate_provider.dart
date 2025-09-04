import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/feature_access.dart';
import '../models/enums.dart';
import '../services/feature_gate_service.dart';
import '../services/subscription_feature_gate_service.dart';
import 'subscription_provider.dart';
import 'usage_tracking_provider.dart';

/// Provider for the feature gate service
final featureGateServiceProvider = Provider<FeatureGateService>((ref) {
  final usageTrackingService = ref.watch(usageTrackingServiceProvider);
  final subscriptionStatus = ref.watch(currentSubscriptionStatusProvider);

  return SubscriptionFeatureGateService(
    usageTrackingService: usageTrackingService,
    initialStatus: subscriptionStatus,
  );
});

/// Provider for current feature access based on subscription tier
final featureAccessProvider = Provider<FeatureAccess>((ref) {
  final tier = ref.watch(currentTierProvider);
  return FeatureAccess.forTier(tier);
});

/// Provider for checking if a specific feature is accessible
final canAccessFeatureProvider = FutureProvider.family<bool, String>((
  ref,
  featureKey,
) async {
  final service = ref.watch(featureGateServiceProvider);
  return service.canAccessFeature(featureKey);
});

/// Provider for checking if a specific action can be performed
final canPerformActionProvider = FutureProvider.family<bool, String>((
  ref,
  actionKey,
) async {
  final service = ref.watch(featureGateServiceProvider);
  return service.canPerformAction(actionKey);
});

/// Provider for checking if a specific spread type is accessible
final canAccessSpreadProvider = FutureProvider.family<bool, SpreadType>((
  ref,
  spread,
) async {
  final service = ref.watch(featureGateServiceProvider);
  return service.canAccessSpread(spread);
});

/// Provider for checking if a specific guide is accessible
final canAccessGuideProvider = FutureProvider.family<bool, GuideType>((
  ref,
  guide,
) async {
  final service = ref.watch(featureGateServiceProvider);
  return service.canAccessGuide(guide);
});

/// Provider for checking if user can perform readings
final canPerformReadingProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(featureGateServiceProvider);
  return service.canPerformReading();
});

/// Provider for checking if user can perform manual interpretations
final canPerformManualInterpretationProvider = FutureProvider<bool>((
  ref,
) async {
  final service = ref.watch(featureGateServiceProvider);
  return service.canPerformManualInterpretation();
});

/// Provider for checking if user should see ads
final shouldShowAdsProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(featureGateServiceProvider);
  return service.shouldShowAds();
});

/// Provider for checking if user can access audio readings
final canAccessAudioReadingsProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(featureGateServiceProvider);
  return service.canAccessAudioReadings();
});

/// Provider for checking if user can access customization features
final canAccessCustomizationProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(featureGateServiceProvider);
  return service.canAccessCustomization();
});

/// Provider for checking if user can access early access features
final canAccessEarlyAccessProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(featureGateServiceProvider);
  return service.canAccessEarlyAccess();
});

/// Provider for getting upgrade requirement for a feature
final upgradeRequirementProvider =
    FutureProvider.family<UpgradeRequirement?, String>((ref, featureKey) async {
      final service = ref.watch(featureGateServiceProvider);
      return service.getUpgradeRequirement(featureKey);
    });

/// Provider for getting usage information for a feature
final featureUsageInfoProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, feature) async {
      // Watch the usage tracking notifier to refresh when usage changes
      ref.watch(usageTrackingNotifierProvider);
      final service = ref.watch(featureGateServiceProvider);
      return service.getUsageInfo(feature);
    });

/// Provider for getting all usage information
final allUsageInfoProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  // Watch the usage tracking notifier to refresh when usage changes
  ref.watch(usageTrackingNotifierProvider);
  final service = ref.watch(featureGateServiceProvider);
  return service.getAllUsageInfo();
});

/// Synchronous providers based on feature access
/// These don't require async calls and are based on the current tier

/// Provider for available spreads
final availableSpreadsProvider = Provider<List<SpreadType>>((ref) {
  final featureAccess = ref.watch(featureAccessProvider);
  return featureAccess.availableSpreads;
});

/// Provider for available guides
final availableGuidesProvider = Provider<List<GuideType>>((ref) {
  final featureAccess = ref.watch(featureAccessProvider);
  return featureAccess.availableGuides;
});

/// Provider for checking if readings are unlimited
final hasUnlimitedReadingsProvider = Provider<bool>((ref) {
  final featureAccess = ref.watch(featureAccessProvider);
  return featureAccess.hasUnlimitedReadings;
});

/// Provider for checking if manual interpretations are unlimited
final hasUnlimitedManualInterpretationsProvider = Provider<bool>((ref) {
  final featureAccess = ref.watch(featureAccessProvider);
  return featureAccess.hasUnlimitedManualInterpretations;
});

/// Provider for checking if user has ad-free experience
final isAdFreeProvider = Provider<bool>((ref) {
  final featureAccess = ref.watch(featureAccessProvider);
  return featureAccess.isAdFree;
});

/// Provider for maximum readings
final maxReadingsProvider = Provider<int>((ref) {
  final featureAccess = ref.watch(featureAccessProvider);
  return featureAccess.maxReadings;
});

/// Provider for maximum manual interpretations
final maxManualInterpretationsProvider = Provider<int>((ref) {
  final featureAccess = ref.watch(featureAccessProvider);
  return featureAccess.maxManualInterpretations;
});

/// Provider for checking if a spread is available (synchronous)
final isSpreadAvailableProvider = Provider.family<bool, SpreadType>((
  ref,
  spread,
) {
  final availableSpreads = ref.watch(availableSpreadsProvider);
  return availableSpreads.contains(spread);
});

/// Provider for checking if a guide is available (synchronous)
final isGuideAvailableProvider = Provider.family<bool, GuideType>((ref, guide) {
  final availableGuides = ref.watch(availableGuidesProvider);
  return availableGuides.contains(guide);
});

/// Provider for checking if Oracle tier features are available
final hasOracleFeaturesProvider = Provider<bool>((ref) {
  final featureAccess = ref.watch(featureAccessProvider);
  return featureAccess.hasAudioReadings ||
      featureAccess.hasAdvancedSpreads ||
      featureAccess.hasCustomization ||
      featureAccess.hasEarlyAccess;
});

/// Provider for checking if Mystic tier features are available
final hasMysticFeaturesProvider = Provider<bool>((ref) {
  final featureAccess = ref.watch(featureAccessProvider);
  return featureAccess.hasUnlimitedReadings && featureAccess.isAdFree;
});

/// State notifier for managing feature gate operations
class FeatureGateNotifier extends StateNotifier<AsyncValue<Map<String, bool>>> {
  FeatureGateNotifier(this._service, this._ref)
    : super(const AsyncValue.loading()) {
    _loadFeatureStates();
  }

  final FeatureGateService _service;
  final Ref _ref;

  /// Load current feature access states
  Future<void> _loadFeatureStates() async {
    try {
      // Load common feature states
      final features = [
        'unlimited_readings',
        'audio_readings',
        'customization',
        'early_access',
        'ad_free',
      ];

      final states = <String, bool>{};
      for (final feature in features) {
        states[feature] = await _service.canAccessFeature(feature);
      }

      state = AsyncValue.data(states);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Refresh feature states
  Future<void> refresh() async {
    await _loadFeatureStates();
  }

  /// Validate and consume usage for an action
  Future<bool> validateAndConsumeUsage(String actionKey) async {
    try {
      final result = await _service.validateAndConsumeUsage(actionKey);
      // Refresh states after usage consumption
      await _loadFeatureStates();
      // Refresh usage tracking notifier to update UI
      await _ref.read(usageTrackingNotifierProvider.notifier).refresh();
      return result;
    } catch (error) {
      rethrow;
    }
  }
}

/// Provider for the feature gate state notifier
final featureGateNotifierProvider =
    StateNotifierProvider<FeatureGateNotifier, AsyncValue<Map<String, bool>>>((
      ref,
    ) {
      final service = ref.watch(featureGateServiceProvider);
      return FeatureGateNotifier(service, ref);
    });

/// Extension methods for easier feature gate access
extension FeatureGateRef on WidgetRef {
  /// Check if a feature is accessible (async)
  AsyncValue<bool> canAccessFeature(String featureKey) {
    return watch(canAccessFeatureProvider(featureKey));
  }

  /// Check if an action can be performed (async)
  AsyncValue<bool> canPerformAction(String actionKey) {
    return watch(canPerformActionProvider(actionKey));
  }

  /// Check if a spread is accessible (async)
  AsyncValue<bool> canAccessSpread(SpreadType spread) {
    return watch(canAccessSpreadProvider(spread));
  }

  /// Check if a guide is accessible (async)
  AsyncValue<bool> canAccessGuide(GuideType guide) {
    return watch(canAccessGuideProvider(guide));
  }

  /// Check if a spread is available (sync)
  bool isSpreadAvailable(SpreadType spread) {
    return read(isSpreadAvailableProvider(spread));
  }

  /// Check if a guide is available (sync)
  bool isGuideAvailable(GuideType guide) {
    return read(isGuideAvailableProvider(guide));
  }

  /// Get available spreads
  List<SpreadType> get availableSpreads => read(availableSpreadsProvider);

  /// Get available guides
  List<GuideType> get availableGuides => read(availableGuidesProvider);

  /// Check if readings are unlimited
  bool get hasUnlimitedReadings => read(hasUnlimitedReadingsProvider);

  /// Check if manual interpretations are unlimited
  bool get hasUnlimitedManualInterpretations =>
      read(hasUnlimitedManualInterpretationsProvider);

  /// Check if user has ad-free experience
  bool get isAdFree => read(isAdFreeProvider);

  /// Get maximum manual interpretations
  int get maxManualInterpretations => read(maxManualInterpretationsProvider);

  /// Check if user has Oracle tier features
  bool get hasOracleFeatures => read(hasOracleFeaturesProvider);

  /// Check if user has Mystic tier features
  bool get hasMysticFeatures => read(hasMysticFeaturesProvider);

  /// Get feature access configuration
  FeatureAccess get featureAccess => read(featureAccessProvider);

  /// Validate and consume usage for an action
  Future<bool> validateAndConsumeUsage(String actionKey) {
    return read(
      featureGateNotifierProvider.notifier,
    ).validateAndConsumeUsage(actionKey);
  }

  /// Refresh feature gate states
  Future<void> refreshFeatureGates() {
    return read(featureGateNotifierProvider.notifier).refresh();
  }
}
