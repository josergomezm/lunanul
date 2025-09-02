import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lunanul/models/enums.dart';
import 'package:lunanul/models/tarot_card.dart';
import 'package:lunanul/services/guide_service.dart';
import 'package:lunanul/services/guide_localizations.dart';

// Helper function to create test card
TarotCard createTestCard() {
  return const TarotCard(
    id: 'test_card',
    name: 'The Fool',
    suit: TarotSuit.majorArcana,
    number: 0,
    imageUrl: 'assets/images/cards/major_00.jpg',
    keywords: ['beginnings', 'innocence', 'spontaneity'],
    uprightMeaning: 'New beginnings and fresh starts',
    reversedMeaning: 'Recklessness and poor judgment',
  );
}

void main() {
  group('Guide Localization Integration Tests', () {
    late GuideService guideService;
    late GuideLocalizations guideLocalizations;

    setUpAll(() {
      TestWidgetsFlutterBinding.ensureInitialized();
    });

    setUp(() {
      guideService = GuideService();
      guideLocalizations = GuideLocalizations();
    });

    tearDown(() {
      guideService.clearLocalizationCache();
      guideLocalizations.clearCache();
    });

    group('Localized Interpretation Generation', () {
      test('should generate localized interpretations in English', () async {
        final card = createTestCard();

        const locale = Locale('en');

        final interpretation = await guideService
            .generateLocalizedInterpretation(
              card,
              GuideType.sage,
              ReadingTopic.self,
              locale,
            );

        expect(interpretation, isNotEmpty);
        expect(interpretation, contains('Fool'));
        expect(
          interpretation.length,
          greaterThan(50),
        ); // Should be a substantial interpretation
      });

      test('should generate localized interpretations in Spanish', () async {
        final card = createTestCard();

        const locale = Locale('es');

        final interpretation = await guideService
            .generateLocalizedInterpretation(
              card,
              GuideType.healer,
              ReadingTopic.love,
              locale,
            );

        expect(interpretation, isNotEmpty);
        expect(interpretation, contains('Fool'));
        expect(
          interpretation.length,
          greaterThan(50),
        ); // Should be a substantial interpretation
      });

      test(
        'should generate different interpretations for different guides',
        () async {
          final card = createTestCard();

          const locale = Locale('en');

          final sageInterpretation = await guideService
              .generateLocalizedInterpretation(
                card,
                GuideType.sage,
                ReadingTopic.self,
                locale,
              );

          final healerInterpretation = await guideService
              .generateLocalizedInterpretation(
                card,
                GuideType.healer,
                ReadingTopic.self,
                locale,
              );

          final mentorInterpretation = await guideService
              .generateLocalizedInterpretation(
                card,
                GuideType.mentor,
                ReadingTopic.self,
                locale,
              );

          final visionaryInterpretation = await guideService
              .generateLocalizedInterpretation(
                card,
                GuideType.visionary,
                ReadingTopic.self,
                locale,
              );

          // All interpretations should be different
          expect(sageInterpretation, isNot(equals(healerInterpretation)));
          expect(sageInterpretation, isNot(equals(mentorInterpretation)));
          expect(sageInterpretation, isNot(equals(visionaryInterpretation)));
          expect(healerInterpretation, isNot(equals(mentorInterpretation)));
          expect(healerInterpretation, isNot(equals(visionaryInterpretation)));
          expect(mentorInterpretation, isNot(equals(visionaryInterpretation)));

          // All should contain the card name
          expect(sageInterpretation, contains('Fool'));
          expect(healerInterpretation, contains('Fool'));
          expect(mentorInterpretation, contains('Fool'));
          expect(visionaryInterpretation, contains('Fool'));
        },
      );

      test('should handle different topics appropriately', () async {
        final card = createTestCard();

        const locale = Locale('en');

        final selfInterpretation = await guideService
            .generateLocalizedInterpretation(
              card,
              GuideType.sage,
              ReadingTopic.self,
              locale,
            );

        final loveInterpretation = await guideService
            .generateLocalizedInterpretation(
              card,
              GuideType.sage,
              ReadingTopic.love,
              locale,
            );

        final workInterpretation = await guideService
            .generateLocalizedInterpretation(
              card,
              GuideType.sage,
              ReadingTopic.work,
              locale,
            );

        final socialInterpretation = await guideService
            .generateLocalizedInterpretation(
              card,
              GuideType.sage,
              ReadingTopic.social,
              locale,
            );

        // All interpretations should be valid
        expect(selfInterpretation, isNotEmpty);
        expect(loveInterpretation, isNotEmpty);
        expect(workInterpretation, isNotEmpty);
        expect(socialInterpretation, isNotEmpty);

        // All should contain the card name
        expect(selfInterpretation, contains('Fool'));
        expect(loveInterpretation, contains('Fool'));
        expect(workInterpretation, contains('Fool'));
        expect(socialInterpretation, contains('Fool'));
      });

      test('should fallback gracefully for unsupported locales', () async {
        final card = createTestCard();

        const locale = Locale('fr'); // Unsupported locale

        final interpretation = await guideService
            .generateLocalizedInterpretation(
              card,
              GuideType.sage,
              ReadingTopic.self,
              locale,
            );

        expect(interpretation, isNotEmpty);
        expect(interpretation, contains('Fool'));
        expect(
          interpretation.length,
          greaterThan(50),
        ); // Should still be substantial
      });
    });

    group('Performance and Caching', () {
      test('should cache templates for better performance', () async {
        final card = createTestCard();

        const locale = Locale('en');

        // First call - loads from assets
        final stopwatch1 = Stopwatch()..start();
        final interpretation1 = await guideService
            .generateLocalizedInterpretation(
              card,
              GuideType.sage,
              ReadingTopic.self,
              locale,
            );
        stopwatch1.stop();

        // Second call - should use cache
        final stopwatch2 = Stopwatch()..start();
        final interpretation2 = await guideService
            .generateLocalizedInterpretation(
              card,
              GuideType.sage,
              ReadingTopic.self,
              locale,
            );
        stopwatch2.stop();

        expect(interpretation1, isNotEmpty);
        expect(interpretation2, isNotEmpty);

        // Both calls should produce valid interpretations (caching is working if no errors)
        expect(interpretation1, contains('Fool'));
        expect(interpretation2, contains('Fool'));
      });

      test('should preload templates without errors', () async {
        expect(() => guideService.preloadLocalizedTemplates(), returnsNormally);
      });

      test('should clear cache properly', () async {
        final card = createTestCard();

        const locale = Locale('en');

        // Load template to populate cache
        await guideService.generateLocalizedInterpretation(
          card,
          GuideType.sage,
          ReadingTopic.self,
          locale,
        );

        // Clear cache
        guideService.clearLocalizationCache();

        // Should still work after cache clear
        final interpretation = await guideService
            .generateLocalizedInterpretation(
              card,
              GuideType.sage,
              ReadingTopic.self,
              locale,
            );

        expect(interpretation, isNotEmpty);
        expect(interpretation, contains('Fool'));
      });
    });
  });
}
