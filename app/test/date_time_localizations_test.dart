import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:lunanul/utils/date_time_localizations.dart';

void main() {
  setUpAll(() async {
    // Initialize locale data before running tests
    await DateTimeLocalizations.initializeLocaleData();
  });

  group('DateTimeLocalizations', () {
    test('should format dates correctly for English locale', () {
      const locale = Locale('en');
      final testDate = DateTime(2024, 3, 15, 14, 30);

      final dateFormatter = DateTimeLocalizations.getDateFormatter(locale);
      final shortDateFormatter = DateTimeLocalizations.getShortDateFormatter(
        locale,
      );
      final timeFormatter = DateTimeLocalizations.getTimeFormatter(locale);

      expect(dateFormatter.format(testDate), 'March 15, 2024');
      expect(shortDateFormatter.format(testDate), '3/15/2024');
      expect(timeFormatter.format(testDate), '2:30 PM');
    });

    test('should format dates correctly for Spanish locale', () {
      const locale = Locale('es');
      final testDate = DateTime(2024, 3, 15, 14, 30);

      final dateFormatter = DateTimeLocalizations.getDateFormatter(locale);
      final shortDateFormatter = DateTimeLocalizations.getShortDateFormatter(
        locale,
      );
      final timeFormatter = DateTimeLocalizations.getTimeFormatter(locale);

      expect(dateFormatter.format(testDate), '15 de marzo de 2024');
      expect(shortDateFormatter.format(testDate), '15/3/2024');
      expect(timeFormatter.format(testDate), '14:30');
    });

    test('should return correct relative dates for English', () {
      const locale = Locale('en');
      final now = DateTime.now();
      final today = now;
      final yesterday = now.subtract(const Duration(days: 1));
      final threeDaysAgo = now.subtract(const Duration(days: 3));
      final oneWeekAgo = now.subtract(const Duration(days: 7));

      expect(DateTimeLocalizations.getRelativeDate(today, locale), 'today');
      expect(
        DateTimeLocalizations.getRelativeDate(yesterday, locale),
        'yesterday',
      );
      expect(
        DateTimeLocalizations.getRelativeDate(threeDaysAgo, locale),
        '3 days ago',
      );

      // For dates older than a week, it should return formatted date
      final result = DateTimeLocalizations.getRelativeDate(oneWeekAgo, locale);
      expect(result, isNot(contains('days ago')));
    });

    test('should return correct relative dates for Spanish', () {
      const locale = Locale('es');
      final now = DateTime.now();
      final today = now;
      final yesterday = now.subtract(const Duration(days: 1));
      final threeDaysAgo = now.subtract(const Duration(days: 3));

      expect(DateTimeLocalizations.getRelativeDate(today, locale), 'hoy');
      expect(DateTimeLocalizations.getRelativeDate(yesterday, locale), 'ayer');
      expect(
        DateTimeLocalizations.getRelativeDate(threeDaysAgo, locale),
        'hace 3 días',
      );
    });

    test('should return correct activity time for English', () {
      const locale = Locale('en');
      final now = DateTime.now();
      final fiveMinutesAgo = now.subtract(const Duration(minutes: 5));
      final twoHoursAgo = now.subtract(const Duration(hours: 2));
      final yesterday = now.subtract(const Duration(days: 1));
      final threeDaysAgo = now.subtract(const Duration(days: 3));

      expect(
        DateTimeLocalizations.getActivityTime(fiveMinutesAgo, locale),
        'Active 5m ago',
      );
      expect(
        DateTimeLocalizations.getActivityTime(twoHoursAgo, locale),
        'Active 2h ago',
      );
      expect(
        DateTimeLocalizations.getActivityTime(yesterday, locale),
        'Active yesterday',
      );
      expect(
        DateTimeLocalizations.getActivityTime(threeDaysAgo, locale),
        'Active 3 days ago',
      );
    });

    test('should return correct activity time for Spanish', () {
      const locale = Locale('es');
      final now = DateTime.now();
      final fiveMinutesAgo = now.subtract(const Duration(minutes: 5));
      final twoHoursAgo = now.subtract(const Duration(hours: 2));
      final yesterday = now.subtract(const Duration(days: 1));
      final threeDaysAgo = now.subtract(const Duration(days: 3));

      expect(
        DateTimeLocalizations.getActivityTime(fiveMinutesAgo, locale),
        'Activo hace 5m',
      );
      expect(
        DateTimeLocalizations.getActivityTime(twoHoursAgo, locale),
        'Activo hace 2h',
      );
      expect(
        DateTimeLocalizations.getActivityTime(yesterday, locale),
        'Activo ayer',
      );
      expect(
        DateTimeLocalizations.getActivityTime(threeDaysAgo, locale),
        'Activo hace 3 días',
      );
    });

    test('should return correct time-based greetings', () {
      const enLocale = Locale('en');
      const esLocale = Locale('es');

      final morning = DateTime(2024, 1, 1, 9, 0);
      final afternoon = DateTime(2024, 1, 1, 15, 0);
      final evening = DateTime(2024, 1, 1, 20, 0);

      // English greetings
      expect(
        DateTimeLocalizations.getTimeBasedGreeting(morning, enLocale),
        'Good morning',
      );
      expect(
        DateTimeLocalizations.getTimeBasedGreeting(afternoon, enLocale),
        'Good afternoon',
      );
      expect(
        DateTimeLocalizations.getTimeBasedGreeting(evening, enLocale),
        'Good evening',
      );

      // Spanish greetings
      expect(
        DateTimeLocalizations.getTimeBasedGreeting(morning, esLocale),
        'Buenos días',
      );
      expect(
        DateTimeLocalizations.getTimeBasedGreeting(afternoon, esLocale),
        'Buenas tardes',
      );
      expect(
        DateTimeLocalizations.getTimeBasedGreeting(evening, esLocale),
        'Buenas noches',
      );
    });

    test('should format reading dates correctly', () {
      const enLocale = Locale('en');
      const esLocale = Locale('es');
      final now = DateTime.now();
      final today = now;
      final yesterday = now.subtract(const Duration(days: 1));

      expect(DateTimeLocalizations.formatReadingDate(today, enLocale), 'today');
      expect(
        DateTimeLocalizations.formatReadingDate(yesterday, enLocale),
        'yesterday',
      );

      expect(DateTimeLocalizations.formatReadingDate(today, esLocale), 'hoy');
      expect(
        DateTimeLocalizations.formatReadingDate(yesterday, esLocale),
        'ayer',
      );
    });

    test('should format journal dates correctly', () {
      const enLocale = Locale('en');
      const esLocale = Locale('es');
      final now = DateTime.now();
      final today = now;
      final yesterday = now.subtract(const Duration(days: 1));

      expect(DateTimeLocalizations.formatJournalDate(today, enLocale), 'Today');
      expect(
        DateTimeLocalizations.formatJournalDate(yesterday, enLocale),
        'Yesterday',
      );

      expect(DateTimeLocalizations.formatJournalDate(today, esLocale), 'Hoy');
      expect(
        DateTimeLocalizations.formatJournalDate(yesterday, esLocale),
        'Ayer',
      );
    });

    test('should format timestamps correctly', () {
      const enLocale = Locale('en');
      const esLocale = Locale('es');
      final testDateTime = DateTime(2024, 3, 15, 14, 30);

      final enTimestamp = DateTimeLocalizations.formatTimestamp(
        testDateTime,
        enLocale,
      );
      final esTimestamp = DateTimeLocalizations.formatTimestamp(
        testDateTime,
        esLocale,
      );

      expect(enTimestamp, contains('March 15, 2024'));
      expect(enTimestamp, contains('2:30 PM'));

      expect(esTimestamp, contains('15 de marzo de 2024'));
      expect(esTimestamp, contains('14:30'));
    });

    test('should get correct month names', () {
      const enLocale = Locale('en');
      const esLocale = Locale('es');

      expect(DateTimeLocalizations.getMonthName(1, enLocale), 'January');
      expect(DateTimeLocalizations.getMonthName(3, enLocale), 'March');
      expect(DateTimeLocalizations.getMonthName(12, enLocale), 'December');

      expect(DateTimeLocalizations.getMonthName(1, esLocale), 'enero');
      expect(DateTimeLocalizations.getMonthName(3, esLocale), 'marzo');
      expect(DateTimeLocalizations.getMonthName(12, esLocale), 'diciembre');
    });

    test('should get correct day of week names', () {
      const enLocale = Locale('en');
      const esLocale = Locale('es');

      expect(DateTimeLocalizations.getDayOfWeekName(1, enLocale), 'Monday');
      expect(DateTimeLocalizations.getDayOfWeekName(3, enLocale), 'Wednesday');
      expect(DateTimeLocalizations.getDayOfWeekName(7, enLocale), 'Sunday');

      expect(DateTimeLocalizations.getDayOfWeekName(1, esLocale), 'lunes');
      expect(DateTimeLocalizations.getDayOfWeekName(3, esLocale), 'miércoles');
      expect(DateTimeLocalizations.getDayOfWeekName(7, esLocale), 'domingo');
    });
  });
}
