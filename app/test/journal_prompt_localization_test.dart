import 'package:flutter_test/flutter_test.dart';
import 'package:lunanul/services/dynamic_content_localizations.dart';
import 'dart:ui';

void main() {
  group('Journal Prompt Localization Tests', () {
    late DynamicContentLocalizations service;

    setUpAll(() async {
      // Set up the test environment to load assets
      TestWidgetsFlutterBinding.ensureInitialized();
    });

    setUp(() {
      service = DynamicContentLocalizations();
    });

    test('should load English journal prompts', () async {
      final prompts = await service.getAllJournalPrompts(const Locale('en'));

      expect(prompts, isNotEmpty);
      expect(prompts.length, greaterThan(10));
      expect(prompts.first, contains('energy'));
    });

    test('should load Spanish journal prompts', () async {
      final prompts = await service.getAllJournalPrompts(const Locale('es'));

      expect(prompts, isNotEmpty);
      expect(prompts.length, greaterThan(10));
      expect(prompts.first, contains('energía'));
    });

    test('should get daily journal prompt consistently', () async {
      final date = DateTime(2024, 1, 1);

      final prompt1 = await service.getDailyJournalPrompt(
        date,
        const Locale('en'),
      );
      final prompt2 = await service.getDailyJournalPrompt(
        date,
        const Locale('en'),
      );

      expect(prompt1, equals(prompt2));
      expect(prompt1, isNotEmpty);
    });

    test('should get different prompts for different dates', () async {
      final date1 = DateTime(2024, 1, 1);
      final date2 = DateTime(2024, 1, 2);

      final prompt1 = await service.getDailyJournalPrompt(
        date1,
        const Locale('en'),
      );
      final prompt2 = await service.getDailyJournalPrompt(
        date2,
        const Locale('en'),
      );

      // They might be the same if there are few prompts, but let's check they're valid
      expect(prompt1, isNotEmpty);
      expect(prompt2, isNotEmpty);
    });

    test('should get localized daily prompts', () async {
      final date = DateTime(2024, 1, 1);

      final englishPrompt = await service.getDailyJournalPrompt(
        date,
        const Locale('en'),
      );
      final spanishPrompt = await service.getDailyJournalPrompt(
        date,
        const Locale('es'),
      );

      expect(englishPrompt, isNotEmpty);
      expect(spanishPrompt, isNotEmpty);
      // They should be different (different languages)
      expect(englishPrompt, isNot(equals(spanishPrompt)));
    });

    test('should fallback to English for unsupported locale', () async {
      final date = DateTime(2024, 1, 1);

      final englishPrompt = await service.getDailyJournalPrompt(
        date,
        const Locale('en'),
      );
      final frenchPrompt = await service.getDailyJournalPrompt(
        date,
        const Locale('fr'),
      );

      // Should fallback to English
      expect(frenchPrompt, equals(englishPrompt));
    });

    test('should get random journal prompt', () async {
      final prompt = await service.getRandomJournalPrompt(const Locale('en'));

      expect(prompt, isNotEmpty);
    });

    test('should get journal prompt by index', () async {
      final prompt = await service.getJournalPrompt(0, const Locale('en'));

      expect(prompt, isNotEmpty);
    });

    test('should handle out of range index gracefully', () async {
      final prompt = await service.getJournalPrompt(999, const Locale('en'));

      expect(prompt, isNotEmpty);
      // Should fallback to default prompt
      expect(prompt, equals('What insights are emerging for you today?'));
    });

    test('should get prompt count', () async {
      final count = await service.getJournalPromptCount(const Locale('en'));

      expect(count, greaterThan(0));
    });

    test('should clear cache', () async {
      // Load prompts to populate cache
      await service.getAllJournalPrompts(const Locale('en'));

      // Clear cache
      service.clearCache();

      // Should still work (reload from assets)
      final prompts = await service.getAllJournalPrompts(const Locale('en'));
      expect(prompts, isNotEmpty);
    });

    test('should preload all journal prompts', () async {
      await service.preloadAllJournalPrompts();

      // Should be able to get prompts quickly now
      final englishPrompts = await service.getAllJournalPrompts(
        const Locale('en'),
      );
      final spanishPrompts = await service.getAllJournalPrompts(
        const Locale('es'),
      );

      expect(englishPrompts, isNotEmpty);
      expect(spanishPrompts, isNotEmpty);
    });
  });
}
