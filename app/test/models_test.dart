import 'package:flutter_test/flutter_test.dart';
import 'package:lunanul/models/models.dart';

void main() {
  group('Data Models Tests', () {
    test('TarotCard model should serialize and deserialize correctly', () {
      final card = TarotCard(
        id: 'fool',
        name: 'The Fool',
        suit: TarotSuit.majorArcana,
        number: 0,
        imageUrl: 'https://example.com/fool.png',
        keywords: ['new beginnings', 'innocence'],
        uprightMeaning: 'New beginnings and innocence',
        reversedMeaning: 'Recklessness and naivety',
        isReversed: false,
      );

      final json = card.toJson();
      final cardFromJson = TarotCard.fromJson(json);

      expect(cardFromJson.id, equals(card.id));
      expect(cardFromJson.name, equals(card.name));
      expect(cardFromJson.suit, equals(card.suit));
      expect(cardFromJson.isReversed, equals(card.isReversed));
      expect(cardFromJson.isValid, isTrue);
    });

    test('Reading model should handle card positions correctly', () {
      final card = TarotCard(
        id: 'fool',
        name: 'The Fool',
        suit: TarotSuit.majorArcana,
        imageUrl: 'https://example.com/fool.png',
        keywords: ['new beginnings'],
        uprightMeaning: 'New beginnings',
        reversedMeaning: 'Recklessness',
      );

      final cardPosition = CardPosition(
        card: card,
        positionName: 'Present',
        positionMeaning: 'Your current situation',
        aiInterpretation: 'You are at the beginning of a new journey',
        order: 0,
      );

      final reading = Reading(
        id: 'reading-1',
        createdAt: DateTime.now(),
        topic: ReadingTopic.self,
        spreadType: SpreadType.singleCard,
        cards: [cardPosition],
        isSaved: true,
      );

      expect(reading.isValid, isTrue);
      expect(reading.cards.length, equals(1));
      expect(reading.displayTitle, equals('Self - Single Card'));
      expect(reading.canBeShared, isTrue);
    });

    test('User model should handle preferences correctly', () {
      final user = User(
        id: 'user-1',
        name: 'Test User',
        createdAt: DateTime.now(),
        lastActiveAt: DateTime.now(),
      );

      final userWithPrefs = user.setPreference('theme', 'dark');
      expect(userWithPrefs.getPreference('theme', 'light'), equals('dark'));
      expect(
        userWithPrefs.getPreference('nonexistent', 'default'),
        equals('default'),
      );

      final userWithoutPref = userWithPrefs.removePreference('theme');
      expect(userWithoutPref.getPreference('theme', 'light'), equals('light'));
    });

    test('Enums should convert to and from strings correctly', () {
      expect(ReadingTopic.fromString('self'), equals(ReadingTopic.self));
      expect(ReadingTopic.fromString('invalid'), equals(ReadingTopic.self));

      expect(SpreadType.fromString('threeCard'), equals(SpreadType.threeCard));
      expect(SpreadType.fromString('invalid'), equals(SpreadType.singleCard));

      expect(TarotSuit.fromString('cups'), equals(TarotSuit.cups));
      expect(TarotSuit.fromString('invalid'), equals(TarotSuit.majorArcana));
    });

    test('SpreadType should return correct spreads by topic', () {
      final selfSpreads = SpreadType.getSpreadsByTopic(ReadingTopic.self);
      expect(selfSpreads, contains(SpreadType.singleCard));
      expect(selfSpreads, contains(SpreadType.threeCard));
      expect(selfSpreads, contains(SpreadType.celtic));

      final loveSpreads = SpreadType.getSpreadsByTopic(ReadingTopic.love);
      expect(loveSpreads, contains(SpreadType.relationship));
      expect(loveSpreads, isNot(contains(SpreadType.career)));
    });
  });
}
