import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/enums.dart';
import '../models/subscription_errors.dart';
import '../providers/providers.dart';
import '../services/network_connectivity_service.dart';
import '../services/ad_service.dart';
import 'subscription_gate.dart';
import 'upgrade_prompt.dart';
import 'subscription_status_widget.dart';
import 'usage_stats_widget.dart';
import 'tranquil_ad_widget.dart';
import 'subscription_onboarding_integration.dart';
import 'subscription_sync_status_widget.dart';
import 'subscription_error_widget.dart';
import 'connectivity_status_widget.dart';

/// Comprehensive widget that demonstrates the complete subscription system integration
/// This widget shows how all subscription components work together in the app
class SubscriptionSystemIntegration extends ConsumerWidget {
  const SubscriptionSystemIntegration({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscriptionAsync = ref.watch(subscriptionProvider);
    final currentTier = ref.watch(currentTierProvider);
    final shouldShowAdsAsync = ref.watch(shouldShowAdsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscription System Demo'),
        actions: [
          // Subscription status indicator
          Consumer(
            builder: (context, ref, child) {
              final tier = ref.watch(currentTierProvider);
              return Chip(
                label: Text(tier.name.toUpperCase()),
                backgroundColor: _getTierColor(tier),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Connectivity and sync status
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'System Status',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    ConnectivityStatusWidget(
                      connectivityInfo: ConnectivityInfo(
                        status: ConnectivityStatus.connected,
                        lastChecked: null,
                        responseTime: null,
                      ),
                    ),
                    SizedBox(height: 8),
                    SubscriptionSyncStatusWidget(),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Subscription status and management
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Subscription Status',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    subscriptionAsync.when(
                      data: (status) =>
                          SubscriptionStatusWidget(subscription: status),
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (error, stack) => SubscriptionErrorWidget(
                        error: error is SubscriptionException
                            ? error
                            : SubscriptionException(
                                SubscriptionError.unknown,
                                message: 'Unknown error: ${error.toString()}',
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Usage statistics (for free tier)
            if (currentTier == SubscriptionTier.seeker)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Usage Statistics',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      subscriptionAsync.when(
                        data: (subscription) =>
                            UsageStatsWidget(subscription: subscription),
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (error, stack) =>
                            const Text('Unable to load usage stats'),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // Feature demonstrations with subscription gates
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Feature Access Demo',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Basic feature (always available)
                    _buildFeatureDemo(
                      'Daily Card Reading',
                      'Available to all users',
                      Icons.today,
                      Colors.green,
                      child: const Text(
                        '✓ Access granted to daily card reading',
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Mystic tier feature
                    _buildFeatureDemo(
                      'Premium Spreads',
                      'Requires Mystic tier or higher',
                      Icons.auto_awesome,
                      Colors.purple,
                      child: SubscriptionGate(
                        featureKey: 'premium_spreads',
                        requiredTier: SubscriptionTier.mystic,
                        upgradePrompt: const UpgradePrompt(
                          featureContext: 'premium spreads',
                          recommendedTier: SubscriptionTier.mystic,
                        ),
                        child: const Text(
                          '✓ Access granted to premium spreads',
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Oracle tier feature
                    _buildFeatureDemo(
                      'Audio Readings',
                      'Requires Oracle tier',
                      Icons.volume_up,
                      Colors.amber,
                      child: SubscriptionGate(
                        featureKey: 'audio_readings',
                        requiredTier: SubscriptionTier.oracle,
                        upgradePrompt: const UpgradePrompt(
                          featureContext: 'audio readings',
                          recommendedTier: SubscriptionTier.oracle,
                        ),
                        child: const Text('✓ Access granted to audio readings'),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Usage-limited feature
                    _buildFeatureDemo(
                      'Manual Interpretations',
                      'Limited for free users',
                      Icons.psychology,
                      Colors.blue,
                      child: SubscriptionGate(
                        featureKey: 'manual_interpretations',
                        requiredTier: SubscriptionTier.seeker,
                        upgradePrompt: const UpgradePrompt(
                          featureContext: 'unlimited manual interpretations',
                          recommendedTier: SubscriptionTier.mystic,
                        ),
                        child: const Text(
                          '✓ Access granted to manual interpretations',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Ad integration demo
            shouldShowAdsAsync.when(
              data: (shouldShowAds) => shouldShowAds
                  ? Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Advertisement',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            TranquilAdWidget(
                              adContent: AdContent(
                                id: 'demo-ad',
                                type: AdType.spiritual,
                                content:
                                    'Discover your inner wisdom with premium features',
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const SizedBox.shrink(),
            ),

            const SizedBox(height: 16),

            // Subscription onboarding integration
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Onboarding & Education',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    SubscriptionOnboardingIntegration(
                      child: Text('Onboarding content would appear here'),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Action buttons
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Actions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => _refreshSubscription(ref),
                          icon: const Icon(Icons.refresh),
                          label: const Text('Refresh Status'),
                        ),

                        if (currentTier == SubscriptionTier.seeker)
                          ElevatedButton.icon(
                            onPressed: () =>
                                _simulateUpgrade(ref, SubscriptionTier.mystic),
                            icon: const Icon(Icons.upgrade),
                            label: const Text('Upgrade to Mystic'),
                          ),

                        if (currentTier == SubscriptionTier.mystic)
                          ElevatedButton.icon(
                            onPressed: () =>
                                _simulateUpgrade(ref, SubscriptionTier.oracle),
                            icon: const Icon(Icons.auto_awesome),
                            label: const Text('Upgrade to Oracle'),
                          ),

                        ElevatedButton.icon(
                          onPressed: () => _simulateUsage(ref),
                          icon: const Icon(Icons.add),
                          label: const Text('Use Feature'),
                        ),

                        ElevatedButton.icon(
                          onPressed: () => _resetUsage(ref),
                          icon: const Icon(Icons.restore),
                          label: const Text('Reset Usage'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureDemo(
    String title,
    String description,
    IconData icon,
    Color color, {
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: color.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(8),
        color: color.withValues(alpha: 0.1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(fontWeight: FontWeight.bold, color: color),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }

  Color _getTierColor(SubscriptionTier tier) {
    switch (tier) {
      case SubscriptionTier.seeker:
        return Colors.grey;
      case SubscriptionTier.mystic:
        return Colors.purple;
      case SubscriptionTier.oracle:
        return Colors.amber;
    }
  }

  Future<void> _refreshSubscription(WidgetRef ref) async {
    await ref.read(subscriptionProvider.notifier).refreshStatus();
  }

  Future<void> _simulateUpgrade(WidgetRef ref, SubscriptionTier tier) async {
    final productId = tier == SubscriptionTier.mystic
        ? 'mystic_monthly'
        : 'oracle_monthly';
    await ref
        .read(subscriptionProvider.notifier)
        .purchaseSubscription(productId);
  }

  Future<void> _simulateUsage(WidgetRef ref) async {
    await ref
        .read(usageTrackingNotifierProvider.notifier)
        .incrementUsage('manual_interpretations');
  }

  Future<void> _resetUsage(WidgetRef ref) async {
    await ref.read(usageTrackingNotifierProvider.notifier).resetMonthlyUsage();
  }
}

/// Extension to add subscription system integration to the app
extension SubscriptionSystemIntegrationExtension on Widget {
  /// Wrap a widget with subscription system integration
  Widget withSubscriptionSystem() {
    return Consumer(
      builder: (context, ref, child) {
        // Listen to subscription changes for global effects
        ref.listen(subscriptionProvider, (previous, next) {
          // Handle subscription status changes
          next.whenOrNull(
            error: (error, stack) {
              // Show error snackbar
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Subscription error: $error'),
                  backgroundColor: Colors.red,
                ),
              );
            },
          );
        });

        // Listen to usage limit warnings
        ref.listen(usageTrackingNotifierProvider, (previous, next) {
          next.whenData((usageCounts) {
            final manualInterpretations =
                usageCounts['manual_interpretations'] ?? 0;
            if (manualInterpretations >= 4) {
              // Show usage warning
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'You\'re approaching your monthly limit. Consider upgrading!',
                  ),
                  backgroundColor: Colors.orange,
                ),
              );
            }
          });
        });

        return this;
      },
    );
  }
}
