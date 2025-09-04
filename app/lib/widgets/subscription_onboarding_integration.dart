import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/enums.dart';
import '../providers/subscription_onboarding_provider.dart';
import '../providers/subscription_provider.dart';
import '../services/subscription_onboarding_service.dart';
import 'subscription_introduction_flow.dart';
import 'feature_discovery_prompt.dart';
import 'gentle_upgrade_suggestion.dart';
import '../pages/subscription_benefits_page.dart';

/// Widget that integrates subscription onboarding throughout the app
class SubscriptionOnboardingIntegration extends ConsumerWidget {
  final Widget child;

  const SubscriptionOnboardingIntegration({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shouldShowIntroAsync = ref.watch(shouldShowSubscriptionIntroProvider);
    final subscriptionAsync = ref.watch(subscriptionProvider);

    return shouldShowIntroAsync.when(
      data: (shouldShowIntro) {
        if (shouldShowIntro) {
          return SubscriptionIntroductionFlow(
            onComplete: () => _handleIntroComplete(context),
            onSkip: () => _handleIntroComplete(context),
          );
        }

        return subscriptionAsync.when(
          data: (subscription) => Stack(
            children: [
              child,
              // Show personalized suggestions for free users
              if (subscription.tier == SubscriptionTier.seeker)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: _buildBottomSuggestions(context, ref),
                ),
            ],
          ),
          loading: () => child,
          error: (_, _) => child,
        );
      },
      loading: () => child,
      error: (_, _) => child,
    );
  }

  Widget _buildBottomSuggestions(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: const PersonalizedUpgradeSuggestions(showAsCards: true),
    );
  }

  void _handleIntroComplete(BuildContext context) {
    // Navigation is handled by the introduction flow itself
    // This could trigger additional onboarding steps if needed
  }
}

/// Mixin for pages that want to show feature discovery prompts
mixin SubscriptionOnboardingMixin<T extends ConsumerStatefulWidget>
    on ConsumerState<T> {
  /// Show a feature discovery prompt for a specific feature
  void showFeatureDiscovery({
    required String featureKey,
    required String title,
    required String description,
    required IconData icon,
    required SubscriptionTier requiredTier,
    VoidCallback? onUpgrade,
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => FeatureDiscoveryPrompt(
        featureKey: featureKey,
        title: title,
        description: description,
        icon: icon,
        requiredTier: requiredTier,
        onUpgrade: onUpgrade ?? () => _navigateToSubscription(),
        onDismiss: () => Navigator.of(context).pop(),
      ),
    );
  }

  /// Show an upgrade suggestion based on user behavior
  void showUpgradeSuggestion({
    required String promptKey,
    required String title,
    required String description,
    required SubscriptionTier recommendedTier,
    VoidCallback? onUpgrade,
  }) {
    final suggestion = UpgradeSuggestion(
      id: promptKey,
      title: title,
      description: description,
      recommendedTier: recommendedTier,
      priority: UpgradePriority.medium,
      triggerContext: 'manual',
    );

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => GentleUpgradeSuggestion(
        promptKey: promptKey,
        suggestion: suggestion,
        isInline: false,
        onUpgrade: onUpgrade ?? () => _navigateToSubscription(),
      ),
    );
  }

  /// Navigate to subscription management
  void _navigateToSubscription() {
    Navigator.of(context).pushNamed('/subscription-management');
  }

  /// Navigate to subscription benefits page with context
  void navigateToSubscriptionBenefits({
    SubscriptionTier? highlightedTier,
    String? fromContext,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SubscriptionBenefitsPage(
          highlightedTier: highlightedTier,
          fromContext: fromContext,
        ),
      ),
    );
  }
}

/// Widget that wraps features with automatic discovery prompts
class FeatureWithDiscovery extends ConsumerWidget {
  final Widget child;
  final String featureKey;
  final String title;
  final String description;
  final IconData icon;
  final SubscriptionTier requiredTier;
  final bool showOnFirstAccess;

  const FeatureWithDiscovery({
    super.key,
    required this.child,
    required this.featureKey,
    required this.title,
    required this.description,
    required this.icon,
    required this.requiredTier,
    this.showOnFirstAccess = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscriptionAsync = ref.watch(subscriptionProvider);

    return subscriptionAsync.when(
      data: (subscription) {
        // Only show discovery for users who don't have access
        if (subscription.tier.index >= requiredTier.index) {
          return child;
        }

        if (showOnFirstAccess) {
          // Check if we should show discovery prompt
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _checkAndShowDiscovery(context, ref);
          });
        }

        return child;
      },
      loading: () => child,
      error: (_, _) => child,
    );
  }

  void _checkAndShowDiscovery(BuildContext context, WidgetRef ref) async {
    final shouldShow = await ref.read(
      shouldShowFeatureDiscoveryProvider(featureKey).future,
    );

    if (shouldShow && context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) => FeatureDiscoveryPrompt(
          featureKey: featureKey,
          title: title,
          description: description,
          icon: icon,
          requiredTier: requiredTier,
          onUpgrade: () => _navigateToSubscription(context),
          onDismiss: () => Navigator.of(context).pop(),
        ),
      );
    }
  }

  void _navigateToSubscription(BuildContext context) {
    Navigator.of(context).pushNamed('/subscription-management');
  }
}

/// Widget that shows contextual upgrade hints
class ContextualUpgradeHint extends ConsumerWidget {
  final String context;
  final String message;
  final SubscriptionTier recommendedTier;
  final bool showAsSnackBar;

  const ContextualUpgradeHint({
    super.key,
    required this.context,
    required this.message,
    required this.recommendedTier,
    this.showAsSnackBar = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscriptionAsync = ref.watch(subscriptionProvider);

    return subscriptionAsync.when(
      data: (subscription) {
        // Only show for users who could benefit from upgrade
        if (subscription.tier.index >= recommendedTier.index) {
          return const SizedBox.shrink();
        }

        if (showAsSnackBar) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showUpgradeSnackBar(context, ref);
          });
          return const SizedBox.shrink();
        }

        return _buildInlineHint(context, ref);
      },
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }

  Widget _buildInlineHint(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.lightbulb_outline,
            size: 16,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          TextButton(
            onPressed: () => _navigateToSubscription(context),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: const Size(0, 0),
            ),
            child: Text(
              'Upgrade',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showUpgradeSnackBar(BuildContext context, WidgetRef ref) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        action: SnackBarAction(
          label: 'Upgrade',
          onPressed: () => _navigateToSubscription(context),
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _navigateToSubscription(BuildContext context) {
    Navigator.of(context).pushNamed('/subscription-management');
  }
}
