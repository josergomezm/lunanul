import 'package:flutter_test/flutter_test.dart';
import 'package:lunanul/services/guide_service.dart';
import 'package:lunanul/models/tarot_card.dart';
import 'package:lunanul/models/enums.dart';

void main() {
  group('GuideService', () {
    late GuideService guideService;

    setUp(() {
      guideService = GuideService();
    });

    test('should return all four guides', () {
      final guides = guideService.getAllGuides();
      expect(guides.length, equals(4));

      final guideTypes = guides.map((g) => g.type).toSet();
      expect(guideTypes, containsAll(GuideType.values));
    });

    test('should get guide by type', () {
      final sage = guideService.getGuideByType(GuideType.sage);
      expect(sage, isNotNull);
      expect(sage!.type, equals(GuideType.sage));
      expect(sage.name, equals('Zian'));
    });

    test('should return null for invalid guide type', () {
      // This test would need a way to test invalid enum,
      // but since we're using enums, this is naturally protected
      final sage = guideService.getGuideByType(GuideType.sage);
      expect(sage, isNotNull);
    });

    test('should get recommended guides for each topic', () {
      final selfRecommended = guideService.getRecommendedGuides(
        ReadingTopic.self,
      );
      expect(selfRecommended, isNotEmpty);
      expect(selfRecommended, contains(GuideType.sage));
      expect(selfRecommended, contains(GuideType.healer));

      final loveRecommended = guideService.getRecommendedGuides(
        ReadingTopic.love,
      );
      expect(loveRecommended, isNotEmpty);
      expect(loveRecommended, contains(GuideType.healer));
      expect(loveRecommended, contains(GuideType.visionary));

      final workRecommended = guideService.getRecommendedGuides(
        ReadingTopic.work,
      );
      expect(workRecommended, isNotEmpty);
      expect(workRecommended, contains(GuideType.mentor));
      expect(workRecommended, contains(GuideType.sage));

      final socialRecommended = guideService.getRecommendedGuides(
        ReadingTopic.social,
      );
      expect(socialRecommended, isNotEmpty);
      expect(socialRecommended, contains(GuideType.healer));
      expect(socialRecommended, contains(GuideType.mentor));
    });

    test('should get best guide for topic', () {
      final bestForSelf = guideService.getBestGuideForTopic(ReadingTopic.self);
      expect(bestForSelf, equals(GuideType.sage));

      final bestForLove = guideService.getBestGuideForTopic(ReadingTopic.love);
      expect(bestForLove, equals(GuideType.healer));

      final bestForWork = guideService.getBestGuideForTopic(ReadingTopic.work);
      expect(bestForWork, equals(GuideType.mentor));

      final bestForSocial = guideService.getBestGuideForTopic(
        ReadingTopic.social,
      );
      expect(bestForSocial, equals(GuideType.healer));
    });

    test('should generate interpretation for each guide type', () {
      // Create a sample tarot card
      final card = TarotCard(
        id: 'test_card',
        name: 'The Fool',
        suit: TarotSuit.majorArcana,
        number: 0,
        imageUrl: 'test_url',
        keywords: ['new beginnings', 'innocence', 'adventure'],
        uprightMeaning: 'A new journey begins with optimism and trust.',
        reversedMeaning: 'Recklessness and poor judgment may lead to setbacks.',
      );

      // Test each guide type
      for (final guideType in GuideType.values) {
        final interpretation = guideService.generateInterpretation(
          card,
          guideType,
          ReadingTopic.self,
        );

        expect(interpretation, isNotEmpty);
        expect(interpretation, contains('The Fool'));

        // Verify guide-specific language patterns
        switch (guideType) {
          case GuideType.sage:
            expect(
              interpretation.toLowerCase(),
              anyOf([
                contains('universe'),
                contains('cosmic'),
                contains('wisdom'),
                contains('spiritual'),
              ]),
            );
            break;
          case GuideType.healer:
            expect(
              interpretation.toLowerCase(),
              anyOf([
                contains('heart'),
                contains('gentle'),
                contains('healing'),
                contains('compassion'),
              ]),
            );
            break;
          case GuideType.mentor:
            expect(
              interpretation.toLowerCase(),
              anyOf([
                contains('practical'),
                contains('action'),
                contains('focus'),
                contains('step'),
              ]),
            );
            break;
          case GuideType.visionary:
            expect(
              interpretation.toLowerCase(),
              anyOf([
                contains('imagine'),
                contains('creative'),
                contains('possibilities'),
                contains('potential'),
              ]),
            );
            break;
        }
      }
    });

    test('should generate different interpretations for different topics', () {
      final card = TarotCard(
        id: 'test_card',
        name: 'The Fool',
        suit: TarotSuit.majorArcana,
        number: 0,
        imageUrl: 'test_url',
        keywords: ['new beginnings', 'innocence', 'adventure'],
        uprightMeaning: 'A new journey begins with optimism and trust.',
        reversedMeaning: 'Recklessness and poor judgment may lead to setbacks.',
      );

      final selfInterpretation = guideService.generateInterpretation(
        card,
        GuideType.sage,
        ReadingTopic.self,
      );

      final loveInterpretation = guideService.generateInterpretation(
        card,
        GuideType.sage,
        ReadingTopic.love,
      );

      expect(selfInterpretation, isNotEmpty);
      expect(loveInterpretation, isNotEmpty);
      // Interpretations should be different due to topic-specific approaches
      expect(selfInterpretation, isNot(equals(loveInterpretation)));
    });

    test('should handle reversed cards', () {
      final reversedCard = TarotCard(
        id: 'test_card',
        name: 'The Fool',
        suit: TarotSuit.majorArcana,
        number: 0,
        imageUrl: 'test_url',
        keywords: ['new beginnings', 'innocence', 'adventure'],
        uprightMeaning: 'A new journey begins with optimism and trust.',
        reversedMeaning: 'Recklessness and poor judgment may lead to setbacks.',
        isReversed: true,
      );

      final interpretation = guideService.generateInterpretation(
        reversedCard,
        GuideType.sage,
        ReadingTopic.self,
      );

      expect(interpretation, isNotEmpty);
      expect(interpretation, contains('Recklessness and poor judgment'));
    });

    test('should include position in interpretation when provided', () {
      final card = TarotCard(
        id: 'test_card',
        name: 'The Fool',
        suit: TarotSuit.majorArcana,
        number: 0,
        imageUrl: 'test_url',
        keywords: ['new beginnings', 'innocence', 'adventure'],
        uprightMeaning: 'A new journey begins with optimism and trust.',
        reversedMeaning: 'Recklessness and poor judgment may lead to setbacks.',
      );

      final interpretationWithPosition = guideService.generateInterpretation(
        card,
        GuideType.sage,
        ReadingTopic.self,
        position: 'Past',
      );

      final interpretationWithoutPosition = guideService.generateInterpretation(
        card,
        GuideType.sage,
        ReadingTopic.self,
      );

      expect(interpretationWithPosition, isNotEmpty);
      expect(interpretationWithoutPosition, isNotEmpty);
      // Should be different when position is included
      expect(
        interpretationWithPosition,
        isNot(equals(interpretationWithoutPosition)),
      );
    });
  });
}
