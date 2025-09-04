import 'dart:ui';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

/// Utility class for handling date and time localization
class DateTimeLocalizations {
  /// Get localized date formatter for the given locale
  static DateFormat getDateFormatter(Locale locale) {
    switch (locale.languageCode) {
      case 'es':
        return DateFormat('d \'de\' MMMM \'de\' y', 'es');
      case 'en':
      default:
        return DateFormat('MMMM d, y', 'en');
    }
  }

  /// Get localized short date formatter for the given locale
  static DateFormat getShortDateFormatter(Locale locale) {
    switch (locale.languageCode) {
      case 'es':
        return DateFormat('d/M/y', 'es');
      case 'en':
      default:
        return DateFormat('M/d/y', 'en');
    }
  }

  /// Get localized time formatter for the given locale
  static DateFormat getTimeFormatter(Locale locale) {
    switch (locale.languageCode) {
      case 'es':
        return DateFormat('HH:mm', 'es');
      case 'en':
      default:
        return DateFormat('h:mm a', 'en');
    }
  }

  /// Get localized date and time formatter for the given locale
  static DateFormat getDateTimeFormatter(Locale locale) {
    switch (locale.languageCode) {
      case 'es':
        return DateFormat('d \'de\' MMMM \'de\' y \'a las\' HH:mm', 'es');
      case 'en':
      default:
        return DateFormat('MMMM d, y \'at\' h:mm a', 'en');
    }
  }

  /// Get localized relative date formatter (today, yesterday, etc.)
  static String getRelativeDate(DateTime date, Locale locale) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return locale.languageCode == 'es' ? 'hoy' : 'today';
    } else if (difference.inDays == 1) {
      return locale.languageCode == 'es' ? 'ayer' : 'yesterday';
    } else if (difference.inDays < 7) {
      if (locale.languageCode == 'es') {
        return 'hace ${difference.inDays} días';
      } else {
        return '${difference.inDays} days ago';
      }
    } else {
      return getShortDateFormatter(locale).format(date);
    }
  }

  /// Get localized activity time (for friends page)
  static String getActivityTime(DateTime lastActive, Locale locale) {
    final now = DateTime.now();
    final difference = now.difference(lastActive);

    if (difference.inMinutes < 1) {
      return locale.languageCode == 'es' ? 'Activo ahora' : 'Active now';
    } else if (difference.inMinutes < 60) {
      if (locale.languageCode == 'es') {
        return 'Activo hace ${difference.inMinutes}m';
      } else {
        return 'Active ${difference.inMinutes}m ago';
      }
    } else if (difference.inHours < 24) {
      if (locale.languageCode == 'es') {
        return 'Activo hace ${difference.inHours}h';
      } else {
        return 'Active ${difference.inHours}h ago';
      }
    } else if (difference.inDays == 1) {
      return locale.languageCode == 'es' ? 'Activo ayer' : 'Active yesterday';
    } else {
      if (locale.languageCode == 'es') {
        return 'Activo hace ${difference.inDays} días';
      } else {
        return 'Active ${difference.inDays} days ago';
      }
    }
  }

  /// Get localized greeting based on time of day
  static String getTimeBasedGreeting(DateTime time, Locale locale) {
    final hour = time.hour;

    if (hour < 12) {
      return locale.languageCode == 'es' ? 'Buenos días' : 'Good morning';
    } else if (hour < 17) {
      return locale.languageCode == 'es' ? 'Buenas tardes' : 'Good afternoon';
    } else {
      return locale.languageCode == 'es' ? 'Buenas noches' : 'Good evening';
    }
  }

  /// Format date for reading display
  /// Format date for readings
  static String formatReadingDate(DateTime date, Locale locale) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return locale.languageCode == 'es' ? 'Hoy' : 'Today';
    } else if (difference.inDays == 1) {
      return locale.languageCode == 'es' ? 'Ayer' : 'Yesterday';
    } else if (difference.inDays < 7) {
      // Show day of week for recent dates
      final dayFormatter = DateFormat('EEEE', locale.languageCode);
      return dayFormatter.format(date);
    } else {
      return getDateFormatter(locale).format(date);
    }
  }

  /// Format timestamp for detailed views
  static String formatTimestamp(DateTime dateTime, Locale locale) {
    return getDateTimeFormatter(locale).format(dateTime);
  }

  /// Get month name in the specified locale
  static String getMonthName(int month, Locale locale) {
    final date = DateTime(2024, month, 1);
    final formatter = DateFormat('MMMM', locale.languageCode);
    return formatter.format(date);
  }

  /// Get day of week name in the specified locale
  static String getDayOfWeekName(int weekday, Locale locale) {
    final date = DateTime(2024, 1, weekday); // January 1, 2024 is a Monday
    final formatter = DateFormat('EEEE', locale.languageCode);
    return formatter.format(date);
  }

  /// Initialize locale data for date formatting
  static Future<void> initializeLocaleData() async {
    // Initialize date formatting for supported locales
    await initializeDateFormatting('en', null);
    await initializeDateFormatting('es', null);
    Intl.defaultLocale = 'en';
  }
}
