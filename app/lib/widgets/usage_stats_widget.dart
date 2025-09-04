import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/enums.dart';
import '../models/subscription_status.dart';
import '../models/usage_limits.dart';
import '../providers/usage_tracking_provider.dart';

/// Widget that displays usage statistics and limits for the current subscription tier
class UsageStatsWidget extends ConsumerWidget {
  final SubscriptionStatus subscription;

  const UsageStatsWidget({super.key, required this.subscription});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usageAsync = ref.watch(usageCountsProvider);

    return usageAsync.when(
      data: (usage) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCurrentPeriodCard(context, usage),
          const SizedBox(height: 16),
          if (subscription.tier == SubscriptionTier.seeker) ...[
            _buildUsageLimitsCard(context, usage),
            const SizedBox(height: 16),
          ],
          _buildActivitySummary(context, usage),
        ],
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildErrorState(context),
    );
  }

  Widget _buildCurrentPeriodCard(BuildContext context, Map<String, int> usage) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final periodStart = DateTime(now.year, now.month, 1);
    final periodEnd = DateTime(now.year, now.month + 1, 0);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.calendar_month, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Current Billing Period',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${_formatDate(periodStart)} - ${_formatDate(periodEnd)}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            _buildUsageOverview(context, usage),
          ],
        ),
      ),
    );
  }

  Widget _buildUsageOverview(BuildContext context, Map<String, int> usage) {
    final totalReadings = usage['readings'] ?? 0;
    final totalInterpretations = usage['manual_interpretations'] ?? 0;

    return Row(
      children: [
        Expanded(
          child: _buildStatItem(
            context,
            Icons.auto_awesome,
            'Readings',
            totalReadings.toString(),
          ),
        ),
        Expanded(
          child: _buildStatItem(
            context,
            Icons.search,
            'Interpretations',
            totalInterpretations.toString(),
          ),
        ),
        Expanded(
          child: _buildStatItem(
            context,
            Icons.book,
            'Readings',
            totalReadings.toString(),
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Icon(icon, color: theme.colorScheme.primary, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildUsageLimitsCard(BuildContext context, Map<String, int> usage) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.trending_up, color: theme.colorScheme.secondary),
                const SizedBox(width: 8),
                Text(
                  'Usage Limits',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildLimitProgress(
              context,
              'Manual Interpretations',
              usage['manual_interpretations'] ?? 0,
              UsageLimits.monthlyLimits['manual_interpretations']!,
              Icons.search,
            ),
            const SizedBox(height: 12),
            _buildLimitProgress(
              context,
              'Readings',
              usage['readings'] ?? 0,
              UsageLimits.monthlyLimits['readings']!,
              Icons.auto_awesome,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(
                  alpha: 0.3,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.upgrade,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Upgrade to Mystic for unlimited access',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLimitProgress(
    BuildContext context,
    String label,
    int used,
    int limit,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    final progress = used / limit;
    final remaining = limit - used;

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
        Row(
          children: [
            Icon(icon, size: 16, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Text(
              '$used / $limit',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: progressColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress.clamp(0.0, 1.0),
          backgroundColor: theme.colorScheme.surfaceContainerHighest,
          valueColor: AlwaysStoppedAnimation<Color>(progressColor),
        ),
        const SizedBox(height: 4),
        Text(
          remaining > 0 ? '$remaining remaining' : 'Limit reached',
          style: theme.textTheme.labelSmall?.copyWith(color: progressColor),
        ),
      ],
    );
  }

  Widget _buildActivitySummary(BuildContext context, Map<String, int> usage) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.insights, color: theme.colorScheme.tertiary),
                const SizedBox(width: 8),
                Text(
                  'Activity Summary',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildActivityItem(
              context,
              Icons.auto_awesome,
              'Most Active Feature',
              _getMostActiveFeature(usage),
            ),
            const SizedBox(height: 8),
            _buildActivityItem(
              context,
              Icons.calendar_today,
              'Days This Month',
              _getActiveDays().toString(),
            ),
            const SizedBox(height: 8),
            _buildActivityItem(
              context,
              Icons.trending_up,
              'Spiritual Growth',
              _getGrowthMessage(usage),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(icon, size: 16, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 12),
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
    );
  }

  Widget _buildErrorState(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text(
              'Unable to load usage statistics',
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Please try again later',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
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

  String _getMostActiveFeature(Map<String, int> usage) {
    if (usage.isEmpty) return 'None yet';

    final entries = usage.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final mostUsed = entries.first.key;
    switch (mostUsed) {
      case 'readings':
        return 'Readings';
      case 'manual_interpretations':
        return 'Manual Interpretations';
      default:
        return 'Exploring';
    }
  }

  int _getActiveDays() {
    // This would typically come from more detailed usage tracking
    // For now, return a reasonable estimate
    final now = DateTime.now();
    return now.day;
  }

  String _getGrowthMessage(Map<String, int> usage) {
    final totalActivity = usage.values.fold(0, (sum, count) => sum + count);

    if (totalActivity == 0) {
      return 'Just beginning';
    } else if (totalActivity < 5) {
      return 'Building habits';
    } else if (totalActivity < 15) {
      return 'Making progress';
    } else if (totalActivity < 30) {
      return 'Strong practice';
    } else {
      return 'Dedicated seeker';
    }
  }
}
