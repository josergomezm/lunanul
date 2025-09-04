import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/enums.dart';
import '../models/subscription_status.dart';
import '../providers/subscription_provider.dart';
import '../providers/usage_tracking_provider.dart' as usage_provider;
import '../pages/subscription_settings_page.dart';

/// Widget that provides subscription settings and management within the main settings page
class SubscriptionSettingsWidget extends ConsumerWidget {
  const SubscriptionSettingsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscriptionAsync = ref.watch(subscriptionProvider);
    final theme = Theme.of(context);

    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.diamond, color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                Text(
                  'Subscription',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            subscriptionAsync.when(
              data: (subscription) =>
                  _buildSubscriptionContent(context, ref, subscription),
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (error, stack) => _buildErrorContent(context, ref),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionContent(
    BuildContext context,
    WidgetRef ref,
    SubscriptionStatus subscription,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Current tier status
        _buildCurrentTierStatus(context, subscription),
        const SizedBox(height: 16),

        // Quick usage overview for free tier
        if (subscription.tier == SubscriptionTier.seeker)
          _buildQuickUsageOverview(context, ref),

        // Action buttons
        const SizedBox(height: 16),
        _buildActionButtons(context, ref, subscription),
      ],
    );
  }

  Widget _buildCurrentTierStatus(
    BuildContext context,
    SubscriptionStatus subscription,
  ) {
    final theme = Theme.of(context);
    final tierInfo = _getTierInfo(subscription.tier);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              tierInfo.icon,
              color: theme.colorScheme.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${tierInfo.name} Plan',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: subscription.isActive
                            ? Colors.green.withValues(alpha: 0.2)
                            : Colors.orange.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        subscription.isActive ? 'Active' : 'Inactive',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: subscription.isActive
                              ? Colors.green.shade700
                              : Colors.orange.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (subscription.tier != SubscriptionTier.seeker) ...[
                      const SizedBox(width: 8),
                      Text(
                        tierInfo.price,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          if (subscription.tier != SubscriptionTier.seeker &&
              subscription.expirationDate != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Renews',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  _formatRenewalDate(subscription.expirationDate!),
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildQuickUsageOverview(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final usageAsync = ref.watch(usage_provider.usageCountsProvider);

    return usageAsync.when(
      data: (usage) {
        final manualInterpretations = usage['manual_interpretations'] ?? 0;
        final readings = usage['readings'] ?? 0;
        final manualLimit = 5;
        final readingLimit = 3;

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withValues(
              alpha: 0.5,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'This Month\'s Usage',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildQuickUsageItem(
                      context,
                      'Interpretations',
                      manualInterpretations,
                      manualLimit,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildQuickUsageItem(
                      context,
                      'Readings',
                      readings,
                      readingLimit,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (error, stack) => const SizedBox.shrink(),
    );
  }

  Widget _buildQuickUsageItem(
    BuildContext context,
    String label,
    int used,
    int limit,
  ) {
    final theme = Theme.of(context);
    final progress = used / limit;

    Color progressColor;
    if (progress >= 1.0) {
      progressColor = theme.colorScheme.error;
    } else if (progress >= 0.8) {
      progressColor = Colors.orange;
    } else {
      progressColor = theme.colorScheme.primary;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '$used/$limit',
              style: theme.textTheme.labelSmall?.copyWith(
                color: progressColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    WidgetRef ref,
    SubscriptionStatus subscription,
  ) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _navigateToFullManagement(context),
            icon: const Icon(Icons.settings),
            label: const Text('Manage Subscription'),
          ),
        ),
        const SizedBox(height: 8),
        if (subscription.tier == SubscriptionTier.seeker)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showUpgradeOptions(context, ref),
              icon: const Icon(Icons.upgrade),
              label: const Text('Upgrade Plan'),
            ),
          )
        else ...[
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showModifySubscription(context, ref),
                  icon: const Icon(Icons.edit),
                  label: const Text('Modify'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showCancelSubscription(context, ref),
                  icon: const Icon(Icons.cancel),
                  label: const Text('Cancel'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.error,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildErrorContent(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        Icon(
          Icons.error_outline,
          color: Theme.of(context).colorScheme.error,
          size: 32,
        ),
        const SizedBox(height: 8),
        Text(
          'Unable to load subscription information',
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => ref.invalidate(subscriptionProvider),
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ),
      ],
    );
  }

  void _navigateToFullManagement(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const SubscriptionSettingsPage()),
    );
  }

  void _showUpgradeOptions(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Upgrade Your Plan',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Unlock deeper insights and personalized guidance',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: [
                    _buildUpgradeOption(
                      context,
                      ref,
                      SubscriptionTier.mystic,
                      'Complete spiritual guidance experience',
                      [
                        'Unlimited AI readings',
                        'All tarot spreads',
                        'Access to all guides',
                        'Unlimited interpretations',
                        'Ad-free experience',
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildUpgradeOption(
                      context,
                      ref,
                      SubscriptionTier.oracle,
                      'Premium features and early access',
                      [
                        'All Mystic benefits',
                        'AI-generated audio readings',
                        'Personalized journal prompts',
                        'Advanced spreads',
                        'Custom themes',
                        'Early access to features',
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUpgradeOption(
    BuildContext context,
    WidgetRef ref,
    SubscriptionTier tier,
    String description,
    List<String> benefits,
  ) {
    final theme = Theme.of(context);
    final tierInfo = _getTierInfo(tier);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(tierInfo.icon, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  tierInfo.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Text(
                  tierInfo.price,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            ...benefits.map(
              (benefit) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Icon(
                      Icons.check,
                      size: 16,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(benefit, style: theme.textTheme.bodySmall),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _purchaseSubscription(context, ref, tier),
                child: Text('Upgrade to ${tierInfo.name}'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showModifySubscription(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modify Subscription'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Choose how you\'d like to modify your subscription:'),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.upgrade),
              title: const Text('Upgrade Plan'),
              subtitle: const Text('Switch to a higher tier'),
              onTap: () {
                Navigator.of(context).pop();
                _showUpgradeOptions(context, ref);
              },
            ),
            ListTile(
              leading: const Icon(Icons.pause),
              title: const Text('Pause Subscription'),
              subtitle: const Text('Temporarily pause billing'),
              onTap: () {
                Navigator.of(context).pop();
                _pauseSubscription(context, ref);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showCancelSubscription(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Subscription'),
        content: const Text(
          'Are you sure you want to cancel your subscription? '
          'You\'ll continue to have access until the end of your current billing period, '
          'after which you\'ll be moved to the free Seeker plan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Keep Subscription'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _cancelSubscription(context, ref);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: const Text('Cancel Subscription'),
          ),
        ],
      ),
    );
  }

  void _purchaseSubscription(
    BuildContext context,
    WidgetRef ref,
    SubscriptionTier tier,
  ) {
    Navigator.of(context).pop(); // Close the upgrade sheet

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Processing subscription...'),
          ],
        ),
      ),
    );

    // Simulate subscription purchase
    Future.delayed(const Duration(seconds: 2), () {
      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading dialog

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Successfully upgraded to ${_getTierInfo(tier).name}!',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }

      // Refresh subscription status
      final _ = ref.refresh(subscriptionProvider);
    });
  }

  void _pauseSubscription(BuildContext context, WidgetRef ref) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Subscription pause requested. You\'ll receive confirmation via email.',
        ),
      ),
    );
  }

  void _cancelSubscription(BuildContext context, WidgetRef ref) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Subscription cancellation requested. Access continues until billing period ends.',
        ),
        backgroundColor: Colors.orange,
      ),
    );
  }

  String _formatRenewalDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now).inDays;

    if (difference < 0) {
      return 'Expired';
    } else if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Tomorrow';
    } else if (difference < 7) {
      return 'In $difference days';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  _TierInfo _getTierInfo(SubscriptionTier tier) {
    switch (tier) {
      case SubscriptionTier.seeker:
        return _TierInfo(name: 'Seeker', price: 'Free', icon: Icons.explore);
      case SubscriptionTier.mystic:
        return _TierInfo(
          name: 'Mystic',
          price: '\$4.99/month',
          icon: Icons.auto_awesome,
        );
      case SubscriptionTier.oracle:
        return _TierInfo(
          name: 'Oracle',
          price: '\$9.99/month',
          icon: Icons.diamond,
        );
    }
  }
}

class _TierInfo {
  final String name;
  final String price;
  final IconData icon;

  _TierInfo({required this.name, required this.price, required this.icon});
}
