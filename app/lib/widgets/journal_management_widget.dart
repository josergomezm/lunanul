import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/enums.dart';
import '../models/reading.dart';
import '../providers/journal_provider.dart';
import '../providers/subscription_providers.dart';
import '../services/subscription_feature_gate_service.dart';
import '../utils/app_theme.dart';

/// Widget that displays journal management UI with usage stats and upgrade options
class JournalManagementWidget extends ConsumerWidget {
  const JournalManagementWidget({
    super.key,
    this.showUpgradePrompt = true,
    this.compact = false,
  });

  final bool showUpgradePrompt;
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscriptionStatus = ref.watch(subscriptionStatusProvider);
    final savedReadingsAsync = ref.watch(savedReadingsProvider);
    final usageInfoAsync = ref.watch(
      featureUsageInfoProvider(SubscriptionFeatureGateService.readingFeature),
    );

    return subscriptionStatus.when(
      loading: () => _buildLoadingState(),
      error: (error, stack) => _buildErrorState(error),
      data: (status) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, status.tier),
            const SizedBox(height: 16),

            // Usage information
            usageInfoAsync.when(
              loading: () => _buildUsageLoadingState(context),
              error: (error, stack) => _buildUsageErrorState(context, error),
              data: (usageInfo) =>
                  _buildUsageInfo(context, status.tier, usageInfo),
            ),

            const SizedBox(height: 16),

            // Saved readings list
            savedReadingsAsync.when(
              loading: () => _buildReadingsLoadingState(context),
              error: (error, stack) => _buildReadingsErrorState(error),
              data: (readings) =>
                  _buildReadingsList(context, status.tier, readings),
            ),

