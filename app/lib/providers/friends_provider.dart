import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../services/friends_service.dart';
import '../services/mock_user_service.dart';

/// Provider for the FriendsService instance
final friendsServiceProvider = Provider<FriendsService>((ref) {
  return FriendsService.instance;
});

/// State notifier for friends management
class FriendsNotifier extends StateNotifier<AsyncValue<List<Friend>>> {
  FriendsNotifier(this._friendsService, this._userService)
    : super(const AsyncValue.loading()) {
    _loadFriends();
  }

  final FriendsService _friendsService;
  final MockUserService _userService;

  /// Load friends list
  Future<void> _loadFriends() async {
    try {
      final currentUser = await _userService.getCurrentUser();
      final friends = await _friendsService.getFriends(currentUser.id);
      state = AsyncValue.data(friends);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Send friend invitation
  Future<void> sendInvitation(String inviteCode) async {
    try {
      final currentUser = await _userService.getCurrentUser();
      await _friendsService.sendFriendInvitation(currentUser.id, inviteCode);
      _loadFriends(); // Reload to get updated list
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  /// Remove a friend
  Future<void> removeFriend(String friendshipId) async {
    try {
      await _friendsService.removeFriend(friendshipId);
      _loadFriends(); // Reload to get updated list
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  /// Refresh friends list
  Future<void> refresh() async {
    _loadFriends();
  }
}

/// Provider for friends management
final friendsProvider =
    StateNotifierProvider<FriendsNotifier, AsyncValue<List<Friend>>>((ref) {
      return FriendsNotifier(
        ref.read(friendsServiceProvider),
        ref.read(userServiceProvider),
      );
    });

/// State notifier for shared readings
class SharedReadingsNotifier
    extends StateNotifier<AsyncValue<List<SharedReading>>> {
  SharedReadingsNotifier(this._friendsService, this._userService)
    : super(const AsyncValue.loading()) {
    _loadSharedReadings();
  }

  final FriendsService _friendsService;
  final MockUserService _userService;

  /// Load shared readings
  Future<void> _loadSharedReadings() async {
    try {
      final currentUser = await _userService.getCurrentUser();
      final sharedReadings = await _friendsService.getSharedReadings(
        currentUser.id,
      );
      state = AsyncValue.data(sharedReadings);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Share a reading with a friend
  Future<void> shareReading(
    String readingId,
    Reading reading,
    String friendUserId,
  ) async {
    try {
      final currentUser = await _userService.getCurrentUser();
      await _friendsService.shareReading(
        readingId,
        reading,
        currentUser.id,
        friendUserId,
      );
      _loadSharedReadings(); // Reload to get updated list
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  /// Add message to shared reading
  Future<void> addMessage(String sharedReadingId, String message) async {
    try {
      final currentUser = await _userService.getCurrentUser();
      await _friendsService.addMessageToSharedReading(
        sharedReadingId,
        currentUser.id,
        message,
      );
      _loadSharedReadings(); // Reload to get updated list
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  /// Mark messages as read
  Future<void> markAsRead(String sharedReadingId) async {
    try {
      final currentUser = await _userService.getCurrentUser();
      await _friendsService.markMessagesAsRead(sharedReadingId, currentUser.id);
      _loadSharedReadings(); // Reload to get updated list
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Refresh shared readings
  Future<void> refresh() async {
    _loadSharedReadings();
  }
}

/// Provider for shared readings
final sharedReadingsProvider =
    StateNotifierProvider<
      SharedReadingsNotifier,
      AsyncValue<List<SharedReading>>
    >((ref) {
      return SharedReadingsNotifier(
        ref.read(friendsServiceProvider),
        ref.read(userServiceProvider),
      );
    });

/// Provider for generating invite codes
final inviteCodeProvider = FutureProvider<String>((ref) async {
  final friendsService = ref.read(friendsServiceProvider);
  final userService = ref.read(userServiceProvider);
  final currentUser = await userService.getCurrentUser();
  return friendsService.generateInviteCode(currentUser.id);
});

/// Provider for pending friend requests
final pendingRequestsProvider = FutureProvider<List<Friendship>>((ref) async {
  final friendsService = ref.read(friendsServiceProvider);
  final userService = ref.read(userServiceProvider);
  final currentUser = await userService.getCurrentUser();
  return friendsService.getPendingRequests(currentUser.id);
});

/// Provider for getting user by ID
final userByIdProvider = FutureProvider.family<User?, String>((
  ref,
  userId,
) async {
  final friendsService = ref.read(friendsServiceProvider);
  return friendsService.getUserById(userId);
});

/// Provider for the MockUserService instance (imported from user_provider)
final userServiceProvider = Provider<MockUserService>((ref) {
  return MockUserService.instance;
});
