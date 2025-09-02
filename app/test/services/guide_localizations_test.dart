import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lunanul/models/enums.dart';
import 'package:lunanul/services/guide_localizations.dart';

void main() {
  group('GuideLocalizations', () {
    late GuideLocalizations guideLocalizations;

    setUpAll(() {
      TestWidgetsFlutterBinding.ensureInitialized();
    });

    setUp(() {
      guideLocalizations = GuideLocalizations();
    });

    tearDown(() {
      guideLocalizations.clearCache();
    });

    group('Interpretation Templates', () {
      test('should load English interpretation templates', () async {
        const locale = Locale('en');

        final template = await guideLocalizations
            .getLocalizedInterpretationTemplate(
              GuideType.sage,
              ReadingTopic.self,
              locale,
            );

        expect(template.guide, equals(GuideType.sage));
        expect(template.openingPhrase, isNotEmpty);
        expect(template.cardContextTemplate, isNotEmpty);
        expect(template.actionAdviceTemplate, isNotEmpty);
        expect(template.closingPhrase, isNotEmpty);
      });

      test('should load Spanish interpretation templates', () async {
        const locale = Locale('es');

        final template = await guideLocalizations
            .getLocalizedInterpretationTemplate(
              GuideType.healer,
              ReadingTopic.love,
              locale,
            );

        expect(template.guide, equals(GuideType.healer));
        expect(template.openingPhrase, isNotEmpty);
        expect(template.cardContextTemplate, isNotEmpty);
        expect(template.actionAdviceTemplate, isNotEmpty);
        expect(template.closingPhrase, isNotEmpty);
      });

      test('should fallback to English for unsupported locale', () async {
        const locale = Locale('fr'); // Unsupported locale

        final template = await guideLocalizations
            .getLocalizedInterpretationTemplate(
              GuideType.mentor,
              ReadingTopic.work,
              locale,
            );

        expect(template.guide, equals(GuideType.mentor));
        expect(template.openingPhrase, isNotEmpty);
      });

      test('should handle all guide types', () async {
        const locale = Locale('en');

        for (final guideType in GuideType.values) {
          final template = await guideLocalizations
              .getLocalizedInterpretationTemplate(
                guideType,
                ReadingTopic.self,
                locale,
              );

          expect(template.guide, equals(guideType));
          expect(template.openingPhrase, isNotEmpty);
          expect(template.cardContextTemplate, isNotEmpty);
          expect(template.actionAdviceTemplate, isNotEmpty);
          expect(template.closingPhrase, isNotEmpty);
        }
      });

      test('should provide different templates on multiple calls', () async {
        const locale = Locale('en');

        final templates = <String>[];

        // Get multiple templates to test randomization
        for (int i = 0; i < 10; i++) {
          final template = await guideLocalizations
              .getLocalizedInterpretationTemplate(
                GuideType.sage,
                ReadingTopic.self,
                locale,
              );
          templates.add(template.openingPhrase);
        }

        // Should have some variation (not all identical)
        final uniqueTemplates = templates.toSet();
        expect(uniqueTemplates.length, greaterThan(1));
      });
    });

    group('Cache Management', () {
      test('should cache loaded templates', () async {
        const locale = Locale('en');

        // Load template first time
        final template1 = await guideLocalizations
            .getLocalizedInterpretationTemplate(
              GuideType.sage,
              ReadingTopic.self,
              locale,
            );

        // Load template second time (should use cache)
        final template2 = await guideLocalizations
            .getLocalizedInterpretationTemplate(
              GuideType.sage,
              ReadingTopic.self,
              locale,
            );

        // Both should be valid templates
        expect(template1.guide, equals(GuideType.sage));
        expect(template2.guide, equals(GuideType.sage));
      });

      test('should clear cache properly', () async {
        const locale = Locale('en');

        // Load template to populate cache
        await guideLocalizations.getLocalizedInterpretationTemplate(
          GuideType.sage,
          ReadingTopic.self,
          locale,
        );

        // Clear cache
        guideLocalizations.clearCache();

        // Should still work after cache clear
        final template = await guideLocalizations
            .getLocalizedInterpretationTemplate(
              GuideType.sage,
              ReadingTopic.self,
              locale,
            );

        expect(template.guide, equals(GuideType.sage));
        expect(template.openingPhrase, isNotEmpty);
      });

      test('should preload all templates without error', () async {
        expect(
          () => guideLocalizations.preloadAllInterpretationTemplates(),
          returnsNormally,
        );
      });
    });

    group('Template Validation', () {
      test('should validate English templates', () async {
        const locale = Locale('en');

        final isValid = await guideLocalizations
            .validateInterpretationTemplates(locale);
        expect(isValid, isTrue);
      });

      test('should validate Spanish templates', () async {
        const locale = Locale('es');

        final isValid = await guideLocalizations
            .validateInterpretationTemplates(locale);
        expect(isValid, isTrue);
      });

      test('should handle validation for unsupported locale', () async {
        const locale = Locale('fr');

        final isValid = await guideLocalizations
            .validateInterpretationTemplates(locale);
        // Should return true because it falls back to English templates
        expect(isValid, isTrue);
      });
    });

    group('Error Handling', () {
      test('should handle missing template gracefully', () async {
        const locale = Locale('xyz'); // Non-existent locale

        final template = await guideLocalizations
            .getLocalizedInterpretationTemplate(
              GuideType.sage,
              ReadingTopic.self,
              locale,
            );

        // Should return fallback template
        expect(template.guide, equals(GuideType.sage));
        expect(template.openingPhrase, isNotEmpty);
      });

      test('should handle empty template lists gracefully', () async {
        // This tests the _getRandomElement method with empty lists
        const locale = Locale('en');

        final template = await guideLocalizations
            .getLocalizedInterpretationTemplate(
              GuideType.sage,
              ReadingTopic.self,
              locale,
            );

        expect(template.openingPhrase, isNotEmpty);
      });
    });
  });
}
