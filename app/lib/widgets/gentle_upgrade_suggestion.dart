import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/enums.dart';
import '../services/subscription_onboarding_service.dart';
import '../providers/subscription_onboarding_provider.dart';

/// Widget that displays gentle upgrade suggestions throughout the app
class GentleUpgradeSuggestion extends ConsumerWidget {
  final String promptKey;
  final UpgradeSuggestion suggestion;
  final bool isInline;
  final VoidCallback? onUpgrade;
  final VoidCallback? onDismiss;

  const GentleUpgradeSuggestion({
    super.key,
    required this.promptKey,
    required this.suggestion,
    this.isInline = true,
    this.onUpgrade,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shouldShowAsync = ref.watch(
      shouldShowUpgradePromptProvider(promptKey),
    );

    return shouldShowAsync.when(
      data: (shouldShow) {
        if (!shouldShow) return const SizedBox.shrink();
        return isInline
            ? _buildInlinePrompt(context, ref)
            : _buildModalPrompt(context, ref);
      },
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }

  Widget _buildInlinePrompt(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
            theme.colorScheme.secondaryContainer.withValues(alpha: 0.3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getIconForPriority(suggestion.priority),
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  suggestion.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => _handleDismiss(ref),
                icon: Icon(
                  Icons.close,
                  size: 18,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            suggestion.description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _handleDismiss(ref),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: theme.colorScheme.outline),
                  ),
                  child: const Text('Not Now'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () => _handleUpgrade(ref),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                  ),
                  child: Text(
                    'Upgrade to ${_getTierName(suggestion.recommendedTier)}',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModalPrompt(BuildContext context, WidgetRef ref) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildModalHeader(context),
            const SizedBox(height: 16),
            _buildModalContent(context),
            const SizedBox(height: 24),
            _buildModalActions(context, ref),
          ],
        ),
      ),
    );
  }

  Widget _buildModalHeader(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: theme.colorScheme.primaryContainer,
          ),
          child: Icon(
            _getIconForTier(suggestion.recommendedTier),
            color: theme.colorScheme.primary,
            size: 30,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          suggestion.title,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildModalContent(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Text(
          suggestion.description,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.star, color: theme.colorScheme.primary, size: 16),
              const SizedBox(width: 6),
              Text(
                '${_getTierName(suggestion.recommendedTier)} Feature',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildModalActions(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _handleDismiss(ref);
            },
            child: const Text('Maybe Later'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _handleUpgrade(ref);
            },
            child: Text('Upgrade Now'),
          ),
        ),
      ],
    );
  }

  void _handleUpgrade(WidgetRef ref) {
    ref.read(onboardingStateProvider.notifier).dismissUpgradePrompt(promptKey);
    onUpgrade?.call();
  }

  void _handleDismiss(WidgetRef ref) {
    ref.read(onboardingStateProvider.notifier).dismissUpgradePrompt(promptKey);
    onDismiss?.call();
  }

  IconData _getIconForPriority(UpgradePriority priority) {
    switch (priority) {
      case UpgradePriority.high:
        return Icons.priority_high;
      case UpgradePriority.medium:
        return Icons.star_outline;
      case UpgradePriority.low:
        return Icons.lightbulb_outline;
    }
  }

  IconData _getIconForTier(SubscriptionTier tier) {
    switch (tier) {
      case SubscriptionTier.seeker:
        return Icons.explore;
      case SubscriptionTier.mystic:
        return Icons.auto_awesome;
      case SubscriptionTier.oracle:
        return Icons.diamond;
    }
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

/// Widget that shows personalized upgrade suggestions based on user behavior
class PersonalizedUpgradeSuggestions extends ConsumerWidget {
  final bool showAsCards;

  const PersonalizedUpgradeSuggestions({super.key, this.showAsCards = true});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final suggestionsAsync = ref.watch(upgradeSuggestionsProvider);

    return suggestionsAsync.when(
      data: (suggestions) {
        if (suggestions.isEmpty) return const SizedBox.shrink();

        return showAsCards
            ? _buildSuggestionCards(context, ref, suggestions)
            : _buildSuggestionList(context, ref, suggestions);
      },
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }

  Widget _buildSuggestionCards(
    BuildContext context,
    WidgetRef ref,
    List<UpgradeSuggestion> suggestions,
  ) {
    return Column(
      children: suggestions
          .take(2) // Show max 2 suggestions as cards
          .map(
            (suggestion) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: GentleUpgradeSuggestion(
                promptKey: suggestion.id,
                suggestion: suggestion,
                isInline: true,
                onUpgrade: () => _navigateToSubscription(context),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildSuggestionList(
    BuildContext context,
    WidgetRef ref,
    List<UpgradeSuggestion> suggestions,
  ) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Personalized for You',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        ...suggestions.map(
          (suggestion) => ListTile(
            leading: Icon(
              _getIconForTier(suggestion.recommendedTier),
              color: theme.colorScheme.primary,
            ),
            title: Text(suggestion.title),
            subtitle: Text(suggestion.description),
            trailing: TextButton(
              onPressed: () => _navigateToSubscription(context),
              child: const Text('Upgrade'),
            ),
            onTap: () => _navigateToSubscription(context),
          ),
        ),
      ],
    );
  }

  void _navigateToSubscription(BuildContext context) {
    Navigator.of(context).pushNamed('/subscription-management');
  }

  IconData _getIconForTier(SubscriptionTier tier) {
    switch (tier) {
      case SubscriptionTier.seeker:
        return Icons.explore;
      case SubscriptionTier.mystic:
        return Icons.auto_awesome;
      case SubscriptionTier.oracle:
        return Icons.diamond;
    }
  }
}
