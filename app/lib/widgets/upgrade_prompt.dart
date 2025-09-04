import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/enums.dart';

/// Widget that displays subscription upgrade options with tier comparison and benefits
class UpgradePrompt extends ConsumerWidget {
  final String featureContext;
  final SubscriptionTier recommendedTier;
  final VoidCallback? onDismiss;
  final bool showFullComparison;

  const UpgradePrompt({
    super.key,
    required this.featureContext,
    this.recommendedTier = SubscriptionTier.mystic,
    this.onDismiss,
    this.showFullComparison = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: 16),
          _buildFeatureContext(context),
          const SizedBox(height: 24),
          if (showFullComparison) ...[
            _buildTierComparison(context),
            const SizedBox(height: 24),
          ] else ...[
            _buildRecommendedTier(context),
            const SizedBox(height: 24),
          ],
          _buildActionButtons(context, ref),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.star_border,
          color: Theme.of(context).colorScheme.primary,
          size: 28,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'Unlock Your Spiritual Journey',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        if (onDismiss != null)
          IconButton(
            onPressed: onDismiss,
            icon: const Icon(Icons.close),
            iconSize: 20,
          ),
      ],
    );
  }

  Widget _buildFeatureContext(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: Theme.of(context).colorScheme.primary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              featureContext,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendedTier(BuildContext context) {
    return _buildTierCard(context, recommendedTier, isRecommended: true);
  }

  Widget _buildTierComparison(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose Your Path',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildTierCard(context, SubscriptionTier.mystic)),
            const SizedBox(width: 16),
            Expanded(child: _buildTierCard(context, SubscriptionTier.oracle)),
          ],
        ),
      ],
    );
  }

  Widget _buildTierCard(
    BuildContext context,
    SubscriptionTier tier, {
    bool isRecommended = false,
  }) {
    final theme = Theme.of(context);
    final tierInfo = _getTierInfo(tier);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isRecommended
            ? theme.colorScheme.primaryContainer.withValues(alpha: 0.2)
            : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: isRecommended
            ? Border.all(color: theme.colorScheme.primary, width: 2)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(tierInfo.icon, color: theme.colorScheme.primary, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  tierInfo.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (isRecommended)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Recommended',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            tierInfo.price,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...tierInfo.benefits.map(
            (benefit) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.check_circle,
                    color: theme.colorScheme.primary,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(benefit, style: theme.textTheme.bodySmall),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        if (onDismiss != null)
          Expanded(
            child: OutlinedButton(
              onPressed: onDismiss,
              child: const Text('Maybe Later'),
            ),
          ),
        if (onDismiss != null) const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: () => _handleUpgrade(context, ref),
            child: Text(showFullComparison ? 'View Plans' : 'Upgrade Now'),
          ),
        ),
      ],
    );
  }

  void _handleUpgrade(BuildContext context, WidgetRef ref) {
    // Navigate to subscription management screen
    Navigator.of(context).pushNamed('/subscription-management');
  }

  _TierInfo _getTierInfo(SubscriptionTier tier) {
    switch (tier) {
      case SubscriptionTier.mystic:
        return _TierInfo(
          name: 'Mystic',
          price: '\$4.99/month',
          icon: Icons.auto_awesome,
          benefits: [
            'Unlimited AI readings',
            'All tarot spreads',
            'All four spiritual guides',
            'Unlimited readings',
            'Ad-free experience',
            'Reading statistics',
          ],
        );
      case SubscriptionTier.oracle:
        return _TierInfo(
          name: 'Oracle',
          price: '\$9.99/month',
          icon: Icons.diamond,
          benefits: [
            'Everything in Mystic',
            'AI-generated audio readings',
            'Personalized journal prompts',
            'Advanced tarot spreads',
            'Custom themes & card backs',
            'Early access to new features',
          ],
        );
      case SubscriptionTier.seeker:
        return _TierInfo(
          name: 'Seeker',
          price: 'Free',
          icon: Icons.explore,
          benefits: [
            'Daily card readings',
            'Basic spreads (1-3 cards)',
            'Two spiritual guides',
            '5 manual interpretations/month',
            '3 readings/month',
          ],
        );
    }
  }
}

class _TierInfo {
  final String name;
  final String price;
  final IconData icon;
  final List<String> benefits;

  _TierInfo({
    required this.name,
    required this.price,
    required this.icon,
    required this.benefits,
  });
}
