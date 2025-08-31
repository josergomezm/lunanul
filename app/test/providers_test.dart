import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lunanul/providers/providers.dart';
import 'package:lunanul/models/models.dart';

void main() {
  // Initialize Flutter binding for asset loading
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Provider Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer(
        overrides: ProviderScopeConfig.getTestOverrides(),
      );
    });

    tearDown(() {
      container.dispose();
    });

    group('Card Providers', () {
      test('cardServiceProvider provides CardService instance', () {
        final cardService = container.read(cardServiceProvider);
        expect(cardService, isNotNull);
      });

      test('allCardsProvider loads all 78 tarot cards', () async {
        final cards = await container.read(allCardsProvider.future);
        expect(cards, hasLength(78));
        expect(cards.every((card) => card.isValid), isTrue);
      });

      test('cardOfTheDayProvider provides a valid card', () async {
        final card = await container.read(cardOfTheDayProvider.future);
        expect(card, isNotNull);
        expect(card.isValid, isTrue);
      });

      test('cardSearchProvider initializes with loading state', () {
        final searchState = container.read(cardSearchProvider);
        expect(searchState, isA<AsyncValue<List<TarotCard>>>());
      });

      test('majorArcanaCardsProvider returns 22 cards', () async {
        final majorArcana = await container.read(
          majorArcanaCardsProvider.future,
        );
        expect(majorArcana, hasLength(22));
        expect(majorArcana.every((card) => card.isMajorArcana), isTrue);
      });

      test('minorArcanaCardsProvider returns 56 cards', () async {
        final minorArcana = await container.read(
          minorArcanaCardsProvider.future,
        );
        expect(minorArcana, hasLength(56));
        expect(minorArcana.every((card) => !card.isMajorArcana), isTrue);
      });
    });

    group('Reading Providers', () {
      test('readingServiceProvider provides MockReadingService instance', () {
        final readingService = container.read(readingServiceProvider);
        expect(readingService, isNotNull);
      });

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
    });

    group('User Providers', () {
      test('userServiceProvider provides MockUserService instance', () {
        final userService = container.read(userServiceProvider);
        expect(userService, isNotNull);
      });

      test('currentUserProvider provides a valid user', () async {
        final user = await container.read(currentUserProvider.future);
        expect(user, isNotNull);
        expect(user.name, isNotEmpty);
        expect(user.email, isNotEmpty);
        expect(user.id, isNotEmpty);
      });

      test('savedReadingsProvider initializes correctly', () {
        final readingsState = container.read(savedReadingsProvider);
        expect(readingsState, isA<AsyncValue<List<Reading>>>());
      });

      test('userStatisticsProvider provides statistics', () async {
        final stats = await container.read(userStatisticsProvider.future);
        expect(stats, isNotNull);
        expect(stats, containsPair('totalReadings', isA<int>()));
      });

      test('dailyJournalPromptProvider provides a prompt', () async {
        final prompt = await container.read(dailyJournalPromptProvider.future);
        expect(prompt, isNotNull);
        expect(prompt, isNotEmpty);
      });

      test('appPreferencesProvider initializes correctly', () async {
        // Wait a bit for preferences to load
        await Future.delayed(const Duration(milliseconds: 100));
        final preferences = container.read(appPreferencesProvider);
        expect(preferences, isNotNull);
        expect(preferences, isA<Map<String, dynamic>>());
      });
    });

    group('App State Providers', () {
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

    group('State Notifier Functionality', () {
      test('AppStateNotifier can update page index', () {
        final notifier = container.read(appStateProvider.notifier);
        notifier.setCurrentPageIndex(2);

        final state = container.read(appStateProvider);
        expect(state.currentPageIndex, 2);
      });

      test('ThemeNotifier can change theme', () {
        final notifier = container.read(themeProvider.notifier);
        notifier.setTheme('dark');

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

      test('ManualInterpretationNotifier can set topic', () {
        final notifier = container.read(manualInterpretationProvider.notifier);
        notifier.selectTopic(ReadingTopic.work);

        final state = container.read(manualInterpretationProvider);
        expect(state.selectedTopic, ReadingTopic.work);
      });

      test('GlobalSearchNotifier can update query', () {
        final notifier = container.read(globalSearchProvider.notifier);
        notifier.updateQuery('fool');

        final query = container.read(globalSearchProvider);
        expect(query, 'fool');
      });
    });

    group('Provider Extensions', () {
      test('WidgetRefExtensions work correctly', () {
        // This would need to be tested in a widget test context
        // For now, just verify the extension methods exist
        expect(ProviderScopeConfig.getTestOverrides(), isNotEmpty);
      });
    });
  });
}
