import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/subscription_sync_provider.dart';
import '../services/subscription_sync_service.dart';

/// Dialog for restoring subscriptions when switching devices
class SubscriptionRestorationDialog extends ConsumerStatefulWidget {
  const SubscriptionRestorationDialog({super.key});

  @override
  ConsumerState<SubscriptionRestorationDialog> createState() =>
      _SubscriptionRestorationDialogState();
}

class _SubscriptionRestorationDialogState
    extends ConsumerState<SubscriptionRestorationDialog> {
  bool _isRestoring = false;
  RestoreResult? _restoreResult;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Restore Subscriptions'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_restoreResult == null && !_isRestoring) ...[
            const Text(
              'If you previously purchased a subscription on this device or another device with the same account, you can restore it here.',
            ),
            const SizedBox(height: 16),
            const Text(
              'This will check your App Store or Google Play account for any active subscriptions.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ] else if (_isRestoring) ...[
            const Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 16),
                Expanded(child: Text('Checking for subscriptions...')),
              ],
            ),
          ] else if (_restoreResult != null) ...[
            _buildResultContent(),
          ],
        ],
      ),
      actions: _buildActions(context),
    );
  }

  Widget _buildResultContent() {
    final result = _restoreResult!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              result.isSuccess ? Icons.check_circle : Icons.error,
              color: result.isSuccess ? Colors.green : Colors.red,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                result.displayMessage,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: result.isSuccess ? Colors.green : Colors.red,
                ),
              ),
            ),
          ],
        ),
        if (_errorMessage != null) ...[
          const SizedBox(height: 8),
          Text(
            _errorMessage!,
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
        if (result == RestoreResult.success) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
            ),
            child: const Row(
              children: [
                Icon(Icons.info, color: Colors.green, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Your subscription has been restored and is now active.',
                    style: TextStyle(color: Colors.green),
                  ),
                ),
              ],
            ),
          ),
        ] else if (result == RestoreResult.noSubscriptionsFound) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info, color: Colors.blue, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'No subscriptions found',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  'If you believe you have an active subscription, make sure you\'re signed in with the same account you used to purchase it.',
                  style: TextStyle(color: Colors.blue, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  List<Widget> _buildActions(BuildContext context) {
    if (_isRestoring) {
      return [TextButton(onPressed: null, child: const Text('Cancel'))];
    }

    if (_restoreResult != null) {
      return [
        if (_restoreResult!.isError)
          TextButton(onPressed: _retryRestore, child: const Text('Retry')),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(_restoreResult!.isSuccess ? 'Done' : 'Close'),
        ),
      ];
    }

    return [
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: const Text('Cancel'),
      ),
      ElevatedButton(onPressed: _performRestore, child: const Text('Restore')),
    ];
  }

  Future<void> _performRestore() async {
    setState(() {
      _isRestoring = true;
      _restoreResult = null;
      _errorMessage = null;
    });

    try {
      final result = await ref
          .read(subscriptionSyncProvider.notifier)
          .restoreSubscriptions();

      setState(() {
        _isRestoring = false;
        _restoreResult = result;
      });
    } catch (e) {
      setState(() {
        _isRestoring = false;
        _restoreResult = RestoreResult.unknownError;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _retryRestore() async {
    setState(() {
      _restoreResult = null;
      _errorMessage = null;
    });

    await _performRestore();
  }
}

/// Helper function to show the restoration dialog
Future<void> showSubscriptionRestorationDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (context) => const SubscriptionRestorationDialog(),
  );
}

/// Widget for displaying a restore subscriptions button
class RestoreSubscriptionsButton extends ConsumerWidget {
  const RestoreSubscriptionsButton({super.key, this.style, this.icon});

  final ButtonStyle? style;
  final Widget? icon;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSyncInProgress = ref.watch(isSyncInProgressProvider);

    return ElevatedButton.icon(
      onPressed: isSyncInProgress
          ? null
          : () => showSubscriptionRestorationDialog(context),
      icon: icon ?? const Icon(Icons.restore),
      label: const Text('Restore Purchases'),
      style: style,
    );
  }
}

/// Compact restore button for use in smaller spaces
class CompactRestoreButton extends ConsumerWidget {
  const CompactRestoreButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSyncInProgress = ref.watch(isSyncInProgressProvider);

    return TextButton.icon(
      onPressed: isSyncInProgress
          ? null
          : () => showSubscriptionRestorationDialog(context),
      icon: const Icon(Icons.restore, size: 18),
      label: const Text('Restore'),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }
}
