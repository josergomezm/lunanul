import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Global app state for navigation and UI
class AppState {
  const AppState({
    required this.currentPageIndex,
    required this.isLoading,
    this.error,
  });

  final int currentPageIndex;
  final bool isLoading;
  final String? error;

  AppState copyWith({
    int? currentPageIndex,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return AppState(
      currentPageIndex: currentPageIndex ?? this.currentPageIndex,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }

  factory AppState.initial() {
    return const AppState(currentPageIndex: 0, isLoading: false);
  }
}

/// State notifier for global app state
class AppStateNotifier extends StateNotifier<AppState> {
  AppStateNotifier() : super(AppState.initial());

  /// Set current page index for bottom navigation
  void setCurrentPageIndex(int index) {
    state = state.copyWith(currentPageIndex: index);
  }

  /// Set loading state
  void setLoading(bool isLoading) {
    state = state.copyWith(isLoading: isLoading);
  }

  /// Set error message
  void setError(String? error) {
    state = state.copyWith(error: error);
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

/// Provider for global app state
final appStateProvider = StateNotifierProvider<AppStateNotifier, AppState>((
  ref,
) {
  return AppStateNotifier();
});

/// Provider for current page index
final currentPageIndexProvider = Provider<int>((ref) {
  return ref.watch(appStateProvider).currentPageIndex;
});

/// Provider for app loading state
final appLoadingProvider = Provider<bool>((ref) {
  return ref.watch(appStateProvider).isLoading;
});

/// Provider for app error state
final appErrorProvider = Provider<String?>((ref) {
  return ref.watch(appStateProvider).error;
});

/// State notifier for theme management
class ThemeNotifier extends StateNotifier<String> {
  ThemeNotifier() : super('auto'); // Default to auto theme

  /// Set theme mode
  void setTheme(String theme) {
    if (['light', 'dark', 'auto'].contains(theme)) {
      state = theme;
    }
  }

  /// Toggle between light and dark
  void toggleTheme() {
    state = state == 'light' ? 'dark' : 'light';
  }
}

/// Provider for theme management
final themeProvider = StateNotifierProvider<ThemeNotifier, String>((ref) {
  return ThemeNotifier();
});

/// State notifier for notification management
class NotificationState {
  const NotificationState({
    required this.hasUnread,
    required this.count,
    required this.notifications,
  });

  final bool hasUnread;
  final int count;
  final List<AppNotification> notifications;

  NotificationState copyWith({
    bool? hasUnread,
    int? count,
    List<AppNotification>? notifications,
  }) {
    return NotificationState(
      hasUnread: hasUnread ?? this.hasUnread,
      count: count ?? this.count,
      notifications: notifications ?? this.notifications,
    );
  }

  factory NotificationState.initial() {
    return const NotificationState(
      hasUnread: false,
      count: 0,
      notifications: [],
    );
  }
}

/// Simple notification model
class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.createdAt,
    required this.isRead,
    this.type = 'info',
  });

  final String id;
  final String title;
  final String message;
  final DateTime createdAt;
  final bool isRead;
  final String type; // 'info', 'success', 'warning', 'error'

  AppNotification copyWith({
    String? id,
    String? title,
    String? message,
    DateTime? createdAt,
    bool? isRead,
    String? type,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      type: type ?? this.type,
    );
  }
}

/// State notifier for notifications
class NotificationNotifier extends StateNotifier<NotificationState> {
  NotificationNotifier() : super(NotificationState.initial());

  /// Add a new notification
  void addNotification(AppNotification notification) {
    final updatedNotifications = [notification, ...state.notifications];
    state = state.copyWith(
      notifications: updatedNotifications,
      count: updatedNotifications.length,
      hasUnread: updatedNotifications.any((n) => !n.isRead),
    );
  }

  /// Mark notification as read
  void markAsRead(String notificationId) {
    final updatedNotifications = state.notifications.map((notification) {
      if (notification.id == notificationId) {
        return notification.copyWith(isRead: true);
      }
      return notification;
    }).toList();

    state = state.copyWith(
      notifications: updatedNotifications,
      hasUnread: updatedNotifications.any((n) => !n.isRead),
    );
  }

  /// Mark all notifications as read
  void markAllAsRead() {
    final updatedNotifications = state.notifications.map((notification) {
      return notification.copyWith(isRead: true);
    }).toList();

    state = state.copyWith(
      notifications: updatedNotifications,
      hasUnread: false,
    );
  }

  /// Remove a notification
  void removeNotification(String notificationId) {
    final updatedNotifications = state.notifications
        .where((notification) => notification.id != notificationId)
        .toList();

    state = state.copyWith(
      notifications: updatedNotifications,
      count: updatedNotifications.length,
      hasUnread: updatedNotifications.any((n) => !n.isRead),
    );
  }

  /// Clear all notifications
  void clearAll() {
    state = NotificationState.initial();
  }
}

/// Provider for notifications
final notificationProvider =
    StateNotifierProvider<NotificationNotifier, NotificationState>((ref) {
      return NotificationNotifier();
    });

/// Provider for unread notification count
final unreadNotificationCountProvider = Provider<int>((ref) {
  final notifications = ref.watch(notificationProvider).notifications;
  return notifications.where((n) => !n.isRead).length;
});

/// State notifier for connectivity status
class ConnectivityNotifier extends StateNotifier<bool> {
  ConnectivityNotifier() : super(true); // Assume connected initially

  /// Set connectivity status
  void setConnected(bool isConnected) {
    state = isConnected;
  }

  /// Toggle connectivity (for testing)
  void toggleConnectivity() {
    state = !state;
  }
}

/// Provider for connectivity status
final connectivityProvider = StateNotifierProvider<ConnectivityNotifier, bool>((
  ref,
) {
  return ConnectivityNotifier();
});

/// Provider for checking if app is online
final isOnlineProvider = Provider<bool>((ref) {
  return ref.watch(connectivityProvider);
});

/// State notifier for search functionality across the app
class GlobalSearchNotifier extends StateNotifier<String> {
  GlobalSearchNotifier() : super('');

  /// Update search query
  void updateQuery(String query) {
    state = query;
  }

  /// Clear search
  void clearSearch() {
    state = '';
  }
}

/// Provider for global search state
final globalSearchProvider =
    StateNotifierProvider<GlobalSearchNotifier, String>((ref) {
      return GlobalSearchNotifier();
    });

/// Provider for checking if search is active
final isSearchActiveProvider = Provider<bool>((ref) {
  return ref.watch(globalSearchProvider).isNotEmpty;
});
