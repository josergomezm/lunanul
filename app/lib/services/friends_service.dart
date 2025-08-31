import 'dart:math';
import '../models/models.dart';

/// Service for managing friends and sharing functionality
class FriendsService {
  static FriendsService? _instance;
  static FriendsService get instance => _instance ??= FriendsService._();
  FriendsService._();

  final Random _random = Random();

  // Mock data storage
  final List<Friendship> _friendships = [];
  final List<SharedReading> _sharedReadings = [];
  final Map<String, User> _users = {}; // Mock user database

  /// Generate a unique invite code for the current user
  Future<String> generateInviteCode(String userId) async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 200 + _random.nextInt(300)));

    // Generate a unique code based on timestamp and user ID
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final userHash = userId.hashCode.abs();
    final randomPart = _random.nextInt(999);

    return 'LUNA-${timestamp.toString().substring(8)}-${userHash.toString().substring(0, 3)}$randomPart';
  }

  /// Send friend invitation using invite code
  Future<void> sendFriendInvitation(
    String currentUserId,
    String inviteCode,
  ) async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 500 + _random.nextInt(500)));

    // Mock validation
    if (!inviteCode.startsWith('LUNA-') || inviteCode.length < 10) {
      throw Exception('Invalid invite code format');
    }

    // Check if friendship already exists
    final existingFriendship = _friendships.any(
      (f) =>
          (f.userId == currentUserId || f.friendUserId == currentUserId) &&
          f.inviteCode == inviteCode,
    );

    if (existingFriendship) {
      throw Exception('Friend request already exists');
    }

    // Create mock friend user if not exists
    final friendUserId = 'friend_${inviteCode.hashCode.abs()}';
    if (!_users.containsKey(friendUserId)) {
      _users[friendUserId] = _createMockFriend(friendUserId, inviteCode);
    }

    // Create pending friendship
    final friendship = Friendship(
      id: 'friendship_${DateTime.now().millisecondsSinceEpoch}',
      userId: currentUserId,
      friendUserId: friendUserId,
      status: FriendshipStatus.pending,
      createdAt: DateTime.now(),
      inviteCode: inviteCode,
    );

    _friendships.add(friendship);

    // Auto-accept for demo purposes (simulate friend accepting)
    await Future.delayed(const Duration(milliseconds: 1000));
    await _acceptFriendRequest(friendship.id);
  }

  /// Accept a friend request
  Future<void> _acceptFriendRequest(String friendshipId) async {
    final friendshipIndex = _friendships.indexWhere(
      (f) => f.id == friendshipId,
    );
    if (friendshipIndex == -1) return;

    _friendships[friendshipIndex] = _friendships[friendshipIndex].copyWith(
      status: FriendshipStatus.accepted,
      acceptedAt: DateTime.now(),
    );
  }

  /// Get all friends for a user
  Future<List<Friend>> getFriends(String userId) async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 200 + _random.nextInt(300)));

    final userFriendships = _friendships
        .where(
          (f) =>
              (f.userId == userId || f.friendUserId == userId) &&
              f.status == FriendshipStatus.accepted,
        )
        .toList();

    final friends = <Friend>[];
    for (final friendship in userFriendships) {
      final friendUserId = friendship.getOtherUserId(userId);
      final friendUser =
          _users[friendUserId] ?? _createMockFriend(friendUserId, 'UNKNOWN');
      friends.add(Friend(user: friendUser, friendship: friendship));
    }

    return friends;
  }

  /// Get pending friend requests
  Future<List<Friendship>> getPendingRequests(String userId) async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 150 + _random.nextInt(250)));

    return _friendships
        .where(
          (f) =>
              f.friendUserId == userId && f.status == FriendshipStatus.pending,
        )
        .toList();
  }

  /// Remove/block a friend
  Future<void> removeFriend(String friendshipId) async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 300 + _random.nextInt(400)));

    _friendships.removeWhere((f) => f.id == friendshipId);

    // Also remove any shared readings with this friend
    _sharedReadings.removeWhere(
      (sr) =>
          sr.sharedByUserId == friendshipId ||
          sr.sharedWithUserId == friendshipId,
    );
  }

  /// Share a reading with a friend
  Future<SharedReading> shareReading(
    String readingId,
    Reading reading,
    String currentUserId,
    String friendUserId,
  ) async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 300 + _random.nextInt(400)));

    // Verify friendship exists
    _friendships.firstWhere(
      (f) =>
          ((f.userId == currentUserId && f.friendUserId == friendUserId) ||
              (f.userId == friendUserId && f.friendUserId == currentUserId)) &&
          f.status == FriendshipStatus.accepted,
      orElse: () => throw Exception('Friendship not found or not active'),
    );

    final sharedReading = SharedReading(
      id: 'shared_${DateTime.now().millisecondsSinceEpoch}',
      readingId: readingId,
      reading: reading,
      sharedByUserId: currentUserId,
      sharedWithUserId: friendUserId,
      sharedAt: DateTime.now(),
      messages: [],
    );

    _sharedReadings.add(sharedReading);
    return sharedReading;
  }

  /// Get shared readings for a user
  Future<List<SharedReading>> getSharedReadings(String userId) async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 200 + _random.nextInt(300)));

    return _sharedReadings
        .where(
          (sr) => sr.sharedByUserId == userId || sr.sharedWithUserId == userId,
        )
        .toList()
      ..sort((a, b) => b.sharedAt.compareTo(a.sharedAt));
  }

  /// Add message to shared reading
  Future<ChatMessage> addMessageToSharedReading(
    String sharedReadingId,
    String senderId,
    String message,
  ) async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 250 + _random.nextInt(350)));

    final sharedReadingIndex = _sharedReadings.indexWhere(
      (sr) => sr.id == sharedReadingId,
    );
    if (sharedReadingIndex == -1) {
      throw Exception('Shared reading not found');
    }

    final chatMessage = ChatMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      senderUserId: senderId,
      message: message,
      sentAt: DateTime.now(),
      readByUserIds: [senderId], // Sender has read it by default
    );

    _sharedReadings[sharedReadingIndex] = _sharedReadings[sharedReadingIndex]
        .addMessage(chatMessage);
    return chatMessage;
  }

  /// Mark messages as read
  Future<void> markMessagesAsRead(String sharedReadingId, String userId) async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 150 + _random.nextInt(250)));

    final sharedReadingIndex = _sharedReadings.indexWhere(
      (sr) => sr.id == sharedReadingId,
    );
    if (sharedReadingIndex == -1) return;

    final sharedReading = _sharedReadings[sharedReadingIndex];
    final updatedMessages = sharedReading.messages
        .map(
          (msg) => msg.senderUserId != userId ? msg.markAsReadBy(userId) : msg,
        )
        .toList();

    _sharedReadings[sharedReadingIndex] = sharedReading.copyWith(
      messages: updatedMessages,
    );
  }

  /// Get user by ID (for displaying friend info)
  Future<User?> getUserById(String userId) async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 100 + _random.nextInt(200)));

    return _users[userId];
  }

  /// Create a mock friend user
  User _createMockFriend(String userId, String inviteCode) {
    final friendNames = [
      'Aria',
      'Zoe',
      'Maya',
      'Kai',
      'Ren',
      'Luna',
      'Sage',
      'River',
      'Aurora',
      'Phoenix',
      'Willow',
      'Iris',
      'Nova',
      'Celeste',
      'Raven',
    ];

    final name = friendNames[userId.hashCode.abs() % friendNames.length];

    return User(
      id: userId,
      name: name,
      email: '${name.toLowerCase()}@example.com',
      createdAt: DateTime.now().subtract(Duration(days: _random.nextInt(365))),
      lastActiveAt: DateTime.now().subtract(
        Duration(hours: _random.nextInt(24)),
      ),
      preferences: {
        'profileImageUrl': 'https://api.lunanul.com/avatars/$name.png',
        'allowReversedCards': true,
        'shareReadings': true,
      },
    );
  }

  /// Clear all data (for testing)
  void clearData() {
    _friendships.clear();
    _sharedReadings.clear();
    _users.clear();
  }

  /// Get friendship status between two users
  Future<FriendshipStatus?> getFriendshipStatus(
    String userId1,
    String userId2,
  ) async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 100 + _random.nextInt(200)));

    final friendship = _friendships.firstWhere(
      (f) =>
          (f.userId == userId1 && f.friendUserId == userId2) ||
          (f.userId == userId2 && f.friendUserId == userId1),
      orElse: () => throw Exception('Friendship not found'),
    );

    return friendship.status;
  }
}
