import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../services/mock_user_service.dart';
import '../services/user_subscription_integration_service.dart';
import 'subscription_provider.dart';

/// Provider for the MockUserService instance
final userServiceProvider = Provider<MockUserService>((ref) {
  return MockUserService.instance;
});

/// Provider for the UserSubscriptionIntegrationService
final userSubscriptionIntegrationProvider =
    Provider<UserSubscriptionIntegrationService>((ref) {
      return UserSubscriptionIntegrationService(
        userService: ref.read(userServiceProvider),
        subscriptionService: ref.read(subscriptionServiceProvider),
      );
    });

/// Provider for current user
final currentUserProvider = FutureProvider<User>((ref) async {
  final userService = ref.read(userServiceProvider);
  return userService.getCurrentUser();
});

/// State notifier for user profile management
class UserProfileNotifier extends StateNotifier<AsyncValue<User>> {
  UserProfileNotifier(this._userService, this._ref)
    : super(const AsyncValue.loading()) {
    _loadUser();
    _listenToSubscriptionChanges();
  }

  final MockUserService _userService;
  final Ref _ref;

  /// Load current user with subscription integration
  Future<void> _loadUser() async {
    try {
      final integrationService = _ref.read(userSubscriptionIntegrationProvider);
      final user = await integrationService.initializeUserSubscription();
      state = AsyncValue.data(user);
    } catch (error) {
      // Fallback to basic user loading if integration fails
      try {
        final user = await _userService.getCurrentUser();
        state = AsyncValue.data(user);
      } catch (fallbackError, fallbackStackTrace) {
        state = AsyncValue.error(fallbackError, fallbackStackTrace);
      }
    }
  }

  /// Listen to subscription status changes and update user accordingly
  void _listenToSubscriptionChanges() {
    _ref.listen<AsyncValue<SubscriptionStatus>>(subscriptionProvider, (
      previous,
      next,
    ) {
      next.whenData((subscriptionStatus) async {
        final currentUser = state.value;
        if (currentUser != null &&
            currentUser.subscriptionStatus != subscriptionStatus) {
          // Update user with new subscription status
          try {
            final updatedUser = await _userService.updateSubscriptionStatus(
              subscriptionStatus,
            );
            state = AsyncValue.data(updatedUser);
          } catch (error) {
            // If update fails, at least update the local state
            final updatedUser = currentUser.updateSubscriptionStatus(
              subscriptionStatus,
            );
            state = AsyncValue.data(updatedUser);
          }
        }
      });
    });
  }

