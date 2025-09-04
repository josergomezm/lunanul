import 'dart:async';
import 'dart:io';

/// Network connectivity status
enum ConnectivityStatus {
  /// Connected to the internet
  connected,

  /// Disconnected from the internet
  disconnected,

  /// Connection status is unknown
  unknown,
}

/// Network connectivity information
class ConnectivityInfo {
  const ConnectivityInfo({
    required this.status,
    this.lastChecked,
    this.responseTime,
  });

  /// Current connectivity status
  final ConnectivityStatus status;

  /// When the status was last checked
  final DateTime? lastChecked;

  /// Response time for the last connectivity check (in milliseconds)
  final int? responseTime;

  /// Whether the device is connected to the internet
  bool get isConnected => status == ConnectivityStatus.connected;

  /// Whether the device is disconnected from the internet
  bool get isDisconnected => status == ConnectivityStatus.disconnected;

  /// Whether the connection status is unknown
  bool get isUnknown => status == ConnectivityStatus.unknown;

  ConnectivityInfo copyWith({
    ConnectivityStatus? status,
    DateTime? lastChecked,
    int? responseTime,
  }) {
    return ConnectivityInfo(
      status: status ?? this.status,
      lastChecked: lastChecked ?? this.lastChecked,
      responseTime: responseTime ?? this.responseTime,
    );
  }

  @override
  String toString() {
    return 'ConnectivityInfo(status: $status, lastChecked: $lastChecked, responseTime: ${responseTime}ms)';
  }
}

/// Service for monitoring network connectivity
abstract class NetworkConnectivityService {
  /// Get current connectivity status
  Future<ConnectivityInfo> getConnectivityStatus();

  /// Stream of connectivity status changes
  Stream<ConnectivityInfo> get connectivityStream;

  /// Check if a specific host is reachable
  Future<bool> canReachHost(
    String host, {
    int port = 80,
    Duration timeout = const Duration(seconds: 5),
  });

  /// Perform a connectivity test with detailed information
  Future<ConnectivityInfo> performConnectivityTest();

  /// Dispose of any resources
  void dispose();
}

/// Implementation of NetworkConnectivityService
class NetworkConnectivityServiceImpl implements NetworkConnectivityService {
  NetworkConnectivityServiceImpl({
    this.testHosts = const ['google.com', 'apple.com', 'cloudflare.com'],
    this.checkInterval = const Duration(seconds: 30),
    this.timeout = const Duration(seconds: 5),
  }) {
    _startPeriodicChecks();
  }

  /// Hosts to test connectivity against
  final List<String> testHosts;

  /// Interval between automatic connectivity checks
  final Duration checkInterval;

  /// Timeout for connectivity tests
  final Duration timeout;

  /// Current connectivity information
  ConnectivityInfo _currentInfo = const ConnectivityInfo(
    status: ConnectivityStatus.unknown,
  );

  /// Stream controller for connectivity updates
  final StreamController<ConnectivityInfo> _connectivityController =
      StreamController<ConnectivityInfo>.broadcast();

  /// Timer for periodic connectivity checks
  Timer? _periodicTimer;

  /// Whether the service has been disposed
  bool _disposed = false;

  void _startPeriodicChecks() {
    // Perform initial check
    _performCheck();

    // Start periodic checks
    _periodicTimer = Timer.periodic(checkInterval, (_) {
      if (!_disposed) {
        _performCheck();
      }
    });
  }

  Future<void> _performCheck() async {
    if (_disposed) return;

    try {
      final info = await performConnectivityTest();
      _updateConnectivityInfo(info);
    } catch (e) {
      // If connectivity test fails, assume disconnected
      _updateConnectivityInfo(
        ConnectivityInfo(
          status: ConnectivityStatus.disconnected,
          lastChecked: DateTime.now(),
        ),
      );
    }
  }

  void _updateConnectivityInfo(ConnectivityInfo info) {
    if (_disposed) return;

    final previousStatus = _currentInfo.status;
    _currentInfo = info;

    // Only emit if status changed or this is the first check
    if (previousStatus != info.status ||
        previousStatus == ConnectivityStatus.unknown) {
      _connectivityController.add(info);
    }
  }

  @override
  Future<ConnectivityInfo> getConnectivityStatus() async {
    if (_disposed) throw StateError('Service has been disposed');

    // If we have recent connectivity info, return it
    if (_currentInfo.lastChecked != null) {
      final age = DateTime.now().difference(_currentInfo.lastChecked!);
      if (age < const Duration(minutes: 1)) {
        return _currentInfo;
      }
    }

    // Otherwise, perform a fresh check
    return performConnectivityTest();
  }

  @override
  Stream<ConnectivityInfo> get connectivityStream {
    if (_disposed) throw StateError('Service has been disposed');

    // Create a stream that emits current status first, then future updates
    late StreamController<ConnectivityInfo> controller;
    controller = StreamController<ConnectivityInfo>(
      onListen: () {
        // Emit current status immediately if available
        if (_currentInfo.status != ConnectivityStatus.unknown) {
          controller.add(_currentInfo);
        }

        // Forward all future updates
        _connectivityController.stream.listen(
          controller.add,
          onError: controller.addError,
          onDone: controller.close,
        );
      },
    );

    return controller.stream;
  }

