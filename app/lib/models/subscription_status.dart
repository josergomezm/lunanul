import 'enums.dart';

/// Represents the current subscription status of a user
class SubscriptionStatus {
  SubscriptionStatus({
    required this.tier,
    required this.isActive,
    this.expirationDate,
    this.platformSubscriptionId,
    this.usageCounts = const {},
    DateTime? lastUpdated,
  }) : lastUpdated = lastUpdated ?? DateTime.now();

  /// The user's current subscription tier
  final SubscriptionTier tier;

  /// Whether the subscription is currently active
  final bool isActive;

  /// When the subscription expires (null for free tier)
  final DateTime? expirationDate;

  /// Platform-specific subscription identifier (App Store/Google Play)
  final String? platformSubscriptionId;

  /// Usage counts for features with limits (e.g., manual interpretations)
  final Map<String, int> usageCounts;

  /// When this status was last updated
  final DateTime lastUpdated;

  /// Create a copy with updated values
  SubscriptionStatus copyWith({
    SubscriptionTier? tier,
    bool? isActive,
    DateTime? expirationDate,
    String? platformSubscriptionId,
    Map<String, int>? usageCounts,
    DateTime? lastUpdated,
  }) {
    return SubscriptionStatus(
      tier: tier ?? this.tier,
      isActive: isActive ?? this.isActive,
      expirationDate: expirationDate ?? this.expirationDate,
      platformSubscriptionId:
          platformSubscriptionId ?? this.platformSubscriptionId,
      usageCounts: usageCounts ?? this.usageCounts,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  /// Check if the subscription is expired
  bool get isExpired {
    if (tier == SubscriptionTier.seeker) return false;
    if (expirationDate == null) return false;
    return DateTime.now().isAfter(expirationDate!);
  }

  /// Check if the subscription is valid and active
  bool get isValid => isActive && !isExpired;

  /// Get usage count for a specific feature
  int getUsageCount(String feature) {
    return usageCounts[feature] ?? 0;
  }

  /// Create a new status with incremented usage for a feature
  SubscriptionStatus incrementUsage(String feature) {
    final newUsageCounts = Map<String, int>.from(usageCounts);
    newUsageCounts[feature] = (newUsageCounts[feature] ?? 0) + 1;

    return copyWith(usageCounts: newUsageCounts, lastUpdated: DateTime.now());
  }

  /// Reset usage counts (typically called monthly)
  SubscriptionStatus resetUsage() {
    return copyWith(usageCounts: {}, lastUpdated: DateTime.now());
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'tier': tier.name,
      'isActive': isActive,
      'expirationDate': expirationDate?.toIso8601String(),
      'platformSubscriptionId': platformSubscriptionId,
      'usageCounts': usageCounts,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  /// Create from JSON
  factory SubscriptionStatus.fromJson(Map<String, dynamic> json) {
    return SubscriptionStatus(
      tier: SubscriptionTier.fromString(json['tier'] as String),
      isActive: json['isActive'] as bool,
      expirationDate: json['expirationDate'] != null
          ? DateTime.parse(json['expirationDate'] as String)
          : null,
      platformSubscriptionId: json['platformSubscriptionId'] as String?,
      usageCounts: Map<String, int>.from(json['usageCounts'] as Map? ?? {}),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );
  }

  /// Create default free tier status
  factory SubscriptionStatus.free() {
    return SubscriptionStatus(
      tier: SubscriptionTier.seeker,
      isActive: true,
      lastUpdated: DateTime.now(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SubscriptionStatus &&
        other.tier == tier &&
        other.isActive == isActive &&
        other.expirationDate == expirationDate &&
        other.platformSubscriptionId == platformSubscriptionId &&
        other.lastUpdated == lastUpdated;
  }

  @override
  int get hashCode {
    return Object.hash(
      tier,
      isActive,
      expirationDate,
      platformSubscriptionId,
      lastUpdated,
    );
  }

  @override
  String toString() {
    return 'SubscriptionStatus(tier: $tier, isActive: $isActive, '
        'expirationDate: $expirationDate, isValid: $isValid)';
  }
}
