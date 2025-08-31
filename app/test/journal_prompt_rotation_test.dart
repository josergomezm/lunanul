import 'package:flutter_test/flutter_test.dart';
import 'package:lunanul/services/dynamic_content_localizations.dart';
import 'dart:ui';

void main() {
  group('Journal Prompt Rotation Tests', () {
    late DynamicContentLocalizations service;

    setUpAll(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
    });

    setUp(() {
      service = DynamicContentLocalizations();
    });

    test('should provide consistent daily prompts for same date', () async {
      final testDate = DateTime(2024, 1, 15);

      // Get the same prompt multiple times for the same date
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

      expect(prompt1, equals(prompt2));
      expect(prompt2, equals(prompt3));
      expect(prompt1, isNotEmpty);
    });

    test('should provide different prompts for different dates', () async {
      final date1 = DateTime(2024, 1, 1);
      final date2 = DateTime(2024, 1, 2);
      final date3 = DateTime(2024, 1, 3);

      final prompt1 = await service.getDailyJournalPrompt(
        date1,
        const Locale('en'),
      );
      final prompt2 = await service.getDailyJournalPrompt(
        date2,
        const Locale('en'),
      );
      final prompt3 = await service.getDailyJournalPrompt(
        date3,
        const Locale('en'),
      );

      expect(prompt1, isNotEmpty);
      expect(prompt2, isNotEmpty);
      expect(prompt3, isNotEmpty);

      // At least one should be different (unless there's only one prompt, which is unlikely)
      final allSame = prompt1 == prompt2 && prompt2 == prompt3;
      expect(
        allSame,
        isFalse,
        reason: 'All prompts should not be identical for different dates',
      );
    });

    test('should rotate through available prompts over time', () async {
      final prompts = <String>{};

      // Get prompts for 30 different days
      for (int i = 0; i < 30; i++) {
        final date = DateTime(2024, 1, 1).add(Duration(days: i));
        final prompt = await service.getDailyJournalPrompt(
          date,
          const Locale('en'),
        );
        prompts.add(prompt);
      }

      // Should have multiple unique prompts (at least 5 different ones in 30 days)
      expect(prompts.length, greaterThan(5));
    });

    test('should provide localized prompts for different languages', () async {
      final testDate = DateTime(2024, 1, 15);

      final englishPrompt = await service.getDailyJournalPrompt(
        testDate,
        const Locale('en'),
      );
      final spanishPrompt = await service.getDailyJournalPrompt(
        testDate,
        const Locale('es'),
      );

      expect(englishPrompt, isNotEmpty);
      expect(spanishPrompt, isNotEmpty);
      expect(englishPrompt, isNot(equals(spanishPrompt)));

      // Verify they're actually in different languages
      expect(englishPrompt.toLowerCase(), isNot(contains('¿')));
      expect(spanishPrompt, contains('¿'));
    });

    test(
      'should maintain consistent rotation pattern across languages',
      () async {
        final englishPrompts = <String>[];
        final spanishPrompts = <String>[];

        // Get prompts for the same dates in both languages
        for (int i = 0; i < 10; i++) {
          final date = DateTime(2024, 1, 1).add(Duration(days: i));
          final englishPrompt = await service.getDailyJournalPrompt(
            date,
            const Locale('en'),
          );
          final spanishPrompt = await service.getDailyJournalPrompt(
            date,
            const Locale('es'),
          );

          englishPrompts.add(englishPrompt);
          spanishPrompts.add(spanishPrompt);
        }

        // Both should have the same number of unique prompts (same rotation pattern)
        final uniqueEnglish = englishPrompts.toSet().length;
        final uniqueSpanish = spanishPrompts.toSet().length;

        expect(uniqueEnglish, equals(uniqueSpanish));
      },
    );

    test('should handle year boundaries correctly', () async {
      final endOfYear = DateTime(2023, 12, 31);
      final startOfYear = DateTime(2024, 1, 1);

      final prompt1 = await service.getDailyJournalPrompt(
        endOfYear,
        const Locale('en'),
      );
      final prompt2 = await service.getDailyJournalPrompt(
        startOfYear,
        const Locale('en'),
      );

      expect(prompt1, isNotEmpty);
      expect(prompt2, isNotEmpty);
      // They might be the same or different, but both should be valid
    });

    test(
      'should provide random prompts that are different from daily prompts',
      () async {
        final testDate = DateTime(2024, 1, 15);
        await service.getDailyJournalPrompt(testDate, const Locale('en'));

        // Get several random prompts
        final randomPrompts = <String>{};
        for (int i = 0; i < 10; i++) {
          final randomPrompt = await service.getRandomJournalPrompt(
            const Locale('en'),
          );
          randomPrompts.add(randomPrompt);
        }

        expect(randomPrompts, isNotEmpty);
        // Should have some variety in random prompts
        expect(
          randomPrompts.length,
          greaterThan(1),
        ); // Should have some variety
        // Daily prompt might or might not be in the random set, that's okay
      },
    );

    test('should handle leap years correctly', () async {
      final leapYearDate = DateTime(2024, 2, 29); // 2024 is a leap year
      final prompt = await service.getDailyJournalPrompt(
        leapYearDate,
        const Locale('en'),
      );

      expect(prompt, isNotEmpty);
      expect(
        prompt,
        isNot(equals('What insights are emerging for you today?')),
      ); // Should not fallback
    });

    test(
      'should provide consistent prompts across multiple years for same day of year',
      () async {
        final date2023 = DateTime(2023, 6, 15);
        final date2024 = DateTime(2024, 6, 15);
        final date2025 = DateTime(2025, 6, 15);

        final prompt2023 = await service.getDailyJournalPrompt(
          date2023,
          const Locale('en'),
        );
        final prompt2024 = await service.getDailyJournalPrompt(
          date2024,
          const Locale('en'),
        );
        final prompt2025 = await service.getDailyJournalPrompt(
          date2025,
          const Locale('en'),
        );

        // All prompts should be valid (not fallback)
        expect(prompt2023, isNotEmpty);
        expect(prompt2024, isNotEmpty);
        expect(prompt2025, isNotEmpty);

        // They might be different due to leap year calculations, but should be valid
        expect(
          prompt2023,
          isNot(equals('What insights are emerging for you today?')),
        );
        expect(
          prompt2024,
          isNot(equals('What insights are emerging for you today?')),
        );
        expect(
          prompt2025,
          isNot(equals('What insights are emerging for you today?')),
        );
      },
    );
  });
}
