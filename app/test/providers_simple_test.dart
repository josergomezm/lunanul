import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lunanul/providers/providers.dart';
import 'package:lunanul/models/models.dart';

void main() {
  group('Provider Setup Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    group('Service Providers', () {
      test('cardServiceProvider provides CardService instance', () {
        final cardService = container.read(cardServiceProvider);
        expect(cardService, isNotNull);
      });

      test('readingServiceProvider provides MockReadingService instance', () {
        final readingService = container.read(readingServiceProvider);
        expect(readingService, isNotNull);
      });

      test('userServiceProvider provides MockUserService instance', () {
        final userService = container.read(userServiceProvider);
        expect(userService, isNotNull);
      });
    });

    group('State Notifier Providers', () {
      test('currentReadingProvider initializes with null reading', () {
        final currentReading = container.read(currentReadingProvider);
        expect(currentReading.value, isNull);
      });

      test('manualInterpretationProvider initializes with empty state', () {
        final manualState = container.read(manualInterpretationProvider);
        expect(manualState.selectedCards, isEmpty);
        expect(manualState.selectedTopic, isNull);
        expect(manualState.isLoading, isFalse);
      });

      test('readingFlowProvider initializes with empty state', () {
        final flowState = container.read(readingFlowProvider);
        expect(flowState.topic, isNull);
        expect(flowState.spreadType, isNull);
      });

      test('appStateProvider initializes with correct defaults', () {
        final appState = container.read(appStateProvider);
        expect(appState.currentPageIndex, 0);
        expect(appState.isLoading, isFalse);
        expect(appState.error, isNull);
      });

      test('themeProvider initializes with auto theme', () {
        final theme = container.read(themeProvider);
        expect(theme, 'auto');
      });

      test('notificationProvider initializes with empty state', () {
        final notifications = container.read(notificationProvider);
        expect(notifications.hasUnread, isFalse);
        expect(notifications.count, 0);
        expect(notifications.notifications, isEmpty);
      });

      test('connectivityProvider initializes as connected', () {
        final isConnected = container.read(connectivityProvider);
        expect(isConnected, isTrue);
      });

      test('globalSearchProvider initializes with empty query', () {
        final searchQuery = container.read(globalSearchProvider);
        expect(searchQuery, isEmpty);
      });
    });

    group('Computed Providers', () {
      test('spreadsByTopicProvider returns correct spreads for topic', () {
        final selfSpreads = container.read(
          spreadsByTopicProvider(ReadingTopic.self),
        );
        expect(selfSpreads, contains(SpreadType.singleCard));
        expect(selfSpreads, contains(SpreadType.threeCard));
        expect(selfSpreads, contains(SpreadType.celtic));

        final loveSpreads = container.read(
          spreadsByTopicProvider(ReadingTopic.love),
        );
        expect(loveSpreads, contains(SpreadType.relationship));
      });

      test('currentPageIndexProvider returns correct index', () {
        final pageIndex = container.read(currentPageIndexProvider);
        expect(pageIndex, 0);
      });

      test('appLoadingProvider returns correct loading state', () {
        final isLoading = container.read(appLoadingProvider);
        expect(isLoading, isFalse);
      });

      test('appErrorProvider returns null initially', () {
        final error = container.read(appErrorProvider);
        expect(error, isNull);
      });

      test('isOnlineProvider returns true initially', () {
        final isOnline = container.read(isOnlineProvider);
        expect(isOnline, isTrue);
      });

      test('isSearchActiveProvider returns false initially', () {
        final isSearchActive = container.read(isSearchActiveProvider);
        expect(isSearchActive, isFalse);
      });

      test('unreadNotificationCountProvider returns 0 initially', () {
        final count = container.read(unreadNotificationCountProvider);
        expect(count, 0);
      });
    });

    group('State Notifier Functionality', () {
      test('AppStateNotifier can update page index', () {
        final notifier = container.read(appStateProvider.notifier);
        notifier.setCurrentPageIndex(2);

        final state = container.read(appStateProvider);
        expect(state.currentPageIndex, 2);
      });

      test('AppStateNotifier can set loading state', () {
        final notifier = container.read(appStateProvider.notifier);
        notifier.setLoading(true);

        final state = container.read(appStateProvider);
        expect(state.isLoading, isTrue);
      });

      test('AppStateNotifier can set and clear error', () {
        final notifier = container.read(appStateProvider.notifier);
        notifier.setError('Test error');

        var state = container.read(appStateProvider);
        expect(state.error, 'Test error');

        notifier.clearError();
        state = container.read(appStateProvider);
        expect(state.error, isNull);
      });

      test('ThemeNotifier can change theme', () {
        final notifier = container.read(themeProvider.notifier);
        notifier.setTheme('dark');

        final theme = container.read(themeProvider);
        expect(theme, 'dark');
      });

      test('ThemeNotifier can toggle theme', () {
        final notifier = container.read(themeProvider.notifier);
        notifier.setTheme('light');
        notifier.toggleTheme();

        final theme = container.read(themeProvider);
        expect(theme, 'dark');
      });

      test('ReadingFlowNotifier can set topic and spread', () {
        final notifier = container.read(readingFlowProvider.notifier);
        notifier.setTopic(ReadingTopic.love);
        notifier.setSpreadType(SpreadType.relationship);

        final state = container.read(readingFlowProvider);
        expect(state.topic, ReadingTopic.love);
        expect(state.spreadType, SpreadType.relationship);
      });

      test('ReadingFlowNotifier can reset state', () {
        final notifier = container.read(readingFlowProvider.notifier);
        notifier.setTopic(ReadingTopic.love);
        notifier.setSpreadType(SpreadType.relationship);
        notifier.reset();

        final state = container.read(readingFlowProvider);
        expect(state.topic, isNull);
        expect(state.spreadType, isNull);
      });

      test('ManualInterpretationNotifier can set topic', () {
        final notifier = container.read(manualInterpretationProvider.notifier);
        notifier.selectTopic(ReadingTopic.work);

        final state = container.read(manualInterpretationProvider);
        expect(state.selectedTopic, ReadingTopic.work);
      });

      test('ManualInterpretationNotifier can clear state', () {
        final notifier = container.read(manualInterpretationProvider.notifier);
        notifier.selectTopic(ReadingTopic.work);
        notifier.clearSelection();

        final state = container.read(manualInterpretationProvider);
        expect(state.selectedTopic, isNull);
        expect(state.selectedCards, isEmpty);
      });

      test('GlobalSearchNotifier can update and clear query', () {
        final notifier = container.read(globalSearchProvider.notifier);
        notifier.updateQuery('fool');

        var query = container.read(globalSearchProvider);
        expect(query, 'fool');

        notifier.clearSearch();
        query = container.read(globalSearchProvider);
        expect(query, isEmpty);
      });

      test('ConnectivityNotifier can toggle connectivity', () {
        final notifier = container.read(connectivityProvider.notifier);
        notifier.toggleConnectivity();

        final isConnected = container.read(connectivityProvider);
        expect(isConnected, isFalse);
      });

      test('NotificationNotifier can add and manage notifications', () {
        final notifier = container.read(notificationProvider.notifier);
        final notification = AppNotification(
          id: 'test1',
          title: 'Test',
          message: 'Test message',
          createdAt: DateTime.now(),
          isRead: false,
        );

        notifier.addNotification(notification);

        var state = container.read(notificationProvider);
        expect(state.count, 1);
        expect(state.hasUnread, isTrue);

        notifier.markAsRead('test1');
        state = container.read(notificationProvider);
        expect(state.hasUnread, isFalse);

        notifier.removeNotification('test1');
        state = container.read(notificationProvider);
        expect(state.count, 0);
      });
    });

    group('Provider Configuration', () {
      test('ProviderScopeConfig.getTestOverrides returns overrides', () {
        final overrides = ProviderScopeConfig.getTestOverrides();
        expect(overrides, isNotEmpty);
        expect(overrides.length, 3); // cardService, readingService, userService
      });

      test('ProviderScopeConfig.getOverrides with custom services', () {
        final overrides = ProviderScopeConfig.getOverrides();
        expect(overrides, isEmpty); // No custom services provided
      });
    });
  });
}
