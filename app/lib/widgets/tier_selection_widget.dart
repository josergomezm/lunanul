import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/enums.dart';
import '../providers/subscription_provider.dart';

/// Widget for selecting subscription tiers with pricing and feature highlights
class TierSelectionWidget extends ConsumerWidget {
  final SubscriptionTier currentTier;
  final bool showCurrentTierBadge;

  const TierSelectionWidget({
    super.key,
    required this.currentTier,
    this.showCurrentTierBadge = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        _buildTierCard(context, ref, SubscriptionTier.mystic, isPopular: true),
        const SizedBox(height: 16),
        _buildTierCard(context, ref, SubscriptionTier.oracle),
        const SizedBox(height: 24),
        _buildFreeTierInfo(context),
      ],
    );
  }

  Widget _buildTierCard(
    BuildContext context,
    WidgetRef ref,
    SubscriptionTier tier, {
    bool isPopular = false,
  }) {
    final theme = Theme.of(context);
    final tierInfo = _getTierInfo(tier);
    final isCurrentTier = currentTier == tier;
    final canUpgrade = _canUpgradeTo(tier);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPopular
              ? theme.colorScheme.primary
              : theme.colorScheme.outline.withValues(alpha: 0.3),
          width: isPopular ? 2 : 1,
        ),
        gradient: isPopular
            ? LinearGradient(
                colors: [
                  theme.colorScheme.primaryContainer.withValues(alpha: 0.1),
                  theme.colorScheme.primaryContainer.withValues(alpha: 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
      ),
      child: Column(
        children: [
          if (isPopular)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
              ),
              child: Text(
                'Most Popular',
                textAlign: TextAlign.center,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer.withValues(
                          alpha: 0.3,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        tierInfo.icon,
                        color: theme.colorScheme.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                tierInfo.name,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (isCurrentTier && showCurrentTierBadge) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.secondary,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'Current',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: theme.colorScheme.onSecondary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: tierInfo.price,
                                  style: theme.textTheme.headlineMedium
                                      ?.copyWith(
                                        color: theme.colorScheme.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                TextSpan(
                                  text: tierInfo.period,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  tierInfo.description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                ...tierInfo.features.map(
                  (feature) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: theme.colorScheme.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            feature,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isCurrentTier
                        ? null
                        : canUpgrade
                        ? () => _handleSubscribe(context, ref, tier)
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isPopular
                          ? theme.colorScheme.primary
                          : null,
                      foregroundColor: isPopular
                          ? theme.colorScheme.onPrimary
                          : null,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      isCurrentTier
                          ? 'Current Plan'
                          : canUpgrade
                          ? 'Upgrade to ${tierInfo.name}'
                          : 'Downgrade to ${tierInfo.name}',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFreeTierInfo(BuildContext context) {
    final theme = Theme.of(context);
    final isCurrentTier = currentTier == SubscriptionTier.seeker;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.explore, color: theme.colorScheme.onSurfaceVariant),
              const SizedBox(width: 8),
              Text(
                'Seeker (Free)',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (isCurrentTier && showCurrentTierBadge) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Current',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Perfect for exploring tarot and building daily spiritual habits',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children:
                [
                      'Daily card readings',
                      'Basic spreads',
                      '2 spiritual guides',
                      '5 interpretations/month',
                    ]
                    .map(
                      (feature) => Chip(
                        label: Text(feature, style: theme.textTheme.labelSmall),
                        backgroundColor:
                            theme.colorScheme.surfaceContainerHighest,
                      ),
                    )
                    .toList(),
          ),
        ],
      ),
    );
  }

  bool _canUpgradeTo(SubscriptionTier tier) {
    return tier.index > currentTier.index;
  }

  void _handleSubscribe(
    BuildContext context,
    WidgetRef ref,
    SubscriptionTier tier,
  ) {
    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Upgrade to ${_getTierName(tier)}'),
        content: Text(
          'Are you ready to unlock enhanced spiritual guidance with ${_getTierName(tier)}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _processPurchase(ref, tier);
            },
            child: const Text('Subscribe'),
          ),
        ],
      ),
    );
  }

  void _processPurchase(WidgetRef ref, SubscriptionTier tier) {
    // Trigger subscription purchase through provider
    ref
        .read(subscriptionProvider.notifier)
        .purchaseSubscription(
          tier == SubscriptionTier.mystic ? 'mystic_monthly' : 'oracle_monthly',
        );
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

  _TierInfo _getTierInfo(SubscriptionTier tier) {
    switch (tier) {
      case SubscriptionTier.mystic:
        return _TierInfo(
          name: 'Mystic',
          price: '\$4.99',
          period: '/month',
          description:
              'Complete tarot experience with unlimited access to all core features',
          icon: Icons.auto_awesome,
          features: [
            'Unlimited AI readings with all spreads',
            'Access to all four spiritual guides',
            'Unlimited manual interpretations',
            'Unlimited readings',
            'Ad-free experience',
            'Reading statistics and insights',
          ],
        );
      case SubscriptionTier.oracle:
        return _TierInfo(
          name: 'Oracle',
          price: '\$9.99',
          period: '/month',
          description:
              'Premium experience with advanced features and personalization',
          icon: Icons.diamond,
          features: [
            'Everything in Mystic tier',
            'AI-generated audio readings',
            'Personalized journal prompts',
            'Advanced and specialized spreads',
            'Custom themes and card backs',
            'Early access to new features',
            'Priority customer support',
          ],
        );
      case SubscriptionTier.seeker:
        return _TierInfo(
          name: 'Seeker',
          price: 'Free',
          period: '',
          description:
              'Essential daily tarot features to start your spiritual journey',
          icon: Icons.explore,
          features: [
            'Daily card readings',
            'Basic spreads (1-3 cards)',
            'Two spiritual guides',
            '5 manual interpretations per month',
            '3 readings per month',
          ],
        );
    }
  }
}

class _TierInfo {
  final String name;
  final String price;
  final String period;
  final String description;
  final IconData icon;
  final List<String> features;

  _TierInfo({
    required this.name,
    required this.price,
    required this.period,
    required this.description,
    required this.icon,
    required this.features,
  });
}
