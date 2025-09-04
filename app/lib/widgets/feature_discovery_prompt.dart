import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/enums.dart';
import '../providers/subscription_onboarding_provider.dart';

/// Widget that shows feature discovery prompts to highlight premium benefits
class FeatureDiscoveryPrompt extends ConsumerWidget {
  final String featureKey;
  final String title;
  final String description;
  final IconData icon;
  final SubscriptionTier requiredTier;
  final VoidCallback? onUpgrade;
  final VoidCallback? onDismiss;
  final Widget? child;

  const FeatureDiscoveryPrompt({
    super.key,
    required this.featureKey,
    required this.title,
    required this.description,
    required this.icon,
    required this.requiredTier,
    this.onUpgrade,
    this.onDismiss,
    this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shouldShowAsync = ref.watch(
      shouldShowFeatureDiscoveryProvider(featureKey),
    );

    return shouldShowAsync.when(
      data: (shouldShow) {
        if (!shouldShow) {
          return child ?? const SizedBox.shrink();
        }
        return _buildDiscoveryOverlay(context, ref);
      },
      loading: () => child ?? const SizedBox.shrink(),
      error: (_, _) => child ?? const SizedBox.shrink(),
    );
  }

  Widget _buildDiscoveryOverlay(BuildContext context, WidgetRef ref) {
    return Stack(
      children: [
        // Dimmed background
        Container(color: Colors.black.withValues(alpha: 0.6)),
        // Discovery prompt
        Center(
          child: Container(
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(context),
                const SizedBox(height: 20),
                _buildContent(context),
                const SizedBox(height: 24),
                _buildActions(context, ref),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Icon(icon, size: 40, color: Colors.white),
        ),
        const SizedBox(height: 16),
        Text(
          title,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Text(
          description,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(Icons.star, color: theme.colorScheme.primary, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Available with ${_getTierName(requiredTier)} subscription',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => _handleDismiss(ref),
            child: const Text('Maybe Later'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: () => _handleUpgrade(ref),
            child: Text('Upgrade to ${_getTierName(requiredTier)}'),
          ),
        ),
      ],
    );
  }

  void _handleUpgrade(WidgetRef ref) {
    // Mark feature as discovered
    ref.read(onboardingStateProvider.notifier).markFeatureDiscoverySeen();
    onUpgrade?.call();
  }

  void _handleDismiss(WidgetRef ref) {
    // Mark feature as discovered (even if dismissed)
    ref.read(onboardingStateProvider.notifier).markFeatureDiscoverySeen();
    onDismiss?.call();
  }

  String _getTierName(SubscriptionTier tier) {
    switch (tier) {
      case SubscriptionTier.seeker:
        return 'Seeker';
      case SubscriptionTier.mystic:
        return 'Mystic';
      case SubscriptionTier.oracle:
        return 'Oracle';
    }
  }
}

/// Specific feature discovery prompts for common features
class AdvancedSpreadsDiscovery extends FeatureDiscoveryPrompt {
  const AdvancedSpreadsDiscovery({
    super.key,
    super.onUpgrade,
    super.onDismiss,
    super.child,
  }) : super(
         featureKey: 'advanced_spreads',
         title: 'Unlock Advanced Spreads',
         description:
             'Discover deeper insights with Celtic Cross, Relationship, and Career spreads. Perfect for complex questions and detailed guidance.',
         icon: Icons.auto_awesome,
         requiredTier: SubscriptionTier.mystic,
       );
}

class AllGuidesDiscovery extends FeatureDiscoveryPrompt {
  const AllGuidesDiscovery({
    super.key,
    super.onUpgrade,
    super.onDismiss,
    super.child,
  }) : super(
         featureKey: 'all_guides',
         title: 'Meet All Four Guides',
         description:
             'Connect with The Sage and The Visionary for wisdom and inspiration. Each guide offers unique perspectives on your spiritual journey.',
         icon: Icons.people,
         requiredTier: SubscriptionTier.mystic,
       );
}

class UnlimitedJournalDiscovery extends FeatureDiscoveryPrompt {
  const UnlimitedJournalDiscovery({
    super.key,
    super.onUpgrade,
    super.onDismiss,
    super.child,
  }) : super(
         featureKey: 'unlimited_journal',
         title: 'Unlimited Journal Storage',
         description:
             'Save all your readings and track your spiritual growth over time. Never lose a meaningful insight again.',
         icon: Icons.book,
         requiredTier: SubscriptionTier.mystic,
       );
}

class AudioReadingsDiscovery extends FeatureDiscoveryPrompt {
  const AudioReadingsDiscovery({
    super.key,
    super.onUpgrade,
    super.onDismiss,
    super.child,
  }) : super(
         featureKey: 'audio_readings',
         title: 'AI-Generated Audio Readings',
         description:
             'Experience your readings in a new way with personalized audio interpretations in your chosen guide\'s voice.',
         icon: Icons.headphones,
         requiredTier: SubscriptionTier.oracle,
       );
}

class PersonalizedPromptsDiscovery extends FeatureDiscoveryPrompt {
  const PersonalizedPromptsDiscovery({
    super.key,
    super.onUpgrade,
    super.onDismiss,
    super.child,
  }) : super(
         featureKey: 'personalized_prompts',
         title: 'Personalized Journal Prompts',
         description:
             'Receive thoughtful reflection questions tailored to your specific reading and cards drawn.',
         icon: Icons.psychology,
         requiredTier: SubscriptionTier.oracle,
       );
}