  /// Update user profile
  Future<void> updateProfile({
    String? name,
    String? email,
    Map<String, dynamic>? preferences,
    SubscriptionStatus? subscriptionStatus,
  }) async {
    state = const AsyncValue.loading();
    try {
      final updatedUser = await _userService.updateUserProfile(
        name: name,
        email: email,
        preferences: preferences,
        subscriptionStatus: subscriptionStatus,
      );
      state = AsyncValue.data(updatedUser);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Update subscription status
  Future<void> updateSubscriptionStatus(
    SubscriptionStatus subscriptionStatus,
  ) async {
    try {
      final updatedUser = await _userService.updateSubscriptionStatus(
        subscriptionStatus,
      );
      state = AsyncValue.data(updatedUser);
    } catch (error) {
      // If service update fails, at least update local state
      final currentUser = state.value;
      if (currentUser != null) {
        final updatedUser = currentUser.updateSubscriptionStatus(
          subscriptionStatus,
        );
        state = AsyncValue.data(updatedUser);
      }
    }
  }

  /// Increment usage for a feature
  Future<void> incrementUsage(String feature) async {
    try {
      final updatedUser = await _userService.incrementUsage(feature);
      state = AsyncValue.data(updatedUser);

      // Also update the subscription provider
      _ref.read(subscriptionProvider.notifier).incrementUsage(feature);
    } catch (error) {
      // If service update fails, at least update local state
      final currentUser = state.value;
      if (currentUser != null) {
        final updatedUser = currentUser.incrementUsage(feature);
        state = AsyncValue.data(updatedUser);
      }
    }
  }

  /// Reset monthly usage
  Future<void> resetUsage() async {
    try {
      final updatedUser = await _userService.resetUsage();
      state = AsyncValue.data(updatedUser);

      // Also update the subscription provider
      _ref.read(subscriptionProvider.notifier).resetUsage();
    } catch (error) {
      // If service update fails, at least update local state
      final currentUser = state.value;
      if (currentUser != null) {
        final updatedUser = currentUser.resetUsage();
        state = AsyncValue.data(updatedUser);
      }
    }
  }

  /// Update user preferences
  Future<void> updatePreferences(Map<String, dynamic> preferences) async {
    final currentUser = state.value;
    if (currentUser != null) {
      await updateProfile(preferences: preferences);
    }
  }

  /// Complete onboarding
  Future<void> completeOnboarding() async {
    await _userService.completeOnboarding();
    _loadUser(); // Reload user to get updated preferences
  }

  /// Refresh user data
  Future<void> refresh() async {
    _loadUser();
  }

  /// Handle subscription purchase completion
  Future<void> handleSubscriptionPurchase(String productId) async {
    try {
      final integrationService = _ref.read(userSubscriptionIntegrationProvider);
      final updatedUser = await integrationService.handleSubscriptionPurchase(
        productId,
      );
      state = AsyncValue.data(updatedUser);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Handle subscription restoration
  Future<void> handleSubscriptionRestoration() async {
    try {
      final integrationService = _ref.read(userSubscriptionIntegrationProvider);
      final updatedUser = await integrationService
          .handleSubscriptionRestoration();
      state = AsyncValue.data(updatedUser);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Handle subscription expiration
  Future<void> handleSubscriptionExpiration() async {
    try {
      final integrationService = _ref.read(userSubscriptionIntegrationProvider);
      final updatedUser = await integrationService
          .handleSubscriptionExpiration();
      state = AsyncValue.data(updatedUser);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Sync user subscription with platform
  Future<void> syncSubscription() async {
    try {
      final integrationService = _ref.read(userSubscriptionIntegrationProvider);
      final updatedUser = await integrationService.syncUserSubscription();
      state = AsyncValue.data(updatedUser);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Update subscription-aware preferences
  Future<void> updateSubscriptionAwarePreferences(
    Map<String, dynamic> preferences,
  ) async {
    try {
      final integrationService = _ref.read(userSubscriptionIntegrationProvider);
      final updatedUser = await integrationService
          .updateSubscriptionAwarePreferences(preferences);
      state = AsyncValue.data(updatedUser);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

/// Provider for user profile state
final userProfileProvider =
    StateNotifierProvider<UserProfileNotifier, AsyncValue<User>>((ref) {
      return UserProfileNotifier(ref.read(userServiceProvider), ref);
    });

/// State notifier for saved readings
class SavedReadingsNotifier extends StateNotifier<AsyncValue<List<Reading>>> {
  SavedReadingsNotifier(this._userService) : super(const AsyncValue.loading()) {
    _loadSavedReadings();
  }

  final MockUserService _userService;

  /// Load saved readings
  Future<void> _loadSavedReadings() async {
    try {
      final readings = await _userService.getSavedReadings();
      state = AsyncValue.data(readings);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Save a reading
  Future<void> saveReading(Reading reading) async {
    try {
      await _userService.saveReading(reading);
      _loadSavedReadings(); // Reload to get updated list
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Delete a reading
  Future<void> deleteReading(String readingId) async {
    try {
      await _userService.deleteReading(readingId);
      _loadSavedReadings(); // Reload to get updated list
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Update reading reflection
  Future<void> updateReflection(String readingId, String reflection) async {
    try {
      await _userService.updateReadingReflection(readingId, reflection);
      _loadSavedReadings(); // Reload to get updated list
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Refresh saved readings
  Future<void> refresh() async {
    _loadSavedReadings();
  }
}

/// Provider for saved readings
final savedReadingsProvider =
    StateNotifierProvider<SavedReadingsNotifier, AsyncValue<List<Reading>>>((
      ref,
    ) {
      return SavedReadingsNotifier(ref.read(userServiceProvider));
    });

/// Provider for recent readings
final recentReadingsProvider = FutureProvider<List<Reading>>((ref) async {
  final userService = ref.read(userServiceProvider);
  return userService.getRecentReadings();
});

/// Provider for user statistics
final userStatisticsProvider = FutureProvider<Map<String, dynamic>>((
  ref,
) async {
  final userService = ref.read(userServiceProvider);
  return userService.getUserStatistics();
});

/// Provider for user preferences
final userPreferencesProvider = FutureProvider<Map<String, dynamic>>((
  ref,
) async {
  final userService = ref.read(userServiceProvider);
  return userService.getUserPreferences();
});

/// Provider for onboarding status
final onboardingStatusProvider = FutureProvider<bool>((ref) async {
  final userService = ref.read(userServiceProvider);
  return userService.hasCompletedOnboarding();
});

/// Provider for daily journal prompt
final dailyJournalPromptProvider = FutureProvider<String>((ref) async {
  final userService = ref.read(userServiceProvider);
  return userService.getDailyJournalPrompt();
});

/// Provider for user invite code
final userInviteCodeProvider = FutureProvider<String>((ref) async {
  final userService = ref.read(userServiceProvider);
  return userService.generateInviteCode();
});

/// State notifier for friends management
class FriendsNotifier extends StateNotifier<AsyncValue<List<Friendship>>> {
  FriendsNotifier(this._userService) : super(const AsyncValue.loading()) {
    _loadFriends();
  }

  final MockUserService _userService;

  /// Load friends list
  Future<void> _loadFriends() async {
    try {
      final friends = await _userService.getFriends();
      state = AsyncValue.data(friends);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Send friend invitation
  Future<void> sendInvitation(String inviteCode) async {
    try {
      await _userService.sendFriendInvitation(inviteCode);
      _loadFriends(); // Reload to get updated list
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Refresh friends list
  Future<void> refresh() async {
    _loadFriends();
  }
}

/// Provider for friends management
final friendsProvider =
    StateNotifierProvider<FriendsNotifier, AsyncValue<List<Friendship>>>((ref) {
      return FriendsNotifier(ref.read(userServiceProvider));
    });

/// State notifier for shared readings
class SharedReadingsNotifier
    extends StateNotifier<AsyncValue<List<SharedReading>>> {
  SharedReadingsNotifier(this._userService)
    : super(const AsyncValue.loading()) {
    _loadSharedReadings();
  }

  final MockUserService _userService;

  /// Load shared readings
  Future<void> _loadSharedReadings() async {
    try {
      final sharedReadings = await _userService.getSharedReadings();
      state = AsyncValue.data(sharedReadings);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Share a reading with a friend
  Future<void> shareReading(String readingId, String friendId) async {
    try {
      await _userService.shareReading(readingId, friendId);
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
      return SharedReadingsNotifier(ref.read(userServiceProvider));
    });

/// State notifier for app preferences
class AppPreferencesNotifier extends StateNotifier<Map<String, dynamic>> {
  AppPreferencesNotifier(this._userService) : super({}) {
    _loadPreferences();
  }

  final MockUserService _userService;

  /// Load user preferences
  Future<void> _loadPreferences() async {
    try {
      final preferences = await _userService.getUserPreferences();
      state = preferences;
    } catch (error) {
      // Handle error silently, keep empty state
    }
  }

  /// Update a specific preference
  Future<void> updatePreference(String key, dynamic value) async {
    final updatedPreferences = {...state, key: value};
    state = updatedPreferences;

    try {
      await _userService.updateUserPreferences(updatedPreferences);
    } catch (error) {
      // Revert state on error
      _loadPreferences();
    }
  }

  /// Update multiple preferences
  Future<void> updatePreferences(Map<String, dynamic> preferences) async {
    final updatedPreferences = {...state, ...preferences};
    state = updatedPreferences;

    try {
      await _userService.updateUserPreferences(updatedPreferences);
    } catch (error) {
      // Revert state on error
      _loadPreferences();
    }
  }

  /// Get a specific preference value
  T? getPreference<T>(String key) {
    return state[key] as T?;
  }

  /// Check if a boolean preference is enabled
  bool isEnabled(String key) {
    return state[key] == true;
  }
}

/// Provider for app preferences
final appPreferencesProvider =
    StateNotifierProvider<AppPreferencesNotifier, Map<String, dynamic>>((ref) {
      return AppPreferencesNotifier(ref.read(userServiceProvider));
    });

/// Provider for user's subscription status (derived from user)
final userSubscriptionStatusProvider = Provider<SubscriptionStatus?>((ref) {
  final userAsync = ref.watch(userProfileProvider);
  return userAsync.when(
    data: (user) => user.subscriptionStatus,
    loading: () => null,
    error: (error, stackTrace) => null,
  );
});

/// Provider for user's subscription tier (derived from user)
final userSubscriptionTierProvider = Provider<SubscriptionTier>((ref) {
  final userAsync = ref.watch(userProfileProvider);
  return userAsync.when(
    data: (user) => user.subscriptionTier,
    loading: () => SubscriptionTier.seeker,
    error: (error, stackTrace) => SubscriptionTier.seeker,
  );
});

/// Provider for checking if user has active subscription (derived from user)
final userHasActiveSubscriptionProvider = Provider<bool>((ref) {
  final userAsync = ref.watch(userProfileProvider);
  return userAsync.when(
    data: (user) => user.hasActiveSubscription,
    loading: () => false,
    error: (error, stackTrace) => false,
  );
});

/// Provider for checking if user is on free tier (derived from user)
final userIsFreeProvider = Provider<bool>((ref) {
  final userAsync = ref.watch(userProfileProvider);
  return userAsync.when(
    data: (user) => user.isFreeUser,
    loading: () => true,
    error: (error, stackTrace) => true,
  );
});

/// Provider for checking if user is on paid tier (derived from user)
final userIsPaidProvider = Provider<bool>((ref) {
  final userAsync = ref.watch(userProfileProvider);
  return userAsync.when(
    data: (user) => user.isPaidUser,
    loading: () => false,
    error: (error, stackTrace) => false,
  );
});

/// Provider for user's usage counts (derived from user)
final userUsageCountsProvider = Provider<Map<String, int>>((ref) {
  final userAsync = ref.watch(userProfileProvider);
  return userAsync.when(
    data: (user) => user.subscriptionStatus.usageCounts,
    loading: () => {},
    error: (error, stackTrace) => {},
  );
});

/// Provider for specific feature usage count (derived from user)
final userFeatureUsageProvider = Provider.family<int, String>((ref, feature) {
  final userAsync = ref.watch(userProfileProvider);
  return userAsync.when(
    data: (user) => user.getUsageCount(feature),
    loading: () => 0,
    error: (error, stackTrace) => 0,
  );
});

/// Provider for subscription-aware user preferences
final subscriptionAwarePreferencesProvider = Provider<Map<String, dynamic>>((
  ref,
) {
  final userAsync = ref.watch(userProfileProvider);
  return userAsync.when(
    data: (user) => user.getSubscriptionAwarePreferences(),
    loading: () => {},
    error: (error, stackTrace) => {},
  );
});
