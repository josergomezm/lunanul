import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/enums.dart';
import '../providers/subscription_providers.dart';

/// Example widget demonstrating subscription providers usage
class SubscriptionProvidersExample extends ConsumerWidget {
  const SubscriptionProvidersExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscriptionAsync = ref.watch(subscriptionProvider);
    final featureAccess = ref.watch(featureAccessProvider);
    final tierDisplayInfo = ref.watch(currentTierDisplayInfoProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Subscription Providers Example')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Subscription Status Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Subscription Status',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    subscriptionAsync.when(
                      data: (status) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tier: ${tierDisplayInfo.name} ${tierDisplayInfo.icon}',
                          ),
                          Text('Price: ${tierDisplayInfo.price}'),
                          Text('Active: ${status.isActive}'),
                          Text('Valid: ${status.isValid}'),
                          if (status.expirationDate != null)
                            Text('Expires: ${status.expirationDate}'),
                        ],
                      ),
                      loading: () => const CircularProgressIndicator(),
                      error: (error, stack) => Text('Error: $error'),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Feature Access Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Feature Access',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Unlimited Readings: ${featureAccess.hasUnlimitedReadings}',
                    ),
                    Text('Ad-Free: ${featureAccess.isAdFree}'),
                    Text('Audio Readings: ${featureAccess.hasAudioReadings}'),
                    Text('Customization: ${featureAccess.hasCustomization}'),
                    Text('Early Access: ${featureAccess.hasEarlyAccess}'),
                    Text(
                      'Available Spreads: ${featureAccess.availableSpreads.length}',
                    ),
                    Text(
                      'Available Guides: ${featureAccess.availableGuides.length}',
                    ),
                    if (featureAccess.maxReadings > 0)
                      Text('Max Readings: ${featureAccess.maxReadings}')
                    else
                      const Text('Unlimited Readings'),
                    if (featureAccess.maxManualInterpretations > 0)
                      Text(
                        'Max Manual Interpretations: ${featureAccess.maxManualInterpretations}',
                      )
                    else
                      const Text('Unlimited Manual Interpretations'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Usage Information Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Usage Information',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Consumer(
                      builder: (context, ref, child) {
                        final usageCounts = ref.watch(usageCountsProvider);
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Manual Interpretations: ${usageCounts['manual_interpretations'] ?? 0}',
                            ),
                            Text('Readings: ${usageCounts['readings'] ?? 0}'),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Actions Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Actions',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            await ref
                                .read(subscriptionProvider.notifier)
                                .incrementUsage('manual_interpretations');
                          },
                          child: const Text('Use Manual Interpretation'),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            await ref
                                .read(subscriptionProvider.notifier)
                                .incrementUsage('readings');
                          },
                          child: const Text('Save Journal Entry'),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            await ref
                                .read(subscriptionProvider.notifier)
                                .resetUsage();
                          },
                          child: const Text('Reset Usage'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            // Simulate upgrade to Mystic tier
                            final mysticStatus = ref
                                .read(subscriptionProvider)
                                .value!
                                .copyWith(
                                  tier: SubscriptionTier.mystic,
                                  expirationDate: DateTime.now().add(
                                    const Duration(days: 30),
                                  ),
                                );
                            ref
                                .read(subscriptionProvider.notifier)
                                .updateStatus(mysticStatus);
                          },
                          child: const Text('Upgrade to Mystic'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            // Simulate upgrade to Oracle tier
                            final oracleStatus = ref
                                .read(subscriptionProvider)
                                .value!
                                .copyWith(
                                  tier: SubscriptionTier.oracle,
                                  expirationDate: DateTime.now().add(
                                    const Duration(days: 30),
                                  ),
                                );
                            ref
                                .read(subscriptionProvider.notifier)
                                .updateStatus(oracleStatus);
                          },
                          child: const Text('Upgrade to Oracle'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            // Reset to free tier
                            final freeStatus = ref
                                .read(subscriptionProvider)
                                .value!
                                .copyWith(
                                  tier: SubscriptionTier.seeker,
                                  expirationDate: null,
                                );
                            ref
                                .read(subscriptionProvider.notifier)
                                .updateStatus(freeStatus);
                          },
                          child: const Text('Reset to Free'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Upgrade Recommendation Section
            Consumer(
              builder: (context, ref, child) {
                final recommendation = ref.watch(
                  tierUpgradeRecommendationProvider,
                );
                if (recommendation == null) {
                  return const SizedBox.shrink();
                }

                return Card(
                  color: Colors.orange.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Upgrade Recommendation',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Recommended Tier: ${recommendation.recommendedTier.displayName}',
                        ),
                        Text('Reason: ${recommendation.reason}'),
                        const SizedBox(height: 8),
                        Text(
                          'Benefits:',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        ...recommendation.benefits.map(
                          (benefit) => Text('• $benefit'),
                        ),
                      ],
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
}
