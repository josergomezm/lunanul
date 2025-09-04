import '../models/enums.dart';
import '../services/ad_service.dart';
import '../services/feature_gate_service.dart';

/// Service that integrates ad display with the reading flow
class ReadingAdIntegrationService {
  ReadingAdIntegrationService({
    required AdService adService,
    required FeatureGateService featureGateService,
  }) : _adService = adService,
       _featureGateService = featureGateService;

  final AdService _adService;
  final FeatureGateService _featureGateService;

  /// Check if an ad should be shown after a reading
  Future<bool> shouldShowPostReadingAd() async {
    return await _featureGateService.shouldShowAds();
  }

  /// Load and prepare an ad for display after a reading
  Future<AdContent?> preparePostReadingAd({
    required ReadingTopic topic,
    required SpreadType spreadType,
  }) async {
    // Check if ads should be shown
    if (!await shouldShowPostReadingAd()) {
      return null;
    }

    // Load appropriate ad content
    return await _adService.loadReadingAd(topic: topic, spreadType: spreadType);
  }

  /// Show an ad and handle the display logic
  Future<void> displayAd(AdContent adContent) async {
    await _adService.showAd(adContent);
  }

  /// Track ad interaction events
  Future<void> trackAdInteraction({
    required String adId,
    required AdInteractionType interactionType,
    Map<String, dynamic>? metadata,
  }) async {
    switch (interactionType) {
      case AdInteractionType.impression:
        await _adService.trackAdImpression(adId);
        break;
      case AdInteractionType.click:
        await _adService.trackAdClick(adId);
        break;
      case AdInteractionType.dismiss:
        // Track dismissal if needed
        break;
    }
  }

  /// Get ad configuration for the current user
  Future<AdDisplayConfiguration> getAdDisplayConfiguration() async {
    final shouldShow = await shouldShowPostReadingAd();

    return AdDisplayConfiguration(
      enabled: shouldShow,
      displayAfterReadings: shouldShow,
      respectUserPreferences: true,
      maxAdsPerSession: shouldShow ? 3 : 0,
    );
  }

  /// Initialize the ad integration service
  Future<void> initialize() async {
    await _adService.initialize();
  }

  /// Dispose of resources
  Future<void> dispose() async {
    await _adService.dispose();
  }
}

/// Types of ad interactions for tracking
enum AdInteractionType { impression, click, dismiss }

/// Configuration for ad display behavior
class AdDisplayConfiguration {
  const AdDisplayConfiguration({
    required this.enabled,
    required this.displayAfterReadings,
    required this.respectUserPreferences,
    required this.maxAdsPerSession,
  });

  final bool enabled;
  final bool displayAfterReadings;
  final bool respectUserPreferences;
  final int maxAdsPerSession;

  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'displayAfterReadings': displayAfterReadings,
      'respectUserPreferences': respectUserPreferences,
      'maxAdsPerSession': maxAdsPerSession,
    };
  }
}
