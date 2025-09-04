import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/onboarding_state.dart';
import '../models/enums.dart';

/// Service for managing subscription onboarding and user education
abstract class SubscriptionOnboardingService {
  /// Get the current onboarding state
  Future<OnboardingState> getOnboardingState();

  /// Update the onboarding state
  Future<void> updateOnboardingState(OnboardingState state);

  /// Mark a specific onboarding step as completed
  Future<void> completeOnboardingStep(OnboardingStep step);

  /// Dismiss a specific upgrade prompt
  Future<void> dismissUpgradePrompt(String promptKey);

  /// Check if a feature discovery prompt should be shown
  Future<bool> shouldShowFeatureDiscovery(String featureKey);

  /// Check if an upgrade prompt should be shown
  Future<bool> shouldShowUpgradePrompt(String promptKey);

  /// Mark subscription introduction as seen
  Future<void> markSubscriptionIntroSeen();

  /// Mark feature discovery as seen
  Future<void> markFeatureDiscoverySeen();

  /// Get personalized upgrade suggestions based on user behavior
  Future<List<UpgradeSuggestion>> getPersonalizedSuggestions(
    SubscriptionTier currentTier,
    Map<String, int> usageStats,
  );

  /// Reset onboarding state (for testing or user request)
  Future<void> resetOnboardingState();
}

