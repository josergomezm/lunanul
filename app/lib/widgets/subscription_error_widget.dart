import 'package:flutter/material.dart';

import '../models/subscription_errors.dart';
import '../services/subscription_error_handler.dart';

/// Widget for displaying subscription errors with recovery options
class SubscriptionErrorWidget extends StatelessWidget {
  const SubscriptionErrorWidget({
    super.key,
    required this.error,
    this.onRetry,
    this.onDismiss,
    this.showRecoverySuggestions = true,
    this.errorHandler,
  });

  /// The subscription error to display
  final SubscriptionException error;

  /// Callback for retry action
  final VoidCallback? onRetry;

  /// Callback for dismiss action
  final VoidCallback? onDismiss;

  /// Whether to show recovery suggestions
  final bool showRecoverySuggestions;

  /// Error handler for getting user-friendly messages
  final SubscriptionErrorHandler? errorHandler;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final handler = errorHandler ?? SubscriptionErrorHandler();

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Error header
            Row(
              children: [
                Icon(_getErrorIcon(), color: _getErrorColor(theme), size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    error.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: _getErrorColor(theme),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (onDismiss != null)
                  IconButton(
                    onPressed: onDismiss,
                    icon: const Icon(Icons.close),
                    iconSize: 20,
                  ),
              ],
            ),

            const SizedBox(height: 12),

            // Error message
            Text(
              handler.getUserFriendlyMessage(error),
              style: theme.textTheme.bodyMedium,
            ),

            // Recovery suggestions
            if (showRecoverySuggestions) ...[
              const SizedBox(height: 16),
              _buildRecoverySuggestions(context, handler),
            ],

            // Action buttons
            const SizedBox(height: 16),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildRecoverySuggestions(
    BuildContext context,
    SubscriptionErrorHandler handler,
  ) {
    final suggestions = handler.getRecoverySuggestions(error);
    if (suggestions.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Try these steps:',
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        ...suggestions.map(
          (suggestion) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '• ',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
                Expanded(
                  child: Text(suggestion, style: theme.textTheme.bodySmall),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (onDismiss != null)
          TextButton(onPressed: onDismiss, child: const Text('Dismiss')),

        if (onRetry != null && error.shouldRetry) ...[
          const SizedBox(width: 8),
          FilledButton(onPressed: onRetry, child: const Text('Try Again')),
        ],
      ],
    );
  }

  IconData _getErrorIcon() {
    switch (error.error) {
      case SubscriptionError.networkError:
        return Icons.wifi_off;
      case SubscriptionError.platformError:
        return Icons.store;
      case SubscriptionError.paymentFailed:
        return Icons.payment;
      case SubscriptionError.subscriptionExpired:
        return Icons.schedule;
      case SubscriptionError.verificationFailed:
        return Icons.verified_user;
      case SubscriptionError.purchaseCancelled:
        return Icons.cancel;
      case SubscriptionError.restorationFailed:
        return Icons.restore;
      case SubscriptionError.serverError:
        return Icons.cloud_off;
      default:
        return Icons.error_outline;
    }
  }

  Color _getErrorColor(ThemeData theme) {
    switch (error.error) {
      case SubscriptionError.networkError:
      case SubscriptionError.platformError:
      case SubscriptionError.verificationFailed:
      case SubscriptionError.serverError:
        return theme.colorScheme.primary; // Recoverable errors
      case SubscriptionError.subscriptionExpired:
        return Colors.orange; // Warning
      case SubscriptionError.purchaseCancelled:
        return theme.colorScheme.outline; // Neutral
      default:
        return theme.colorScheme.error; // Error
    }
  }
}

/// Compact error banner for inline display
class SubscriptionErrorBanner extends StatelessWidget {
  const SubscriptionErrorBanner({
    super.key,
    required this.error,
    this.onRetry,
    this.onDismiss,
    this.errorHandler,
  });

  final SubscriptionException error;
  final VoidCallback? onRetry;
  final VoidCallback? onDismiss;
  final SubscriptionErrorHandler? errorHandler;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final handler = errorHandler ?? SubscriptionErrorHandler();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _getBackgroundColor(theme),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _getErrorColor(theme).withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(_getErrorIcon(), color: _getErrorColor(theme), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              handler.getUserFriendlyMessage(error),
              style: theme.textTheme.bodySmall?.copyWith(
                color: _getErrorColor(theme),
              ),
            ),
          ),
          if (onRetry != null && error.shouldRetry) ...[
            const SizedBox(width: 8),
            TextButton(
              onPressed: onRetry,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Retry',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: _getErrorColor(theme),
                ),
              ),
            ),
          ],
          if (onDismiss != null) ...[
            const SizedBox(width: 4),
            IconButton(
              onPressed: onDismiss,
              icon: const Icon(Icons.close),
              iconSize: 16,
              padding: const EdgeInsets.all(4),
              constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
            ),
          ],
        ],
      ),
    );
  }

  IconData _getErrorIcon() {
    switch (error.error) {
      case SubscriptionError.networkError:
        return Icons.wifi_off;
      case SubscriptionError.platformError:
        return Icons.store;
      case SubscriptionError.paymentFailed:
        return Icons.payment;
      case SubscriptionError.subscriptionExpired:
        return Icons.schedule;
      case SubscriptionError.verificationFailed:
        return Icons.verified_user;
      case SubscriptionError.purchaseCancelled:
        return Icons.cancel;
      case SubscriptionError.restorationFailed:
        return Icons.restore;
      case SubscriptionError.serverError:
        return Icons.cloud_off;
      default:
        return Icons.error_outline;
    }
  }

  Color _getErrorColor(ThemeData theme) {
    switch (error.error) {
      case SubscriptionError.networkError:
      case SubscriptionError.platformError:
      case SubscriptionError.verificationFailed:
      case SubscriptionError.serverError:
        return theme.colorScheme.primary;
      case SubscriptionError.subscriptionExpired:
        return Colors.orange;
      case SubscriptionError.purchaseCancelled:
        return theme.colorScheme.outline;
      default:
        return theme.colorScheme.error;
    }
  }

  Color _getBackgroundColor(ThemeData theme) {
    return _getErrorColor(theme).withValues(alpha: 0.1);
  }
}

