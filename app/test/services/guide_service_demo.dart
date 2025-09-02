import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lunanul/services/guide_service.dart';
import 'package:lunanul/models/tarot_card.dart';
import 'package:lunanul/models/enums.dart';

/// Demo test to showcase the GuideService functionality
void main() {
  group('GuideService Demo', () {
    late GuideService guideService;

    setUp(() {
      guideService = GuideService();
    });

    test('Demo: Show different guide interpretations for The Fool card', () {
      // Create The Fool card
      final theFool = TarotCard(
        id: 'major_00',
        name: 'The Fool',
        suit: TarotSuit.majorArcana,
        number: 0,
        imageUrl: 'assets/cards/major_00.jpg',
        keywords: ['new beginnings', 'innocence', 'adventure', 'spontaneity'],
        uprightMeaning:
            'A new journey begins with optimism and trust in the unknown.',
        reversedMeaning: 'Recklessness and poor judgment may lead to setbacks.',
      );

      debugPrint('\n=== THE FOOL CARD INTERPRETATIONS ===\n');

      // Show interpretations from each guide for Self topic
      for (final guideType in GuideType.values) {
        final guide = guideService.getGuideByType(guideType)!;
        final interpretation = guideService.generateInterpretation(
          theFool,
          guideType,
          ReadingTopic.self,
        );

        debugPrint('${guide.fullDisplayName}:');
        debugPrint(interpretation);
        debugPrint('');
      }

      // Show how the same guide (Sage) interprets for different topics
      debugPrint('\n=== ZIAN (THE SAGE) - DIFFERENT TOPICS ===\n');

      for (final topic in ReadingTopic.values) {
        final interpretation = guideService.generateInterpretation(
          theFool,
          GuideType.sage,
          topic,
        );

        debugPrint('${topic.displayName} Reading:');
        debugPrint(interpretation);
        debugPrint('');
      }

      // Show guide recommendations for each topic
      debugPrint('\n=== GUIDE RECOMMENDATIONS BY TOPIC ===\n');

      for (final topic in ReadingTopic.values) {
        final recommended = guideService.getRecommendedGuides(topic);
        final best = guideService.getBestGuideForTopic(topic);

        debugPrint('${topic.displayName}:');
        debugPrint(
          '  Recommended: ${recommended.map((g) => g.guideName).join(', ')}',
        );
        debugPrint('  Best match: ${best?.guideName ?? 'None'}');
        debugPrint('');
      }

      // This test always passes - it's just for demonstration
      expect(true, isTrue);
    });

    test('Demo: Show reversed card interpretation', () {
      // Create a reversed card
      final reversedFool = TarotCard(
        id: 'major_00',
        name: 'The Fool',
        suit: TarotSuit.majorArcana,
        number: 0,
        imageUrl: 'assets/cards/major_00.jpg',
        keywords: ['new beginnings', 'innocence', 'adventure', 'spontaneity'],
        uprightMeaning:
            'A new journey begins with optimism and trust in the unknown.',
        reversedMeaning: 'Recklessness and poor judgment may lead to setbacks.',
        isReversed: true,
      );

      debugPrint('\n=== REVERSED FOOL INTERPRETATION ===\n');

      final interpretation = guideService.generateInterpretation(
        reversedFool,
        GuideType.healer,
        ReadingTopic.self,
      );

      debugPrint('Lyra (The Healer) on The Fool Reversed:');
      debugPrint(interpretation);
      debugPrint('');

      expect(interpretation, contains('Recklessness and poor judgment'));
    });

    test('Demo: Show all available guides', () {
      final guides = guideService.getAllGuides();

      debugPrint('\n=== ALL AVAILABLE GUIDES ===\n');

      for (final guide in guides) {
        debugPrint(guide.fullDisplayName);
        debugPrint('  Expertise: ${guide.expertise}');
        debugPrint(
          '  Best for: ${guide.bestForTopics.map((t) => t.displayName).join(', ')}',
        );
        debugPrint('  Voice: ${guide.personality.voiceTone}');
        debugPrint('  Focus: ${guide.personality.focusArea}');
        debugPrint('');
      }

      expect(guides.length, equals(4));
    });
  });
}
