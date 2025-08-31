import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lunanul/models/reading.dart';
import 'package:lunanul/models/enums.dart';
import 'package:lunanul/models/card_position.dart';
import 'package:lunanul/models/tarot_card.dart';
import 'package:lunanul/utils/date_time_localizations.dart';

void main() {
  setUpAll(() async {
    // Initialize locale data before running tests
    await DateTimeLocalizations.initializeLocaleData();
  });

  group('Date Time Integration Tests', () {
    test('Reading model should use localized dates', () {
      // Create a test reading
      final testCard = TarotCard(
        id: 'test',
        name: 'Test Card',
        suit: TarotSuit.majorArcana,
        number: 0,
        imageUrl: 'test_image.jpg',
        keywords: ['test'],
        uprightMeaning: 'Test meaning',
        reversedMeaning: 'Test reversed',
        isReversed: false,
      );

      final testReading = Reading(
        id: 'test-reading',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        topic: ReadingTopic.self,
        spreadType: SpreadType.singleCard,
        cards: [
          CardPosition(
            card: testCard,
            positionName: 'Test Position',
            positionMeaning: 'Test position meaning',
            order: 0,
            aiInterpretation: 'Test interpretation',
          ),
        ],
      );

      // Test English locale
      const enLocale = Locale('en');
      final enDate = testReading.getFormattedDate(enLocale);
      expect(enDate, 'yesterday');

      // Test Spanish locale
      const esLocale = Locale('es');
      final esDate = testReading.getFormattedDate(esLocale);
      expect(esDate, 'ayer');
    });

    test('Date formatting should work for different time periods', () {
      final now = DateTime.now();
      final today = now;
      final yesterday = now.subtract(const Duration(days: 1));
      final threeDaysAgo = now.subtract(const Duration(days: 3));

      // English
      const enLocale = Locale('en');
      expect(DateTimeLocalizations.formatReadingDate(today, enLocale), 'today');
      expect(
        DateTimeLocalizations.formatReadingDate(yesterday, enLocale),
        'yesterday',
      );
      expect(
        DateTimeLocalizations.formatReadingDate(threeDaysAgo, enLocale),
        '3 days ago',
      );

      // Spanish
      const esLocale = Locale('es');
      expect(DateTimeLocalizations.formatReadingDate(today, esLocale), 'hoy');
      expect(
        DateTimeLocalizations.formatReadingDate(yesterday, esLocale),
        'ayer',
      );
      expect(
        DateTimeLocalizations.formatReadingDate(threeDaysAgo, esLocale),
        'hace 3 días',
      );
    });

    test('Time-based greetings should be localized', () {
      const enLocale = Locale('en');
      const esLocale = Locale('es');

      final morningTime = DateTime(2024, 1, 1, 9, 0);
      final afternoonTime = DateTime(2024, 1, 1, 15, 0);
      final eveningTime = DateTime(2024, 1, 1, 20, 0);

      // English greetings
      expect(
        DateTimeLocalizations.getTimeBasedGreeting(morningTime, enLocale),
        'Good morning',
      );
      expect(
        DateTimeLocalizations.getTimeBasedGreeting(afternoonTime, enLocale),
        'Good afternoon',
      );
      expect(
        DateTimeLocalizations.getTimeBasedGreeting(eveningTime, enLocale),
        'Good evening',
      );

      // Spanish greetings
      expect(
        DateTimeLocalizations.getTimeBasedGreeting(morningTime, esLocale),
        'Buenos días',
      );
      expect(
        DateTimeLocalizations.getTimeBasedGreeting(afternoonTime, esLocale),
        'Buenas tardes',
      );
      expect(
        DateTimeLocalizations.getTimeBasedGreeting(eveningTime, esLocale),
        'Buenas noches',
      );
    });

    test('Activity time formatting should be localized', () {
      final now = DateTime.now();
      final fiveMinutesAgo = now.subtract(const Duration(minutes: 5));
      final twoHoursAgo = now.subtract(const Duration(hours: 2));
      final yesterday = now.subtract(const Duration(days: 1));

      // English
      const enLocale = Locale('en');
      expect(
        DateTimeLocalizations.getActivityTime(fiveMinutesAgo, enLocale),
        'Active 5m ago',
      );
      expect(
        DateTimeLocalizations.getActivityTime(twoHoursAgo, enLocale),
        'Active 2h ago',
      );
      expect(
        DateTimeLocalizations.getActivityTime(yesterday, enLocale),
        'Active yesterday',
      );

      // Spanish
      const esLocale = Locale('es');
      expect(
        DateTimeLocalizations.getActivityTime(fiveMinutesAgo, esLocale),
        'Activo hace 5m',
      );
      expect(
        DateTimeLocalizations.getActivityTime(twoHoursAgo, esLocale),
        'Activo hace 2h',
      );
      expect(
        DateTimeLocalizations.getActivityTime(yesterday, esLocale),
        'Activo ayer',
      );
    });

    test('Date formatters should work correctly', () {
      final testDate = DateTime(2024, 3, 15, 14, 30);

      // English formatters
      const enLocale = Locale('en');
      final enDateFormatter = DateTimeLocalizations.getDateFormatter(enLocale);
      final enShortDateFormatter = DateTimeLocalizations.getShortDateFormatter(
        enLocale,
      );
      final enTimeFormatter = DateTimeLocalizations.getTimeFormatter(enLocale);

      expect(enDateFormatter.format(testDate), 'March 15, 2024');
      expect(enShortDateFormatter.format(testDate), '3/15/2024');
      expect(enTimeFormatter.format(testDate), '2:30 PM');

      // Spanish formatters
      const esLocale = Locale('es');
      final esDateFormatter = DateTimeLocalizations.getDateFormatter(esLocale);
      final esShortDateFormatter = DateTimeLocalizations.getShortDateFormatter(
        esLocale,
      );
      final esTimeFormatter = DateTimeLocalizations.getTimeFormatter(esLocale);

      expect(esDateFormatter.format(testDate), '15 de marzo de 2024');
      expect(esShortDateFormatter.format(testDate), '15/3/2024');
      expect(esTimeFormatter.format(testDate), '14:30');
    });

    test('Journal date formatting should be localized', () {
      final now = DateTime.now();
      final today = now;
      final yesterday = now.subtract(const Duration(days: 1));

      // English
      const enLocale = Locale('en');
      expect(DateTimeLocalizations.formatJournalDate(today, enLocale), 'Today');
      expect(
        DateTimeLocalizations.formatJournalDate(yesterday, enLocale),
        'Yesterday',
      );

      // Spanish
      const esLocale = Locale('es');
      expect(DateTimeLocalizations.formatJournalDate(today, esLocale), 'Hoy');
      expect(
        DateTimeLocalizations.formatJournalDate(yesterday, esLocale),
        'Ayer',
      );
    });
  });
}
