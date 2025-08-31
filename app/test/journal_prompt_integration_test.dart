import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lunanul/services/dynamic_content_localizations.dart';
import 'package:lunanul/providers/providers.dart';
import 'package:lunanul/models/enums.dart';
import 'package:lunanul/l10n/generated/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  group('Journal Prompt Integration Tests', () {
    testWidgets(
      'DynamicContentLocalizations service should work with providers',
      (WidgetTester tester) async {
        final container = ProviderContainer();

        // Test that the provider is properly configured
        final service = container.read(dynamicContentLocalizationsProvider);
        expect(service, isA<DynamicContentLocalizations>());

        // Test that we can get a journal prompt
        final prompt = await service.getDailyJournalPrompt(
          DateTime.now(),
          const Locale('en'),
        );
        expect(prompt, isNotEmpty);

        container.dispose();
      },
    );

    testWidgets(
      'Language provider should work with DynamicContentLocalizations',
      (WidgetTester tester) async {
        final container = ProviderContainer();

        // Test English
        container
            .read(languageProvider.notifier)
            .changeLanguage(const Locale('en'));
        final englishLocale = container.read(languageProvider);
        expect(englishLocale.languageCode, equals('en'));

        final service = container.read(dynamicContentLocalizationsProvider);
        final englishPrompt = await service.getDailyJournalPrompt(
          DateTime.now(),
          englishLocale,
        );
        expect(englishPrompt, isNotEmpty);

        // Test Spanish
        container
            .read(languageProvider.notifier)
            .changeLanguage(const Locale('es'));
        final spanishLocale = container.read(languageProvider);
        expect(spanishLocale.languageCode, equals('es'));

        final spanishPrompt = await service.getDailyJournalPrompt(
          DateTime.now(),
          spanishLocale,
        );
        expect(spanishPrompt, isNotEmpty);
        expect(spanishPrompt, isNot(equals(englishPrompt)));

        container.dispose();
      },
    );

    testWidgets('Journal prompt widget should display localized content', (
      WidgetTester tester,
    ) async {
      // Create a simple widget that uses the journal prompt functionality
      Widget createTestWidget(Locale locale) {
        return ProviderScope(
          child: MaterialApp(
            locale: locale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('en'), Locale('es')],
            home: Scaffold(
              body: Consumer(
                builder: (context, ref, child) {
                  final currentLocale = ref.watch(languageProvider);
                  final dynamicLocalizations = ref.read(
                    dynamicContentLocalizationsProvider,
                  );

                  return FutureBuilder<String>(
                    future: dynamicLocalizations.getDailyJournalPrompt(
                      DateTime.now(),
                      currentLocale,
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Column(
                          children: [
                            Text('Daily Reflection', key: const Key('title')),
                            Text(snapshot.data!, key: const Key('prompt')),
                          ],
                        );
                      }
                      return const CircularProgressIndicator();
                    },
                  );
                },
              ),
            ),
          ),
        );
      }

      // Test English
      await tester.pumpWidget(createTestWidget(const Locale('en')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('title')), findsOneWidget);
      expect(find.byKey(const Key('prompt')), findsOneWidget);

      final englishPrompt = tester
          .widget<Text>(find.byKey(const Key('prompt')))
          .data;
      expect(englishPrompt, isNotNull);
      expect(englishPrompt!, isNotEmpty);

      // Test Spanish
      await tester.pumpWidget(createTestWidget(const Locale('es')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('title')), findsOneWidget);
      expect(find.byKey(const Key('prompt')), findsOneWidget);

      final spanishPrompt = tester
          .widget<Text>(find.byKey(const Key('prompt')))
          .data;
      expect(spanishPrompt, isNotNull);
      expect(spanishPrompt!, isNotEmpty);
      expect(spanishPrompt, isNot(equals(englishPrompt)));
    });

    testWidgets('Journal prompt should update when language changes', (
      WidgetTester tester,
    ) async {
      final container = ProviderContainer();

      Widget createTestWidget() {
        return UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('en'), Locale('es')],
            home: Scaffold(
              body: Consumer(
                builder: (context, ref, child) {
                  final currentLocale = ref.watch(languageProvider);
                  final dynamicLocalizations = ref.read(
                    dynamicContentLocalizationsProvider,
                  );

                  return FutureBuilder<String>(
                    future: dynamicLocalizations.getDailyJournalPrompt(
                      DateTime.now(),
                      currentLocale,
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Column(
                          children: [
                            Text(
                              'Locale: ${currentLocale.languageCode}',
                              key: const Key('locale'),
                            ),
                            Text(snapshot.data!, key: const Key('prompt')),
                            ElevatedButton(
                              onPressed: () {
                                final newLocale =
                                    currentLocale.languageCode == 'en'
                                    ? const Locale('es')
                                    : const Locale('en');
                                ref
                                    .read(languageProvider.notifier)
                                    .changeLanguage(newLocale);
                              },
                              child: const Text('Switch Language'),
                            ),
                          ],
                        );
                      }
                      return const CircularProgressIndicator();
                    },
                  );
                },
              ),
            ),
          ),
        );
      }

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Should start with English
      expect(find.text('Locale: en'), findsOneWidget);
      final initialPrompt = tester
          .widget<Text>(find.byKey(const Key('prompt')))
          .data;

      // Switch language
      await tester.tap(find.text('Switch Language'));
      await tester.pumpAndSettle();

      // Should now be Spanish
      expect(find.text('Locale: es'), findsOneWidget);
      final newPrompt = tester
          .widget<Text>(find.byKey(const Key('prompt')))
          .data;

      // Prompts should be different
      expect(newPrompt, isNot(equals(initialPrompt)));

      container.dispose();
    });

    test(
      'DynamicContentLocalizations should handle all required methods',
      () async {
        final service = DynamicContentLocalizations();

        // Test all the methods that should be available
        expect(
          () =>
              service.getDailyJournalPrompt(DateTime.now(), const Locale('en')),
          returnsNormally,
        );
        expect(
          () => service.getRandomJournalPrompt(const Locale('en')),
          returnsNormally,
        );
        expect(
          () => service.getJournalPrompt(0, const Locale('en')),
          returnsNormally,
        );
        expect(
          () => service.getAllJournalPrompts(const Locale('en')),
          returnsNormally,
        );
        expect(
          () => service.getJournalPromptCount(const Locale('en')),
          returnsNormally,
        );
        expect(() => service.clearCache(), returnsNormally);
        expect(() => service.preloadAllJournalPrompts(), returnsNormally);

        // Test topic and spread methods
        expect(
          () => service.getTopicDescription(
            ReadingTopic.self,
            const Locale('en'),
          ),
          returnsNormally,
        );
        expect(
          () => service.getTopicDisplayName(
            ReadingTopic.love,
            const Locale('es'),
          ),
          returnsNormally,
        );
      },
    );
  });
}
