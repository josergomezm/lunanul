import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/onboarding_state.dart';
import '../services/subscription_onboarding_service.dart';
import 'subscription_provider.dart';
import 'usage_tracking_provider.dart';

/// Provider for subscription onboarding service
final subscriptionOnboardingServiceProvider =
    Provider<SubscriptionOnboardingService>((ref) {
      return SharedPreferencesOnboardingService();
    });

/// Provider for onboarding state
final onboardingStateProvider =
    StateNotifierProvider<OnboardingStateNotifier, AsyncValue<OnboardingState>>(
      (ref) {
        final service = ref.watch(subscriptionOnboardingServiceProvider);
        return OnboardingStateNotifier(service);
      },
    );

/// Provider for personalized upgrade suggestions
final upgradeSuggestionsProvider = FutureProvider<List<UpgradeSuggestion>>((
  ref,
) async {
  final onboardingService = ref.watch(subscriptionOnboardingServiceProvider);
  final subscriptionAsync = ref.watch(subscriptionProvider);
  final usageAsync = ref.watch(usageTrackingNotifierProvider);

  return subscriptionAsync.when(
    data: (subscription) => usageAsync.when(
      data: (usage) => onboardingService.getPersonalizedSuggestions(
        subscription.tier,
        usage,
      ),
      loading: () => <UpgradeSuggestion>[],
      error: (_, _) => <UpgradeSuggestion>[],
    ),
    loading: () => <UpgradeSuggestion>[],
    error: (_, _) => <UpgradeSuggestion>[],
  );
});

/// Provider to check if subscription intro should be shown
final shouldShowSubscriptionIntroProvider = FutureProvider<bool>((ref) async {
  final onboardingAsync = ref.watch(onboardingStateProvider);

  return onboardingAsync.when(
    data: (onboarding) => !onboarding.hasSeenSubscriptionIntro,
    loading: () => false,
    error: (_, _) => false,
  );
});

/// Provider to check if feature discovery should be shown for a specific feature
final shouldShowFeatureDiscoveryProvider = FutureProvider.family<bool, String>((
  ref,
  featureKey,
) async {
  final service = ref.watch(subscriptionOnboardingServiceProvider);
  return service.shouldShowFeatureDiscovery(featureKey);
});

/// Provider to check if upgrade prompt should be shown for a specific context
final shouldShowUpgradePromptProvider = FutureProvider.family<bool, String>((
  ref,
  promptKey,
) async {
  final service = ref.watch(subscriptionOnboardingServiceProvider);
  return service.shouldShowUpgradePrompt(promptKey);
});

/// Notifier for managing onboarding state
class OnboardingStateNotifier
    extends StateNotifier<AsyncValue<OnboardingState>> {
  OnboardingStateNotifier(this._service) : super(const AsyncValue.loading()) {
    _loadOnboardingState();
  }

  final SubscriptionOnboardingService _service;

  /// Load the current onboarding state
  Future<void> _loadOnboardingState() async {
    try {
      final onboardingState = await _service.getOnboardingState();
      state = AsyncValue.data(onboardingState);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Complete an onboarding step
  Future<void> completeStep(OnboardingStep step) async {
    try {
      await _service.completeOnboardingStep(step);
      await _loadOnboardingState(); // Refresh state
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Mark subscription introduction as seen
  Future<void> markSubscriptionIntroSeen() async {
    try {
      await _service.markSubscriptionIntroSeen();
      await _loadOnboardingState(); // Refresh state
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Mark feature discovery as seen
  Future<void> markFeatureDiscoverySeen() async {
    try {
      await _service.markFeatureDiscoverySeen();
      await _loadOnboardingState(); // Refresh state
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Dismiss an upgrade prompt
  Future<void> dismissUpgradePrompt(String promptKey) async {
    try {
      await _service.dismissUpgradePrompt(promptKey);
      await _loadOnboardingState(); // Refresh state
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Start the onboarding process
  Future<void> startOnboarding() async {
    try {
      final currentState = await _service.getOnboardingState();
      final updatedState = currentState.startOnboarding();
      await _service.updateOnboardingState(updatedState);
      await _loadOnboardingState(); // Refresh state
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Reset onboarding state (for testing or user request)
  Future<void> resetOnboarding() async {
    try {
      await _service.resetOnboardingState();
      await _loadOnboardingState(); // Refresh state
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Refresh the onboarding state
  Future<void> refresh() async {
    await _loadOnboardingState();
  }
}

/// Provider for the subscription onboarding state notifier
final subscriptionOnboardingProvider =
    StateNotifierProvider<OnboardingStateNotifier, AsyncValue<OnboardingState>>(
      (ref) {
        final service = ref.watch(subscriptionOnboardingServiceProvider);
        return OnboardingStateNotifier(service);
      },
    );
