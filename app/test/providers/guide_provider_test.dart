import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lunanul/providers/guide_provider.dart';
import 'package:lunanul/models/enums.dart';

void main() {
  group('Guide Providers', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('guideServiceProvider provides GuideService instance', () {
      final guideService = container.read(guideServiceProvider);
      expect(guideService, isNotNull);
    });

    test('availableGuidesProvider returns all guides', () {
      final guides = container.read(availableGuidesProvider);
      expect(guides, hasLength(4));
      expect(guides.map((g) => g.type), containsAll(GuideType.values));
    });

    test('selectedGuideProvider starts as null', () {
      final selectedGuide = container.read(selectedGuideProvider);
      expect(selectedGuide, isNull);
    });

    test('selectedGuideProvider can be updated', () {
      final notifier = container.read(selectedGuideProvider.notifier);
      notifier.state = GuideType.sage;

      final selectedGuide = container.read(selectedGuideProvider);
      expect(selectedGuide, equals(GuideType.sage));
    });

    test('guideByTypeProvider returns correct guide', () {
      final sageGuide = container.read(guideByTypeProvider(GuideType.sage));
      expect(sageGuide, isNotNull);
      expect(sageGuide!.type, equals(GuideType.sage));
      expect(sageGuide.name, equals('Zian'));
    });

    test('recommendedGuidesProvider returns guides for topic', () {
      final recommendedForSelf = container.read(
        recommendedGuidesProvider(ReadingTopic.self),
      );
      expect(recommendedForSelf, isNotEmpty);
      expect(recommendedForSelf, contains(GuideType.sage));
    });

    test('bestGuideForTopicProvider returns best guide', () {
      final bestForWork = container.read(
        bestGuideForTopicProvider(ReadingTopic.work),
      );
      expect(bestForWork, isNotNull);
    });

    test('hasSelectedGuideProvider reflects selection state', () {
      expect(container.read(hasSelectedGuideProvider), isFalse);

      container.read(selectedGuideProvider.notifier).state = GuideType.healer;
      expect(container.read(hasSelectedGuideProvider), isTrue);
    });

    test('currentGuideProvider returns selected guide object', () {
      expect(container.read(currentGuideProvider), isNull);

      container.read(selectedGuideProvider.notifier).state =
          GuideType.visionary;
      final currentGuide = container.read(currentGuideProvider);

      expect(currentGuide, isNotNull);
      expect(currentGuide!.type, equals(GuideType.visionary));
      expect(currentGuide.name, equals('Elara'));
    });
  });

  group('GuideSelectionNotifier', () {
    late ProviderContainer container;
    late GuideSelectionNotifier notifier;

    setUp(() {
      container = ProviderContainer();
      notifier = container.read(guideSelectionProvider.notifier);
    });

    tearDown(() {
      container.dispose();
    });

    test('starts with initial state', () {
      final state = container.read(guideSelectionProvider);
      expect(state.currentTopic, isNull);
      expect(state.selectedGuide, isNull);
      expect(state.recommendedGuides, isEmpty);
      expect(state.suggestedGuide, isNull);
    });

    test('setReadingTopic updates state with recommendations', () {
      notifier.setReadingTopic(ReadingTopic.love);

      final state = container.read(guideSelectionProvider);
      expect(state.currentTopic, equals(ReadingTopic.love));
      expect(state.recommendedGuides, isNotEmpty);
      expect(state.suggestedGuide, isNotNull);
    });

    test('selectGuide updates selected guide', () {
      notifier.selectGuide(GuideType.mentor);

      final state = container.read(guideSelectionProvider);
      expect(state.selectedGuide, equals(GuideType.mentor));
    });

    test('clearSelection clears selected guide', () {
      notifier.selectGuide(GuideType.sage);
      notifier.clearSelection();

      final state = container.read(guideSelectionProvider);
      expect(state.selectedGuide, isNull);
    });

    test('reset returns to initial state', () {
      notifier.setReadingTopic(ReadingTopic.work);
      notifier.selectGuide(GuideType.mentor);
      notifier.reset();

      final state = container.read(guideSelectionProvider);
      expect(state.currentTopic, isNull);
      expect(state.selectedGuide, isNull);
      expect(state.recommendedGuides, isEmpty);
      expect(state.suggestedGuide, isNull);
    });

    test('canProceedWithReading returns correct value', () {
      expect(notifier.canProceedWithReading, isFalse);

      notifier.selectGuide(GuideType.healer);
      expect(notifier.canProceedWithReading, isTrue);
    });
  });
}
