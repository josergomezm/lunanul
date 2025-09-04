import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/subscription_analytics_service.dart';
import '../services/mock_subscription_analytics_service.dart';
import '../services/subscription_monitoring_service.dart';
import '../models/subscription_analytics.dart';
import '../models/enums.dart';

/// Provider for subscription analytics service
final subscriptionAnalyticsServiceProvider =
    Provider<SubscriptionAnalyticsService>((ref) {
      // In production, this would be the LocalSubscriptionAnalyticsService
      // For development and testing, we use the mock service
      return MockSubscriptionAnalyticsService();
    });

/// Provider for subscription monitoring service
final subscriptionMonitoringServiceProvider =
    Provider<SubscriptionMonitoringService>((ref) {
      final analyticsService = ref.watch(subscriptionAnalyticsServiceProvider);
      return SubscriptionMonitoringService(analyticsService);
    });

/// Provider for subscription health metrics
final subscriptionHealthMetricsProvider =
    FutureProvider<SubscriptionHealthMetrics>((ref) async {
      final analyticsService = ref.watch(subscriptionAnalyticsServiceProvider);
      return await analyticsService.getHealthMetrics();
    });

/// Provider for feature usage statistics
final featureUsageStatsProvider =
    FutureProvider.family<List<FeatureUsageStats>, FeatureUsageStatsParams>((
      ref,
      params,
    ) async {
      final analyticsService = ref.watch(subscriptionAnalyticsServiceProvider);
      return await analyticsService.getFeatureUsageStats(
        tier: params.tier,
        featureKey: params.featureKey,
        startDate: params.startDate,
        endDate: params.endDate,
      );
    });

/// Provider for conversion rates by tier
final conversionRateProvider = FutureProvider.family<double, SubscriptionTier>((
  ref,
  tier,
) async {
  final analyticsService = ref.watch(subscriptionAnalyticsServiceProvider);
  return await analyticsService.getConversionRate(tier);
});

/// Provider for churn rates by tier
final churnRateProvider = FutureProvider.family<double, SubscriptionTier>((
  ref,
  tier,
) async {
  final analyticsService = ref.watch(subscriptionAnalyticsServiceProvider);
  return await analyticsService.getChurnRate(tier);
});

/// Provider for feature adoption rates by tier
final featureAdoptionRatesProvider =
    FutureProvider.family<Map<String, double>, SubscriptionTier>((
      ref,
      tier,
    ) async {
      final analyticsService = ref.watch(subscriptionAnalyticsServiceProvider);
      return await analyticsService.getFeatureAdoptionRates(tier);
    });

/// Provider for system error rate
final errorRateProvider = FutureProvider<double>((ref) async {
  final analyticsService = ref.watch(subscriptionAnalyticsServiceProvider);
  return await analyticsService.getErrorRate();
});

/// Provider for subscription system health check
final healthCheckProvider = FutureProvider<bool>((ref) async {
  final analyticsService = ref.watch(subscriptionAnalyticsServiceProvider);
  return await analyticsService.performHealthCheck();
});

/// Provider for system diagnostics
final systemDiagnosticsProvider = FutureProvider<Map<String, dynamic>>((
  ref,
) async {
  final analyticsService = ref.watch(subscriptionAnalyticsServiceProvider);
  return await analyticsService.getDiagnostics();
});

/// Provider for subscription performance metrics
final performanceMetricsProvider = FutureProvider<Map<String, dynamic>>((
  ref,
) async {
  final monitoringService = ref.watch(subscriptionMonitoringServiceProvider);
  return await monitoringService.getPerformanceMetrics();
});

/// Provider for subscription trends
final subscriptionTrendsProvider =
    FutureProvider.family<Map<String, dynamic>, int>((ref, days) async {
      final monitoringService = ref.watch(
        subscriptionMonitoringServiceProvider,
      );
      return await monitoringService.getSubscriptionTrends(days: days);
    });

/// Provider for system alerts
final systemAlertsProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final monitoringService = ref.watch(subscriptionMonitoringServiceProvider);
  return await monitoringService.getSystemAlerts();
});

/// Provider for health status
final healthStatusProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final monitoringService = ref.watch(subscriptionMonitoringServiceProvider);
  return await monitoringService.getHealthStatus();
});

/// Stream provider for real-time analytics events
final analyticsStreamProvider = StreamProvider<SubscriptionAnalyticsEvent>((
  ref,
) {
  final analyticsService = ref.watch(subscriptionAnalyticsServiceProvider);
  return analyticsService.analyticsStream;
});

