import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/feature_gate_provider.dart';

/// Reusable usage tracker widget for seeker plan features
class UsageTrackerWidget extends ConsumerWidget {
  const UsageTrackerWidget({
    super.key,
    required this.featureKey,
    required this.featureName,
  });

  final String featureKey;
  final String featureName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usageAsync = ref.watch(featureUsageInfoProvider(featureKey));
    final isAdFree = ref.watch(isAdFreeProvider);

    return usageAsync.when(
      data: (usage) {
        final current = usage['current'] as int? ?? 0;
        final limit = usage['limit'] as int?;
        final unlimited = usage['unlimited'] as bool? ?? false;
        final reachedLimit = usage['reached_limit'] as bool? ?? false;

        // Don't show usage indicator for unlimited users
        if (unlimited || isAdFree) {
          return const SizedBox.shrink();
        }

        return Card(
          color: reachedLimit
              ? Theme.of(context).colorScheme.errorContainer
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      reachedLimit ? Icons.warning : Icons.info_outline,
                      color: reachedLimit
                          ? Theme.of(context).colorScheme.error
                          : Theme.of(context).colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      featureName,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: reachedLimit
                            ? Theme.of(context).colorScheme.error
                            : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (limit != null) ...[
                  Text(
                    'Used $current of $limit this month',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: (current / limit).clamp(0.0, 1.0),
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.outline.withValues(alpha: 0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      reachedLimit
                          ? Theme.of(context).colorScheme.error
                          : Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  if (reachedLimit) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Upgrade to Mystic for unlimited $featureName',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (error, stack) => const SizedBox.shrink(),
    );
  }
}