/// Implementation using SharedPreferences for local storage
class SharedPreferencesOnboardingService
    implements SubscriptionOnboardingService {
  static const String _onboardingStateKey = 'subscription_onboarding_state';
  static const String _featureDiscoveryKey = 'feature_discovery_';
  static const String _upgradePromptKey = 'upgrade_prompt_';

  @override
  Future<OnboardingState> getOnboardingState() async {
    final prefs = await SharedPreferences.getInstance();
    final stateJson = prefs.getString(_onboardingStateKey);

    if (stateJson == null) {
      return OnboardingState.initial();
    }

    try {
      final stateMap = jsonDecode(stateJson) as Map<String, dynamic>;
      return OnboardingState.fromJson(stateMap);
    } catch (e) {
      // If parsing fails, return initial state
      return OnboardingState.initial();
    }
  }

  @override
  Future<void> updateOnboardingState(OnboardingState state) async {
    final prefs = await SharedPreferences.getInstance();
    final stateJson = jsonEncode(state.toJson());
    await prefs.setString(_onboardingStateKey, stateJson);
  }

  @override
  Future<void> completeOnboardingStep(OnboardingStep step) async {
    final currentState = await getOnboardingState();
    final updatedState = currentState.completeStep(step);
    await updateOnboardingState(updatedState);
  }

  @override
  Future<void> dismissUpgradePrompt(String promptKey) async {
    final currentState = await getOnboardingState();
    final updatedState = currentState.dismissPrompt(promptKey);
    await updateOnboardingState(updatedState);

    // Also store individual prompt dismissal for quick lookup
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('$_upgradePromptKey$promptKey', true);
  }

  @override
  Future<bool> shouldShowFeatureDiscovery(String featureKey) async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeenFeature =
        prefs.getBool('$_featureDiscoveryKey$featureKey') ?? false;

    if (hasSeenFeature) return false;

    final onboardingState = await getOnboardingState();
    return onboardingState.canShowPrompt();
  }

  @override
  Future<bool> shouldShowUpgradePrompt(String promptKey) async {
    final prefs = await SharedPreferences.getInstance();
    final hasBeenDismissed =
        prefs.getBool('$_upgradePromptKey$promptKey') ?? false;

    if (hasBeenDismissed) return false;

    final onboardingState = await getOnboardingState();
    return onboardingState.canShowPrompt() &&
        !onboardingState.hasPromptBeenDismissed(promptKey);
  }

  @override
  Future<void> markSubscriptionIntroSeen() async {
    final currentState = await getOnboardingState();
    final updatedState = currentState.copyWith(hasSeenSubscriptionIntro: true);
    await updateOnboardingState(updatedState);
  }

  @override
  Future<void> markFeatureDiscoverySeen() async {
    final currentState = await getOnboardingState();
    final updatedState = currentState.copyWith(hasSeenFeatureDiscovery: true);
    await updateOnboardingState(updatedState);
  }

  @override
  Future<List<UpgradeSuggestion>> getPersonalizedSuggestions(
    SubscriptionTier currentTier,
    Map<String, int> usageStats,
  ) async {
    final suggestions = <UpgradeSuggestion>[];

    if (currentTier == SubscriptionTier.seeker) {
      // Analyze usage patterns for free users
      final manualInterpretations = usageStats['manual_interpretations'] ?? 0;
      final readings = usageStats['readings'] ?? 0;
      final readingCount = usageStats['readings_completed'] ?? 0;

      // Suggest based on high usage
      if (manualInterpretations >= 3) {
        suggestions.add(
          UpgradeSuggestion(
            id: 'manual_interpretations_limit',
            title: 'Unlimited Card Interpretations',
            description:
                'You\'ve used $manualInterpretations/5 manual interpretations this month. Upgrade to Mystic for unlimited access.',
            recommendedTier: SubscriptionTier.mystic,
            priority: UpgradePriority.high,
            triggerContext: 'manual_interpretations',
          ),
        );
      }

      if (readings >= 2) {
        suggestions.add(
          UpgradeSuggestion(
            id: 'reading_limit',
            title: 'Unlimited Readings',
            description:
                'You\'ve used $readings/3 readings this month. Upgrade for unlimited access to all readings.',
            recommendedTier: SubscriptionTier.mystic,
            priority: UpgradePriority.medium,
            triggerContext: 'reading_limit',
          ),
        );
      }

      if (readingCount >= 5) {
        suggestions.add(
          UpgradeSuggestion(
            id: 'advanced_spreads',
            title: 'Advanced Tarot Spreads',
            description:
                'You\'re actively using Lunanul! Unlock Celtic Cross and other advanced spreads.',
            recommendedTier: SubscriptionTier.mystic,
            priority: UpgradePriority.medium,
            triggerContext: 'reading_frequency',
          ),
        );
      }
    } else if (currentTier == SubscriptionTier.mystic) {
      // Suggest Oracle features for engaged Mystic users
      final readingCount = usageStats['readings_completed'] ?? 0;

      if (readingCount >= 10) {
        suggestions.add(
          UpgradeSuggestion(
            id: 'audio_readings',
            title: 'AI-Generated Audio Readings',
            description:
                'Experience your readings in a new way with personalized audio interpretations.',
            recommendedTier: SubscriptionTier.oracle,
            priority: UpgradePriority.low,
            triggerContext: 'high_engagement',
          ),
        );
      }
    }

    return suggestions;
  }

  @override
  Future<void> resetOnboardingState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_onboardingStateKey);

    // Remove all feature discovery and upgrade prompt flags
    final keys = prefs.getKeys();
    for (final key in keys) {
      if (key.startsWith(_featureDiscoveryKey) ||
          key.startsWith(_upgradePromptKey)) {
        await prefs.remove(key);
      }
    }
  }
}

/// Represents a personalized upgrade suggestion
class UpgradeSuggestion {
  const UpgradeSuggestion({
    required this.id,
    required this.title,
    required this.description,
    required this.recommendedTier,
    required this.priority,
    required this.triggerContext,
  });

  /// Unique identifier for this suggestion
  final String id;

  /// Title of the suggestion
  final String title;

  /// Description explaining the benefit
  final String description;

  /// Recommended subscription tier
  final SubscriptionTier recommendedTier;

  /// Priority level for showing this suggestion
  final UpgradePriority priority;

  /// Context that triggered this suggestion
  final String triggerContext;
}

/// Priority levels for upgrade suggestions
enum UpgradePriority {
  low('Low priority - show occasionally'),
  medium('Medium priority - show regularly'),
  high('High priority - show prominently');

  const UpgradePriority(this.description);

  final String description;
}