/// Snackbar for temporary error notifications
class SubscriptionErrorSnackBar {
  static void show(
    BuildContext context,
    SubscriptionException error, {
    VoidCallback? onRetry,
    SubscriptionErrorHandler? errorHandler,
  }) {
    final handler = errorHandler ?? SubscriptionErrorHandler();
    final messenger = ScaffoldMessenger.of(context);

    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(_getErrorIcon(error), color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                handler.getUserFriendlyMessage(error),
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: _getSnackBarColor(error),
        action: onRetry != null && error.shouldRetry
            ? SnackBarAction(
                label: 'Retry',
                textColor: Colors.white,
                onPressed: onRetry,
              )
            : null,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  static IconData _getErrorIcon(SubscriptionException error) {
    switch (error.error) {
      case SubscriptionError.networkError:
        return Icons.wifi_off;
      case SubscriptionError.platformError:
        return Icons.store;
      case SubscriptionError.paymentFailed:
        return Icons.payment;
      case SubscriptionError.subscriptionExpired:
        return Icons.schedule;
      case SubscriptionError.verificationFailed:
        return Icons.verified_user;
      case SubscriptionError.purchaseCancelled:
        return Icons.cancel;
      case SubscriptionError.restorationFailed:
        return Icons.restore;
      case SubscriptionError.serverError:
        return Icons.cloud_off;
      default:
        return Icons.error_outline;
    }
  }

  static Color _getSnackBarColor(SubscriptionException error) {
    switch (error.error) {
      case SubscriptionError.networkError:
      case SubscriptionError.platformError:
      case SubscriptionError.verificationFailed:
      case SubscriptionError.serverError:
        return Colors.blue;
      case SubscriptionError.subscriptionExpired:
        return Colors.orange;
      case SubscriptionError.purchaseCancelled:
        return Colors.grey;
      default:
        return Colors.red;
    }
  }
}

/// Dialog for critical subscription errors
class SubscriptionErrorDialog extends StatelessWidget {
  const SubscriptionErrorDialog({
    super.key,
    required this.error,
    this.onRetry,
    this.onDismiss,
    this.errorHandler,
  });

  final SubscriptionException error;
  final VoidCallback? onRetry;
  final VoidCallback? onDismiss;
  final SubscriptionErrorHandler? errorHandler;

  @override
  Widget build(BuildContext context) {
    final handler = errorHandler ?? SubscriptionErrorHandler();

    return AlertDialog(
      icon: Icon(
        _getErrorIcon(),
        color: _getErrorColor(Theme.of(context)),
        size: 32,
      ),
      title: Text(error.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(handler.getUserFriendlyMessage(error)),

          const SizedBox(height: 16),

          // Recovery suggestions
          ...handler
              .getRecoverySuggestions(error)
              .map(
                (suggestion) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• '),
                      Expanded(child: Text(suggestion)),
                    ],
                  ),
                ),
              ),
        ],
      ),
      actions: [
        if (onDismiss != null)
          TextButton(onPressed: onDismiss, child: const Text('OK')),

        if (onRetry != null && error.shouldRetry)
          FilledButton(onPressed: onRetry, child: const Text('Try Again')),
      ],
    );
  }

  IconData _getErrorIcon() {
    switch (error.error) {
      case SubscriptionError.networkError:
        return Icons.wifi_off;
      case SubscriptionError.platformError:
        return Icons.store;
      case SubscriptionError.paymentFailed:
        return Icons.payment;
      case SubscriptionError.subscriptionExpired:
        return Icons.schedule;
      case SubscriptionError.verificationFailed:
        return Icons.verified_user;
      case SubscriptionError.purchaseCancelled:
        return Icons.cancel;
      case SubscriptionError.restorationFailed:
        return Icons.restore;
      case SubscriptionError.serverError:
        return Icons.cloud_off;
      default:
        return Icons.error_outline;
    }
  }

  Color _getErrorColor(ThemeData theme) {
    switch (error.error) {
      case SubscriptionError.networkError:
      case SubscriptionError.platformError:
      case SubscriptionError.verificationFailed:
      case SubscriptionError.serverError:
        return theme.colorScheme.primary;
      case SubscriptionError.subscriptionExpired:
        return Colors.orange;
      case SubscriptionError.purchaseCancelled:
        return theme.colorScheme.outline;
      default:
        return theme.colorScheme.error;
    }
  }

  /// Show the error dialog
  static Future<void> show(
    BuildContext context,
    SubscriptionException error, {
    VoidCallback? onRetry,
    VoidCallback? onDismiss,
    SubscriptionErrorHandler? errorHandler,
  }) {
    return showDialog<void>(
      context: context,
      builder: (context) => SubscriptionErrorDialog(
        error: error,
        onRetry: onRetry,
        onDismiss: onDismiss,
        errorHandler: errorHandler,
      ),
    );
  }
}
