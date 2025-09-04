import 'dart:async';
import 'subscription_analytics_service.dart';
import '../models/subscription_analytics.dart';
import '../models/enums.dart';

/// Service for monitoring subscription system health and performance
class SubscriptionMonitoringService {
  final SubscriptionAnalyticsService _analyticsService;
  Timer? _healthCheckTimer;
  Timer? _metricsUpdateTimer;

  final StreamController<SubscriptionHealthMetrics> _healthController =
      StreamController<SubscriptionHealthMetrics>.broadcast();

  final StreamController<Map<String, dynamic>> _alertController =
      StreamController<Map<String, dynamic>>.broadcast();

  SubscriptionMonitoringService(this._analyticsService);

  /// Stream of health metrics updates
  Stream<SubscriptionHealthMetrics> get healthMetricsStream =>
      _healthController.stream;

  /// Stream of system alerts
  Stream<Map<String, dynamic>> get alertsStream => _alertController.stream;

  /// Start monitoring subscription system health
  Future<void> startMonitoring({
    Duration healthCheckInterval = const Duration(minutes: 15),
    Duration metricsUpdateInterval = const Duration(minutes: 5),
  }) async {
    await stopMonitoring();

    // Start periodic health checks
    _healthCheckTimer = Timer.periodic(healthCheckInterval, (_) async {
      await _performHealthCheck();
    });

    // Start periodic metrics updates
    _metricsUpdateTimer = Timer.periodic(metricsUpdateInterval, (_) async {
      await _updateHealthMetrics();
    });

    // Perform initial checks
    await _performHealthCheck();
    await _updateHealthMetrics();
  }

  /// Stop monitoring
  Future<void> stopMonitoring() async {
    _healthCheckTimer?.cancel();
    _metricsUpdateTimer?.cancel();
    _healthCheckTimer = null;
    _metricsUpdateTimer = null;
  }

  /// Perform immediate health check
  Future<bool> performHealthCheck() async {
    return await _performHealthCheck();
  }

  /// Get current health status
  Future<Map<String, dynamic>> getHealthStatus() async {
    try {
      final isHealthy = await _analyticsService.performHealthCheck();
      final diagnostics = await _analyticsService.getDiagnostics();
      final metrics = await _analyticsService.getHealthMetrics();

      return {
        'isHealthy': isHealthy,
        'status': isHealthy ? 'healthy' : 'unhealthy',
        'lastCheck': DateTime.now().toIso8601String(),
        'metrics': metrics.toJson(),
        'diagnostics': diagnostics,
        'alerts': await _generateAlerts(metrics),
      };
    } catch (e) {
      return {
        'isHealthy': false,
        'status': 'error',
        'error': e.toString(),
        'lastCheck': DateTime.now().toIso8601String(),
      };
    }
  }

