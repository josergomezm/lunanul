import 'package:flutter/foundation.dart';
import 'enums.dart';

/// Represents different types of subscription events for analytics
enum SubscriptionEventType {
  tierUpgrade,
  tierDowngrade,
  subscriptionPurchase,
  subscriptionCancellation,
  subscriptionRenewal,
  subscriptionExpired,
  featureUsage,
  upgradePromptShown,
  upgradePromptClicked,
  upgradePromptDismissed,
  subscriptionError,
  subscriptionRestored,
}

/// Analytics event for subscription-related activities
@immutable
class SubscriptionAnalyticsEvent {
  final String id;
  final SubscriptionEventType eventType;
  final SubscriptionTier? fromTier;
  final SubscriptionTier? toTier;
  final String? featureKey;
  final Map<String, dynamic> properties;
  final DateTime timestamp;
  final String? errorMessage;
  final String? userId;

  const SubscriptionAnalyticsEvent({
    required this.id,
    required this.eventType,
    this.fromTier,
    this.toTier,
    this.featureKey,
    this.properties = const {},
    required this.timestamp,
    this.errorMessage,
    this.userId,
  });

  factory SubscriptionAnalyticsEvent.tierUpgrade({
    required String id,
    required SubscriptionTier fromTier,
    required SubscriptionTier toTier,
    String? userId,
    Map<String, dynamic> properties = const {},
  }) {
    return SubscriptionAnalyticsEvent(
      id: id,
      eventType: SubscriptionEventType.tierUpgrade,
      fromTier: fromTier,
      toTier: toTier,
      userId: userId,
      properties: properties,
      timestamp: DateTime.now(),
    );
  }

  factory SubscriptionAnalyticsEvent.featureUsage({
    required String id,
    required String featureKey,
    required SubscriptionTier tier,
    String? userId,
    Map<String, dynamic> properties = const {},
  }) {
    return SubscriptionAnalyticsEvent(
      id: id,
      eventType: SubscriptionEventType.featureUsage,
      featureKey: featureKey,
      properties: {'tier': tier.name, ...properties},
      userId: userId,
      timestamp: DateTime.now(),
    );
  }

  factory SubscriptionAnalyticsEvent.upgradePrompt({
    required String id,
    required SubscriptionEventType eventType,
    required String featureKey,
    required SubscriptionTier currentTier,
    required SubscriptionTier recommendedTier,
    String? userId,
    Map<String, dynamic> properties = const {},
  }) {
    return SubscriptionAnalyticsEvent(
      id: id,
      eventType: eventType,
      featureKey: featureKey,
      fromTier: currentTier,
      toTier: recommendedTier,
      userId: userId,
      properties: properties,
      timestamp: DateTime.now(),
    );
  }

  factory SubscriptionAnalyticsEvent.subscriptionError({
    required String id,
    required String errorMessage,
    SubscriptionTier? tier,
    String? userId,
    Map<String, dynamic> properties = const {},
  }) {
    return SubscriptionAnalyticsEvent(
      id: id,
      eventType: SubscriptionEventType.subscriptionError,
      fromTier: tier,
      errorMessage: errorMessage,
      userId: userId,
      properties: properties,
      timestamp: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'eventType': eventType.name,
      'fromTier': fromTier?.name,
      'toTier': toTier?.name,
      'featureKey': featureKey,
      'properties': properties,
      'timestamp': timestamp.toIso8601String(),
      'errorMessage': errorMessage,
      'userId': userId,
    };
  }

  factory SubscriptionAnalyticsEvent.fromJson(Map<String, dynamic> json) {
    return SubscriptionAnalyticsEvent(
      id: json['id'] as String,
      eventType: SubscriptionEventType.values.firstWhere(
        (e) => e.name == json['eventType'],
      ),
      fromTier: json['fromTier'] != null
          ? SubscriptionTier.values.firstWhere(
              (e) => e.name == json['fromTier'],
            )
          : null,
      toTier: json['toTier'] != null
          ? SubscriptionTier.values.firstWhere((e) => e.name == json['toTier'])
          : null,
      featureKey: json['featureKey'] as String?,
      properties: Map<String, dynamic>.from(json['properties'] ?? {}),
      timestamp: DateTime.parse(json['timestamp'] as String),
      errorMessage: json['errorMessage'] as String?,
      userId: json['userId'] as String?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SubscriptionAnalyticsEvent &&
        other.id == id &&
        other.eventType == eventType &&
        other.fromTier == fromTier &&
        other.toTier == toTier &&
        other.featureKey == featureKey &&
        mapEquals(other.properties, properties) &&
        other.timestamp == timestamp &&
        other.errorMessage == errorMessage &&
        other.userId == userId;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      eventType,
      fromTier,
      toTier,
      featureKey,
      properties,
      timestamp,
      errorMessage,
      userId,
    );
  }

