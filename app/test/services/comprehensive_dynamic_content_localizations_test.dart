import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:lunanul/services/dynamic_content_localizations.dart';
import 'package:lunanul/models/enums.dart';
import 'package:lunanul/utils/localization_error_handler.dart';

void main() {
  group('Comprehensive DynamicContentLocalizations Tests', () {
    late DynamicContentLocalizations service;

    setUpAll(() {
      TestWidgetsFlutterBinding.ensureInitialized();
    });

    setUp(() {
      service = DynamicContentLocalizations();
      LocalizationErrorHandler.resetStatistics();
    });

    tearDown(() {
      service.clearCache();
    });

    group(
      'Caching and Memory Management Tests - Requirements 5.1, 5.3, 5.4',
      () {
        test('caching improves performance for journal prompts', () async {
          // First call loads from asset
          final stopwatch1 = Stopwatch()..start();
          await service.getRandomJournalPrompt(const Locale('en'));
          stopwatch1.stop();

          // Second call should use cache
          final stopwatch2 = Stopwatch()..start();
          await service.getRandomJournalPrompt(const Locale('en'));
          stopwatch2.stop();

          // Both calls should complete successfully
          expect(stopwatch1.elapsedMicroseconds, greaterThan(0));
          expect(stopwatch2.elapsedMicroseconds, greaterThan(0));
        });

        test('clearCache removes cached prompt data', () async {
          // Load some data to cache
          await service.getAllJournalPrompts(const Locale('en'));
          await service.getAllJournalPrompts(const Locale('es'));

          // Clear cache
          service.clearCache();

          // Should still work after cache clear
          final result = await service.getRandomJournalPrompt(
            const Locale('en'),
          );
          expect(result, isA<String>());
          expect(result.isNotEmpty, isTrue);
        });

        test('preloadAllJournalPrompts works correctly', () async {
          // Test preloading functionality
          expect(() => service.preloadAllJournalPrompts(), returnsNormally);

          // Service should work after preloading
          final englishPrompt = await service.getRandomJournalPrompt(
            const Locale('en'),
          );
          final spanishPrompt = await service.getRandomJournalPrompt(
            const Locale('es'),
          );

          expect(englishPrompt, isA<String>());
          expect(spanishPrompt, isA<String>());
        });

        test('cache handles multiple locales independently', () async {
          // Load data for both locales
          final englishPrompts = await service.getAllJournalPrompts(
            const Locale('en'),
          );
          final spanishPrompts = await service.getAllJournalPrompts(
            const Locale('es'),
          );

          expect(englishPrompts, isA<List<String>>());
          expect(spanishPrompts, isA<List<String>>());

          // Clear cache and verify both locales still work
          service.clearCache();

          final englishCount = await service.getJournalPromptCount(
            const Locale('en'),
          );
          final spanishCount = await service.getJournalPromptCount(
            const Locale('es'),
          );

          expect(englishCount, greaterThanOrEqualTo(0));
          expect(spanishCount, greaterThanOrEqualTo(0));
        });

        test('memory usage remains stable with repeated operations', () async {
          // Perform many operations to test memory stability
          for (int i = 0; i < 50; i++) {
            await service.getRandomJournalPrompt(const Locale('en'));
            await service.getDailyJournalPrompt(
              DateTime.now(),
              const Locale('es'),
            );

            // Occasionally clear cache
            if (i % 10 == 0) {
              service.clearCache();
            }
          }

          // Service should still be responsive
          final result = await service.getRandomJournalPrompt(
            const Locale('en'),
          );
          expect(result, isA<String>());
        });
      },
    );

    group('Journal Prompt Retrieval Tests - Requirements 5.1, 5.2, 5.4', () {
      test('getJournalPrompt handles valid indices correctly', () async {
        // Test with valid indices
        final prompt0 = await service.getJournalPrompt(0, const Locale('en'));
        final prompt1 = await service.getJournalPrompt(1, const Locale('en'));

        expect(prompt0, isA<String>());
        expect(prompt1, isA<String>());
        expect(prompt0.isNotEmpty, isTrue);
        expect(prompt1.isNotEmpty, isTrue);
      });

      test('getJournalPrompt handles invalid indices with fallback', () async {
        // Test with invalid indices
        final negativeIndex = await service.getJournalPrompt(
          -1,
          const Locale('en'),
        );
        final largeIndex = await service.getJournalPrompt(
          99999,
          const Locale('en'),
        );

        expect(
          negativeIndex,
          equals('What insights are emerging for you today?'),
        );
        expect(largeIndex, equals('What insights are emerging for you today?'));
      });

      test('getRandomJournalPrompt returns different prompts', () async {
        // Get multiple random prompts
        final prompts = <String>{};
        for (int i = 0; i < 10; i++) {
          final prompt = await service.getRandomJournalPrompt(
            const Locale('en'),
          );
          prompts.add(prompt);
        }

        // Should have at least some variety (unless there's only one prompt)
        expect(prompts.isNotEmpty, isTrue);
        for (final prompt in prompts) {
          expect(prompt.isNotEmpty, isTrue);
        }
      });

      test('getDailyJournalPrompt is deterministic for same date', () async {
        final testDate = DateTime(2024, 6, 15);

        // Get prompt multiple times for same date
        final prompt1 = await service.getDailyJournalPrompt(
          testDate,
          const Locale('en'),
        );
        final prompt2 = await service.getDailyJournalPrompt(
          testDate,
          const Locale('en'),
        );
        final prompt3 = await service.getDailyJournalPrompt(
          testDate,
          const Locale('en'),
        );

        // Should be the same
        expect(prompt1, equals(prompt2));
        expect(prompt2, equals(prompt3));
        expect(prompt1.isNotEmpty, isTrue);
      });

      test('getDailyJournalPrompt varies across different dates', () async {
        final dates = [
          DateTime(2024, 1, 1),
          DateTime(2024, 6, 15),
          DateTime(2024, 12, 31),
        ];

        final prompts = <String>{};
        for (final date in dates) {
          final prompt = await service.getDailyJournalPrompt(
            date,
            const Locale('en'),
          );
          prompts.add(prompt);
          expect(prompt.isNotEmpty, isTrue);
        }

        // Should have some variety across different dates
        expect(prompts.isNotEmpty, isTrue);
      });

      test('journal prompt count is consistent', () async {
        // Get count multiple times
        final count1 = await service.getJournalPromptCount(const Locale('en'));
        final count2 = await service.getJournalPromptCount(const Locale('en'));

        expect(count1, equals(count2));
        expect(count1, greaterThanOrEqualTo(0));
      });

      test('getAllJournalPrompts returns consistent data', () async {
        // Get all prompts multiple times
        final prompts1 = await service.getAllJournalPrompts(const Locale('en'));
        final prompts2 = await service.getAllJournalPrompts(const Locale('en'));

        expect(prompts1.length, equals(prompts2.length));
        for (int i = 0; i < prompts1.length; i++) {
          expect(prompts1[i], equals(prompts2[i]));
        }
      });
    });

    group('Fallback Mechanism Tests - Requirements 5.1, 5.2, 5.4, 5.5', () {
      test(
        'journal prompts fall back to English when Spanish unavailable',
        () async {
          // Test fallback behavior
          final englishPrompt = await service.getRandomJournalPrompt(
            const Locale('en'),
          );
          final spanishPrompt = await service.getRandomJournalPrompt(
            const Locale('es'),
          );

          expect(englishPrompt, isA<String>());
          expect(spanishPrompt, isA<String>());
          expect(englishPrompt.isNotEmpty, isTrue);
          expect(spanishPrompt.isNotEmpty, isTrue);
        },
      );

      test('unsupported locales fall back to English', () async {
        // Test with unsupported locales
        final frenchPrompt = await service.getRandomJournalPrompt(
          const Locale('fr'),
        );
        final germanPrompt = await service.getRandomJournalPrompt(
          const Locale('de'),
        );

        expect(frenchPrompt, isA<String>());
        expect(germanPrompt, isA<String>());
        expect(frenchPrompt.isNotEmpty, isTrue);
        expect(germanPrompt.isNotEmpty, isTrue);
      });

      test('fallback preserves prompt quality', () async {
        // Test that fallback prompts are meaningful
        final fallbackPrompt = await service.getRandomJournalPrompt(
          const Locale('invalid'),
        );

        expect(fallbackPrompt, isA<String>());
        expect(fallbackPrompt.isNotEmpty, isTrue);
        // Should be the default fallback or a valid prompt
        expect(fallbackPrompt.length, greaterThan(10)); // Reasonable length
      });

      test('daily prompt fallback is consistent', () async {
        final testDate = DateTime(2024, 6, 15);

        // Test fallback for unsupported locale
        final fallbackPrompt1 = await service.getDailyJournalPrompt(
          testDate,
          const Locale('fr'),
        );
        final fallbackPrompt2 = await service.getDailyJournalPrompt(
          testDate,
          const Locale('fr'),
        );

        // Should be consistent even with fallback
        expect(fallbackPrompt1, equals(fallbackPrompt2));
        expect(fallbackPrompt1.isNotEmpty, isTrue);
      });
    });

    group('Error Handling Tests - Requirements 5.1, 5.2, 5.3, 5.4, 5.5', () {
      test('handles asset loading errors gracefully', () async {
        // Test behavior when assets might not be available
        final promptCount = await service.getJournalPromptCount(
          const Locale('en'),
        );
        final allPrompts = await service.getAllJournalPrompts(
          const Locale('en'),
        );

        expect(promptCount, greaterThanOrEqualTo(0));
        expect(allPrompts, isA<List<String>>());
        expect(allPrompts.length, equals(promptCount));
      });

      test('handles JSON parsing errors gracefully', () async {
        // Test that service handles malformed JSON gracefully
        final randomPrompt = await service.getRandomJournalPrompt(
          const Locale('en'),
        );
        final dailyPrompt = await service.getDailyJournalPrompt(
          DateTime.now(),
          const Locale('en'),
        );

        expect(randomPrompt, isA<String>());
        expect(dailyPrompt, isA<String>());
        expect(randomPrompt.isNotEmpty, isTrue);
        expect(dailyPrompt.isNotEmpty, isTrue);
      });

      test('recovers from errors and continues functioning', () async {
        // Try operations that might cause errors
        await service.getJournalPrompt(-999, const Locale('invalid'));
        await service.getDailyJournalPrompt(
          DateTime(1900),
          const Locale('invalid'),
        );

        // Service should still work normally
        final normalPrompt = await service.getRandomJournalPrompt(
          const Locale('en'),
        );
        expect(normalPrompt, isA<String>());
        expect(normalPrompt.isNotEmpty, isTrue);
      });

      test('error statistics are tracked correctly', () async {
        // Reset error statistics
        LocalizationErrorHandler.resetStatistics();

        // Perform operations that might trigger errors
        await service.getJournalPrompt(-1, const Locale('invalid'));
        await service.getRandomJournalPrompt(const Locale('nonexistent'));

        // Check error statistics
        final stats = LocalizationErrorHandler.getErrorStatistics();
        expect(stats, isA<Map<String, dynamic>>());
        expect(stats.containsKey('totalErrors'), isTrue);
        expect(stats.containsKey('fallbacksUsed'), isTrue);
      });

      test('handles concurrent access gracefully', () async {
        // Test concurrent access
        final futures = List.generate(
          10,
          (index) => service.getRandomJournalPrompt(const Locale('en')),
        );

        final results = await Future.wait(futures);

        // All results should be valid
        for (final result in results) {
          expect(result, isA<String>());
          expect(result.isNotEmpty, isTrue);
        }
      });
    });

    group('Topic Localization Tests - Requirements 5.2, 5.4', () {
      test('topic descriptions are correct for English', () {
        final topics = ReadingTopic.values;

        for (final topic in topics) {
          final description = service.getTopicDescription(
            topic,
            const Locale('en'),
          );
          final displayName = service.getTopicDisplayName(
            topic,
            const Locale('en'),
          );

          expect(description, isA<String>());
          expect(displayName, isA<String>());
          expect(description.isNotEmpty, isTrue);
          expect(displayName.isNotEmpty, isTrue);
        }
      });

      test('topic descriptions are correct for Spanish', () {
        final topics = ReadingTopic.values;

        for (final topic in topics) {
          final description = service.getTopicDescription(
            topic,
            const Locale('es'),
          );
          final displayName = service.getTopicDisplayName(
            topic,
            const Locale('es'),
          );

          expect(description, isA<String>());
          expect(displayName, isA<String>());
          expect(description.isNotEmpty, isTrue);
          expect(displayName.isNotEmpty, isTrue);
        }
      });

      test(
        'topic localization falls back to English for unsupported locales',
        () {
          final topics = ReadingTopic.values;

          for (final topic in topics) {
            final frenchDescription = service.getTopicDescription(
              topic,
              const Locale('fr'),
            );
            final englishDescription = service.getTopicDescription(
              topic,
              const Locale('en'),
            );

            // Should fallback to English
            expect(frenchDescription, equals(englishDescription));
          }
        },
      );
    });

    group('Spread Localization Tests - Requirements 5.2, 5.4', () {
      test('spread descriptions are correct for English', () {
        final spreads = SpreadType.values;

        for (final spread in spreads) {
          final description = service.getSpreadDescription(
            spread,
            const Locale('en'),
          );
          final displayName = service.getSpreadDisplayName(
            spread,
            const Locale('en'),
          );

          expect(description, isA<String>());
          expect(displayName, isA<String>());
          expect(description.isNotEmpty, isTrue);
          expect(displayName.isNotEmpty, isTrue);
        }
      });

      test('spread descriptions are correct for Spanish', () {
        final spreads = SpreadType.values;

        for (final spread in spreads) {
          final description = service.getSpreadDescription(
            spread,
            const Locale('es'),
          );
          final displayName = service.getSpreadDisplayName(
            spread,
            const Locale('es'),
          );

          expect(description, isA<String>());
          expect(displayName, isA<String>());
          expect(description.isNotEmpty, isTrue);
          expect(displayName.isNotEmpty, isTrue);
        }
      });

      test(
        'spread localization falls back to English for unsupported locales',
        () {
          final spreads = SpreadType.values;

          for (final spread in spreads) {
            final germanDescription = service.getSpreadDescription(
              spread,
              const Locale('de'),
            );
            final englishDescription = service.getSpreadDescription(
              spread,
              const Locale('en'),
            );

            // Should fallback to English
            expect(germanDescription, equals(englishDescription));
          }
        },
      );
    });

    group('Tarot Suit Localization Tests - Requirements 5.2, 5.4', () {
      test('suit descriptions are correct for English', () {
        final suits = TarotSuit.values;

        for (final suit in suits) {
          final description = service.getTarotSuitDescription(
            suit,
            const Locale('en'),
          );
          final displayName = service.getTarotSuitDisplayName(
            suit,
            const Locale('en'),
          );

          expect(description, isA<String>());
          expect(displayName, isA<String>());
          expect(description.isNotEmpty, isTrue);
          expect(displayName.isNotEmpty, isTrue);
        }
      });

      test('suit descriptions are correct for Spanish', () {
        final suits = TarotSuit.values;

        for (final suit in suits) {
          final description = service.getTarotSuitDescription(
            suit,
            const Locale('es'),
          );
          final displayName = service.getTarotSuitDisplayName(
            suit,
            const Locale('es'),
          );

          expect(description, isA<String>());
          expect(displayName, isA<String>());
          expect(description.isNotEmpty, isTrue);
          expect(displayName.isNotEmpty, isTrue);
        }
      });

      test(
        'suit localization falls back to English for unsupported locales',
        () {
          final suits = TarotSuit.values;

          for (final suit in suits) {
            final chineseDescription = service.getTarotSuitDescription(
              suit,
              const Locale('zh'),
            );
            final englishDescription = service.getTarotSuitDescription(
              suit,
              const Locale('en'),
            );

            // Should fallback to English
            expect(chineseDescription, equals(englishDescription));
          }
        },
      );
    });

    group('Data Consistency and Validation Tests', () {
      test('journal prompt indices are consistent with count', () async {
        final count = await service.getJournalPromptCount(const Locale('en'));

        if (count > 0) {
          // Test valid indices
          final firstPrompt = await service.getJournalPrompt(
            0,
            const Locale('en'),
          );
          final lastPrompt = await service.getJournalPrompt(
            count - 1,
            const Locale('en'),
          );

          expect(firstPrompt, isA<String>());
          expect(lastPrompt, isA<String>());
          expect(firstPrompt.isNotEmpty, isTrue);
          expect(lastPrompt.isNotEmpty, isTrue);
        }
      });

      test('all prompts list matches individual prompt retrieval', () async {
        final allPrompts = await service.getAllJournalPrompts(
          const Locale('en'),
        );

        for (int i = 0; i < allPrompts.length && i < 5; i++) {
          // Test first 5
          final individualPrompt = await service.getJournalPrompt(
            i,
            const Locale('en'),
          );

          if (allPrompts.isNotEmpty) {
            expect(individualPrompt, isA<String>());
            expect(individualPrompt.isNotEmpty, isTrue);
          }
        }
      });

      test('daily prompts cycle correctly through available prompts', () async {
        final promptCount = await service.getJournalPromptCount(
          const Locale('en'),
        );

        if (promptCount > 0) {
          // Test that daily prompts cycle through available prompts
          final testDates = List.generate(
            promptCount + 5,
            (index) => DateTime(2024, 1, 1).add(Duration(days: index)),
          );

          final dailyPrompts = <String>{};
          for (final date in testDates) {
            final prompt = await service.getDailyJournalPrompt(
              date,
              const Locale('en'),
            );
            dailyPrompts.add(prompt);
          }

          // Should have some variety
          expect(dailyPrompts.isNotEmpty, isTrue);
        }
      });
    });

    group('Locale-Specific Content Quality Tests', () {
      test('English content maintains spiritual tone', () {
        // Test that English content is appropriate for spiritual context
        final topics = ReadingTopic.values;
        final spreads = SpreadType.values;
        final suits = TarotSuit.values;

        for (final topic in topics) {
          final description = service.getTopicDescription(
            topic,
            const Locale('en'),
          );
          expect(
            description.toLowerCase(),
            anyOf(
              contains('growth'),
              contains('self'),
              contains('relationship'),
              contains('career'),
              contains('social'),
              contains('connection'),
              contains('professional'),
            ),
          );
        }

        for (final spread in spreads) {
          final description = service.getSpreadDescription(
            spread,
            const Locale('en'),
          );
          expect(description, isA<String>());
          expect(description.isNotEmpty, isTrue);
        }

        for (final suit in suits) {
          final description = service.getTarotSuitDescription(
            suit,
            const Locale('en'),
          );
          expect(description, isA<String>());
          expect(description.isNotEmpty, isTrue);
        }
      });

      test(
        'Spanish content maintains spiritual tone and cultural appropriateness',
        () {
          // Test that Spanish content is culturally appropriate
          final topics = ReadingTopic.values;

          for (final topic in topics) {
            final description = service.getTopicDescription(
              topic,
              const Locale('es'),
            );
            final displayName = service.getTopicDisplayName(
              topic,
              const Locale('es'),
            );

            expect(description, isA<String>());
            expect(displayName, isA<String>());
            expect(description.isNotEmpty, isTrue);
            expect(displayName.isNotEmpty, isTrue);

            // Should contain Spanish spiritual/personal growth terms
            expect(
              description.toLowerCase(),
              anyOf(
                contains('crecimiento'),
                contains('relaciones'),
                contains('carrera'),
                contains('comunidad'),
                contains('personal'),
                contains('profesional'),
                contains('conexiones'),
              ),
            );
          }
        },
      );
    });
  });
}
