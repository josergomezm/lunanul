import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/subscription_analytics.dart';
import '../models/enums.dart';

/// Service for tracking and analyzing subscription-related events and metrics
abstract class SubscriptionAnalyticsService {
  /// Track a subscription analytics event
  Future<void> trackEvent(SubscriptionAnalyticsEvent event);

  /// Get feature usage statistics by tier
  Future<List<FeatureUsageStats>> getFeatureUsageStats({
    SubscriptionTier? tier,
    String? featureKey,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Get subscription health metrics
  Future<SubscriptionHealthMetrics> getHealthMetrics();

  /// Get conversion rate for a specific tier
  Future<double> getConversionRate(SubscriptionTier tier);

  /// Get churn rate for a specific tier
  Future<double> getChurnRate(SubscriptionTier tier);

  /// Get feature adoption rates by tier
  Future<Map<String, double>> getFeatureAdoptionRates(SubscriptionTier tier);

  /// Get error rate for subscription operations
  Future<double> getErrorRate();

  /// Perform subscription health check
  Future<bool> performHealthCheck();

  /// Get diagnostic information
  Future<Map<String, dynamic>> getDiagnostics();

  /// Clear analytics data (for testing or privacy)
  Future<void> clearAnalytics();

  /// Stream of real-time analytics events
  Stream<SubscriptionAnalyticsEvent> get analyticsStream;
}

/// Local implementation of subscription analytics service using SharedPreferences
class LocalSubscriptionAnalyticsService
    implements SubscriptionAnalyticsService {
  static const String _eventsKey = 'subscription_analytics_events';
  static const String _metricsKey = 'subscription_health_metrics';
  static const int _maxStoredEvents = 1000;

  final StreamController<SubscriptionAnalyticsEvent> _analyticsController =
      StreamController<SubscriptionAnalyticsEvent>.broadcast();

  @override
  Stream<SubscriptionAnalyticsEvent> get analyticsStream =>
      _analyticsController.stream;

  @override
  Future<void> trackEvent(SubscriptionAnalyticsEvent event) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final eventsJson = prefs.getStringList(_eventsKey) ?? [];

      // Add new event
      eventsJson.add(jsonEncode(event.toJson()));

      // Keep only the most recent events to prevent storage bloat
      if (eventsJson.length > _maxStoredEvents) {
        eventsJson.removeRange(0, eventsJson.length - _maxStoredEvents);
      }

      await prefs.setStringList(_eventsKey, eventsJson);

      // Emit event to stream
      _analyticsController.add(event);

      // Update health metrics if this is an error event
      if (event.eventType == SubscriptionEventType.subscriptionError) {
        await _updateErrorMetrics();
      }
    } catch (e) {
      // Silently fail to avoid disrupting app functionality
      // ignore: avoid_print
      print('Failed to track analytics event: $e');
    }
  }

  @override
  Future<List<FeatureUsageStats>> getFeatureUsageStats({
    SubscriptionTier? tier,
    String? featureKey,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final events = await _getStoredEvents();
      final featureEvents = events.where((event) {
        if (event.eventType != SubscriptionEventType.featureUsage) {
          return false;
        }
        if (tier != null && event.properties['tier'] != tier.name) {
          return false;
        }
        if (featureKey != null && event.featureKey != featureKey) {
          return false;
        }
        if (startDate != null && event.timestamp.isBefore(startDate)) {
          return false;
        }
        if (endDate != null && event.timestamp.isAfter(endDate)) {
          return false;
        }
        return true;
      }).toList();

      // Group by feature and tier
      final Map<String, List<SubscriptionAnalyticsEvent>> groupedEvents = {};
      for (final event in featureEvents) {
        final key = '${event.featureKey}_${event.properties['tier']}';
        groupedEvents.putIfAbsent(key, () => []).add(event);
      }

      // Calculate statistics for each group
      final List<FeatureUsageStats> stats = [];
      for (final entry in groupedEvents.entries) {
        final events = entry.value;
        if (events.isEmpty) continue;

        final featureKey = events.first.featureKey!;
        final tierName = events.first.properties['tier'] as String;
        final tier = SubscriptionTier.values.firstWhere(
          (t) => t.name == tierName,
        );

        events.sort((a, b) => a.timestamp.compareTo(b.timestamp));
        final firstUsed = events.first.timestamp;
        final lastUsed = events.last.timestamp;
        final usageCount = events.length;

        final daysDiff = lastUsed.difference(firstUsed).inDays + 1;
        final averageUsagePerDay = usageCount / daysDiff;

        stats.add(
          FeatureUsageStats(
            featureKey: featureKey,
            tier: tier,
            usageCount: usageCount,
            firstUsed: firstUsed,
            lastUsed: lastUsed,
            averageUsagePerDay: averageUsagePerDay,
          ),
        );
      }

      return stats;
    } catch (e) {
      // ignore: avoid_print
      print('Failed to get feature usage stats: $e');
      return [];
    }
  }

