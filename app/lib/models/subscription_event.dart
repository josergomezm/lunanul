import 'enums.dart';

/// Represents a subscription event or change
class SubscriptionEvent {
  SubscriptionEvent({
    required this.type,
    required this.timestamp,
    required this.tier,
    this.previousTier,
    this.expirationDate,
    this.platformTransactionId,
    this.metadata = const {},
  });

  /// Type of subscription event
  final SubscriptionEventType type;

  /// When the event occurred
  final DateTime timestamp;

  /// Subscription tier involved in the event
  final SubscriptionTier tier;

  /// Previous tier (for upgrades/downgrades)
  final SubscriptionTier? previousTier;

  /// Expiration date (for purchases/renewals)
  final DateTime? expirationDate;

  /// Platform-specific transaction identifier
  final String? platformTransactionId;

  /// Additional event metadata
  final Map<String, dynamic> metadata;

  /// Create a copy with updated values
  SubscriptionEvent copyWith({
    SubscriptionEventType? type,
    DateTime? timestamp,
    SubscriptionTier? tier,
    SubscriptionTier? previousTier,
    DateTime? expirationDate,
    String? platformTransactionId,
    Map<String, dynamic>? metadata,
  }) {
    return SubscriptionEvent(
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      tier: tier ?? this.tier,
      previousTier: previousTier ?? this.previousTier,
      expirationDate: expirationDate ?? this.expirationDate,
      platformTransactionId:
          platformTransactionId ?? this.platformTransactionId,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'timestamp': timestamp.toIso8601String(),
      'tier': tier.name,
      'previousTier': previousTier?.name,
      'expirationDate': expirationDate?.toIso8601String(),
      'platformTransactionId': platformTransactionId,
      'metadata': metadata,
    };
  }

  /// Create from JSON
  factory SubscriptionEvent.fromJson(Map<String, dynamic> json) {
    return SubscriptionEvent(
      type: SubscriptionEventTypeExtension.fromString(json['type'] as String),
      timestamp: DateTime.parse(json['timestamp'] as String),
      tier: SubscriptionTier.fromString(json['tier'] as String),
      previousTier: json['previousTier'] != null
          ? SubscriptionTier.fromString(json['previousTier'] as String)
          : null,
      expirationDate: json['expirationDate'] != null
          ? DateTime.parse(json['expirationDate'] as String)
          : null,
      platformTransactionId: json['platformTransactionId'] as String?,
      metadata: Map<String, dynamic>.from(json['metadata'] as Map? ?? {}),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SubscriptionEvent &&
        other.type == type &&
        other.timestamp == timestamp &&
        other.tier == tier &&
        other.previousTier == previousTier &&
        other.expirationDate == expirationDate &&
        other.platformTransactionId == platformTransactionId;
  }

  @override
  int get hashCode {
    return Object.hash(
      type,
      timestamp,
      tier,
      previousTier,
      expirationDate,
      platformTransactionId,
    );
  }

  @override
  String toString() {
    return 'SubscriptionEvent(type: $type, tier: $tier, timestamp: $timestamp)';
  }
}

/// Types of subscription events
enum SubscriptionEventType {
  purchased,
  renewed,
  upgraded,
  downgraded,
  cancelled,
  expired,
  restored,
  refunded,
}

/// Extension for subscription event type display
extension SubscriptionEventTypeExtension on SubscriptionEventType {
  String get displayName {
    switch (this) {
      case SubscriptionEventType.purchased:
        return 'Purchased';
      case SubscriptionEventType.renewed:
        return 'Renewed';
      case SubscriptionEventType.upgraded:
        return 'Upgraded';
      case SubscriptionEventType.downgraded:
        return 'Downgraded';
      case SubscriptionEventType.cancelled:
        return 'Cancelled';
      case SubscriptionEventType.expired:
        return 'Expired';
      case SubscriptionEventType.restored:
        return 'Restored';
      case SubscriptionEventType.refunded:
        return 'Refunded';
    }
  }

  /// Create from string
  static SubscriptionEventType fromString(String value) {
    return SubscriptionEventType.values.firstWhere(
      (type) => type.name == value,
      orElse: () =>
          throw ArgumentError('Invalid subscription event type: $value'),
    );
  }

  bool get isPositive => [
    SubscriptionEventType.purchased,
    SubscriptionEventType.renewed,
    SubscriptionEventType.upgraded,
    SubscriptionEventType.restored,
  ].contains(this);

  bool get isNegative => [
    SubscriptionEventType.cancelled,
    SubscriptionEventType.expired,
    SubscriptionEventType.refunded,
    SubscriptionEventType.downgraded,
  ].contains(this);
}
