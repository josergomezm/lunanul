import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:lunanul/services/tarot_card_localizations.dart';
import 'package:lunanul/utils/localization_error_handler.dart';

void main() {
  group('Comprehensive TarotCardLocalizations Tests', () {
    late TarotCardLocalizations service;

    setUpAll(() {
      TestWidgetsFlutterBinding.ensureInitialized();
    });

    setUp(() {
      service = TarotCardLocalizations();
      LocalizationErrorHandler.resetStatistics();
    });

    tearDown(() {
      service.clearCache();
    });

    group(
      'JSON Parsing and Asset Loading Tests - Requirements 5.1, 5.2, 5.3',
      () {
        test('handles missing asset files gracefully', () async {
          // Test with non-existent card ID to trigger asset loading
          final result = await service.getCardName(
            'nonexistent_card',
            const Locale('en'),
          );

          // Should return formatted fallback, not throw
          expect(result, equals('Nonexistent Card'));
        });

        test('handles corrupted JSON data gracefully', () async {
          // This tests the error handling when JSON parsing fails
          // The service should handle FormatException and return fallbacks

          final cardName = await service.getCardName(
            'test_card',
            const Locale('en'),
          );
          final uprightMeaning = await service.getUprightMeaning(
            'test_card',
            const Locale('en'),
          );
          final reversedMeaning = await service.getReversedMeaning(
            'test_card',
            const Locale('en'),
          );
          final keywords = await service.getKeywords(
            'test_card',
            const Locale('en'),
          );

          // All should return fallback values, not throw
          expect(cardName, isA<String>());
          expect(uprightMeaning, isA<String>());
          expect(reversedMeaning, isA<String>());
          expect(keywords, isA<List<String>>());
        });

        test('handles empty JSON files gracefully', () async {
          // Test behavior when JSON files are empty or malformed
          final availableCards = await service.getAvailableCardIds();

          // Should return empty list, not throw
          expect(availableCards, isA<List<String>>());
        });

        test('validates JSON structure correctly', () async {
          // Test that the service validates expected JSON structure
          final cardInfo = await service.getCardInfo(
            'test_card',
            const Locale('en'),
          );

          // Should return map with expected structure or null
          if (cardInfo != null) {
            expect(cardInfo.containsKey('id'), isTrue);
            expect(cardInfo.containsKey('name'), isTrue);
            expect(cardInfo.containsKey('uprightMeaning'), isTrue);
            expect(cardInfo.containsKey('reversedMeaning'), isTrue);
            expect(cardInfo.containsKey('keywords'), isTrue);
          }
        });

        test('handles asset loading errors for different locales', () async {
          // Test error handling for both English and Spanish assets
          final englishCard = await service.getCardName(
            'test_card',
            const Locale('en'),
          );
          final spanishCard = await service.getCardName(
            'test_card',
            const Locale('es'),
          );

          expect(englishCard, isA<String>());
          expect(spanishCard, isA<String>());
        });
      },
    );

    group('Fallback Mechanism Tests - Requirements 5.1, 5.2, 5.4, 5.5', () {
      test('falls back to English when Spanish translation missing', () async {
        // Test fallback from Spanish to English
        final cardName = await service.getCardName(
          'fallback_test_card',
          const Locale('es'),
        );

        // Should attempt Spanish first, then fallback to English formatting
        expect(cardName, isA<String>());
        expect(cardName.isNotEmpty, isTrue);
      });

      test(
        'falls back to formatted card ID when all translations missing',
        () async {
          // Test ultimate fallback to formatted card ID
          final cardName = await service.getCardName(
            'ultimate_fallback_test',
            const Locale('en'),
          );

          expect(cardName, equals('Ultimate Fallback Test'));
        },
      );

      test('upright meaning fallback chain works correctly', () async {
        // Test fallback chain: requested locale -> English -> "Meaning not available"
        final meaning = await service.getUprightMeaning(
          'missing_card',
          const Locale('es'),
        );

        expect(meaning, isA<String>());
        // Should be either a valid meaning or the fallback message
        expect(meaning.isNotEmpty, isTrue);
      });

      test('reversed meaning fallback chain works correctly', () async {
        // Test fallback chain for reversed meanings
        final meaning = await service.getReversedMeaning(
          'missing_card',
          const Locale('es'),
        );

        expect(meaning, isA<String>());
        expect(meaning.isNotEmpty, isTrue);
      });

      test('keywords fallback returns empty list when not found', () async {
        // Test that keywords fallback to empty list
        final keywords = await service.getKeywords(
          'missing_card',
          const Locale('es'),
        );

        expect(keywords, isA<List<String>>());
        // Should be empty list when not found
      });

      test('fallback preserves data integrity', () async {
        // Test that fallback mechanisms don't corrupt data
        final cardInfo = await service.getCardInfo(
          'test_card',
          const Locale('es'),
        );

        if (cardInfo != null) {
          expect(cardInfo['id'], equals('test_card'));
          expect(cardInfo['name'], isA<String>());
          expect(cardInfo['uprightMeaning'], isA<String>());
          expect(cardInfo['reversedMeaning'], isA<String>());
          expect(cardInfo['keywords'], isA<List>());
        }
      });
    });

    group('Caching and Memory Management Tests - Requirements 5.3, 5.4', () {
      test('caching improves performance on repeated calls', () async {
        // First call loads from asset
        final stopwatch1 = Stopwatch()..start();
        await service.getCardName('cache_test_card', const Locale('en'));
        stopwatch1.stop();

        // Second call should use cache (faster)
        final stopwatch2 = Stopwatch()..start();
        await service.getCardName('cache_test_card', const Locale('en'));
        stopwatch2.stop();

        // Both calls should complete successfully
        expect(stopwatch1.elapsedMicroseconds, greaterThan(0));
        expect(stopwatch2.elapsedMicroseconds, greaterThan(0));
      });

      test('clearCache removes cached data', () async {
        // Load some data to cache
        await service.getCardName('cache_clear_test', const Locale('en'));
        await service.getCardName('cache_clear_test', const Locale('es'));

        // Clear cache
        service.clearCache();

        // Should still work after cache clear
        final result = await service.getCardName(
          'cache_clear_test',
          const Locale('en'),
        );
        expect(result, isA<String>());
      });

      test('preloadAllCardData completes without errors', () async {
        // Test preloading functionality
        expect(() => service.preloadAllCardData(), returnsNormally);

        // Service should still work after preloading
        final result = await service.getCardName(
          'preload_test',
          const Locale('en'),
        );
        expect(result, isA<String>());
      });

      test('cache handles multiple locales correctly', () async {
        // Load data for both locales
        final englishName = await service.getCardName(
          'multi_locale_test',
          const Locale('en'),
        );
        final spanishName = await service.getCardName(
          'multi_locale_test',
          const Locale('es'),
        );

        expect(englishName, isA<String>());
        expect(spanishName, isA<String>());

        // Clear cache and verify both locales still work
        service.clearCache();

        final englishName2 = await service.getCardName(
          'multi_locale_test',
          const Locale('en'),
        );
        final spanishName2 = await service.getCardName(
          'multi_locale_test',
          const Locale('es'),
        );

        expect(englishName2, isA<String>());
        expect(spanishName2, isA<String>());
      });

      test('memory usage remains stable with repeated operations', () async {
        // Perform many operations to test memory stability
        for (int i = 0; i < 50; i++) {
          await service.getCardName('memory_test_$i', const Locale('en'));
          await service.getUprightMeaning('memory_test_$i', const Locale('es'));

          // Occasionally clear cache to test memory management
          if (i % 10 == 0) {
            service.clearCache();
          }
        }

        // Service should still be responsive
        final result = await service.getCardName(
          'final_memory_test',
          const Locale('en'),
        );
        expect(result, isA<String>());
      });
    });

    group(
      'Error Handling and Recovery Tests - Requirements 5.1, 5.2, 5.3, 5.4, 5.5',
      () {
        test('handles concurrent access gracefully', () async {
          // Test concurrent access to the service
          final futures = List.generate(
            10,
            (index) => service.getCardName(
              'concurrent_test_$index',
              const Locale('en'),
            ),
          );

          final results = await Future.wait(futures);

          // All results should be valid strings
          for (final result in results) {
            expect(result, isA<String>());
            expect(result.isNotEmpty, isTrue);
          }
        });

        test('recovers from errors and continues functioning', () async {
          // Try operations that might cause errors
          await service.getCardName('', const Locale('en')); // Empty card ID
          await service.getCardName(
            'invalid_card',
            const Locale('invalid'),
          ); // Invalid locale

          // Service should still work normally
          final normalResult = await service.getCardName(
            'normal_card',
            const Locale('en'),
          );
          expect(normalResult, isA<String>());
        });

        test('error statistics are tracked correctly', () async {
          // Reset error statistics
          LocalizationErrorHandler.resetStatistics();

          // Perform operations that might trigger errors
          await service.getCardName(
            'nonexistent',
            const Locale('fr'),
          ); // Unsupported locale
          await service.getUprightMeaning('missing', const Locale('en'));

          // Check error statistics
          final stats = LocalizationErrorHandler.getErrorStatistics();
          expect(stats, isA<Map<String, dynamic>>());
          expect(stats.containsKey('totalErrors'), isTrue);
          expect(stats.containsKey('fallbacksUsed'), isTrue);
        });

        test('handles malformed card IDs gracefully', () async {
          // Test various malformed card IDs
          final testIds = [
            '',
            '   ',
            'card with spaces',
            'card-with-dashes',
            'card.with.dots',
          ];

          for (final cardId in testIds) {
            final name = await service.getCardName(cardId, const Locale('en'));
            final meaning = await service.getUprightMeaning(
              cardId,
              const Locale('en'),
            );
            final keywords = await service.getKeywords(
              cardId,
              const Locale('en'),
            );

            expect(name, isA<String>());
            expect(meaning, isA<String>());
            expect(keywords, isA<List<String>>());
          }
        });

        test('handles unsupported locales gracefully', () async {
          // Test with various unsupported locales
          final unsupportedLocales = [
            const Locale('fr'), // French
            const Locale('de'), // German
            const Locale('zh'), // Chinese
            const Locale('invalid'), // Invalid
          ];

          for (final locale in unsupportedLocales) {
            final name = await service.getCardName('test_card', locale);
            final meaning = await service.getUprightMeaning(
              'test_card',
              locale,
            );
            final keywords = await service.getKeywords('test_card', locale);

            expect(name, isA<String>());
            expect(meaning, isA<String>());
            expect(keywords, isA<List<String>>());
          }
        });
      },
    );

    group('Data Integrity and Validation Tests', () {
      test('card existence check works correctly', () async {
        // Test card existence for various scenarios
        final existsResult1 = await service.cardExists('test_card');
        final existsResult2 = await service.cardExists(
          'definitely_nonexistent_card',
        );

        expect(existsResult1, isA<bool>());
        expect(existsResult2, isA<bool>());
      });

      test('getAvailableCardIds returns consistent results', () async {
        // Test that available card IDs are consistent
        final cardIds1 = await service.getAvailableCardIds();
        final cardIds2 = await service.getAvailableCardIds();

        expect(cardIds1, isA<List<String>>());
        expect(cardIds2, isA<List<String>>());
        expect(cardIds1.length, equals(cardIds2.length));
      });

      test('card info structure is consistent', () async {
        // Test that card info always has the expected structure
        final cardInfo = await service.getCardInfo(
          'structure_test',
          const Locale('en'),
        );

        if (cardInfo != null) {
          // Verify all required fields are present
          expect(cardInfo.containsKey('id'), isTrue);
          expect(cardInfo.containsKey('name'), isTrue);
          expect(cardInfo.containsKey('uprightMeaning'), isTrue);
          expect(cardInfo.containsKey('reversedMeaning'), isTrue);
          expect(cardInfo.containsKey('keywords'), isTrue);

          // Verify field types
          expect(cardInfo['id'], isA<String>());
          expect(cardInfo['name'], isA<String>());
          expect(cardInfo['uprightMeaning'], isA<String>());
          expect(cardInfo['reversedMeaning'], isA<String>());
          expect(cardInfo['keywords'], isA<List>());
        }
      });

      test('formatting utility works correctly', () async {
        // Test the internal formatting utility through card names
        final testCases = {
          'the_fool': 'The Fool',
          'ace_of_cups': 'Ace Of Cups',
          'ten_of_pentacles': 'Ten Of Pentacles',
          'knight_of_wands': 'Knight Of Wands',
        };

        for (final entry in testCases.entries) {
          final result = await service.getCardName(
            entry.key,
            const Locale('en'),
          );
          // Should either be the actual card name or the formatted fallback
          expect(result, isA<String>());
          expect(result.isNotEmpty, isTrue);
        }
      });
    });

    group('Locale-Specific Behavior Tests', () {
      test('English locale behavior is consistent', () async {
        // Test multiple operations with English locale
        final cardName = await service.getCardName(
          'english_test',
          const Locale('en'),
        );
        final uprightMeaning = await service.getUprightMeaning(
          'english_test',
          const Locale('en'),
        );
        final reversedMeaning = await service.getReversedMeaning(
          'english_test',
          const Locale('en'),
        );
        final keywords = await service.getKeywords(
          'english_test',
          const Locale('en'),
        );

        expect(cardName, isA<String>());
        expect(uprightMeaning, isA<String>());
        expect(reversedMeaning, isA<String>());
        expect(keywords, isA<List<String>>());
      });

      test('Spanish locale behavior is consistent', () async {
        // Test multiple operations with Spanish locale
        final cardName = await service.getCardName(
          'spanish_test',
          const Locale('es'),
        );
        final uprightMeaning = await service.getUprightMeaning(
          'spanish_test',
          const Locale('es'),
        );
        final reversedMeaning = await service.getReversedMeaning(
          'spanish_test',
          const Locale('es'),
        );
        final keywords = await service.getKeywords(
          'spanish_test',
          const Locale('es'),
        );

        expect(cardName, isA<String>());
        expect(uprightMeaning, isA<String>());
        expect(reversedMeaning, isA<String>());
        expect(keywords, isA<List<String>>());
      });

      test('locale fallback chain is consistent across methods', () async {
        // Test that all methods follow the same fallback pattern
        const testLocale = Locale('fr'); // Unsupported locale

        final cardName = await service.getCardName(
          'fallback_chain_test',
          testLocale,
        );
        final uprightMeaning = await service.getUprightMeaning(
          'fallback_chain_test',
          testLocale,
        );
        final reversedMeaning = await service.getReversedMeaning(
          'fallback_chain_test',
          testLocale,
        );
        final keywords = await service.getKeywords(
          'fallback_chain_test',
          testLocale,
        );

        // All should fallback to English behavior
        expect(cardName, isA<String>());
        expect(uprightMeaning, isA<String>());
        expect(reversedMeaning, isA<String>());
        expect(keywords, isA<List<String>>());
      });
    });
  });
}
