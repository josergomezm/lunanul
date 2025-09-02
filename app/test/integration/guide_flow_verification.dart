import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lunanul/models/enums.dart';
import 'package:lunanul/models/tarot_card.dart';
import 'package:lunanul/providers/reading_provider.dart';
import 'package:lunanul/services/guide_service.dart';

/// Verification test for the complete guide selection flow
/// This test verifies that all components work together correctly
void main() {
  group('Guide Flow Verification', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('Complete guide flow works end-to-end', () async {
      // Step 1: Set topic in reading flow
      container.read(readingFlowProvider.notifier).setTopic(ReadingTopic.self);

      var readingFlow = container.read(readingFlowProvider);
      expect(readingFlow.topic, equals(ReadingTopic.self));
      expect(readingFlow.selectedGuide, isNull);
      expect(readingFlow.spreadType, isNull);

      // Step 2: Select a guide
      container
          .read(readingFlowProvider.notifier)
          .setSelectedGuide(GuideType.sage);

      readingFlow = container.read(readingFlowProvider);
      expect(readingFlow.selectedGuide, equals(GuideType.sage));

      // Step 3: Select a spread
      container
          .read(readingFlowProvider.notifier)
          .setSpreadType(SpreadType.threeCard);

      readingFlow = container.read(readingFlowProvider);
      expect(readingFlow.spreadType, equals(SpreadType.threeCard));

      // Step 4: Create reading with guide
      await container
          .read(currentReadingProvider.notifier)
          .createReading(
            topic: readingFlow.topic!,
            spreadType: readingFlow.spreadType!,
            selectedGuide: readingFlow.selectedGuide,
          );

      // Step 5: Verify reading was created with guide
      final reading = container.read(currentReadingProvider).value;
      expect(reading, isNotNull);
      expect(reading!.topic, equals(ReadingTopic.self));
      expect(reading.spreadType, equals(SpreadType.threeCard));
      expect(reading.selectedGuide, equals(GuideType.sage));
      expect(reading.cards.length, equals(3));
    });

    test('Guide selection persists throughout session', () async {
      // Set initial state
      container.read(readingFlowProvider.notifier).setTopic(ReadingTopic.love);
      container
          .read(readingFlowProvider.notifier)
          .setSelectedGuide(GuideType.healer);
      container
          .read(readingFlowProvider.notifier)
          .setSpreadType(SpreadType.relationship);

      // Create first reading
      await container
          .read(currentReadingProvider.notifier)
          .createReading(
            topic: ReadingTopic.love,
            spreadType: SpreadType.relationship,
            selectedGuide: GuideType.healer,
          );

      var reading = container.read(currentReadingProvider).value;
      expect(reading?.selectedGuide, equals(GuideType.healer));

      // Create second reading with same guide
      await container
          .read(currentReadingProvider.notifier)
          .createReading(
            topic: ReadingTopic.love,
            spreadType: SpreadType.singleCard,
            selectedGuide: GuideType.healer,
          );

      reading = container.read(currentReadingProvider).value;
      expect(reading?.selectedGuide, equals(GuideType.healer));
    });

    test('Can change guide mid-flow', () async {
      // Set initial guide
      container.read(readingFlowProvider.notifier).setTopic(ReadingTopic.work);
      container
          .read(readingFlowProvider.notifier)
          .setSelectedGuide(GuideType.mentor);

      var readingFlow = container.read(readingFlowProvider);
      expect(readingFlow.selectedGuide, equals(GuideType.mentor));

      // Change guide
      container
          .read(readingFlowProvider.notifier)
          .setSelectedGuide(GuideType.visionary);

      readingFlow = container.read(readingFlowProvider);
      expect(readingFlow.selectedGuide, equals(GuideType.visionary));

      // Verify topic is preserved
      expect(readingFlow.topic, equals(ReadingTopic.work));
    });

    test('Skip guide selection works correctly', () async {
      // Set topic and spread without guide
      container
          .read(readingFlowProvider.notifier)
          .setTopic(ReadingTopic.social);
      container
          .read(readingFlowProvider.notifier)
          .setSpreadType(SpreadType.singleCard);

      // Create reading without guide
      await container
          .read(currentReadingProvider.notifier)
          .createReading(
            topic: ReadingTopic.social,
            spreadType: SpreadType.singleCard,
            selectedGuide: null,
          );

      final reading = container.read(currentReadingProvider).value;
      expect(reading, isNotNull);
      expect(reading!.selectedGuide, isNull);
      expect(reading.topic, equals(ReadingTopic.social));
    });

    test('Guide service generates different interpretations', () async {
      final guideService = GuideService();

      // Create a mock card for testing
      final mockCard = await _createMockCard();

      // Generate interpretations with different guides
      final sageInterpretation = guideService.generateInterpretation(
        mockCard,
        GuideType.sage,
        ReadingTopic.self,
      );

      final healerInterpretation = guideService.generateInterpretation(
        mockCard,
        GuideType.healer,
        ReadingTopic.self,
      );

      final mentorInterpretation = guideService.generateInterpretation(
        mockCard,
        GuideType.mentor,
        ReadingTopic.self,
      );

      final visionaryInterpretation = guideService.generateInterpretation(
        mockCard,
        GuideType.visionary,
        ReadingTopic.self,
      );

      // Verify interpretations are different
      expect(sageInterpretation, isNot(equals(healerInterpretation)));
      expect(mentorInterpretation, isNot(equals(visionaryInterpretation)));
      expect(sageInterpretation, isNot(equals(mentorInterpretation)));

      // Verify interpretations are not empty
      expect(sageInterpretation.isNotEmpty, isTrue);
      expect(healerInterpretation.isNotEmpty, isTrue);
      expect(mentorInterpretation.isNotEmpty, isTrue);
      expect(visionaryInterpretation.isNotEmpty, isTrue);
    });

    test('Reading flow state resets correctly', () async {
      // Set up complete flow
      container.read(readingFlowProvider.notifier).setTopic(ReadingTopic.love);
      container
          .read(readingFlowProvider.notifier)
          .setSelectedGuide(GuideType.healer);
      container
          .read(readingFlowProvider.notifier)
          .setSpreadType(SpreadType.threeCard);

      var readingFlow = container.read(readingFlowProvider);
      expect(readingFlow.topic, equals(ReadingTopic.love));
      expect(readingFlow.selectedGuide, equals(GuideType.healer));
      expect(readingFlow.spreadType, equals(SpreadType.threeCard));

      // Reset flow
      container.read(readingFlowProvider.notifier).reset();

      readingFlow = container.read(readingFlowProvider);
      expect(readingFlow.topic, isNull);
      expect(readingFlow.selectedGuide, isNull);
      expect(readingFlow.spreadType, isNull);
    });

    test('Topic change clears guide and spread selection', () async {
      // Set up complete flow
      container.read(readingFlowProvider.notifier).setTopic(ReadingTopic.work);
      container
          .read(readingFlowProvider.notifier)
          .setSelectedGuide(GuideType.mentor);
      container
          .read(readingFlowProvider.notifier)
          .setSpreadType(SpreadType.career);

      // Change topic
      container.read(readingFlowProvider.notifier).setTopic(ReadingTopic.love);

      final readingFlow = container.read(readingFlowProvider);
      expect(readingFlow.topic, equals(ReadingTopic.love));
      expect(readingFlow.selectedGuide, isNull);
      expect(readingFlow.spreadType, isNull);
    });
  });
}

/// Helper function to create a mock card for testing
Future<TarotCard> _createMockCard() async {
  return TarotCard(
    id: 'test-card',
    name: 'The Fool',
    suit: TarotSuit.majorArcana,
    number: 0,
    imageUrl: 'assets/images/cards/major/00_fool.jpg',
    keywords: ['new beginnings', 'innocence', 'adventure'],
    uprightMeaning: 'New beginnings, innocence, spontaneity, free spirit',
    reversedMeaning: 'Recklessness, taken advantage of, inconsideration',
    isReversed: false,
  );
}
