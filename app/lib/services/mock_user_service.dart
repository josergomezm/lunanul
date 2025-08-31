import 'dart:math';
import '../models/user.dart';
import '../models/reading.dart';
import '../models/friendship.dart';
import '../models/shared_reading.dart';
import '../models/enums.dart';

/// Mock service for user management, authentication, and user data
class MockUserService {
  static MockUserService? _instance;
  static MockUserService get instance => _instance ??= MockUserService._();
  MockUserService._();

  final Random _random = Random();

  // Mock current user
  User? _currentUser;

  // Mock data storage
  final List<Reading> _savedReadings = [];
  final List<Friendship> _friendships = [];
  final List<SharedReading> _sharedReadings = [];

  /// Get current user (creates a mock user if none exists)
  Future<User> getCurrentUser() async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 200 + _random.nextInt(300)));

    _currentUser ??= _createMockUser();

    return _currentUser!;
  }

  /// Create a mock user with realistic data
  User _createMockUser() {
    final names = [
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
      'Jade',
      'Skye',
      'Ember',
      'Hazel',
      'Indigo',
      'Coral',
    ];

    final name = names[_random.nextInt(names.length)];
    final userId =
        'user_${DateTime.now().millisecondsSinceEpoch}_${_random.nextInt(9999)}';

    final now = DateTime.now();

    return User(
      id: userId,
      name: name,
      email: '${name.toLowerCase()}@lunanul.app',
      createdAt: now.subtract(Duration(days: _random.nextInt(365))),
      lastActiveAt: now,
      preferences: {
        'allowReversedCards': true,
        'dailyNotifications': true,
        'shareReadings': true,
        'theme': 'auto',
        'profileImageUrl': 'https://api.lunanul.com/avatars/$name.png',
      },
    );
  }

  /// Update user profile
  Future<User> updateUserProfile({
    String? name,
    String? email,
    Map<String, dynamic>? preferences,
  }) async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 300 + _random.nextInt(400)));

    if (_currentUser == null) {
      throw Exception('No user logged in');
    }

    _currentUser = _currentUser!.copyWith(
      name: name ?? _currentUser!.name,
      email: email ?? _currentUser!.email,
      preferences: preferences ?? _currentUser!.preferences,
    );

    return _currentUser!;
  }

  /// Save a reading to user's journal
  Future<void> saveReading(Reading reading) async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 200 + _random.nextInt(300)));

    final savedReading = reading.copyWith(isSaved: true);

    // Remove existing reading with same ID if it exists
    _savedReadings.removeWhere((r) => r.id == reading.id);

    // Add the saved reading
    _savedReadings.add(savedReading);

    // Sort by creation date (newest first)
    _savedReadings.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Get all saved readings for the current user
  Future<List<Reading>> getSavedReadings() async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 150 + _random.nextInt(250)));

    return List.from(_savedReadings);
  }

  /// Get recent readings (last 5)
  Future<List<Reading>> getRecentReadings() async {
    final savedReadings = await getSavedReadings();
    return savedReadings.take(5).toList();
  }

  /// Delete a saved reading
  Future<void> deleteReading(String readingId) async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 200 + _random.nextInt(300)));

    _savedReadings.removeWhere((reading) => reading.id == readingId);
  }

  /// Update reading with user reflection
  Future<Reading> updateReadingReflection(
    String readingId,
    String reflection,
  ) async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 250 + _random.nextInt(350)));

    final readingIndex = _savedReadings.indexWhere((r) => r.id == readingId);
    if (readingIndex == -1) {
      throw Exception('Reading not found');
    }

    final updatedReading = _savedReadings[readingIndex].copyWith(
      userReflection: reflection,
    );

    _savedReadings[readingIndex] = updatedReading;
    return updatedReading;
  }

  /// Get user statistics
  Future<Map<String, dynamic>> getUserStatistics() async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 200 + _random.nextInt(300)));

    final readings = await getSavedReadings();

    // Calculate statistics
    final totalReadings = readings.length;
    final readingsWithReflections = readings
        .where((r) => r.hasReflection)
        .length;

    // Most common topic
    final topicCounts = <String, int>{};
    for (final reading in readings) {
      final topic = reading.topic.name;
      topicCounts[topic] = (topicCounts[topic] ?? 0) + 1;
    }

    final mostCommonTopic = topicCounts.entries
        .fold<MapEntry<String, int>?>(
          null,
          (prev, curr) => prev == null || curr.value > prev.value ? curr : prev,
        )
        ?.key;

    // Most drawn cards
    final cardCounts = <String, int>{};
    for (final reading in readings) {
      for (final cardId in reading.uniqueCardIds) {
        cardCounts[cardId] = (cardCounts[cardId] ?? 0) + 1;
      }
    }

    final mostDrawnCards = cardCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Days since first reading
    final daysSinceFirst = readings.isNotEmpty
        ? DateTime.now().difference(readings.last.createdAt).inDays
        : 0;

    return {
      'totalReadings': totalReadings,
      'readingsWithReflections': readingsWithReflections,
      'reflectionRate': totalReadings > 0
          ? (readingsWithReflections / totalReadings * 100).round()
          : 0,
      'mostCommonTopic': mostCommonTopic,
      'daysSinceFirstReading': daysSinceFirst,
      'mostDrawnCards': mostDrawnCards
          .take(5)
          .map((e) => {'cardId': e.key, 'count': e.value})
          .toList(),
      'averageReadingsPerWeek': daysSinceFirst > 0
          ? (totalReadings / (daysSinceFirst / 7)).toStringAsFixed(1)
          : '0',
    };
  }

  /// Generate mock friends for demonstration
  Future<List<Friendship>> getFriends() async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 200 + _random.nextInt(300)));

    // Generate some mock friends if none exist
    if (_friendships.isEmpty) {
      await _generateMockFriends();
    }

    return List.from(_friendships);
  }

  /// Generate mock friends
  Future<void> _generateMockFriends() async {
    final currentUser = await getCurrentUser();
    final friendNames = ['Aria', 'Zoe', 'Maya', 'Kai', 'Ren'];

    for (int i = 0; i < friendNames.length; i++) {
      final friendId = 'friend_${i + 1}';
      // Create friend user data (not stored as we only track friendships)

      final friendship = Friendship(
        id: 'friendship_${currentUser.id}_$friendId',
        userId: currentUser.id,
        friendUserId: friendId,
        status: FriendshipStatus.accepted,
        createdAt: DateTime.now().subtract(
          Duration(days: _random.nextInt(100)),
        ),
        acceptedAt: DateTime.now().subtract(
          Duration(days: _random.nextInt(100)),
        ),
      );

      _friendships.add(friendship);
    }
  }

  /// Send friend invitation (mock)
  Future<void> sendFriendInvitation(String inviteCode) async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 500 + _random.nextInt(500)));

    // Mock validation
    if (inviteCode.length < 6) {
      throw Exception('Invalid invite code');
    }

    // Simulate success (in real app, this would create a pending friendship)
    print('Friend invitation sent with code: $inviteCode');
  }

  /// Share reading with friend
  Future<void> shareReading(String readingId, String friendId) async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 300 + _random.nextInt(400)));

    final reading = _savedReadings.firstWhere(
      (r) => r.id == readingId,
      orElse: () => throw Exception('Reading not found'),
    );

    final currentUser = await getCurrentUser();

    final sharedReading = SharedReading(
      id: 'shared_${DateTime.now().millisecondsSinceEpoch}',
      readingId: readingId,
      reading: reading,
      sharedByUserId: currentUser.id,
      sharedWithUserId: friendId,
      sharedAt: DateTime.now(),
      messages: [],
    );

    _sharedReadings.add(sharedReading);
  }

  /// Get shared readings
  Future<List<SharedReading>> getSharedReadings() async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 200 + _random.nextInt(300)));

    final currentUser = await getCurrentUser();

    return _sharedReadings
        .where(
          (sr) =>
              sr.sharedByUserId == currentUser.id ||
              sr.sharedWithUserId == currentUser.id,
        )
        .toList();
  }

  /// Generate user's invite code
  Future<String> generateInviteCode() async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 200 + _random.nextInt(300)));

    final currentUser = await getCurrentUser();

    // Generate a mock invite code based on user ID
    final code = currentUser.id
        .substring(currentUser.id.length - 6)
        .toUpperCase();
    return 'LUN-$code';
  }

  /// Get user preferences
  Future<Map<String, dynamic>> getUserPreferences() async {
    final user = await getCurrentUser();
    return user.preferences;
  }

  /// Update user preferences
  Future<void> updateUserPreferences(Map<String, dynamic> preferences) async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 200 + _random.nextInt(300)));

    await updateUserProfile(preferences: preferences);
  }

  /// Clear all user data (for testing)
  void clearUserData() {
    _currentUser = null;
    _savedReadings.clear();
    _friendships.clear();
    _sharedReadings.clear();
  }

  /// Check if user has completed onboarding
  Future<bool> hasCompletedOnboarding() async {
    final user = await getCurrentUser();
    return user.preferences['completedOnboarding'] == true;
  }

  /// Mark onboarding as completed
  Future<void> completeOnboarding() async {
    final currentPrefs = await getUserPreferences();
    currentPrefs['completedOnboarding'] = true;
    await updateUserPreferences(currentPrefs);
  }

  /// Get daily journal prompt
  Future<String> getDailyJournalPrompt() async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 150 + _random.nextInt(250)));

    final prompts = [
      'What intention do you want to set for today?',
      'How are you feeling in this moment, and what does your heart need?',
      'What lesson is the universe trying to teach you right now?',
      'What are you most grateful for in your life today?',
      'How can you show yourself more compassion today?',
      'What patterns in your life are you ready to release?',
      'What brings you the most joy and how can you invite more of it?',
      'What would your wisest self tell you about your current situation?',
      'How can you better align your actions with your values today?',
      'What are you being called to create or manifest?',
    ];

    // Use date as seed for consistent daily prompt
    final today = DateTime.now();
    final daysSinceEpoch = today.difference(DateTime(1970, 1, 1)).inDays;
    final seededRandom = Random(daysSinceEpoch);

    return prompts[seededRandom.nextInt(prompts.length)];
  }
}
