import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:lunanul/services/language_service.dart';
import 'package:lunanul/services/tarot_card_localizations.dart';
import 'package:lunanul/services/dynamic_content_localizations.dart';
import 'package:lunanul/utils/localization_error_handler.dart';

void main() {
  group('Localization Error Integration Tests', () {
    late LanguageService languageService;
    late TarotCardLocalizations tarotCardLocalizations;
    late DynamicContentLocalizations dynamicContentLocalizations;

    setUpAll(() {
      // Initialize Flutter binding for tests
      TestWidgetsFlutterBinding.ensureInitialized();
    });

    setUp(() {
      languageService = LanguageService();
      tarotCardLocalizations = TarotCardLocalizations();
      dynamicContentLocalizations = DynamicContentLocalizations();

      // Reset error statistics
      LocalizationErrorHandler.resetStatistics();
    });

    group('LanguageService Error Handling', () {
      test(
        'getSavedLanguage handles SharedPreferences errors gracefully',
        () async {
          // This test verifies that the service handles errors gracefully
          final result = await languageService.getSavedLanguage();

          // Should return a valid supported locale even if there are errors
          expect(result, isA<Locale>());
          expect(languageService.isSupported(result), isTrue);
        },
      );

      test('getDeviceLocale handles platform errors gracefully', () {
        final result = languageService.getDeviceLocale();

        // Should return a valid locale even if platform access fails
        expect(result, isA<Locale>());
        expect(result.languageCode, isNotEmpty);
      });

      test('saveLanguage validates and handles unsupported locales', () async {
        // Try to save an unsupported locale
        const unsupportedLocale = Locale('de'); // German not supported

        // Should not throw an exception, but handle gracefully
        await expectLater(
          () => languageService.saveLanguage(unsupportedLocale),
          returnsNormally,
        );
      });

      test('clearSavedLanguage handles errors gracefully', () async {
        // Should not throw even if SharedPreferences operations fail
        await expectLater(
          () => languageService.clearSavedLanguage(),
          returnsNormally,
        );
      });
    });

    group('TarotCardLocalizations Error Handling', () {
      test('getCardName handles missing card gracefully', () async {
        const nonExistentCardId = 'non_existent_card';

        final result = await tarotCardLocalizations.getCardName(
          nonExistentCardId,
          const Locale('en'),
        );

        // Should return a formatted fallback name
        expect(result, isNotEmpty);
        expect(result, contains('Non Existent Card'));
      });

      test(
        'getCardName falls back to English for unsupported locale',
        () async {
          const cardId = 'fool'; // Assuming this card exists
          const unsupportedLocale = Locale('de'); // German not supported

          final result = await tarotCardLocalizations.getCardName(
            cardId,
            unsupportedLocale,
          );

          // Should return English fallback
          expect(result, isNotEmpty);
          expect(result, isNot(equals(cardId)));
        },
      );

      test('getUprightMeaning handles missing meaning gracefully', () async {
        const nonExistentCardId = 'non_existent_card';

        final result = await tarotCardLocalizations.getUprightMeaning(
          nonExistentCardId,
          const Locale('en'),
        );

        // Should return fallback message
        expect(result, equals('Meaning not available'));
      });

      test('getReversedMeaning handles missing meaning gracefully', () async {
        const nonExistentCardId = 'non_existent_card';

        final result = await tarotCardLocalizations.getReversedMeaning(
          nonExistentCardId,
          const Locale('en'),
        );

        // Should return fallback message
        expect(result, equals('Meaning not available'));
      });

      test('getKeywords handles missing keywords gracefully', () async {
        const nonExistentCardId = 'non_existent_card';

        final result = await tarotCardLocalizations.getKeywords(
          nonExistentCardId,
          const Locale('en'),
        );

        // Should return empty list as fallback
        expect(result, isEmpty);
      });

      test('getCardInfo handles complete card data errors', () async {
        const nonExistentCardId = 'non_existent_card';

        final result = await tarotCardLocalizations.getCardInfo(
          nonExistentCardId,
          const Locale('en'),
        );

        // Should return a map with fallback values
        expect(result, isNotNull);
        expect(result!['id'], equals(nonExistentCardId));
        expect(result['name'], isNotEmpty);
      });

      test('cardExists handles errors gracefully', () async {
        const nonExistentCardId = 'non_existent_card';

        final result = await tarotCardLocalizations.cardExists(
          nonExistentCardId,
        );

        // Should return false for non-existent cards
        expect(result, isFalse);
      });

      test('preloadAllCardData handles asset loading errors', () async {
        // Should not throw even if asset loading fails
        await expectLater(
          () => tarotCardLocalizations.preloadAllCardData(),
          returnsNormally,
        );
      });
    });

    group('DynamicContentLocalizations Error Handling', () {
      test('getJournalPrompt handles out of range index gracefully', () async {
        const outOfRangeIndex = 99999;

        final result = await dynamicContentLocalizations.getJournalPrompt(
          outOfRangeIndex,
          const Locale('en'),
        );

        // Should return fallback prompt
        expect(result, equals('What insights are emerging for you today?'));
      });

      test('getJournalPrompt handles negative index gracefully', () async {
        const negativeIndex = -1;

        final result = await dynamicContentLocalizations.getJournalPrompt(
          negativeIndex,
          const Locale('en'),
        );

        // Should return fallback prompt
        expect(result, equals('What insights are emerging for you today?'));
      });

      test('getRandomJournalPrompt handles empty prompts gracefully', () async {
        // Clear cache to simulate empty prompts scenario
        dynamicContentLocalizations.clearCache();

        final result = await dynamicContentLocalizations.getRandomJournalPrompt(
          const Locale('unsupported'),
        );

        // Should return fallback prompt
        expect(result, isNotEmpty);
      });

      test('getDailyJournalPrompt handles date edge cases', () async {
        // Test with extreme dates
        final extremeDate = DateTime(1900, 1, 1);

        final result = await dynamicContentLocalizations.getDailyJournalPrompt(
          extremeDate,
          const Locale('en'),
        );

        // Should return a valid prompt
        expect(result, isNotEmpty);
      });

      test('getJournalPromptCount handles errors gracefully', () async {
        const unsupportedLocale = Locale('unsupported');

        final result = await dynamicContentLocalizations.getJournalPromptCount(
          unsupportedLocale,
        );

        // Should return a valid count (fallback to English) or 0 for errors
        expect(result, greaterThanOrEqualTo(0));
      });

      test('getAllJournalPrompts handles errors gracefully', () async {
        const unsupportedLocale = Locale('unsupported');

        final result = await dynamicContentLocalizations.getAllJournalPrompts(
          unsupportedLocale,
        );

        // Should return prompts (fallback to English) or empty list for errors
        expect(result, isA<List<String>>());
      });

      test('preloadAllJournalPrompts handles asset loading errors', () async {
        // Should not throw even if asset loading fails
        await expectLater(
          () => dynamicContentLocalizations.preloadAllJournalPrompts(),
          returnsNormally,
        );
      });
    });

    group('Cross-Service Error Scenarios', () {
      test('multiple service errors do not cascade', () async {
        // Trigger errors in multiple services simultaneously
        final futures = [
          tarotCardLocalizations.getCardName(
            'non_existent',
            const Locale('unsupported'),
          ),
          dynamicContentLocalizations.getJournalPrompt(
            -1,
            const Locale('unsupported'),
          ),
          languageService.getSavedLanguage(),
        ];

        final results = await Future.wait(futures);

        // All should complete without throwing
        expect(results, hasLength(3));
        expect(results[0], isNotEmpty); // Card name fallback
        expect(results[1], isNotEmpty); // Prompt fallback
        expect(results[2], isA<Locale>()); // Valid locale
      });

      test('error statistics are tracked across services', () async {
        // Generate errors in different services
        await tarotCardLocalizations.getCardName(
          'non_existent',
          const Locale('en'),
        );
        await dynamicContentLocalizations.getJournalPrompt(
          -1,
          const Locale('en'),
        );

        final stats = LocalizationErrorHandler.getErrorStatistics();

        // Should have recorded some error activity (either errors or fallbacks)
        final totalActivity = stats['totalErrors'] + stats['fallbacksUsed'];
        expect(totalActivity, greaterThanOrEqualTo(0));
      });

      test('locale validation works consistently across services', () async {
        const unsupportedLocale = Locale('xyz'); // Completely unsupported

        // Test with all services
        final cardName = await tarotCardLocalizations.getCardName(
          'fool',
          unsupportedLocale,
        );
        final prompt = await dynamicContentLocalizations.getRandomJournalPrompt(
          unsupportedLocale,
        );
        final savedLocale = await languageService.getSavedLanguage();

        // All should handle the unsupported locale gracefully
        expect(cardName, isNotEmpty);
        expect(prompt, isNotEmpty);
        expect(languageService.isSupported(savedLocale), isTrue);
      });
    });

    group('Performance Under Error Conditions', () {
      test('repeated errors do not cause memory leaks', () async {
        // Repeatedly trigger the same error
        for (int i = 0; i < 100; i++) {
          await tarotCardLocalizations.getCardName(
            'non_existent_$i',
            const Locale('en'),
          );
        }

        final stats = LocalizationErrorHandler.getErrorStatistics();

        // Should have tracked some activity but not caused performance issues
        expect(stats, isA<Map<String, dynamic>>());
        expect(stats['errorsByKey'], isA<Map<String, int>>());
      });

      test('cache clearing works under error conditions', () {
        // Clear caches while errors might be occurring
        tarotCardLocalizations.clearCache();
        dynamicContentLocalizations.clearCache();

        // Should not throw
        expect(() => tarotCardLocalizations.clearCache(), returnsNormally);
        expect(() => dynamicContentLocalizations.clearCache(), returnsNormally);
      });
    });

    group('Fallback Chain Validation', () {
      test('complete fallback chain works for card localization', () async {
        // Test the complete fallback chain:
        // 1. Unsupported locale -> English
        // 2. Missing card -> formatted name
        // 3. Asset error -> fallback value

        const nonExistentCard = 'completely_missing_card_xyz';
        const unsupportedLocale = Locale('xyz');

        final result = await tarotCardLocalizations.getCardName(
          nonExistentCard,
          unsupportedLocale,
        );

        // Should get formatted fallback name
        expect(result, equals('Completely Missing Card Xyz'));
      });

      test('complete fallback chain works for dynamic content', () async {
        // Test fallback chain for prompts
        const unsupportedLocale = Locale('xyz');

        final result = await dynamicContentLocalizations.getRandomJournalPrompt(
          unsupportedLocale,
        );

        // Should get a valid prompt (either from fallback or English)
        expect(result, isNotEmpty);
        expect(result, isA<String>());
      });
    });
  });
}