  @override
  Future<bool> canReachHost(
    String host, {
    int port = 80,
    Duration timeout = const Duration(seconds: 5),
  }) async {
    if (_disposed) throw StateError('Service has been disposed');

    try {
      final socket = await Socket.connect(host, port, timeout: timeout);
      socket.destroy();
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<ConnectivityInfo> performConnectivityTest() async {
    if (_disposed) throw StateError('Service has been disposed');

    final startTime = DateTime.now();

    // Test connectivity to multiple hosts
    final results = await Future.wait(
      testHosts.map((host) => _testHost(host)),
      eagerError: false,
    );

    final endTime = DateTime.now();
    final responseTime = endTime.difference(startTime).inMilliseconds;

    // Determine connectivity status based on results
    final successfulTests = results.where((result) => result).length;
    final ConnectivityStatus status;

    if (successfulTests == 0) {
      status = ConnectivityStatus.disconnected;
    } else if (successfulTests >= (testHosts.length / 2).ceil()) {
      status = ConnectivityStatus.connected;
    } else {
      // Partial connectivity - treat as connected but with poor quality
      status = ConnectivityStatus.connected;
    }

    return ConnectivityInfo(
      status: status,
      lastChecked: endTime,
      responseTime: responseTime,
    );
  }

  Future<bool> _testHost(String host) async {
    try {
      // Try to resolve the host and connect
      final addresses = await InternetAddress.lookup(host);
      if (addresses.isEmpty) return false;

      // Try to connect to the first address
      final socket = await Socket.connect(
        addresses.first,
        80,
        timeout: timeout,
      );
      socket.destroy();
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  void dispose() {
    if (!_disposed) {
      _periodicTimer?.cancel();
      _connectivityController.close();
      _disposed = true;
    }
  }

  /// Get current connectivity info without performing a new test
  ConnectivityInfo get currentInfo => _currentInfo;

  /// Check if service is disposed
  bool get isDisposed => _disposed;
}

/// Mock implementation for testing
class MockNetworkConnectivityService implements NetworkConnectivityService {
  MockNetworkConnectivityService({
    ConnectivityStatus initialStatus = ConnectivityStatus.connected,
    this.simulateDelay = true,
  }) : _currentInfo = ConnectivityInfo(
         status: initialStatus,
         lastChecked: DateTime.now(),
         responseTime: 100,
       );

  final bool simulateDelay;
  ConnectivityInfo _currentInfo;
  final StreamController<ConnectivityInfo> _controller =
      StreamController<ConnectivityInfo>.broadcast();
  bool _disposed = false;

  @override
  Future<ConnectivityInfo> getConnectivityStatus() async {
    if (_disposed) throw StateError('Service has been disposed');

    if (simulateDelay) {
      await Future.delayed(const Duration(milliseconds: 100));
    }

    return _currentInfo;
  }

  @override
  Stream<ConnectivityInfo> get connectivityStream {
    if (_disposed) throw StateError('Service has been disposed');

    late StreamController<ConnectivityInfo> controller;
    controller = StreamController<ConnectivityInfo>(
      onListen: () {
        controller.add(_currentInfo);
        _controller.stream.listen(
          controller.add,
          onError: controller.addError,
          onDone: controller.close,
        );
      },
    );

    return controller.stream;
  }

  @override
  Future<bool> canReachHost(
    String host, {
    int port = 80,
    Duration timeout = const Duration(seconds: 5),
  }) async {
    if (_disposed) throw StateError('Service has been disposed');

    if (simulateDelay) {
      await Future.delayed(const Duration(milliseconds: 50));
    }

    return _currentInfo.isConnected;
  }

  @override
  Future<ConnectivityInfo> performConnectivityTest() async {
    if (_disposed) throw StateError('Service has been disposed');

    if (simulateDelay) {
      await Future.delayed(const Duration(milliseconds: 200));
    }

    _currentInfo = _currentInfo.copyWith(
      lastChecked: DateTime.now(),
      responseTime: 100,
    );

    return _currentInfo;
  }

  @override
  void dispose() {
    if (!_disposed) {
      _controller.close();
      _disposed = true;
    }
  }

  // Mock-specific methods for testing

  /// Simulate connectivity change
  void simulateConnectivityChange(ConnectivityStatus status) {
    if (_disposed) throw StateError('Service has been disposed');

    _currentInfo = ConnectivityInfo(
      status: status,
      lastChecked: DateTime.now(),
      responseTime: status == ConnectivityStatus.connected ? 100 : null,
    );

    _controller.add(_currentInfo);
  }

  /// Simulate network disconnection
  void simulateDisconnection() {
    simulateConnectivityChange(ConnectivityStatus.disconnected);
  }

  /// Simulate network reconnection
  void simulateReconnection() {
    simulateConnectivityChange(ConnectivityStatus.connected);
  }

  /// Get current connectivity info
  ConnectivityInfo get currentInfo => _currentInfo;

  /// Check if service is disposed
  bool get isDisposed => _disposed;
}
