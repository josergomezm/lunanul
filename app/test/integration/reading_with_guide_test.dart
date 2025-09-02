import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lunanul/providers/reading_provider.dart';
import 'package:lunanul/providers/guide_provider.dart';
import 'package:lunanul/models/enums.dart';

void main() {
  group('Reading with Guide Integration', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('reading flow includes guide selection', () {
      final readingFlowNotifier = container.read(readingFlowProvider.notifier);

      // Set topic
      readingFlowNotifier.setTopic(ReadingTopic.love);

      // Set guide
      readingFlowNotifier.setSelectedGuide(GuideType.healer);

      // Set spread
      readingFlowNotifier.setSpreadType(SpreadType.threeCard);

      final flowState = container.read(readingFlowProvider);

      expect(flowState.topic, equals(ReadingTopic.love));
      expect(flowState.selectedGuide, equals(GuideType.healer));
      expect(flowState.spreadType, equals(SpreadType.threeCard));
      expect(readingFlowNotifier.canCreateReading, isTrue);
      expect(readingFlowNotifier.hasGuideSelection, isTrue);
    });

    test('guide selection is optional in reading flow', () {
      final readingFlowNotifier = container.read(readingFlowProvider.notifier);

      // Set topic and spread without guide
      readingFlowNotifier.setTopic(ReadingTopic.work);
      readingFlowNotifier.setSpreadType(SpreadType.singleCard);

      final flowState = container.read(readingFlowProvider);

      expect(flowState.topic, equals(ReadingTopic.work));
      expect(flowState.selectedGuide, isNull);
      expect(flowState.spreadType, equals(SpreadType.singleCard));
      expect(readingFlowNotifier.canCreateReading, isTrue);
      expect(readingFlowNotifier.hasGuideSelection, isFalse);
    });

    test('guide selection state synchronizes with reading flow', () {
      final readingFlowNotifier = container.read(readingFlowProvider.notifier);
      final guideSelectionNotifier = container.read(
        guideSelectionProvider.notifier,
      );
      final selectedGuideNotifier = container.read(
        selectedGuideProvider.notifier,
      );

      // Set topic in reading flow
      readingFlowNotifier.setTopic(ReadingTopic.self);

      // Set topic in guide selection
      guideSelectionNotifier.setReadingTopic(ReadingTopic.self);

      // Select guide in guide selection
      guideSelectionNotifier.selectGuide(GuideType.sage);

      // Update reading flow with selected guide
      final selectedGuide = container
          .read(guideSelectionProvider)
          .selectedGuide;
      readingFlowNotifier.setSelectedGuide(selectedGuide);

      // Also update the global selected guide provider
      selectedGuideNotifier.state = selectedGuide;

      final readingFlowState = container.read(readingFlowProvider);
      final guideSelectionState = container.read(guideSelectionProvider);
      final globalSelectedGuide = container.read(selectedGuideProvider);

      expect(readingFlowState.selectedGuide, equals(GuideType.sage));
      expect(guideSelectionState.selectedGuide, equals(GuideType.sage));
      expect(globalSelectedGuide, equals(GuideType.sage));
    });

    test('resetting reading flow clears guide selection', () {
      final readingFlowNotifier = container.read(readingFlowProvider.notifier);

      // Set up complete flow
      readingFlowNotifier.setTopic(ReadingTopic.social);
      readingFlowNotifier.setSelectedGuide(GuideType.visionary);
      readingFlowNotifier.setSpreadType(SpreadType.relationship);

      // Reset
      readingFlowNotifier.reset();

      final flowState = container.read(readingFlowProvider);

      expect(flowState.topic, isNull);
      expect(flowState.selectedGuide, isNull);
      expect(flowState.spreadType, isNull);
      expect(readingFlowNotifier.canCreateReading, isFalse);
      expect(readingFlowNotifier.hasGuideSelection, isFalse);
    });

    test('changing topic clears guide selection in reading flow', () {
      final readingFlowNotifier = container.read(readingFlowProvider.notifier);

      // Set initial state with topic first
      readingFlowNotifier.setTopic(ReadingTopic.love);

      // Then set guide and spread
      readingFlowNotifier.setSelectedGuide(GuideType.healer);
      readingFlowNotifier.setSpreadType(SpreadType.threeCard);

      // Verify initial state
      var flowState = container.read(readingFlowProvider);
      expect(flowState.selectedGuide, equals(GuideType.healer));
      expect(flowState.spreadType, equals(SpreadType.threeCard));

      // Change topic (should clear guide and spread)
      readingFlowNotifier.setTopic(ReadingTopic.work);

      flowState = container.read(readingFlowProvider);

      expect(flowState.topic, equals(ReadingTopic.work));
      expect(flowState.selectedGuide, isNull);
      expect(flowState.spreadType, isNull);
    });
  });
}
