import 'dart:convert';
import 'enums.dart';
import 'user.dart';

/// Represents a friendship connection between two users
class Friendship {
  final String id;
  final String userId;
  final String friendUserId;
  final FriendshipStatus status;
  final DateTime createdAt;
  final DateTime? acceptedAt;
  final String? inviteCode; // Private code for friend invitations

  const Friendship({
    required this.id,
    required this.userId,
    required this.friendUserId,
    required this.status,
    required this.createdAt,
    this.acceptedAt,
    this.inviteCode,
  });

  /// Create a copy of this friendship with some properties changed
  Friendship copyWith({
    String? id,
    String? userId,
    String? friendUserId,
    FriendshipStatus? status,
    DateTime? createdAt,
    DateTime? acceptedAt,
    String? inviteCode,
  }) {
    return Friendship(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      friendUserId: friendUserId ?? this.friendUserId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      inviteCode: inviteCode ?? this.inviteCode,
    );
  }

  /// Check if friendship is active
  bool get isActive => status == FriendshipStatus.accepted;

  /// Check if friendship is pending
  bool get isPending => status == FriendshipStatus.pending;

  /// Check if friendship is blocked
  bool get isBlocked => status == FriendshipStatus.blocked;

  /// Get the other user's ID in this friendship
  String getOtherUserId(String currentUserId) {
    return currentUserId == userId ? friendUserId : userId;
  }

  /// Check if current user initiated this friendship
  bool isInitiatedBy(String currentUserId) {
    return userId == currentUserId;
  }

  /// Get duration of friendship (if accepted)
  Duration? get friendshipDuration {
    if (acceptedAt == null) return null;
    return DateTime.now().difference(acceptedAt!);
  }

  /// Validate friendship data
  bool get isValid {
    return id.isNotEmpty &&
        userId.isNotEmpty &&
        friendUserId.isNotEmpty &&
        userId != friendUserId;
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'friendUserId': friendUserId,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'acceptedAt': acceptedAt?.toIso8601String(),
      'inviteCode': inviteCode,
    };
  }

  /// Create from JSON
  factory Friendship.fromJson(Map<String, dynamic> json) {
    return Friendship(
      id: json['id'] as String,
      userId: json['userId'] as String,
      friendUserId: json['friendUserId'] as String,
      status: FriendshipStatus.fromString(json['status'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      acceptedAt: json['acceptedAt'] != null
          ? DateTime.parse(json['acceptedAt'] as String)
          : null,
      inviteCode: json['inviteCode'] as String?,
    );
  }

  /// Convert to JSON string
  String toJsonString() => jsonEncode(toJson());

  /// Create from JSON string
  factory Friendship.fromJsonString(String jsonString) {
    return Friendship.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Friendship && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Friendship(id: $id, status: ${status.name}, userId: $userId, friendUserId: $friendUserId)';
  }
}

/// Represents a friend with their user information and friendship status
class Friend {
  final User user;
  final Friendship friendship;

  const Friend({required this.user, required this.friendship});

  /// Get display name for the friend
  String get displayName => user.displayName;

  /// Check if friendship is active
  bool get isActive => friendship.isActive;

  /// Check if friendship is pending
  bool get isPending => friendship.isPending;

  /// Get friendship status
  FriendshipStatus get status => friendship.status;

  /// Get when friendship was created
  DateTime get friendsSince => friendship.acceptedAt ?? friendship.createdAt;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Friend &&
        other.user.id == user.id &&
        other.friendship.id == friendship.id;
  }

  @override
  int get hashCode => Object.hash(user.id, friendship.id);

  @override
  String toString() {
    return 'Friend(name: ${user.name}, status: ${friendship.status.name})';
  }
}
