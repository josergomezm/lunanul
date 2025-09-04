import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/enums.dart';
import '../models/subscription_status.dart';
import '../providers/subscription_provider.dart';

/// Widget that displays current subscription status with renewal dates and management options
class SubscriptionStatusWidget extends ConsumerWidget {
  final SubscriptionStatus subscription;

  const SubscriptionStatusWidget({super.key, required this.subscription});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 16),
            _buildStatusInfo(context),
            const SizedBox(height: 20),
            _buildActionButtons(context, ref),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final tierInfo = _getTierInfo(subscription.tier);

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            tierInfo.icon,
            color: theme.colorScheme.primary,
            size: 28,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${tierInfo.name} Plan',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: subscription.isActive
                          ? Colors.green.withValues(alpha: 0.2)
                          : Colors.orange.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
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
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusInfo(BuildContext context) {
    return Column(
      children: [
        if (subscription.tier != SubscriptionTier.seeker) ...[
          _buildInfoRow(
            context,
            Icons.calendar_today,
            'Renewal Date',
            _formatRenewalDate(),
          ),
          const SizedBox(height: 12),
          _buildInfoRow(context, Icons.payment, 'Billing Cycle', 'Monthly'),
          const SizedBox(height: 12),
        ],
        _buildInfoRow(
          context,
          Icons.access_time,
          'Member Since',
          _formatMemberSince(),
        ),
        if (subscription.platformSubscriptionId != null) ...[
          const SizedBox(height: 12),
          _buildInfoRow(
            context,
            Icons.receipt,
            'Subscription ID',
            '${subscription.platformSubscriptionId!.substring(0, 8)}...',
          ),
        ],
      ],
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.onSurfaceVariant),
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

  Widget _buildActionButtons(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        if (subscription.tier != SubscriptionTier.seeker) ...[
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showManageSubscriptionDialog(context, ref),
              icon: const Icon(Icons.settings),
              label: const Text('Manage Subscription'),
            ),
          ),
          const SizedBox(height: 8),
        ],
        SizedBox(
          width: double.infinity,
          child: TextButton.icon(
            onPressed: () => _refreshSubscriptionStatus(ref),
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh Status'),
          ),
        ),
      ],
    );
  }

  void _showManageSubscriptionDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Manage Subscription'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Choose an action for your subscription:'),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.pause),
              title: const Text('Pause Subscription'),
              subtitle: const Text('Temporarily pause your subscription'),
              onTap: () {
                Navigator.of(context).pop();
                _pauseSubscription(ref);
              },
            ),
            ListTile(
              leading: const Icon(Icons.cancel),
              title: const Text('Cancel Subscription'),
              subtitle: const Text('Cancel at the end of billing period'),
              onTap: () {
                Navigator.of(context).pop();
                _showCancelConfirmation(context, ref);
              },
            ),
            ListTile(
              leading: const Icon(Icons.restore),
              title: const Text('Restore Purchases'),
              subtitle: const Text('Restore previous purchases'),
              onTap: () {
                Navigator.of(context).pop();
                _restorePurchases(ref);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showCancelConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Subscription'),
        content: const Text(
          'Are you sure you want to cancel your subscription? '
          'You will continue to have access until the end of your current billing period.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Keep Subscription'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _cancelSubscription(ref);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _refreshSubscriptionStatus(WidgetRef ref) {
    final _ = ref.refresh(subscriptionProvider);
    ScaffoldMessenger.of(ref.context).showSnackBar(
      const SnackBar(
        content: Text('Subscription status refreshed'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _pauseSubscription(WidgetRef ref) {
    // Implementation would depend on platform capabilities
    ScaffoldMessenger.of(ref.context).showSnackBar(
      const SnackBar(
        content: Text('Subscription pause requested'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _cancelSubscription(WidgetRef ref) {
    // Implementation would depend on platform capabilities
    ScaffoldMessenger.of(ref.context).showSnackBar(
      const SnackBar(
        content: Text('Subscription cancellation requested'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _restorePurchases(WidgetRef ref) {
    ref.read(subscriptionProvider.notifier).restoreSubscriptions();
    ScaffoldMessenger.of(ref.context).showSnackBar(
      const SnackBar(
        content: Text('Restoring purchases...'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  String _formatRenewalDate() {
    if (subscription.expirationDate == null) {
      return 'N/A';
    }

    final now = DateTime.now();
    final expiration = subscription.expirationDate!;
    final difference = expiration.difference(now).inDays;

    if (difference < 0) {
      return 'Expired';
    } else if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Tomorrow';
    } else if (difference < 30) {
      return 'In $difference days';
    } else {
      return '${expiration.day}/${expiration.month}/${expiration.year}';
    }
  }

  String _formatMemberSince() {
    final memberSince = subscription.lastUpdated;
    return '${memberSince.day}/${memberSince.month}/${memberSince.year}';
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
