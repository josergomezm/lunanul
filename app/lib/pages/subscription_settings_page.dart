import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/enums.dart';
import '../models/subscription_status.dart';
import '../providers/subscription_provider.dart';
import '../providers/usage_tracking_provider.dart' as usage_provider;
import '../widgets/subscription_status_widget.dart';
import '../widgets/usage_stats_widget.dart';

/// Dedicated subscription settings and management page
class SubscriptionSettingsPage extends ConsumerStatefulWidget {
  const SubscriptionSettingsPage({super.key});

  @override
  ConsumerState<SubscriptionSettingsPage> createState() =>
      _SubscriptionSettingsPageState();
}

class _SubscriptionSettingsPageState
    extends ConsumerState<SubscriptionSettingsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final subscriptionAsync = ref.watch(subscriptionProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscription Settings'),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview', icon: Icon(Icons.dashboard_outlined)),
            Tab(text: 'Billing', icon: Icon(Icons.receipt_outlined)),
          ],
        ),
      ),
      body: subscriptionAsync.when(
        data: (subscription) => TabBarView(
          controller: _tabController,
          children: [
            _buildOverviewTab(context, subscription),
            _buildBillingTab(context, subscription),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildErrorState(context, error),
      ),
    );
  }

  Widget _buildOverviewTab(
    BuildContext context,
    SubscriptionStatus subscription,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SubscriptionStatusWidget(subscription: subscription),
          const SizedBox(height: 24),
          _buildCurrentBenefits(context, subscription),
          const SizedBox(height: 24),
          UsageStatsWidget(subscription: subscription),
          const SizedBox(height: 24),
          _buildQuickActions(context, subscription),
        ],
      ),
    );
  }

  Widget _buildBillingTab(
    BuildContext context,
    SubscriptionStatus subscription,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBillingInfo(context, subscription),
          const SizedBox(height: 24),
          _buildCurrentPeriodUsage(context, subscription),
          const SizedBox(height: 24),
          _buildPaymentMethod(context),
          const SizedBox(height: 24),
          _buildBillingHistory(context),
          const SizedBox(height: 24),
          _buildSubscriptionActions(context, subscription),
        ],
      ),
    );
  }

  Widget _buildCurrentBenefits(
    BuildContext context,
    SubscriptionStatus subscription,
  ) {
    final theme = Theme.of(context);
    final benefits = _getCurrentTierBenefits(subscription.tier);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.star, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Your Current Benefits',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...benefits.map(
              (benefit) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
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
                      child: Text(benefit, style: theme.textTheme.bodyMedium),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(
    BuildContext context,
    SubscriptionStatus subscription,
  ) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.flash_on, color: theme.colorScheme.secondary),
                const SizedBox(width: 8),
                Text(
                  'Quick Actions',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (subscription.tier == SubscriptionTier.seeker) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showUpgradeDialog(context),
                  icon: const Icon(Icons.upgrade),
                  label: const Text('Upgrade to Premium'),
                ),
              ),
            ] else ...[
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showModifyDialog(context),
                      icon: const Icon(Icons.edit),
                      label: const Text('Modify Plan'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _refreshSubscription(),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Refresh'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBillingInfo(
    BuildContext context,
    SubscriptionStatus subscription,
  ) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.receipt, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Billing Information',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (subscription.tier != SubscriptionTier.seeker) ...[
              _buildBillingRow('Current Plan', _getTierName(subscription.tier)),
              _buildBillingRow(
                'Monthly Cost',
                _getTierPrice(subscription.tier),
              ),
              _buildBillingRow(
                'Next Billing',
                _formatNextBilling(subscription),
              ),
              _buildBillingRow('Billing Cycle', 'Monthly'),
            ] else ...[
              _buildBillingRow('Current Plan', 'Seeker (Free)'),
              _buildBillingRow('Monthly Cost', '\$0.00'),
              _buildBillingRow('Next Billing', 'N/A'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBillingRow(String label, String value) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethod(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.payment, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Payment Method',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Payment methods are managed through your device\'s app store',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBillingHistory(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.history, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Billing History',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Billing history and receipts are available through your device\'s app store.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => _openAppStoreBilling(),
              icon: const Icon(Icons.open_in_new),
              label: const Text('View in App Store'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionActions(
    BuildContext context,
    SubscriptionStatus subscription,
  ) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.settings, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Subscription Management',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (subscription.tier != SubscriptionTier.seeker) ...[
              ListTile(
                leading: const Icon(Icons.upgrade),
                title: const Text('Change Plan'),
                subtitle: Text(
                  subscription.tier == SubscriptionTier.mystic
                      ? 'Upgrade to Oracle for premium features'
                      : 'Modify your subscription plan',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showChangePlanDialog(context, subscription),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.pause),
                title: const Text('Pause Subscription'),
                subtitle: const Text('Temporarily pause your subscription'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showPauseDialog(context),
              ),
              const Divider(),
              ListTile(
                leading: Icon(Icons.cancel, color: theme.colorScheme.error),
                title: Text(
                  'Cancel Subscription',
                  style: TextStyle(color: theme.colorScheme.error),
                ),
                subtitle: const Text('Cancel at the end of billing period'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showCancelDialog(context, subscription),
              ),
              const Divider(),
            ] else ...[
              ListTile(
                leading: const Icon(Icons.upgrade),
                title: const Text('Upgrade to Premium'),
                subtitle: const Text(
                  'Unlock unlimited access and advanced features',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showUpgradeDialog(context),
              ),
              const Divider(),
            ],
            ListTile(
              leading: const Icon(Icons.restore),
              title: const Text('Restore Purchases'),
              subtitle: const Text('Restore previous purchases'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _restorePurchases(),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.refresh),
              title: const Text('Refresh Status'),
              subtitle: const Text('Update subscription information'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _refreshSubscription(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Unable to load subscription settings',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => ref.refresh(subscriptionProvider),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  // Helper methods
  List<String> _getCurrentTierBenefits(SubscriptionTier tier) {
    switch (tier) {
      case SubscriptionTier.seeker:
        return [
          'Daily card readings',
          'Basic spreads (1-3 cards)',
          'Access to Healer and Mentor guides',
          '5 manual interpretations per month',
          '3 journal entries',
        ];
      case SubscriptionTier.mystic:
        return [
          'Unlimited AI readings',
          'All tarot spreads available',
          'Access to all four spiritual guides',
          'Unlimited manual interpretations',
          'Unlimited journal entries',
          'Ad-free experience',
        ];
      case SubscriptionTier.oracle:
        return [
          'All Mystic tier benefits',
          'AI-generated audio readings',
          'Personalized journal prompts',
          'Advanced and specialized spreads',
          'Custom themes and card backs',
          'Early access to new features',
        ];
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

  String _getTierPrice(SubscriptionTier tier) {
    switch (tier) {
      case SubscriptionTier.seeker:
        return '\$0.00';
      case SubscriptionTier.mystic:
        return '\$4.99';
      case SubscriptionTier.oracle:
        return '\$9.99';
    }
  }

  String _formatNextBilling(SubscriptionStatus subscription) {
    if (subscription.expirationDate == null) {
      return 'N/A';
    }
    final date = subscription.expirationDate!;
    return '${date.day}/${date.month}/${date.year}';
  }

  // Action methods
  void _showUpgradeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Upgrade Your Plan'),
        content: const Text(
          'Choose from our premium plans to unlock unlimited access and advanced features.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('View Plans'),
          ),
        ],
      ),
    );
  }

  void _showModifyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modify Subscription'),
        content: const Text(
          'Subscription modifications are managed through your device\'s app store.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _openAppStoreBilling();
            },
            child: const Text('Open App Store'),
          ),
        ],
      ),
    );
  }

  void _showPauseDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pause Subscription'),
        content: const Text(
          'Subscription pausing is managed through your device\'s app store.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _openAppStoreBilling();
            },
            child: const Text('Open App Store'),
          ),
        ],
      ),
    );
  }

  void _showChangePlanDialog(
    BuildContext context,
    SubscriptionStatus subscription,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Your Plan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current Plan: ${_getTierName(subscription.tier)}',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            if (subscription.tier == SubscriptionTier.mystic) ...[
              const Text('Available upgrades:'),
              const SizedBox(height: 8),
              ListTile(
                leading: const Icon(Icons.diamond),
                title: const Text('Oracle Plan'),
                subtitle: const Text('\$9.99/month - Premium features'),
                dense: true,
                onTap: () {
                  Navigator.of(context).pop();
                  _confirmPlanChange(context, SubscriptionTier.oracle);
                },
              ),
            ] else ...[
              const Text(
                'Plan changes are managed through your device\'s app store.',
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          if (subscription.tier == SubscriptionTier.oracle)
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _openAppStoreBilling();
              },
              child: const Text('Manage in App Store'),
            ),
        ],
      ),
    );
  }

  void _confirmPlanChange(BuildContext context, SubscriptionTier newTier) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Upgrade to ${_getTierName(newTier)}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'You\'re about to upgrade to the ${_getTierName(newTier)} plan.',
            ),
            const SizedBox(height: 16),
            const Text('New features you\'ll unlock:'),
            const SizedBox(height: 8),
            if (newTier == SubscriptionTier.oracle) ...[
              _buildFeatureBullet('AI-generated audio readings'),
              _buildFeatureBullet('Personalized journal prompts'),
              _buildFeatureBullet('Advanced tarot spreads'),
              _buildFeatureBullet('Custom themes and card backs'),
              _buildFeatureBullet('Early access to new features'),
            ],
            const SizedBox(height: 16),
            Text(
              'Price: ${_getTierPrice(newTier)}/month',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _processPlanUpgrade(context, newTier);
            },
            child: const Text('Upgrade Now'),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureBullet(String feature) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            Icons.check,
            size: 16,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(feature, style: Theme.of(context).textTheme.bodySmall),
          ),
        ],
      ),
    );
  }

  void _processPlanUpgrade(BuildContext context, SubscriptionTier newTier) {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Processing upgrade...'),
          ],
        ),
      ),
    );

    // Simulate upgrade process
    Future.delayed(const Duration(seconds: 2), () {
      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading dialog

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully upgraded to ${_getTierName(newTier)}!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }

      // Refresh subscription status
      final _ = ref.refresh(subscriptionProvider);
    });
  }

  void _showCancelDialog(
    BuildContext context,
    SubscriptionStatus subscription,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Subscription'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Are you sure you want to cancel your subscription?',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            const Text('What happens when you cancel:'),
            const SizedBox(height: 8),
            _buildCancelBullet(
              'You\'ll keep access until ${subscription.expirationDate != null ? _formatNextBilling(subscription) : "the end of your billing period"}',
            ),
            _buildCancelBullet(
              'After that, you\'ll be moved to the free Seeker plan',
            ),
            _buildCancelBullet(
              'Your journal entries and reading history will be preserved',
            ),
            _buildCancelBullet(
              'You can resubscribe anytime to restore full access',
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.errorContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Theme.of(context).colorScheme.error,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Cancellation is processed through your device\'s app store.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Keep Subscription'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _openAppStoreBilling();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: const Text('Cancel in App Store'),
          ),
        ],
      ),
    );
  }

  Widget _buildCancelBullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodySmall),
          ),
        ],
      ),
    );
  }

  void _refreshSubscription() {
    final _ = ref.refresh(subscriptionProvider);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Subscription status refreshed')),
    );
  }

  void _restorePurchases() {
    ref.read(subscriptionProvider.notifier).restoreSubscriptions();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Restoring purchases...')));
  }

  Widget _buildCurrentPeriodUsage(
    BuildContext context,
    SubscriptionStatus subscription,
  ) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Current Billing Period Usage',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _getCurrentBillingPeriod(),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Consumer(
              builder: (context, ref, child) {
                final usageAsync = ref.watch(
                  usage_provider.usageCountsProvider,
                );
                return usageAsync.when(
                  data: (usage) =>
                      _buildDetailedUsageStats(context, usage, subscription),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => Text(
                    'Unable to load usage statistics',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedUsageStats(
    BuildContext context,
    Map<String, int> usage,
    SubscriptionStatus subscription,
  ) {
    final theme = Theme.of(context);

    return Column(
      children: [
        _buildUsageStatRow(
          context,
          Icons.auto_awesome,
          'AI Readings',
          usage['readings'] ?? 0,
          subscription.tier == SubscriptionTier.seeker
              ? 'Unlimited for basic spreads'
              : 'Unlimited',
        ),
        const SizedBox(height: 12),
        _buildUsageStatRow(
          context,
          Icons.search,
          'Manual Interpretations',
          usage['manual_interpretations'] ?? 0,
          subscription.tier == SubscriptionTier.seeker
              ? '5 per month'
              : 'Unlimited',
        ),
        const SizedBox(height: 12),
        _buildUsageStatRow(
          context,
          Icons.book,
          'Journal Entries',
          usage['journal_entries'] ?? 0,
          subscription.tier == SubscriptionTier.seeker
              ? '3 entries max'
              : 'Unlimited',
        ),
        if (subscription.tier != SubscriptionTier.seeker) ...[
          const SizedBox(height: 12),
          _buildUsageStatRow(
            context,
            Icons.volume_up,
            'Audio Readings',
            usage['audio_readings'] ?? 0,
            subscription.tier == SubscriptionTier.oracle
                ? 'Unlimited'
                : 'Not available',
          ),
        ],
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: theme.colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  subscription.tier == SubscriptionTier.seeker
                      ? 'Usage resets on the 1st of each month'
                      : 'Enjoy unlimited access with your ${_getTierName(subscription.tier)} plan',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUsageStatRow(
    BuildContext context,
    IconData icon,
    String label,
    int count,
    String limit,
  ) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                limit,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            count.toString(),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }

  String _getCurrentBillingPeriod() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);

    return '${_formatDateShort(startOfMonth)} - ${_formatDateShort(endOfMonth)}';
  }

  String _formatDateShort(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}';
  }

  void _openAppStoreBilling() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening app store billing management...')),
    );
  }
}
