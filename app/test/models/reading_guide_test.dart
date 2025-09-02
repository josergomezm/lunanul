import 'package:flutter_test/flutter_test.dart';
import 'package:lunanul/models/models.dart';

void main() {
  group('Reading Model with Guide Selection', () {
    test('should create reading with selected guide', () {
      final reading = Reading(
        id: 'test_reading_1',
        createdAt: DateTime.now(),
        topic: ReadingTopic.self,
        spreadType: SpreadType.singleCard,
        cards: [],
        selectedGuide: GuideType.sage,
      );

      expect(reading.selectedGuide, equals(GuideType.sage));
    });

    test('should create reading without selected guide (null)', () {
      final reading = Reading(
        id: 'test_reading_2',
        createdAt: DateTime.now(),
        topic: ReadingTopic.love,
        spreadType: SpreadType.threeCard,
        cards: [],
        selectedGuide: null,
      );

      expect(reading.selectedGuide, isNull);
    });

    test('should copy reading with new guide selection', () {
      final originalReading = Reading(
        id: 'test_reading_3',
        createdAt: DateTime.now(),
        topic: ReadingTopic.work,
        spreadType: SpreadType.singleCard,
        cards: [],
        selectedGuide: GuideType.mentor,
      );

      final copiedReading = originalReading.copyWith(
        selectedGuide: GuideType.visionary,
      );

      expect(copiedReading.selectedGuide, equals(GuideType.visionary));
      expect(originalReading.selectedGuide, equals(GuideType.mentor));
    });

    test('should serialize and deserialize reading with guide', () {
      final originalReading = Reading(
        id: 'test_reading_4',
        createdAt: DateTime.parse('2024-01-01T12:00:00Z'),
        topic: ReadingTopic.social,
        spreadType: SpreadType.singleCard,
        cards: [],
        selectedGuide: GuideType.healer,
      );

      final json = originalReading.toJson();
      final deserializedReading = Reading.fromJson(json);

      expect(deserializedReading.selectedGuide, equals(GuideType.healer));
      expect(deserializedReading.id, equals(originalReading.id));
      expect(deserializedReading.topic, equals(originalReading.topic));
    });

    test('should handle backward compatibility with null guide in JSON', () {
      final jsonWithoutGuide = {
        'id': 'test_reading_5',
        'createdAt': '2024-01-01T12:00:00Z',
        'topic': 'self',
        'spreadType': 'singleCard',
        'cards': [],
        'userReflection': null,
        'isSaved': false,
        'title': null,
        // Note: selectedGuide is intentionally omitted
      };

      final reading = Reading.fromJson(jsonWithoutGuide);

      expect(reading.selectedGuide, isNull);
      expect(reading.id, equals('test_reading_5'));
    });

    test('should handle JSON with explicit null guide', () {
      final jsonWithNullGuide = {
        'id': 'test_reading_6',
        'createdAt': '2024-01-01T12:00:00Z',
        'topic': 'love',
        'spreadType': 'threeCard',
        'cards': [],
        'userReflection': null,
        'isSaved': false,
        'title': null,
        'selectedGuide': null,
      };

      final reading = Reading.fromJson(jsonWithNullGuide);

      expect(reading.selectedGuide, isNull);
      expect(reading.id, equals('test_reading_6'));
    });

    test('should serialize null guide correctly', () {
      final reading = Reading(
        id: 'test_reading_7',
        createdAt: DateTime.parse('2024-01-01T12:00:00Z'),
        topic: ReadingTopic.work,
        spreadType: SpreadType.singleCard,
        cards: [],
        selectedGuide: null,
      );

      final json = reading.toJson();

      expect(json['selectedGuide'], isNull);
    });

    test('should convert guide enum to string in JSON', () {
      final reading = Reading(
        id: 'test_reading_8',
        createdAt: DateTime.parse('2024-01-01T12:00:00Z'),
        topic: ReadingTopic.self,
        spreadType: SpreadType.singleCard,
        cards: [],
        selectedGuide: GuideType.sage,
      );

      final json = reading.toJson();

      expect(json['selectedGuide'], equals('sage'));
    });
  });
}
