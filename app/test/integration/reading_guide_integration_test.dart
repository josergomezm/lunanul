import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lunanul/models/models.dart';
import 'package:lunanul/providers/reading_provider.dart';

void main() {
  group('Reading Guide Integration Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('complete reading creation flow with guide selection', () async {
      final readingFlowNotifier = container.read(readingFlowProvider.notifier);

      // Step 1: Set topic
      readingFlowNotifier.setTopic(ReadingTopic.self);

      // Step 2: Set spread type
      readingFlowNotifier.setSpreadType(SpreadType.singleCard);

      // Step 3: Set guide
      readingFlowNotifier.setSelectedGuide(GuideType.sage);

      // Step 4: Set custom title
      readingFlowNotifier.setCustomTitle('My Spiritual Journey');

      // Verify flow state
      final flowState = container.read(readingFlowProvider);
      expect(flowState.topic, equals(ReadingTopic.self));
      expect(flowState.spreadType, equals(SpreadType.singleCard));
      expect(flowState.selectedGuide, equals(GuideType.sage));
      expect(flowState.customTitle, equals('My Spiritual Journey'));
      expect(readingFlowNotifier.canCreateReading, isTrue);
      expect(readingFlowNotifier.hasGuideSelection, isTrue);
    });

    test('reading serialization roundtrip with guide', () {
      // Create a reading with guide
      final originalReading = Reading(
        id: 'integration_test_1',
        createdAt: DateTime.parse('2024-01-15T10:30:00Z'),
        topic: ReadingTopic.love,
        spreadType: SpreadType.relationship,
        cards: [],
        selectedGuide: GuideType.healer,
        title: 'Love Guidance',
        isSaved: true,
      );

      // Serialize to JSON
      final json = originalReading.toJson();

      // Verify JSON structure
      expect(json['selectedGuide'], equals('healer'));
      expect(json['title'], equals('Love Guidance'));
      expect(json['topic'], equals('love'));

      // Deserialize back to Reading
      final deserializedReading = Reading.fromJson(json);

      // Verify all fields match
      expect(deserializedReading.id, equals(originalReading.id));
      expect(deserializedReading.createdAt, equals(originalReading.createdAt));
      expect(deserializedReading.topic, equals(originalReading.topic));
      expect(
        deserializedReading.spreadType,
        equals(originalReading.spreadType),
      );
      expect(
        deserializedReading.selectedGuide,
        equals(originalReading.selectedGuide),
      );
      expect(deserializedReading.title, equals(originalReading.title));
      expect(deserializedReading.isSaved, equals(originalReading.isSaved));
    });

    test('backward compatibility with legacy reading data', () {
      // Simulate old reading data without guide field
      final legacyJson = {
        'id': 'legacy_reading_1',
        'createdAt': '2023-12-01T15:45:00Z',
        'topic': 'work',
        'spreadType': 'career',
        'cards': [],
        'userReflection': 'This was helpful',
        'isSaved': true,
        'title': 'Career Guidance',
        // Note: selectedGuide field is missing (legacy data)
      };

      // Should deserialize successfully with null guide
      final reading = Reading.fromJson(legacyJson);

      expect(reading.id, equals('legacy_reading_1'));
      expect(reading.topic, equals(ReadingTopic.work));
      expect(reading.spreadType, equals(SpreadType.career));
      expect(reading.selectedGuide, isNull);
      expect(reading.title, equals('Career Guidance'));
      expect(reading.userReflection, equals('This was helpful'));
      expect(reading.isSaved, isTrue);
    });

    test('guide enum conversion edge cases', () {
      // Test all guide types
      for (final guideType in GuideType.values) {
        final reading = Reading(
          id: 'test_${guideType.name}',
          createdAt: DateTime.now(),
          topic: ReadingTopic.self,
          spreadType: SpreadType.singleCard,
          cards: [],
          selectedGuide: guideType,
        );

        final json = reading.toJson();
        final deserializedReading = Reading.fromJson(json);

        expect(deserializedReading.selectedGuide, equals(guideType));
      }
    });

    test('reading flow state transitions with guide selection', () {
      final readingFlowNotifier = container.read(readingFlowProvider.notifier);

      // Start with empty state
      var state = container.read(readingFlowProvider);
      expect(state.selectedGuide, isNull);

      // Set topic (should clear guide)
      readingFlowNotifier.setTopic(ReadingTopic.love);
      state = container.read(readingFlowProvider);
      expect(state.topic, equals(ReadingTopic.love));
      expect(state.selectedGuide, isNull);

      // Set guide
      readingFlowNotifier.setSelectedGuide(GuideType.healer);
      state = container.read(readingFlowProvider);
      expect(state.selectedGuide, equals(GuideType.healer));

      // Change topic (should clear guide and spread)
      readingFlowNotifier.setTopic(ReadingTopic.work);
      state = container.read(readingFlowProvider);
      expect(state.topic, equals(ReadingTopic.work));
      expect(state.selectedGuide, isNull);
      expect(state.spreadType, isNull);

      // Set new guide for work topic
      readingFlowNotifier.setSelectedGuide(GuideType.mentor);
      state = container.read(readingFlowProvider);
      expect(state.selectedGuide, equals(GuideType.mentor));
    });
  });
}
