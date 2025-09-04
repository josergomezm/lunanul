import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/enums.dart';
import '../providers/usage_tracking_provider.dart';

/// Example widget demonstrating usage tracking integration
class UsageTrackingExample extends ConsumerWidget {
  const UsageTrackingExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch current usage counts
    final usageCountsAsync = ref.watch(usageCountsProvider);

    // Watch usage summary for seeker tier
    final usageSummaryAsync = ref.watch(
      usageSummaryProvider(SubscriptionTier.seeker),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Usage Tracking Example')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current Usage Counts Section
            const Text(
              'Current Usage Counts',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            usageCountsAsync.when(
              data: (counts) => counts.isEmpty
                  ? const Text('No usage recorded yet')
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: counts.entries
                          .map((entry) => Text('${entry.key}: ${entry.value}'))
                          .toList(),
                    ),
              loading: () => const CircularProgressIndicator(),
              error: (error, stack) => Text('Error: $error'),
            ),

            const SizedBox(height: 24),

            // Usage Summary for Seeker Tier
            const Text(
              'Seeker Tier Usage Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            usageSummaryAsync.when(
              data: (summary) => summary.isEmpty
                  ? const Text('No limited features for this tier')
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: summary.entries.map((entry) {
                        final featureName = entry.key;
                        final featureData = entry.value as Map<String, dynamic>;
                        final current = featureData['current'] as int;
                        final limit = featureData['limit'] as int;
                        final remaining = featureData['remaining'] as int;
                        final percentage = featureData['percentage'] as double;
                        final approachingLimit =
                            featureData['approaching_limit'] as bool;
                        final reachedLimit =
                            featureData['reached_limit'] as bool;

                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  featureName
                                      .replaceAll('_', ' ')
                                      .toUpperCase(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text('Current: $current / $limit'),
                                Text('Remaining: $remaining'),
                                Text(
                                  'Usage: ${(percentage * 100).toStringAsFixed(1)}%',
                                ),
                                if (reachedLimit)
                                  const Text(
                                    'LIMIT REACHED',
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                else if (approachingLimit)
                                  const Text(
                                    'Approaching limit',
                                    style: TextStyle(
                                      color: Colors.orange,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
              loading: () => const CircularProgressIndicator(),
              error: (error, stack) => Text('Error: $error'),
            ),

            const SizedBox(height: 24),

            // Action Buttons
            const Text(
              'Actions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                ElevatedButton(
                  onPressed: () => ref.incrementUsage('manual_interpretations'),
                  child: const Text('Use Manual Interpretation'),
                ),
                ElevatedButton(
                  onPressed: () => ref.incrementUsage('readings'),
                  child: const Text('Perform Reading'),
                ),
                ElevatedButton(
                  onPressed: () => ref.resetMonthlyUsage(),
                  child: const Text('Reset Monthly Usage'),
                ),
                ElevatedButton(
                  onPressed: () => ref.checkAndResetUsageIfNeeded(),
                  child: const Text('Check & Reset If Needed'),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Feature Limit Checks
            const Text(
              'Feature Limit Checks',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _FeatureLimitChecker(
              tier: SubscriptionTier.seeker,
              feature: 'manual_interpretations',
            ),
            const SizedBox(height: 8),
            _FeatureLimitChecker(
              tier: SubscriptionTier.seeker,
              feature: 'readings',
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget to demonstrate feature limit checking
class _FeatureLimitChecker extends ConsumerWidget {
  const _FeatureLimitChecker({required this.tier, required this.feature});

  final SubscriptionTier tier;
  final String feature;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final withinLimit = ref.isFeatureWithinLimit(tier, feature);
    final remaining = ref.getRemainingUsage(tier, feature);
    final approaching = ref.isApproachingLimit(tier, feature);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${feature.replaceAll('_', ' ')} (${tier.displayName})',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            withinLimit.when(
              data: (within) => Text(
                within ? 'Within limit' : 'Limit exceeded',
                style: TextStyle(color: within ? Colors.green : Colors.red),
              ),
              loading: () => const Text('Checking...'),
              error: (error, stack) => Text('Error: $error'),
            ),
            remaining.when(
              data: (rem) => Text(rem == -1 ? 'Unlimited' : 'Remaining: $rem'),
              loading: () => const Text('Loading...'),
              error: (error, stack) => Text('Error: $error'),
            ),
            approaching.when(
              data: (app) => app
                  ? const Text(
                      'Approaching limit!',
                      style: TextStyle(color: Colors.orange),
                    )
                  : const SizedBox.shrink(),
              loading: () => const SizedBox.shrink(),
              error: (error, stack) => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
