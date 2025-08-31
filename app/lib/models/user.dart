import 'dart:convert';

/// Represents a user of the Lunanul app
class User {
  final String id;
  final String name;
  final String? email;
  final DateTime createdAt;
  final DateTime lastActiveAt;
  final Map<String, dynamic> preferences;

  const User({
    required this.id,
    required this.name,
    this.email,
    required this.createdAt,
    required this.lastActiveAt,
    this.preferences = const {},
  });

  /// Create a copy of this user with some properties changed
  User copyWith({
    String? id,
    String? name,
    String? email,
    DateTime? createdAt,
    DateTime? lastActiveAt,
    Map<String, dynamic>? preferences,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      preferences: preferences ?? this.preferences,
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
    return 'User(id: $id, name: $name, email: $email)';
  }
}
