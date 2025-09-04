import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/enums.dart';
import '../models/subscription_status.dart';
import '../providers/subscription_provider.dart';
import '../widgets/tier_selection_widget.dart';
import '../widgets/subscription_status_widget.dart';
import '../widgets/usage_stats_widget.dart';

/// Screen for viewing and managing subscriptions
class SubscriptionManagementPage extends ConsumerStatefulWidget {
  const SubscriptionManagementPage({super.key});

  @override
  ConsumerState<SubscriptionManagementPage> createState() =>
      _SubscriptionManagementPageState();
}

class _SubscriptionManagementPageState
    extends ConsumerState<SubscriptionManagementPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
        title: const Text('Subscription'),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Status', icon: Icon(Icons.info_outline)),
            Tab(text: 'Plans', icon: Icon(Icons.star_outline)),
            Tab(text: 'Usage', icon: Icon(Icons.analytics_outlined)),
          ],
        ),
      ),
      body: subscriptionAsync.when(
        data: (subscription) => TabBarView(
          controller: _tabController,
          children: [
            _buildStatusTab(context, subscription),
            _buildPlansTab(context, subscription),
            _buildUsageTab(context, subscription),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildErrorState(context, error),
      ),
    );
  }

  Widget _buildStatusTab(
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
          if (subscription.tier != SubscriptionTier.oracle)
            _buildUpgradeSection(context, subscription),
        ],
      ),
    );
  }

  Widget _buildPlansTab(BuildContext context, SubscriptionStatus subscription) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Choose Your Spiritual Path',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Unlock deeper insights and personalized guidance',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          TierSelectionWidget(currentTier: subscription.tier),
        ],
      ),
    );
  }

  Widget _buildUsageTab(BuildContext context, SubscriptionStatus subscription) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Usage Statistics',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Track your spiritual journey progress',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          UsageStatsWidget(subscription: subscription),
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
                Icon(Icons.check_circle, color: theme.colorScheme.primary),
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
                      Icons.star,
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

  Widget _buildUpgradeSection(
    BuildContext context,
    SubscriptionStatus subscription,
  ) {
    final theme = Theme.of(context);
    final nextTier = subscription.tier == SubscriptionTier.seeker
        ? SubscriptionTier.mystic
        : SubscriptionTier.oracle;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.upgrade, color: theme.colorScheme.secondary),
                const SizedBox(width: 8),
                Text(
                  'Unlock More Features',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Upgrade to ${_getTierName(nextTier)} for enhanced spiritual guidance',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _tabController.animateTo(1),
                child: Text('View ${_getTierName(nextTier)} Benefits'),
              ),
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
              'Unable to load subscription information',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Please check your connection and try again',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
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
          'Reading statistics and insights',
        ];
      case SubscriptionTier.oracle:
        return [
          'All Mystic tier benefits',
          'AI-generated audio readings',
          'Personalized journal prompts',
          'Advanced and specialized spreads',
          'Custom themes and card backs',
          'Early access to new features',
          'Priority customer support',
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
}