  @override
  Future<SubscriptionHealthMetrics> getHealthMetrics() async {
    try {
      final events = await _getStoredEvents();
      final now = DateTime.now();

      // Calculate conversion rate (upgrades / total users)
      final upgradeEvents = events
          .where((e) => e.eventType == SubscriptionEventType.tierUpgrade)
          .length;
      final totalUsers = events
          .map((e) => e.userId)
          .where((id) => id != null)
          .toSet()
          .length;
      final conversionRate = totalUsers > 0 ? upgradeEvents / totalUsers : 0.0;

      // Calculate churn rate (cancellations / active subscriptions)
      final cancellationEvents = events
          .where(
            (e) =>
                e.eventType == SubscriptionEventType.subscriptionCancellation,
          )
          .length;
      final activeSubscriptions = _calculateActiveSubscriptions(events);
      final totalActive = activeSubscriptions.values.fold(0, (a, b) => a + b);
      final churnRate = totalActive > 0
          ? cancellationEvents / totalActive
          : 0.0;

      // Calculate feature adoption rates
      final featureAdoptionRates = <SubscriptionTier, double>{};
      for (final tier in SubscriptionTier.values) {
        final tierUsers = events
            .where((e) => e.properties['tier'] == tier.name)
            .map((e) => e.userId)
            .where((id) => id != null)
            .toSet()
            .length;
        final featureUsers = events
            .where(
              (e) =>
                  e.eventType == SubscriptionEventType.featureUsage &&
                  e.properties['tier'] == tier.name,
            )
            .map((e) => e.userId)
            .where((id) => id != null)
            .toSet()
            .length;
        featureAdoptionRates[tier] = tierUsers > 0
            ? featureUsers / tierUsers
            : 0.0;
      }

      // Calculate error metrics
      final errorEvents = events
          .where((e) => e.eventType == SubscriptionEventType.subscriptionError)
          .length;
      final totalEvents = events.length;
      final errorRate = totalEvents > 0 ? errorEvents / totalEvents : 0.0;

      return SubscriptionHealthMetrics(
        conversionRate: conversionRate,
        churnRate: churnRate,
        activeSubscriptions: activeSubscriptions,
        featureAdoptionRates: featureAdoptionRates,
        totalErrors: errorEvents,
        errorRate: errorRate,
        lastUpdated: now,
      );
    } catch (e) {
      // ignore: avoid_print
      print('Failed to get health metrics: $e');
      return SubscriptionHealthMetrics(
        conversionRate: 0.0,
        churnRate: 0.0,
        activeSubscriptions: const {},
        featureAdoptionRates: const {},
        totalErrors: 0,
        errorRate: 0.0,
        lastUpdated: DateTime.now(),
      );
    }
  }

  @override
  Future<double> getConversionRate(SubscriptionTier tier) async {
    try {
      final events = await _getStoredEvents();
      final upgradeEvents = events
          .where(
            (e) =>
                e.eventType == SubscriptionEventType.tierUpgrade &&
                e.toTier == tier,
          )
          .length;
      final totalUsers = events
          .map((e) => e.userId)
          .where((id) => id != null)
          .toSet()
          .length;
      return totalUsers > 0 ? upgradeEvents / totalUsers : 0.0;
    } catch (e) {
      // ignore: avoid_print
      print('Failed to get conversion rate: $e');
      return 0.0;
    }
  }

  @override
  Future<double> getChurnRate(SubscriptionTier tier) async {
    try {
      final events = await _getStoredEvents();
      final cancellationEvents = events
          .where(
            (e) =>
                e.eventType == SubscriptionEventType.subscriptionCancellation &&
                e.fromTier == tier,
          )
          .length;
      final activeSubscriptions = _calculateActiveSubscriptions(events);
      final tierActive = activeSubscriptions[tier] ?? 0;
      return tierActive > 0 ? cancellationEvents / tierActive : 0.0;
    } catch (e) {
      // ignore: avoid_print
      print('Failed to get churn rate: $e');
      return 0.0;
    }
  }