/// Stream provider for health metrics updates
final healthMetricsStreamProvider = StreamProvider<SubscriptionHealthMetrics>((
  ref,
) {
  final monitoringService = ref.watch(subscriptionMonitoringServiceProvider);
  return monitoringService.healthMetricsStream;
});

/// Stream provider for system alerts
final alertsStreamProvider = StreamProvider<Map<String, dynamic>>((ref) {
  final monitoringService = ref.watch(subscriptionMonitoringServiceProvider);
  return monitoringService.alertsStream;
});

/// Notifier for tracking analytics events
class SubscriptionAnalyticsNotifier extends StateNotifier<AsyncValue<void>> {
  final SubscriptionAnalyticsService _analyticsService;

  SubscriptionAnalyticsNotifier(this._analyticsService)
    : super(const AsyncValue.data(null));

  /// Track a subscription analytics event
  Future<void> trackEvent(SubscriptionAnalyticsEvent event) async {
    state = const AsyncValue.loading();
    try {
      await _analyticsService.trackEvent(event);
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Track tier upgrade event
  Future<void> trackTierUpgrade({
    required SubscriptionTier fromTier,
    required SubscriptionTier toTier,
    String? userId,
    Map<String, dynamic> properties = const {},
  }) async {
    final event = SubscriptionAnalyticsEvent.tierUpgrade(
      id: 'upgrade_${DateTime.now().millisecondsSinceEpoch}',
      fromTier: fromTier,
      toTier: toTier,
      userId: userId,
      properties: properties,
    );
    await trackEvent(event);
  }

  /// Track feature usage event
  Future<void> trackFeatureUsage({
    required String featureKey,
    required SubscriptionTier tier,
    String? userId,
    Map<String, dynamic> properties = const {},
  }) async {
    final event = SubscriptionAnalyticsEvent.featureUsage(
      id: 'usage_${DateTime.now().millisecondsSinceEpoch}',
      featureKey: featureKey,
      tier: tier,
      userId: userId,
      properties: properties,
    );
    await trackEvent(event);
  }

  /// Track upgrade prompt interaction
  Future<void> trackUpgradePrompt({
    required SubscriptionEventType eventType,
    required String featureKey,
    required SubscriptionTier currentTier,
    required SubscriptionTier recommendedTier,
    String? userId,
    Map<String, dynamic> properties = const {},
  }) async {
    final event = SubscriptionAnalyticsEvent.upgradePrompt(
      id: 'prompt_${DateTime.now().millisecondsSinceEpoch}',
      eventType: eventType,
      featureKey: featureKey,
      currentTier: currentTier,
      recommendedTier: recommendedTier,
      userId: userId,
      properties: properties,
    );
    await trackEvent(event);
  }

  /// Track subscription error
  Future<void> trackSubscriptionError({
    required String errorMessage,
    SubscriptionTier? tier,
    String? userId,
    Map<String, dynamic> properties = const {},
  }) async {
    final event = SubscriptionAnalyticsEvent.subscriptionError(
      id: 'error_${DateTime.now().millisecondsSinceEpoch}',
      errorMessage: errorMessage,
      tier: tier,
      userId: userId,
      properties: properties,
    );
    await trackEvent(event);
  }

  /// Clear all analytics data
  Future<void> clearAnalytics() async {
    state = const AsyncValue.loading();
    try {
      await _analyticsService.clearAnalytics();
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

/// Provider for subscription analytics notifier
final subscriptionAnalyticsNotifierProvider =
    StateNotifierProvider<SubscriptionAnalyticsNotifier, AsyncValue<void>>((
      ref,
    ) {
      final analyticsService = ref.watch(subscriptionAnalyticsServiceProvider);
      return SubscriptionAnalyticsNotifier(analyticsService);
    });

/// Parameters for feature usage stats provider
class FeatureUsageStatsParams {
  final SubscriptionTier? tier;
  final String? featureKey;
  final DateTime? startDate;
  final DateTime? endDate;

  const FeatureUsageStatsParams({
    this.tier,
    this.featureKey,
    this.startDate,
    this.endDate,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FeatureUsageStatsParams &&
        other.tier == tier &&
        other.featureKey == featureKey &&
        other.startDate == startDate &&
        other.endDate == endDate;
  }

  @override
  int get hashCode {
    return Object.hash(tier, featureKey, startDate, endDate);
  }
}
