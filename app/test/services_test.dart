import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:lunanul/services/card_service.dart';
import 'package:lunanul/services/mock_reading_service.dart';
import 'package:lunanul/services/mock_user_service.dart';
import 'package:lunanul/models/enums.dart';

void main() {
  group('Services Tests', () {
    setUpAll(() {
      // Initialize Flutter binding for tests
      TestWidgetsFlutterBinding.ensureInitialized();

      // Mock the asset loading for tests
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(const MethodChannel('flutter/assets'), (
            MethodCall methodCall,
          ) async {
            if (methodCall.method == 'loadString') {
              // Return a minimal mock JSON for testing
              return '''
            {
              "cards": [
                {
                  "id": "fool",
                  "name": "The Fool",
                  "suit": "majorArcana",
                  "number": 0,
                  "imageUrl": "https://api.lunanul.com/cards/major/fool.png",
                  "keywords": ["new beginnings", "innocence"],
                  "uprightMeaning": "New beginnings and innocence",
                  "reversedMeaning": "Recklessness and poor judgment"
                }
              ]
            }
            ''';
            }
            return null;
          });
    });

    group('CardService', () {
      test('should load cards successfully', () async {
        final cardService = CardService.instance;
        final cards = await cardService.getAllCards();

        expect(cards, isNotEmpty);
        expect(cards.first.name, equals('The Fool'));
        expect(cards.first.id, equals('fool'));
      });

      test('should draw single card', () async {
        final cardService = CardService.instance;
        final card = await cardService.drawSingleCard();

        expect(card, isNotNull);
        expect(card.name, isNotEmpty);
      });

      test('should get card of the day consistently', () async {
        final cardService = CardService.instance;
        final date = DateTime(2024, 1, 1);

        final card1 = await cardService.getCardOfTheDay(date: date);
        final card2 = await cardService.getCardOfTheDay(date: date);

        expect(card1.id, equals(card2.id));
        expect(card1.isReversed, equals(card2.isReversed));
      });
    });

    group('MockReadingService', () {
      test('should create reading successfully', () async {
        final readingService = MockReadingService.instance;
        final reading = await readingService.createReading(
          topic: ReadingTopic.self,
          spreadType: SpreadType.singleCard,
        );

        expect(reading, isNotNull);
        expect(reading.topic, equals(ReadingTopic.self));
        expect(reading.spreadType, equals(SpreadType.singleCard));
        expect(reading.cards, hasLength(1));
        expect(reading.cards.first.aiInterpretation, isNotEmpty);
      });

      test('should generate AI interpretation', () async {
        final readingService = MockReadingService.instance;
        final cardService = CardService.instance;

        final card = await cardService.drawSingleCard();
        final interpretation = await readingService
            .generateManualInterpretation(card: card, topic: ReadingTopic.love);

        expect(interpretation, isNotEmpty);
        expect(interpretation, contains(card.name));
      });

      test('should generate daily affirmation', () async {
        final readingService = MockReadingService.instance;
        final cardService = CardService.instance;

        final card = await cardService.drawSingleCard();
        final affirmation = await readingService.generateDailyAffirmation(card);

        expect(affirmation, isNotEmpty);
        expect(affirmation, startsWith('I '));
      });
    });

    group('MockUserService', () {
      test('should create and get current user', () async {
        final userService = MockUserService.instance;
        final user = await userService.getCurrentUser();

        expect(user, isNotNull);
        expect(user.name, isNotEmpty);
        expect(user.email, contains('@'));
        expect(user.id, isNotEmpty);
      });

      test('should save and retrieve readings', () async {
        final userService = MockUserService.instance;
        final readingService = MockReadingService.instance;

        final reading = await readingService.createReading(
          topic: ReadingTopic.work,
          spreadType: SpreadType.threeCard,
        );

        await userService.saveReading(reading);
        final savedReadings = await userService.getSavedReadings();

        expect(savedReadings, hasLength(1));
        expect(savedReadings.first.id, equals(reading.id));
        expect(savedReadings.first.isSaved, isTrue);
      });

      test('should generate daily journal prompt', () async {
        final userService = MockUserService.instance;
        final prompt = await userService.getDailyJournalPrompt();

        expect(prompt, isNotEmpty);
        expect(prompt, endsWith('?'));
      });

      test('should get user statistics', () async {
        final userService = MockUserService.instance;
        final readingService = MockReadingService.instance;

        // Save a few readings
        for (int i = 0; i < 3; i++) {
          final reading = await readingService.createReading(
            topic: ReadingTopic.values[i % ReadingTopic.values.length],
            spreadType: SpreadType.singleCard,
          );
          await userService.saveReading(reading);
        }

        final stats = await userService.getUserStatistics();

        expect(stats['totalReadings'], equals(3));
        expect(stats.containsKey('mostCommonTopic'), isTrue);
        expect(stats.containsKey('averageReadingsPerWeek'), isTrue);
      });
    });
  });
}
