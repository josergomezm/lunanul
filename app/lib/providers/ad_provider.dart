import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/ad_service.dart';
import '../services/mock_ad_service.dart';
import '../services/reading_ad_integration_service.dart';
import '../models/enums.dart';
import 'subscription_providers.dart';

/// Provider for the ad service
final adServiceProvider = Provider<AdService>((ref) {
  return MockAdService();
});

/// Provider for the reading ad integration service
final readingAdIntegrationProvider = Provider<ReadingAdIntegrationService>((
  ref,
) {
  return ReadingAdIntegrationService(
    adService: ref.watch(adServiceProvider),
    featureGateService: ref.watch(featureGateServiceProvider),
  );
});

/// Provider that determines if ads should be shown based on subscription status
final adDisplayEnabledProvider = FutureProvider<bool>((ref) async {
  final subscriptionAsync = ref.watch(subscriptionProvider);
  final adService = ref.watch(adServiceProvider);

  return subscriptionAsync.when(
    data: (subscriptionStatus) async {
      // Only show ads for free tier users
      if (subscriptionStatus.tier != SubscriptionTier.seeker) {
        return false;
      }

      // Check if ads should be shown based on service logic
      return await adService.shouldShowAds();
    },
    loading: () => false,
    error: (_, _) => false,
  );
});

/// Provider for loading reading ads
final readingAdProvider = FutureProvider.family<AdContent?, ReadingAdRequest>((
  ref,
  request,
) async {
  final shouldShow = await ref.watch(adDisplayEnabledProvider.future);

  if (!shouldShow) {
    return null;
  }

  final adService = ref.watch(adServiceProvider);
  return await adService.loadReadingAd(
    topic: request.topic,
    spreadType: request.spreadType,
  );
});

/// Provider for tracking ad state
final adStateProvider = StateNotifierProvider<AdStateNotifier, AdState>((ref) {
  return AdStateNotifier(ref.watch(adServiceProvider));
});

/// Request object for reading ads
class ReadingAdRequest {
  const ReadingAdRequest({required this.topic, required this.spreadType});

  final ReadingTopic topic;
  final SpreadType spreadType;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReadingAdRequest &&
        other.topic == topic &&
        other.spreadType == spreadType;
  }

  @override
  int get hashCode => Object.hash(topic, spreadType);
}

/// State for ad management
class AdState {
  const AdState({
    this.currentAd,
    this.isLoading = false,
    this.error,
    this.adsShownThisSession = 0,
  });

  final AdContent? currentAd;
  final bool isLoading;
  final String? error;
  final int adsShownThisSession;

  AdState copyWith({
    AdContent? currentAd,
    bool? isLoading,
    String? error,
    int? adsShownThisSession,
  }) {
    return AdState(
      currentAd: currentAd ?? this.currentAd,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      adsShownThisSession: adsShownThisSession ?? this.adsShownThisSession,
    );
  }
}

/// Notifier for managing ad state
class AdStateNotifier extends StateNotifier<AdState> {
  AdStateNotifier(this._adService) : super(const AdState());

  final AdService _adService;

  /// Load an ad for a reading
  Future<void> loadReadingAd({
    required ReadingTopic topic,
    required SpreadType spreadType,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final adContent = await _adService.loadReadingAd(
        topic: topic,
        spreadType: spreadType,
      );

      state = state.copyWith(currentAd: adContent, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Show the current ad
  Future<void> showCurrentAd() async {
    final currentAd = state.currentAd;
    if (currentAd == null) return;

    try {
      await _adService.showAd(currentAd);
      state = state.copyWith(
        adsShownThisSession: state.adsShownThisSession + 1,
        currentAd: null,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Track ad click
  Future<void> trackAdClick(String adId) async {
    try {
      await _adService.trackAdClick(adId);
    } catch (e) {
      // Log error but don't update state for tracking failures
      // TODO: Replace with proper logging in production
      // ignore: avoid_print
      print('Failed to track ad click: $e');
    }
  }

  /// Clear current ad
  void clearCurrentAd() {
    state = state.copyWith(currentAd: null);
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}
