import 'dart:async';
import 'dart:math';
import 'subscription_analytics_service.dart';
import '../models/subscription_analytics.dart';
import '../models/enums.dart';

/// Mock implementation of subscription analytics service for testing and development
class MockSubscriptionAnalyticsService implements SubscriptionAnalyticsService {
  final List<SubscriptionAnalyticsEvent> _events = [];
  final StreamController<SubscriptionAnalyticsEvent> _analyticsController =
      StreamController<SubscriptionAnalyticsEvent>.broadcast();
  final Random _random = Random();

  MockSubscriptionAnalyticsService() {
    _generateMockData();
  }

  @override
  Stream<SubscriptionAnalyticsEvent> get analyticsStream =>
      _analyticsController.stream;

  @override
  Future<void> trackEvent(SubscriptionAnalyticsEvent event) async {
    _events.add(event);
    _analyticsController.add(event);
  }

  @override
  Future<List<FeatureUsageStats>> getFeatureUsageStats({
    SubscriptionTier? tier,
    String? featureKey,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    await Future.delayed(const Duration(milliseconds: 100));

    final features = [
      'reading_spreads',
      'guide_access',
      'journal_entries',
      'manual_interpretations',
    ];
    final stats = <FeatureUsageStats>[];

    for (final feature in features) {
      if (featureKey != null && feature != featureKey) continue;

      for (final tierValue in SubscriptionTier.values) {
        if (tier != null && tierValue != tier) continue;

        final usageCount = _random.nextInt(100) + 10;
        final firstUsed = DateTime.now().subtract(
          Duration(days: _random.nextInt(30) + 1),
        );
        final lastUsed = DateTime.now().subtract(
          Duration(days: _random.nextInt(7)),
        );
        final daysDiff = lastUsed.difference(firstUsed).inDays + 1;
        final averageUsagePerDay = usageCount / daysDiff;

        stats.add(
          FeatureUsageStats(
            featureKey: feature,
            tier: tierValue,
            usageCount: usageCount,
            firstUsed: firstUsed,
            lastUsed: lastUsed,
            averageUsagePerDay: averageUsagePerDay,
          ),
        );
      }
    }

    return stats;
  }

  @override
  Future<SubscriptionHealthMetrics> getHealthMetrics() async {
    await Future.delayed(const Duration(milliseconds: 150));

    return SubscriptionHealthMetrics(
      conversionRate: 0.15 + _random.nextDouble() * 0.1, // 15-25%
      churnRate: 0.05 + _random.nextDouble() * 0.05, // 5-10%
      activeSubscriptions: {
        SubscriptionTier.seeker: 1000 + _random.nextInt(500),
        SubscriptionTier.mystic: 200 + _random.nextInt(100),
        SubscriptionTier.oracle: 50 + _random.nextInt(25),
      },
      featureAdoptionRates: {
        SubscriptionTier.seeker: 0.8 + _random.nextDouble() * 0.15,
        SubscriptionTier.mystic: 0.9 + _random.nextDouble() * 0.1,
        SubscriptionTier.oracle: 0.95 + _random.nextDouble() * 0.05,
      },
      totalErrors: _random.nextInt(10),
      errorRate: _random.nextDouble() * 0.02, // 0-2%
      lastUpdated: DateTime.now(),
    );
  }

  @override
  Future<double> getConversionRate(SubscriptionTier tier) async {
    await Future.delayed(const Duration(milliseconds: 50));

    switch (tier) {
      case SubscriptionTier.seeker:
        return 1.0; // Everyone starts as seeker
      case SubscriptionTier.mystic:
        return 0.15 + _random.nextDouble() * 0.1; // 15-25%
      case SubscriptionTier.oracle:
        return 0.03 + _random.nextDouble() * 0.02; // 3-5%
    }
  }

  @override
  Future<double> getChurnRate(SubscriptionTier tier) async {
    await Future.delayed(const Duration(milliseconds: 50));

    switch (tier) {
      case SubscriptionTier.seeker:
        return 0.0; // Free tier doesn't churn
      case SubscriptionTier.mystic:
        return 0.08 + _random.nextDouble() * 0.04; // 8-12%
      case SubscriptionTier.oracle:
        return 0.05 + _random.nextDouble() * 0.03; // 5-8%
    }
  }

  @override
  Future<Map<String, double>> getFeatureAdoptionRates(
    SubscriptionTier tier,
  ) async {
    await Future.delayed(const Duration(milliseconds: 75));

    final baseRate = switch (tier) {
      SubscriptionTier.seeker => 0.7,
      SubscriptionTier.mystic => 0.85,
      SubscriptionTier.oracle => 0.95,
    };

    return {
      'reading_spreads': baseRate + _random.nextDouble() * 0.1,
      'guide_access': baseRate + _random.nextDouble() * 0.15,
      'journal_entries': baseRate - 0.1 + _random.nextDouble() * 0.2,
      'manual_interpretations': baseRate - 0.05 + _random.nextDouble() * 0.1,
      if (tier != SubscriptionTier.seeker)
        'premium_features': baseRate + _random.nextDouble() * 0.05,
      if (tier == SubscriptionTier.oracle)
        'audio_readings': 0.6 + _random.nextDouble() * 0.3,
      if (tier == SubscriptionTier.oracle)
        'customization': 0.4 + _random.nextDouble() * 0.4,
    };
  }

  @override
  Future<double> getErrorRate() async {
    await Future.delayed(const Duration(milliseconds: 25));
    return _random.nextDouble() * 0.02; // 0-2%
  }

  @override
  Future<bool> performHealthCheck() async {
    await Future.delayed(const Duration(milliseconds: 200));

    final metrics = await getHealthMetrics();
    return metrics.errorRate < 0.05 &&
        metrics.churnRate < 0.1 &&
        metrics.conversionRate > 0.01;
  }

  @override
  Future<Map<String, dynamic>> getDiagnostics() async {
    await Future.delayed(const Duration(milliseconds: 100));

    final metrics = await getHealthMetrics();

    return {
      'totalEvents': _events.length,
      'eventTypes': {
        'tierUpgrade': _random.nextInt(50),
        'featureUsage': _random.nextInt(500),
        'upgradePromptShown': _random.nextInt(200),
        'subscriptionError': _random.nextInt(10),
      },
      'healthMetrics': metrics.toJson(),
      'storageSize': _events.length,
      'lastEventTime': _events.isNotEmpty
          ? _events.last.timestamp.toIso8601String()
          : null,
      'isHealthy': await performHealthCheck(),
      'diagnosticsTimestamp': DateTime.now().toIso8601String(),
      'mockDataGenerated': true,
    };
  }

  @override
  Future<void> clearAnalytics() async {
    await Future.delayed(const Duration(milliseconds: 50));
    _events.clear();
  }

  void _generateMockData() {
    final features = [
      'reading_spreads',
      'guide_access',
      'journal_entries',
      'manual_interpretations',
    ];

    // Generate some mock events for the past 30 days
    for (int i = 0; i < 100; i++) {
      final userId = 'user_${_random.nextInt(50)}';
      final tier = SubscriptionTier
          .values[_random.nextInt(SubscriptionTier.values.length)];

      // Feature usage events
      if (_random.nextBool()) {
        final feature = features[_random.nextInt(features.length)];
        _events.add(
          SubscriptionAnalyticsEvent.featureUsage(
            id: 'event_$i',
            featureKey: feature,
            tier: tier,
            userId: userId,
            properties: {'sessionId': 'session_${_random.nextInt(1000)}'},
          ),
        );
      }

      // Upgrade events
      if (_random.nextInt(10) == 0 && tier != SubscriptionTier.seeker) {
        final fromTier = SubscriptionTier.values[_random.nextInt(tier.index)];
        _events.add(
          SubscriptionAnalyticsEvent.tierUpgrade(
            id: 'upgrade_$i',
            fromTier: fromTier,
            toTier: tier,
            userId: userId,
            properties: {'upgradeReason': 'feature_limit_reached'},
          ),
        );
      }

      // Error events (rare)
      if (_random.nextInt(50) == 0) {
        _events.add(
          SubscriptionAnalyticsEvent.subscriptionError(
            id: 'error_$i',
            errorMessage: 'Mock subscription error',
            tier: tier,
            userId: userId,
            properties: {'errorCode': 'MOCK_ERROR_${_random.nextInt(5)}'},
          ),
        );
      }
    }
  }

  void dispose() {
    _analyticsController.close();
  }
}