  /// Get system performance metrics
  Future<Map<String, dynamic>> getPerformanceMetrics() async {
    try {
      final metrics = await _analyticsService.getHealthMetrics();
      final diagnostics = await _analyticsService.getDiagnostics();

      return {
        'conversionMetrics': {
          'overall': metrics.conversionRate,
          'byTier': {
            for (final tier in SubscriptionTier.values)
              tier.name: await _analyticsService.getConversionRate(tier),
          },
        },
        'churnMetrics': {
          'overall': metrics.churnRate,
          'byTier': {
            for (final tier in SubscriptionTier.values)
              tier.name: await _analyticsService.getChurnRate(tier),
          },
        },
        'featureAdoption': {
          for (final tier in SubscriptionTier.values)
            tier.name: await _analyticsService.getFeatureAdoptionRates(tier),
        },
        'errorMetrics': {
          'totalErrors': metrics.totalErrors,
          'errorRate': metrics.errorRate,
        },
        'systemMetrics': {
          'totalEvents': diagnostics['totalEvents'],
          'storageSize': diagnostics['storageSize'],
          'lastEventTime': diagnostics['lastEventTime'],
        },
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      return {
        'error': e.toString(),
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }

  /// Generate system alerts based on metrics
  Future<List<Map<String, dynamic>>> getSystemAlerts() async {
    try {
      final metrics = await _analyticsService.getHealthMetrics();
      return await _generateAlerts(metrics);
    } catch (e) {
      return [
        {
          'type': 'error',
          'severity': 'high',
          'message': 'Failed to generate system alerts: $e',
          'timestamp': DateTime.now().toIso8601String(),
        },
      ];
    }
  }

  /// Track subscription system event for monitoring
  Future<void> trackSystemEvent({
    required String eventType,
    required String message,
    Map<String, dynamic> properties = const {},
    String severity = 'info',
  }) async {
    try {
      final event = {
        'eventType': eventType,
        'message': message,
        'properties': properties,
        'severity': severity,
        'timestamp': DateTime.now().toIso8601String(),
      };

      // Emit to alerts stream if it's a warning or error
      if (severity == 'warning' ||
          severity == 'error' ||
          severity == 'critical') {
        _alertController.add(event);
      }

      // Track as analytics event if it's subscription-related
      if (eventType.startsWith('subscription_')) {
        await _analyticsService.trackEvent(
          SubscriptionAnalyticsEvent.subscriptionError(
            id: 'system_${DateTime.now().millisecondsSinceEpoch}',
            errorMessage: message,
            properties: {
              'systemEvent': true,
              'severity': severity,
              ...properties,
            },
          ),
        );
      }
    } catch (e) {
      // ignore: avoid_print
      print('Failed to track system event: $e');
    }
  }

  /// Get subscription trends over time
  Future<Map<String, dynamic>> getSubscriptionTrends({int days = 30}) async {
    try {
      final endDate = DateTime.now();
      final startDate = endDate.subtract(Duration(days: days));

      final usageStats = await _analyticsService.getFeatureUsageStats(
        startDate: startDate,
        endDate: endDate,
      );

      // Group usage stats by tier and calculate trends
      final Map<String, List<FeatureUsageStats>> tierStats = {};
      for (final stat in usageStats) {
        tierStats.putIfAbsent(stat.tier.name, () => []).add(stat);
      }

      final trends = <String, dynamic>{};
      for (final entry in tierStats.entries) {
        final tierName = entry.key;
        final stats = entry.value;

        final totalUsage = stats.fold(0, (sum, stat) => sum + stat.usageCount);
        final avgDailyUsage = stats.isNotEmpty
            ? stats.map((s) => s.averageUsagePerDay).reduce((a, b) => a + b) /
                  stats.length
            : 0.0;

        trends[tierName] = {
          'totalUsage': totalUsage,
          'averageDailyUsage': avgDailyUsage,
          'featureCount': stats.length,
          'mostUsedFeature': stats.isNotEmpty
              ? stats
                    .reduce((a, b) => a.usageCount > b.usageCount ? a : b)
                    .featureKey
              : null,
        };
      }

      return {
        'period': {
          'startDate': startDate.toIso8601String(),
          'endDate': endDate.toIso8601String(),
          'days': days,
        },
        'trends': trends,
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      return {
        'error': e.toString(),
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }

  Future<bool> _performHealthCheck() async {
    try {
      final isHealthy = await _analyticsService.performHealthCheck();

      if (!isHealthy) {
        await trackSystemEvent(
          eventType: 'subscription_health_check_failed',
          message: 'Subscription system health check failed',
          severity: 'warning',
        );
      }

      return isHealthy;
    } catch (e) {
      await trackSystemEvent(
        eventType: 'subscription_health_check_error',
        message: 'Health check failed with error: $e',
        severity: 'error',
      );
      return false;
    }
  }

  Future<void> _updateHealthMetrics() async {
    try {
      final metrics = await _analyticsService.getHealthMetrics();
      _healthController.add(metrics);

      // Check for alerts
      final alerts = await _generateAlerts(metrics);
      for (final alert in alerts) {
        _alertController.add(alert);
      }
    } catch (e) {
      await trackSystemEvent(
        eventType: 'subscription_metrics_update_error',
        message: 'Failed to update health metrics: $e',
        severity: 'error',
      );
    }
  }

  Future<List<Map<String, dynamic>>> _generateAlerts(
    SubscriptionHealthMetrics metrics,
  ) async {
    final alerts = <Map<String, dynamic>>[];
    final now = DateTime.now();

    // High error rate alert
    if (metrics.errorRate > 0.05) {
      alerts.add({
        'type': 'high_error_rate',
        'severity': 'warning',
        'message':
            'High error rate detected: ${(metrics.errorRate * 100).toStringAsFixed(1)}%',
        'value': metrics.errorRate,
        'threshold': 0.05,
        'timestamp': now.toIso8601String(),
      });
    }

    // High churn rate alert
    if (metrics.churnRate > 0.15) {
      alerts.add({
        'type': 'high_churn_rate',
        'severity': 'warning',
        'message':
            'High churn rate detected: ${(metrics.churnRate * 100).toStringAsFixed(1)}%',
        'value': metrics.churnRate,
        'threshold': 0.15,
        'timestamp': now.toIso8601String(),
      });
    }

    // Low conversion rate alert
    if (metrics.conversionRate < 0.05) {
      alerts.add({
        'type': 'low_conversion_rate',
        'severity': 'info',
        'message':
            'Low conversion rate: ${(metrics.conversionRate * 100).toStringAsFixed(1)}%',
        'value': metrics.conversionRate,
        'threshold': 0.05,
        'timestamp': now.toIso8601String(),
      });
    }

    // Low feature adoption alerts
    for (final entry in metrics.featureAdoptionRates.entries) {
      if (entry.value < 0.3) {
        alerts.add({
          'type': 'low_feature_adoption',
          'severity': 'info',
          'message':
              'Low feature adoption for ${entry.key.name}: ${(entry.value * 100).toStringAsFixed(1)}%',
          'tier': entry.key.name,
          'value': entry.value,
          'threshold': 0.3,
          'timestamp': now.toIso8601String(),
        });
      }
    }

    return alerts;
  }

  void dispose() {
    stopMonitoring();
    _healthController.close();
    _alertController.close();
  }
}
