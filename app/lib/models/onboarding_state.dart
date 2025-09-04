/// Represents the state of user onboarding and education
class OnboardingState {
  const OnboardingState({
    required this.hasSeenSubscriptionIntro,
    required this.hasSeenFeatureDiscovery,
    required this.completedOnboardingSteps,
    required this.dismissedPrompts,
    this.lastPromptShown,
    this.onboardingStartedAt,
    this.onboardingCompletedAt,
  });

  /// Whether the user has seen the subscription introduction
  final bool hasSeenSubscriptionIntro;

  /// Whether the user has seen feature discovery prompts
  final bool hasSeenFeatureDiscovery;

  /// List of completed onboarding steps
  final List<OnboardingStep> completedOnboardingSteps;

  /// List of dismissed upgrade prompts (to avoid showing repeatedly)
  final List<String> dismissedPrompts;

  /// When the last prompt was shown (for rate limiting)
  final DateTime? lastPromptShown;

  /// When onboarding was started
  final DateTime? onboardingStartedAt;

  /// When onboarding was completed
  final DateTime? onboardingCompletedAt;

  /// Check if onboarding is complete
  bool get isOnboardingComplete => onboardingCompletedAt != null;

  /// Check if a specific step is completed
  bool hasCompletedStep(OnboardingStep step) {
    return completedOnboardingSteps.contains(step);
  }

  /// Check if a prompt has been dismissed
  bool hasPromptBeenDismissed(String promptKey) {
    return dismissedPrompts.contains(promptKey);
  }

  /// Check if enough time has passed since last prompt (rate limiting)
  bool canShowPrompt() {
    if (lastPromptShown == null) return true;
    final timeSinceLastPrompt = DateTime.now().difference(lastPromptShown!);
    return timeSinceLastPrompt.inHours >= 24; // Show at most once per day
  }

  /// Create a copy with updated values
  OnboardingState copyWith({
    bool? hasSeenSubscriptionIntro,
    bool? hasSeenFeatureDiscovery,
    List<OnboardingStep>? completedOnboardingSteps,
    List<String>? dismissedPrompts,
    DateTime? lastPromptShown,
    DateTime? onboardingStartedAt,
    DateTime? onboardingCompletedAt,
  }) {
    return OnboardingState(
      hasSeenSubscriptionIntro:
          hasSeenSubscriptionIntro ?? this.hasSeenSubscriptionIntro,
      hasSeenFeatureDiscovery:
          hasSeenFeatureDiscovery ?? this.hasSeenFeatureDiscovery,
      completedOnboardingSteps:
          completedOnboardingSteps ?? this.completedOnboardingSteps,
      dismissedPrompts: dismissedPrompts ?? this.dismissedPrompts,
      lastPromptShown: lastPromptShown ?? this.lastPromptShown,
      onboardingStartedAt: onboardingStartedAt ?? this.onboardingStartedAt,
      onboardingCompletedAt:
          onboardingCompletedAt ?? this.onboardingCompletedAt,
    );
  }

  /// Mark a step as completed
  OnboardingState completeStep(OnboardingStep step) {
    if (hasCompletedStep(step)) return this;

    final updatedSteps = [...completedOnboardingSteps, step];
    final isNowComplete = updatedSteps.length >= OnboardingStep.values.length;

    return copyWith(
      completedOnboardingSteps: updatedSteps,
      onboardingCompletedAt: isNowComplete ? DateTime.now() : null,
    );
  }

  /// Dismiss a prompt
  OnboardingState dismissPrompt(String promptKey) {
    if (hasPromptBeenDismissed(promptKey)) return this;

    return copyWith(
      dismissedPrompts: [...dismissedPrompts, promptKey],
      lastPromptShown: DateTime.now(),
    );
  }

  /// Start onboarding
  OnboardingState startOnboarding() {
    return copyWith(onboardingStartedAt: onboardingStartedAt ?? DateTime.now());
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'hasSeenSubscriptionIntro': hasSeenSubscriptionIntro,
      'hasSeenFeatureDiscovery': hasSeenFeatureDiscovery,
      'completedOnboardingSteps': completedOnboardingSteps
          .map((s) => s.name)
          .toList(),
      'dismissedPrompts': dismissedPrompts,
      'lastPromptShown': lastPromptShown?.toIso8601String(),
      'onboardingStartedAt': onboardingStartedAt?.toIso8601String(),
      'onboardingCompletedAt': onboardingCompletedAt?.toIso8601String(),
    };
  }

  /// Create from JSON
  factory OnboardingState.fromJson(Map<String, dynamic> json) {
    return OnboardingState(
      hasSeenSubscriptionIntro:
          json['hasSeenSubscriptionIntro'] as bool? ?? false,
      hasSeenFeatureDiscovery:
          json['hasSeenFeatureDiscovery'] as bool? ?? false,
      completedOnboardingSteps:
          (json['completedOnboardingSteps'] as List<dynamic>?)
              ?.map((s) => OnboardingStep.fromString(s as String))
              .toList() ??
          [],
      dismissedPrompts: List<String>.from(
        json['dismissedPrompts'] as List? ?? [],
      ),
      lastPromptShown: json['lastPromptShown'] != null
          ? DateTime.parse(json['lastPromptShown'] as String)
          : null,
      onboardingStartedAt: json['onboardingStartedAt'] != null
          ? DateTime.parse(json['onboardingStartedAt'] as String)
          : null,
      onboardingCompletedAt: json['onboardingCompletedAt'] != null
          ? DateTime.parse(json['onboardingCompletedAt'] as String)
          : null,
    );
  }

  /// Create initial state for new users
  factory OnboardingState.initial() {
    return const OnboardingState(
      hasSeenSubscriptionIntro: false,
      hasSeenFeatureDiscovery: false,
      completedOnboardingSteps: [],
      dismissedPrompts: [],
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OnboardingState &&
        other.hasSeenSubscriptionIntro == hasSeenSubscriptionIntro &&
        other.hasSeenFeatureDiscovery == hasSeenFeatureDiscovery &&
        other.isOnboardingComplete == isOnboardingComplete;
  }

  @override
  int get hashCode {
    return Object.hash(
      hasSeenSubscriptionIntro,
      hasSeenFeatureDiscovery,
      isOnboardingComplete,
    );
  }

  @override
  String toString() {
    return 'OnboardingState(intro: $hasSeenSubscriptionIntro, '
        'discovery: $hasSeenFeatureDiscovery, complete: $isOnboardingComplete)';
  }
}

/// Steps in the subscription onboarding process
enum OnboardingStep {
  subscriptionIntroduction('Introduction to subscription tiers'),
  featureDiscovery('Discover premium features'),
  benefitsExplanation('Understanding subscription benefits'),
  firstUpgradePrompt('First gentle upgrade suggestion');

  const OnboardingStep(this.description);

  final String description;

  /// Convert from string to enum
  static OnboardingStep fromString(String value) {
    return OnboardingStep.values.firstWhere(
      (step) => step.name == value,
      orElse: () => OnboardingStep.subscriptionIntroduction,
    );
  }
}