  @override
  String toString() {
    return 'SubscriptionAnalyticsEvent('
        'id: $id, '
        'eventType: $eventType, '
        'fromTier: $fromTier, '
        'toTier: $toTier, '
        'featureKey: $featureKey, '
        'timestamp: $timestamp'
        ')';
  }
}

/// Usage statistics for a specific feature by tier
@immutable
class FeatureUsageStats {
  final String featureKey;
  final SubscriptionTier tier;
  final int usageCount;
  final DateTime firstUsed;
  final DateTime lastUsed;
  final double averageUsagePerDay;

  const FeatureUsageStats({
    required this.featureKey,
    required this.tier,
    required this.usageCount,
    required this.firstUsed,
    required this.lastUsed,
    required this.averageUsagePerDay,
  });

  Map<String, dynamic> toJson() {
    return {
      'featureKey': featureKey,
      'tier': tier.name,
      'usageCount': usageCount,
      'firstUsed': firstUsed.toIso8601String(),
      'lastUsed': lastUsed.toIso8601String(),
      'averageUsagePerDay': averageUsagePerDay,
    };
  }

  factory FeatureUsageStats.fromJson(Map<String, dynamic> json) {
    return FeatureUsageStats(
      featureKey: json['featureKey'] as String,
      tier: SubscriptionTier.values.firstWhere((e) => e.name == json['tier']),
      usageCount: json['usageCount'] as int,
      firstUsed: DateTime.parse(json['firstUsed'] as String),
      lastUsed: DateTime.parse(json['lastUsed'] as String),
      averageUsagePerDay: (json['averageUsagePerDay'] as num).toDouble(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FeatureUsageStats &&
        other.featureKey == featureKey &&
        other.tier == tier &&
        other.usageCount == usageCount &&
        other.firstUsed == firstUsed &&
        other.lastUsed == lastUsed &&
        other.averageUsagePerDay == averageUsagePerDay;
  }

  @override
  int get hashCode {
    return Object.hash(
      featureKey,
      tier,
      usageCount,
      firstUsed,
      lastUsed,
      averageUsagePerDay,
    );
  }
}

/// Subscription health metrics
@immutable
class SubscriptionHealthMetrics {
  final double conversionRate;
  final double churnRate;
  final Map<SubscriptionTier, int> activeSubscriptions;
  final Map<SubscriptionTier, double> featureAdoptionRates;
  final int totalErrors;
  final double errorRate;
  final DateTime lastUpdated;

  const SubscriptionHealthMetrics({
    required this.conversionRate,
    required this.churnRate,
    required this.activeSubscriptions,
    required this.featureAdoptionRates,
    required this.totalErrors,
    required this.errorRate,
    required this.lastUpdated,
  });

  Map<String, dynamic> toJson() {
    return {
      'conversionRate': conversionRate,
      'churnRate': churnRate,
      'activeSubscriptions': activeSubscriptions.map(
        (key, value) => MapEntry(key.name, value),
      ),
      'featureAdoptionRates': featureAdoptionRates.map(
        (key, value) => MapEntry(key.name, value),
      ),
      'totalErrors': totalErrors,
      'errorRate': errorRate,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory SubscriptionHealthMetrics.fromJson(Map<String, dynamic> json) {
    return SubscriptionHealthMetrics(
      conversionRate: (json['conversionRate'] as num).toDouble(),
      churnRate: (json['churnRate'] as num).toDouble(),
      activeSubscriptions: (json['activeSubscriptions'] as Map<String, dynamic>)
          .map(
            (key, value) => MapEntry(
              SubscriptionTier.values.firstWhere((e) => e.name == key),
              value as int,
            ),
          ),
      featureAdoptionRates:
          (json['featureAdoptionRates'] as Map<String, dynamic>).map(
            (key, value) => MapEntry(
              SubscriptionTier.values.firstWhere((e) => e.name == key),
              (value as num).toDouble(),
            ),
          ),
      totalErrors: json['totalErrors'] as int,
      errorRate: (json['errorRate'] as num).toDouble(),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SubscriptionHealthMetrics &&
        other.conversionRate == conversionRate &&
        other.churnRate == churnRate &&
        mapEquals(other.activeSubscriptions, activeSubscriptions) &&
        mapEquals(other.featureAdoptionRates, featureAdoptionRates) &&
        other.totalErrors == totalErrors &&
        other.errorRate == errorRate &&
        other.lastUpdated == lastUpdated;
  }

  @override
  int get hashCode {
    return Object.hash(
      conversionRate,
      churnRate,
      activeSubscriptions,
      featureAdoptionRates,
      totalErrors,
      errorRate,
      lastUpdated,
    );
  }
}
