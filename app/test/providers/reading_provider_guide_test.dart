import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lunanul/models/models.dart';
import 'package:lunanul/providers/reading_provider.dart';

void main() {
  group('Reading Provider with Guide Selection', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('should create reading flow state with guide selection', () {
      final readingFlowNotifier = container.read(readingFlowProvider.notifier);

      // Set topic
      readingFlowNotifier.setTopic(ReadingTopic.self);

      // Set spread type
      readingFlowNotifier.setSpreadType(SpreadType.singleCard);

      // Set guide
      readingFlowNotifier.setSelectedGuide(GuideType.sage);

      final state = container.read(readingFlowProvider);

      expect(state.topic, equals(ReadingTopic.self));
      expect(state.spreadType, equals(SpreadType.singleCard));
      expect(state.selectedGuide, equals(GuideType.sage));
      expect(readingFlowNotifier.canCreateReading, isTrue);
      expect(readingFlowNotifier.hasGuideSelection, isTrue);
    });

    test('should handle reading flow without guide selection', () {
      final readingFlowNotifier = container.read(readingFlowProvider.notifier);

      // Set topic and spread type but no guide
      readingFlowNotifier.setTopic(ReadingTopic.love);
      readingFlowNotifier.setSpreadType(SpreadType.threeCard);

      final state = container.read(readingFlowProvider);

      expect(state.topic, equals(ReadingTopic.love));
      expect(state.spreadType, equals(SpreadType.threeCard));
      expect(state.selectedGuide, isNull);
      expect(readingFlowNotifier.canCreateReading, isTrue);
      expect(readingFlowNotifier.hasGuideSelection, isFalse);
    });

    test('should clear guide selection when topic changes', () {
      final readingFlowNotifier = container.read(readingFlowProvider.notifier);

      // Set initial state with guide
      readingFlowNotifier.setTopic(ReadingTopic.work);
      readingFlowNotifier.setSpreadType(SpreadType.singleCard);
      readingFlowNotifier.setSelectedGuide(GuideType.mentor);

      // Verify initial state
      var state = container.read(readingFlowProvider);
      expect(state.selectedGuide, equals(GuideType.mentor));

      // Change topic - should clear guide and spread
      readingFlowNotifier.setTopic(ReadingTopic.social);

      state = container.read(readingFlowProvider);
      expect(state.topic, equals(ReadingTopic.social));
      expect(state.selectedGuide, isNull);
      expect(state.spreadType, isNull);
    });

    test('should reset reading flow state', () {
      final readingFlowNotifier = container.read(readingFlowProvider.notifier);

      // Set all values
      readingFlowNotifier.setTopic(ReadingTopic.self);
      readingFlowNotifier.setSpreadType(SpreadType.celtic);
      readingFlowNotifier.setSelectedGuide(GuideType.visionary);
      readingFlowNotifier.setCustomTitle('Test Reading');

      // Reset
      readingFlowNotifier.reset();

      final state = container.read(readingFlowProvider);
      expect(state.topic, isNull);
      expect(state.spreadType, isNull);
      expect(state.selectedGuide, isNull);
      expect(state.customTitle, isNull);
    });

    test('should copy reading flow state with guide changes', () {
      final initialState = ReadingFlowState(
        topic: ReadingTopic.love,
        spreadType: SpreadType.relationship,
        selectedGuide: GuideType.healer,
        customTitle: 'Love Reading',
      );

      final newState = initialState.copyWith(
        selectedGuide: GuideType.visionary,
      );

      expect(newState.topic, equals(ReadingTopic.love));
      expect(newState.spreadType, equals(SpreadType.relationship));
      expect(newState.selectedGuide, equals(GuideType.visionary));
      expect(newState.customTitle, equals('Love Reading'));
    });

    test('should clear guide selection with copyWith', () {
      final initialState = ReadingFlowState(
        topic: ReadingTopic.work,
        spreadType: SpreadType.career,
        selectedGuide: GuideType.mentor,
      );

      final newState = initialState.copyWith(clearSelectedGuide: true);

      expect(newState.topic, equals(ReadingTopic.work));
      expect(newState.spreadType, equals(SpreadType.career));
      expect(newState.selectedGuide, isNull);
    });
  });
}
