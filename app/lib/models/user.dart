import 'dart:convert';
import 'subscription_status.dart';
import 'enums.dart';

/// Represents a user of the Lunanul app
class User {
  final String id;
  final String name;
  final String? email;
  final DateTime createdAt;
  final DateTime lastActiveAt;
  final Map<String, dynamic> preferences;
  final SubscriptionStatus subscriptionStatus;

  User({
    required this.id,
    required this.name,
    this.email,
    required this.createdAt,
    required this.lastActiveAt,
    this.preferences = const {},
    SubscriptionStatus? subscriptionStatus,
  }) : subscriptionStatus = subscriptionStatus ?? SubscriptionStatus.free();

  /// Create a copy of this user with some properties changed
  User copyWith({
    String? id,
    String? name,
    String? email,
    DateTime? createdAt,
    DateTime? lastActiveAt,
    Map<String, dynamic>? preferences,
    SubscriptionStatus? subscriptionStatus,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      preferences: preferences ?? this.preferences,
      subscriptionStatus: subscriptionStatus ?? this.subscriptionStatus,
    );
  }

  /// Get display name for greetings
  String get displayName => name.isNotEmpty ? name : 'Friend';

  /// Get personalized greeting based on time of day
  String get personalizedGreeting {
    final hour = DateTime.now().hour;
    String timeGreeting;

    if (hour < 12) {
      timeGreeting = 'Good morning';
    } else if (hour < 17) {
      timeGreeting = 'Good afternoon';
    } else {
      timeGreeting = 'Good evening';
    }

    return '$timeGreeting, $displayName';
  }

  /// Check if user is new (created within last 7 days)
  bool get isNewUser {
    final daysSinceCreation = DateTime.now().difference(createdAt).inDays;
    return daysSinceCreation <= 7;
  }

  /// Get user preference with default value
  T getPreference<T>(String key, T defaultValue) {
    return preferences[key] as T? ?? defaultValue;
  }

  /// Set user preference
  User setPreference(String key, dynamic value) {
    final newPreferences = Map<String, dynamic>.from(preferences);
    newPreferences[key] = value;
    return copyWith(preferences: newPreferences);
  }

  /// Remove user preference
  User removePreference(String key) {
    final newPreferences = Map<String, dynamic>.from(preferences);
    newPreferences.remove(key);
    return copyWith(preferences: newPreferences);
  }

  /// Update subscription status
  User updateSubscriptionStatus(SubscriptionStatus newStatus) {
    return copyWith(subscriptionStatus: newStatus);
  }

  /// Get current subscription tier
  SubscriptionTier get subscriptionTier => subscriptionStatus.tier;

  /// Check if user has active subscription
  bool get hasActiveSubscription => subscriptionStatus.isValid;

  /// Check if user is on free tier
  bool get isFreeUser => subscriptionStatus.tier == SubscriptionTier.seeker;

  /// Check if user is on paid tier
  bool get isPaidUser => subscriptionStatus.tier != SubscriptionTier.seeker;

  /// Check if user has specific tier or higher
  bool hasAtLeastTier(SubscriptionTier minimumTier) {
    const tierHierarchy = {
      SubscriptionTier.seeker: 0,
      SubscriptionTier.mystic: 1,
      SubscriptionTier.oracle: 2,
    };

    final currentLevel = tierHierarchy[subscriptionStatus.tier] ?? 0;
    final minimumLevel = tierHierarchy[minimumTier] ?? 0;

    return currentLevel >= minimumLevel;
  }

  /// Get usage count for a specific feature
  int getUsageCount(String feature) {
    return subscriptionStatus.getUsageCount(feature);
  }

  /// Increment usage for a feature
  User incrementUsage(String feature) {
    final updatedStatus = subscriptionStatus.incrementUsage(feature);
    return copyWith(subscriptionStatus: updatedStatus);
  }

  /// Reset monthly usage
  User resetUsage() {
    final updatedStatus = subscriptionStatus.resetUsage();
    return copyWith(subscriptionStatus: updatedStatus);
  }

  /// Get subscription-aware preferences
  Map<String, dynamic> getSubscriptionAwarePreferences() {
    final basePreferences = Map<String, dynamic>.from(preferences);

    // Add subscription-specific preferences
    basePreferences['subscriptionTier'] = subscriptionStatus.tier.name;
    basePreferences['subscriptionActive'] = subscriptionStatus.isActive;
    basePreferences['subscriptionExpiration'] = subscriptionStatus
        .expirationDate
        ?.toIso8601String();

    return basePreferences;
  }

  /// Validate user data
  bool get isValid {
    return id.isNotEmpty && name.isNotEmpty;
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'createdAt': createdAt.toIso8601String(),
      'lastActiveAt': lastActiveAt.toIso8601String(),
      'preferences': preferences,
      'subscriptionStatus': subscriptionStatus.toJson(),
    };
  }

  /// Create from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastActiveAt: DateTime.parse(json['lastActiveAt'] as String),
      preferences: Map<String, dynamic>.from(json['preferences'] as Map? ?? {}),
      subscriptionStatus: json['subscriptionStatus'] != null
          ? SubscriptionStatus.fromJson(
              json['subscriptionStatus'] as Map<String, dynamic>,
            )
          : SubscriptionStatus.free(),
    );
  }

  /// Convert to JSON string
  String toJsonString() => jsonEncode(toJson());

  /// Create from JSON string
  factory User.fromJsonString(String jsonString) {
    return User.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'User(id: $id, name: $name, email: $email, tier: ${subscriptionStatus.tier})';
  }
}
