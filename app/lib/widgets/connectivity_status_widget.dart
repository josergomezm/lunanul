import 'package:flutter/material.dart';

import '../services/network_connectivity_service.dart';

/// Widget that displays current network connectivity status
class ConnectivityStatusWidget extends StatelessWidget {
  const ConnectivityStatusWidget({
    super.key,
    required this.connectivityInfo,
    this.showWhenConnected = false,
    this.onRetry,
  });

  /// Current connectivity information
  final ConnectivityInfo connectivityInfo;

  /// Whether to show the widget when connected
  final bool showWhenConnected;

  /// Callback for retry action
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    // Don't show anything if connected and showWhenConnected is false
    if (connectivityInfo.isConnected && !showWhenConnected) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: _getBackgroundColor(theme),
        border: Border(
          bottom: BorderSide(
            color: _getStatusColor(theme).withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(_getStatusIcon(), color: _getStatusColor(theme), size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _getStatusMessage(),
              style: theme.textTheme.bodySmall?.copyWith(
                color: _getStatusColor(theme),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (connectivityInfo.isDisconnected && onRetry != null) ...[
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
                  color: _getStatusColor(theme),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  IconData _getStatusIcon() {
    switch (connectivityInfo.status) {
      case ConnectivityStatus.connected:
        return Icons.wifi;
      case ConnectivityStatus.disconnected:
        return Icons.wifi_off;
      case ConnectivityStatus.unknown:
        return Icons.help_outline;
    }
  }

  Color _getStatusColor(ThemeData theme) {
    switch (connectivityInfo.status) {
      case ConnectivityStatus.connected:
        return Colors.green;
      case ConnectivityStatus.disconnected:
        return theme.colorScheme.error;
      case ConnectivityStatus.unknown:
        return theme.colorScheme.outline;
    }
  }

  Color _getBackgroundColor(ThemeData theme) {
    return _getStatusColor(theme).withValues(alpha: 0.1);
  }

  String _getStatusMessage() {
    switch (connectivityInfo.status) {
      case ConnectivityStatus.connected:
        final responseTime = connectivityInfo.responseTime;
        if (responseTime != null) {
          return 'Connected (${responseTime}ms)';
        }
        return 'Connected to internet';
      case ConnectivityStatus.disconnected:
        return 'No internet connection';
      case ConnectivityStatus.unknown:
        return 'Connection status unknown';
    }
  }
}

/// Floating connectivity indicator
class ConnectivityIndicator extends StatelessWidget {
  const ConnectivityIndicator({
    super.key,
    required this.connectivityInfo,
    this.position = ConnectivityIndicatorPosition.topRight,
  });

  /// Current connectivity information
  final ConnectivityInfo connectivityInfo;

  /// Position of the indicator
  final ConnectivityIndicatorPosition position;

  @override
  Widget build(BuildContext context) {
    // Only show when disconnected
    if (connectivityInfo.isConnected) {
      return const SizedBox.shrink();
    }

    return Positioned(
      top:
          position == ConnectivityIndicatorPosition.topLeft ||
              position == ConnectivityIndicatorPosition.topRight
          ? 16
          : null,
      bottom:
          position == ConnectivityIndicatorPosition.bottomLeft ||
              position == ConnectivityIndicatorPosition.bottomRight
          ? 16
          : null,
      left:
          position == ConnectivityIndicatorPosition.topLeft ||
              position == ConnectivityIndicatorPosition.bottomLeft
          ? 16
          : null,
      right:
          position == ConnectivityIndicatorPosition.topRight ||
              position == ConnectivityIndicatorPosition.bottomRight
          ? 16
          : null,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: connectivityInfo.isDisconnected ? 1.0 : 0.0,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.error,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wifi_off, color: Colors.white, size: 16),
              const SizedBox(width: 6),
              Text(
                'Offline',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Position options for connectivity indicator
enum ConnectivityIndicatorPosition {
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
}

/// Stream builder wrapper for connectivity status
class ConnectivityStatusBuilder extends StatelessWidget {
  const ConnectivityStatusBuilder({
    super.key,
    required this.connectivityService,
    required this.builder,
    this.initialData,
  });

  /// Connectivity service to monitor
  final NetworkConnectivityService connectivityService;

  /// Builder function that receives connectivity info
  final Widget Function(
    BuildContext context,
    ConnectivityInfo? connectivityInfo,
  )
  builder;

  /// Initial connectivity data
  final ConnectivityInfo? initialData;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ConnectivityInfo>(
      stream: connectivityService.connectivityStream,
      initialData: initialData,
      builder: (context, snapshot) {
        return builder(context, snapshot.data);
      },
    );
  }
}

/// Wrapper widget that shows connectivity status and handles offline scenarios
class ConnectivityAwareWidget extends StatelessWidget {
  const ConnectivityAwareWidget({
    super.key,
    required this.connectivityService,
    required this.child,
    this.offlineWidget,
    this.showConnectivityStatus = true,
    this.onRetry,
  });

  /// Connectivity service to monitor
  final NetworkConnectivityService connectivityService;

  /// Child widget to show when connected
  final Widget child;

  /// Widget to show when offline (if null, shows default offline message)
  final Widget? offlineWidget;

  /// Whether to show connectivity status bar
  final bool showConnectivityStatus;

  /// Callback for retry action
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return ConnectivityStatusBuilder(
      connectivityService: connectivityService,
      builder: (context, connectivityInfo) {
        if (connectivityInfo == null) {
          return child; // Show child while loading connectivity status
        }

        return Column(
          children: [
            // Connectivity status bar
            if (showConnectivityStatus)
              ConnectivityStatusWidget(
                connectivityInfo: connectivityInfo,
                onRetry: onRetry,
              ),

            // Main content
            Expanded(
              child: connectivityInfo.isDisconnected
                  ? offlineWidget ?? _buildDefaultOfflineWidget(context)
                  : child,
            ),
          ],
        );
      },
    );
  }

  Widget _buildDefaultOfflineWidget(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off, size: 64, color: theme.colorScheme.outline),
            const SizedBox(height: 16),
            Text(
              'No Internet Connection',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Please check your connection and try again.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Mixin for widgets that need connectivity awareness
mixin ConnectivityAwareMixin<T extends StatefulWidget> on State<T> {
  NetworkConnectivityService? _connectivityService;
  ConnectivityInfo? _connectivityInfo;

  /// Initialize connectivity monitoring
  void initConnectivityMonitoring(
    NetworkConnectivityService connectivityService,
  ) {
    _connectivityService = connectivityService;
    _connectivityService!.connectivityStream.listen((info) {
      if (mounted) {
        setState(() {
          _connectivityInfo = info;
        });
        onConnectivityChanged(info);
      }
    });
  }

  /// Called when connectivity status changes
  void onConnectivityChanged(ConnectivityInfo info) {
    // Override in subclasses to handle connectivity changes
  }

  /// Get current connectivity info
  ConnectivityInfo? get connectivityInfo => _connectivityInfo;

  /// Check if currently connected
  bool get isConnected => _connectivityInfo?.isConnected ?? true;

  /// Check if currently disconnected
  bool get isDisconnected => _connectivityInfo?.isDisconnected ?? false;

  @override
  void dispose() {
    // Connectivity service disposal is handled by the service itself
    super.dispose();
  }
}
