import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/subscription_sync_provider.dart';
import '../services/subscription_sync_service.dart';

/// Widget that displays subscription synchronization status
class SubscriptionSyncStatusWidget extends ConsumerWidget {
  const SubscriptionSyncStatusWidget({
    super.key,
    this.showDetails = false,
    this.onManualSync,
    this.onRestore,
  });

  /// Whether to show detailed sync information
  final bool showDetails;

  /// Callback for manual sync action
  final VoidCallback? onManualSync;

  /// Callback for restore action
  final VoidCallback? onRestore;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncStatus = ref.watch(subscriptionSyncProvider);
    final syncMessage = ref.watch(syncStatusMessageProvider);
    final canManualSync = ref.watch(canManualSyncProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                _buildStatusIcon(syncStatus),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Subscription Status',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                if (canManualSync && onManualSync != null)
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: onManualSync,
                    tooltip: 'Sync now',
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              syncMessage,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: _getStatusColor(context, syncStatus),
              ),
            ),
            if (showDetails) ...[
              const SizedBox(height: 16),
              _buildDetailedInfo(context, ref),
            ],
            if (syncStatus == SyncStatus.expired) ...[
              const SizedBox(height: 12),
              _buildExpiredActions(context, ref),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIcon(SyncStatus status) {
    switch (status) {
      case SyncStatus.idle:
        return const Icon(Icons.check_circle_outline, color: Colors.grey);
      case SyncStatus.syncing:
        return const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        );
      case SyncStatus.success:
        return const Icon(Icons.check_circle, color: Colors.green);
      case SyncStatus.failed:
        return const Icon(Icons.error_outline, color: Colors.red);
      case SyncStatus.expired:
        return const Icon(Icons.warning, color: Colors.orange);
      case SyncStatus.restoring:
        return const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        );
    }
  }

  Color _getStatusColor(BuildContext context, SyncStatus status) {
    switch (status) {
      case SyncStatus.idle:
        return Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey;
      case SyncStatus.syncing:
      case SyncStatus.restoring:
        return Colors.blue;
      case SyncStatus.success:
        return Colors.green;
      case SyncStatus.failed:
        return Colors.red;
      case SyncStatus.expired:
        return Colors.orange;
    }
  }

  Widget _buildDetailedInfo(BuildContext context, WidgetRef ref) {
    final syncNotifier = ref.read(subscriptionSyncProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (syncNotifier.lastSuccessfulSync != null) ...[
          Text(
            'Last sync: ${_formatDateTime(syncNotifier.lastSuccessfulSync!)}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 4),
        ],
        if (syncNotifier.timeUntilNextSync != null) ...[
          Text(
            'Next sync: ${_formatDuration(syncNotifier.timeUntilNextSync!)}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 4),
        ],
        if (syncNotifier.isSyncOverdue) ...[
          Text(
            'Sync is overdue',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.orange,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildExpiredActions(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: onRestore,
            icon: const Icon(Icons.restore),
            label: const Text('Restore'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              // Navigate to subscription management
              // This would be implemented based on your navigation setup
            },
            icon: const Icon(Icons.shopping_cart),
            label: const Text('Renew'),
          ),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  String _formatDuration(Duration duration) {
    if (duration.isNegative || duration == Duration.zero) {
      return 'Now';
    }

    if (duration.inMinutes < 60) {
      return 'in ${duration.inMinutes}m';
    } else if (duration.inHours < 24) {
      return 'in ${duration.inHours}h';
    } else {
      return 'in ${duration.inDays}d';
    }
  }
}

/// Compact version of the sync status widget for use in app bars or status bars
class CompactSyncStatusWidget extends ConsumerWidget {
  const CompactSyncStatusWidget({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncStatus = ref.watch(subscriptionSyncProvider);
    final isSyncInProgress = ref.watch(isSyncInProgressProvider);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSyncInProgress)
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              Icon(
                _getCompactIcon(syncStatus),
                size: 16,
                color: _getCompactColor(syncStatus),
              ),
            const SizedBox(width: 4),
            Text(
              _getCompactText(syncStatus),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: _getCompactColor(syncStatus),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCompactIcon(SyncStatus status) {
    switch (status) {
      case SyncStatus.idle:
        return Icons.sync;
      case SyncStatus.syncing:
      case SyncStatus.restoring:
        return Icons.sync;
      case SyncStatus.success:
        return Icons.sync;
      case SyncStatus.failed:
        return Icons.sync_problem;
      case SyncStatus.expired:
        return Icons.warning;
    }
  }

  Color _getCompactColor(SyncStatus status) {
    switch (status) {
      case SyncStatus.idle:
        return Colors.grey;
      case SyncStatus.syncing:
      case SyncStatus.restoring:
        return Colors.blue;
      case SyncStatus.success:
        return Colors.green;
      case SyncStatus.failed:
        return Colors.red;
      case SyncStatus.expired:
        return Colors.orange;
    }
  }

  String _getCompactText(SyncStatus status) {
    switch (status) {
      case SyncStatus.idle:
        return 'Sync';
      case SyncStatus.syncing:
        return 'Syncing';
      case SyncStatus.success:
        return 'Synced';
      case SyncStatus.failed:
        return 'Failed';
      case SyncStatus.expired:
        return 'Expired';
      case SyncStatus.restoring:
        return 'Restoring';
    }
  }
}