  @override
  Future<Map<String, double>> getFeatureAdoptionRates(
    SubscriptionTier tier,
  ) async {
    try {
      final events = await _getStoredEvents();
      final tierUsers = events
          .where((e) => e.properties['tier'] == tier.name)
          .map((e) => e.userId)
          .where((id) => id != null)
          .toSet()
          .length;

      if (tierUsers == 0) return {};

      final featureUsage = <String, Set<String>>{};
      for (final event in events) {
        if (event.eventType == SubscriptionEventType.featureUsage &&
            event.properties['tier'] == tier.name &&
            event.userId != null) {
          featureUsage
              .putIfAbsent(event.featureKey!, () => <String>{})
              .add(event.userId!);
        }
      }

      return featureUsage.map(
        (feature, users) => MapEntry(feature, users.length / tierUsers),
      );
    } catch (e) {
      // ignore: avoid_print
      print('Failed to get feature adoption rates: $e');
      return {};
    }
  }

  @override
  Future<double> getErrorRate() async {
    try {
      final events = await _getStoredEvents();
      final errorEvents = events
          .where((e) => e.eventType == SubscriptionEventType.subscriptionError)
          .length;
      final totalEvents = events.length;
      return totalEvents > 0 ? errorEvents / totalEvents : 0.0;
    } catch (e) {
      // ignore: avoid_print
      print('Failed to get error rate: $e');
      return 0.0;
    }
  }

  @override
  Future<bool> performHealthCheck() async {
    try {
      final metrics = await getHealthMetrics();

      // Health check criteria
      final isHealthy =
          metrics.errorRate < 0.05 && // Less than 5% error rate
          metrics.churnRate < 0.1 && // Less than 10% churn rate
          metrics.conversionRate > 0.01; // At least 1% conversion rate

      return isHealthy;
    } catch (e) {
      // ignore: avoid_print
      print('Health check failed: $e');
      return false;
    }
  }

  @override
  Future<Map<String, dynamic>> getDiagnostics() async {
    try {
      final events = await _getStoredEvents();
      final metrics = await getHealthMetrics();
      final prefs = await SharedPreferences.getInstance();

      return {
        'totalEvents': events.length,
        'eventTypes': _getEventTypeCounts(events),
        'healthMetrics': metrics.toJson(),
        'storageSize': prefs.getStringList(_eventsKey)?.length ?? 0,
        'lastEventTime': events.isNotEmpty
            ? events.last.timestamp.toIso8601String()
            : null,
        'isHealthy': await performHealthCheck(),
        'diagnosticsTimestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      // ignore: avoid_print
      print('Failed to get diagnostics: $e');
      return {
        'error': e.toString(),
        'diagnosticsTimestamp': DateTime.now().toIso8601String(),
      };
    }
  }

  @override
  Future<void> clearAnalytics() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_eventsKey);
      await prefs.remove(_metricsKey);
    } catch (e) {
      // ignore: avoid_print
      print('Failed to clear analytics: $e');
    }
  }

  Future<List<SubscriptionAnalyticsEvent>> _getStoredEvents() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final eventsJson = prefs.getStringList(_eventsKey) ?? [];
      return eventsJson
          .map(
            (json) => SubscriptionAnalyticsEvent.fromJson(
              jsonDecode(json) as Map<String, dynamic>,
            ),
          )
          .toList();
    } catch (e) {
      // ignore: avoid_print
      print('Failed to get stored events: $e');
      return [];
    }
  }

  Map<SubscriptionTier, int> _calculateActiveSubscriptions(
    List<SubscriptionAnalyticsEvent> events,
  ) {
    final Map<SubscriptionTier, int> active = {};

    // This is a simplified calculation - in a real app, you'd track
    // actual subscription states more precisely
    for (final tier in SubscriptionTier.values) {
      final purchases = events
          .where(
            (e) =>
                e.eventType == SubscriptionEventType.subscriptionPurchase &&
                e.toTier == tier,
          )
          .length;
      final cancellations = events
          .where(
            (e) =>
                e.eventType == SubscriptionEventType.subscriptionCancellation &&
                e.fromTier == tier,
          )
          .length;
      active[tier] = purchases - cancellations;
    }

    return active;
  }

  Map<String, int> _getEventTypeCounts(
    List<SubscriptionAnalyticsEvent> events,
  ) {
    final Map<String, int> counts = {};
    for (final event in events) {
      counts[event.eventType.name] = (counts[event.eventType.name] ?? 0) + 1;
    }
    return counts;
  }

  Future<void> _updateErrorMetrics() async {
    // This could trigger alerts or notifications in a production app
    // For now, we just log the error
    // ignore: avoid_print
    print('Subscription error detected - updating metrics');
  }

  void dispose() {
    _analyticsController.close();
  }
}
