import 'package:flutter_test/flutter_test.dart';
import 'package:lunanul/services/mock_reading_service.dart';
import 'package:lunanul/services/mock_user_service.dart';
import 'package:lunanul/models/enums.dart';
import 'package:lunanul/models/tarot_card.dart';

void main() {
  group('Simple Services Tests', () {
    test('MockReadingService should generate AI interpretation', () async {
      final readingService = MockReadingService.instance;

      // Create a mock card
      final card = TarotCard(
        id: 'fool',
        name: 'The Fool',
        suit: TarotSuit.majorArcana,
        number: 0,
        imageUrl: 'https://api.lunanul.com/cards/major/fool.png',
        keywords: ['new beginnings', 'innocence'],
        uprightMeaning: 'New beginnings and innocence',
        reversedMeaning: 'Recklessness and poor judgment',
      );

      final interpretation = await readingService.generateManualInterpretation(
        card: card,
        topic: ReadingTopic.love,
      );

      expect(interpretation, isNotEmpty);
      expect(interpretation, contains(card.name));
    });

    test('MockReadingService should generate daily affirmation', () async {
      final readingService = MockReadingService.instance;

      final card = TarotCard(
        id: 'fool',
        name: 'The Fool',
        suit: TarotSuit.majorArcana,
        number: 0,
        imageUrl: 'https://api.lunanul.com/cards/major/fool.png',
        keywords: ['new beginnings', 'innocence'],
        uprightMeaning: 'New beginnings and innocence',
        reversedMeaning: 'Recklessness and poor judgment',
      );

      final affirmation = await readingService.generateDailyAffirmation(card);

      expect(affirmation, isNotEmpty);
      expect(affirmation, startsWith('I '));
    });

    test('MockUserService should create and get current user', () async {
      final userService = MockUserService.instance;
      final user = await userService.getCurrentUser();

      expect(user, isNotNull);
      expect(user.name, isNotEmpty);
      expect(user.email, contains('@'));
      expect(user.id, isNotEmpty);
    });

    test('MockUserService should generate daily journal prompt', () async {
      final userService = MockUserService.instance;
      final prompt = await userService.getDailyJournalPrompt();

      expect(prompt, isNotEmpty);
      expect(prompt, endsWith('?'));
    });

    test('MockUserService should generate invite code', () async {
      final userService = MockUserService.instance;
      final inviteCode = await userService.generateInviteCode();

      expect(inviteCode, isNotEmpty);
      expect(inviteCode, startsWith('LUN-'));
    });
  });
}