            // Upgrade prompt for free users
            if (showUpgradePrompt &&
                status.tier == SubscriptionTier.seeker) ...[
              const SizedBox(height: 16),
              _buildUpgradeSection(context),
            ],
          ],
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, SubscriptionTier tier) {
    return Row(
      children: [
        Icon(
          Icons.book,
          color: AppTheme.primaryPurple,
          size: compact ? 20 : 24,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'Journal Management',
            style: compact
                ? Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)
                : Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        _buildTierBadge(context, tier),
      ],
    );
  }

  Widget _buildTierBadge(BuildContext context, SubscriptionTier tier) {
    Color badgeColor;
    IconData badgeIcon;

    switch (tier) {
      case SubscriptionTier.seeker:
        badgeColor = AppTheme.serenityGreen;
        badgeIcon = Icons.explore;
        break;
      case SubscriptionTier.mystic:
        badgeColor = AppTheme.primaryPurple;
        badgeIcon = Icons.auto_awesome;
        break;
      case SubscriptionTier.oracle:
        badgeColor = AppTheme.softGold;
        badgeIcon = Icons.diamond;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: badgeColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(badgeIcon, size: 14, color: badgeColor),
          const SizedBox(width: 4),
          Text(
            tier.displayName,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: badgeColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsageInfo(
    BuildContext context,
    SubscriptionTier tier,
    Map<String, dynamic> usageInfo,
  ) {
    final isUnlimited = usageInfo['unlimited'] as bool? ?? false;
    final current = usageInfo['current'] as int? ?? 0;
    final limit = usageInfo['limit'] as int?;
    final percentage = usageInfo['percentage'] as double? ?? 0.0;
    final reachedLimit = usageInfo['reached_limit'] as bool? ?? false;
    final approachingLimit = usageInfo['approaching_limit'] as bool? ?? false;

    if (isUnlimited) {
      return _buildUnlimitedUsageCard(context, current);
    }

    return _buildLimitedUsageCard(
      context,
      current,
      limit ?? 0,
      percentage,
      reachedLimit,
      approachingLimit,
    );
  }

  Widget _buildUnlimitedUsageCard(BuildContext context, int current) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryPurple.withValues(alpha: 0.1),
            AppTheme.mysticPurple.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primaryPurple.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryPurple.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.all_inclusive,
              color: AppTheme.primaryPurple,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Unlimited Journal Storage',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryPurple,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'You have $current saved readings with unlimited storage',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.darkGray.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLimitedUsageCard(
    BuildContext context,
    int current,
    int limit,
    double percentage,
    bool reachedLimit,
    bool approachingLimit,
  ) {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    if (reachedLimit) {
      statusColor = AppTheme.errorColor;
      statusIcon = Icons.warning;
      statusText = 'Journal Full';
    } else if (approachingLimit) {
      statusColor = AppTheme.warningColor;
      statusIcon = Icons.warning_amber;
      statusText = 'Almost Full';
    } else {
      statusColor = AppTheme.serenityGreen;
      statusIcon = Icons.check_circle;
      statusText = 'Available';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.3),
          width: reachedLimit ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(statusIcon, color: statusColor, size: 20),
              const SizedBox(width: 8),
              Text(
                statusText,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: statusColor,
                ),
              ),
              const Spacer(),
              Text(
                '$current / $limit',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: statusColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: percentage,
            backgroundColor: AppTheme.moonlightSilver,
            valueColor: AlwaysStoppedAnimation<Color>(statusColor),
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 8),
          Text(
            reachedLimit
                ? 'Your journal is full. Delete a reading or upgrade to save more.'
                : approachingLimit
                ? 'Your journal is almost full. Consider upgrading for unlimited storage.'
                : 'You have ${limit - current} reading slots remaining.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.darkGray.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReadingsList(
    BuildContext context,
    SubscriptionTier tier,
    List<Reading> readings,
  ) {
    if (readings.isEmpty) {
      return _buildEmptyReadingsState(context);
    }

    final displayReadings = compact ? readings.take(3).toList() : readings;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Saved Readings',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            if (compact && readings.length > 3)
              TextButton(
                onPressed: () => _navigateToFullJournal(context),
                child: const Text('View All'),
              ),
          ],
        ),
        const SizedBox(height: 8),
        ...displayReadings.map(
          (reading) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _buildReadingItem(context, reading, tier),
          ),
        ),
      ],
    );
  }

  Widget _buildReadingItem(
    BuildContext context,
    Reading reading,
    SubscriptionTier tier,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getTopicColor(reading.topic).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getTopicIcon(reading.topic),
              color: _getTopicColor(reading.topic),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reading.displayTitle,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  reading.getFormattedDate(const Locale('en')),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
              ],
            ),
          ),
          if (tier == SubscriptionTier.seeker)
            PopupMenuButton<String>(
              onSelected: (value) =>
                  _handleReadingAction(context, reading, value),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline, size: 16),
                      SizedBox(width: 8),
                      Text('Delete'),
                    ],
                  ),
                ),
              ],
              child: Icon(
                Icons.more_vert,
                color: Theme.of(context).colorScheme.outline,
                size: 16,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildUpgradeSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryPurple.withValues(alpha: 0.1),
            AppTheme.mysticPurple.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primaryPurple.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, color: AppTheme.primaryPurple, size: 24),
              const SizedBox(width: 8),
              Text(
                'Upgrade to Mystic',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryPurple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Get unlimited journal storage, access to all guides, and an ad-free experience.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.darkGray.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _handleUpgradeRequest(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Upgrade Now',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyReadingsState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            Icons.book_outlined,
            size: 48,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 12),
          Text(
            'No Saved Readings',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            'Start saving your readings to build your spiritual journal.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildErrorState(Object error) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.errorColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.errorColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(Icons.error_outline, color: AppTheme.errorColor),
          const SizedBox(height: 8),
          Text(
            'Unable to load journal management',
            style: TextStyle(color: AppTheme.errorColor),
          ),
        ],
      ),
    );
  }

  Widget _buildUsageLoadingState(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildUsageErrorState(BuildContext context, Object error) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.errorColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'Unable to load usage information',
        style: TextStyle(color: AppTheme.errorColor),
      ),
    );
  }

  Widget _buildReadingsLoadingState(BuildContext context) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildReadingsErrorState(Object error) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.errorColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'Unable to load saved readings',
        style: TextStyle(color: AppTheme.errorColor),
      ),
    );
  }

  Color _getTopicColor(ReadingTopic topic) {
    switch (topic) {
      case ReadingTopic.self:
        return AppTheme.primaryPurple;
      case ReadingTopic.love:
        return Colors.pink;
      case ReadingTopic.work:
        return AppTheme.softGold;
      case ReadingTopic.social:
        return Colors.blue;
    }
  }

  IconData _getTopicIcon(ReadingTopic topic) {
    switch (topic) {
      case ReadingTopic.self:
        return Icons.self_improvement;
      case ReadingTopic.love:
        return Icons.favorite;
      case ReadingTopic.work:
        return Icons.work;
      case ReadingTopic.social:
        return Icons.people;
    }
  }

  void _handleReadingAction(
    BuildContext context,
    Reading reading,
    String action,
  ) {
    if (action == 'delete') {
      _showDeleteConfirmation(context, reading);
    }
  }

  void _showDeleteConfirmation(BuildContext context, Reading reading) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Reading'),
        content: Text(
          'Are you sure you want to delete "${reading.displayTitle}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteReading(context, reading);
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.errorColor),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _deleteReading(BuildContext context, Reading reading) {
    // This will be handled by the consumer's ref
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Reading deleted'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _handleUpgradeRequest(BuildContext context) {
    // TODO: Navigate to subscription management
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Upgrade to Mystic requested'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _navigateToFullJournal(BuildContext context) {
    // TODO: Navigate to full journal page
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Navigate to full journal')));
  }
}

/// Compact version for use in other screens
class CompactJournalManagementWidget extends StatelessWidget {
  const CompactJournalManagementWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const JournalManagementWidget(
      compact: true,
      showUpgradePrompt: false,
    );
  }
}
