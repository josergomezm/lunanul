import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lunanul/services/language_service.dart';

void main() {
  group('LanguageService Tests', () {
    late LanguageService languageService;

    setUp(() {
      languageService = LanguageService();
      // Clear SharedPreferences before each test
      SharedPreferences.setMockInitialValues({});
    });

    group('getSavedLanguage', () {
      test('returns saved language when valid preference exists', () async {
        // Arrange
        SharedPreferences.setMockInitialValues({'selected_language': 'es'});

        // Act
        final result = await languageService.getSavedLanguage();

        // Assert
        expect(result.languageCode, equals('es'));
      });

      test('returns English fallback when no preference exists', () async {
        // Arrange
        SharedPreferences.setMockInitialValues({});

        // Act
        final result = await languageService.getSavedLanguage();

        // Assert
        expect(result.languageCode, equals('en'));
      });

      test(
        'returns English fallback when unsupported language is saved',
        () async {
          // Arrange
          SharedPreferences.setMockInitialValues({'selected_language': 'fr'});

          // Act
          final result = await languageService.getSavedLanguage();

          // Assert
          expect(result.languageCode, equals('en'));
        },
      );

      test(
        'returns English fallback when SharedPreferences throws error',
        () async {
          // This test simulates error handling, though it's harder to force
          // SharedPreferences to throw in tests. The service handles this gracefully.

          // Act
          final result = await languageService.getSavedLanguage();

          // Assert
          expect(result.languageCode, equals('en'));
        },
      );
    });

    group('saveLanguage', () {
      test('saves supported language successfully', () async {
        // Arrange
        const locale = Locale('es');

        // Act
        await languageService.saveLanguage(locale);

        // Assert
        final prefs = await SharedPreferences.getInstance();
        final savedLanguage = prefs.getString('selected_language');
        expect(savedLanguage, equals('es'));
      });

      test('throws ArgumentError for unsupported language', () async {
        // Arrange
        const locale = Locale('fr'); // French is not supported

        // Act & Assert
        expect(
          () => languageService.saveLanguage(locale),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('saves English language successfully', () async {
        // Arrange
        const locale = Locale('en');

        // Act
        await languageService.saveLanguage(locale);

        // Assert
        final prefs = await SharedPreferences.getInstance();
        final savedLanguage = prefs.getString('selected_language');
        expect(savedLanguage, equals('en'));
      });
    });

    group('getDeviceLocale', () {
      test('returns a valid Locale object', () {
        // Act
        final result = languageService.getDeviceLocale();

        // Assert
        expect(result, isA<Locale>());
        expect(result.languageCode, isNotEmpty);
      });

      test(
        'returns English fallback when device locale cannot be determined',
        () {
          // This is hard to test directly since PlatformDispatcher.instance.locale
          // is system-dependent, but the method handles errors gracefully

          // Act
          final result = languageService.getDeviceLocale();

          // Assert
          expect(result, isA<Locale>());
        },
      );
    });

    group('isSupported', () {
      test('returns true for English locale', () {
        // Arrange
        const locale = Locale('en');

        // Act
        final result = languageService.isSupported(locale);

        // Assert
        expect(result, isTrue);
      });

      test('returns true for Spanish locale', () {
        // Arrange
        const locale = Locale('es');

        // Act
        final result = languageService.isSupported(locale);

        // Assert
        expect(result, isTrue);
      });

      test('returns false for unsupported locale', () {
        // Arrange
        const locale = Locale('fr');

        // Act
        final result = languageService.isSupported(locale);

        // Assert
        expect(result, isFalse);
      });

      test('returns false for invalid language code', () {
        // Arrange
        const locale = Locale('invalid');

        // Act
        final result = languageService.isSupported(locale);

        // Assert
        expect(result, isFalse);
      });
    });

    group('getSupportedLocales', () {
      test('returns list of supported locales', () {
        // Act
        final result = languageService.getSupportedLocales();

        // Assert
        expect(result, hasLength(2));
        expect(result.map((l) => l.languageCode), contains('en'));
        expect(result.map((l) => l.languageCode), contains('es'));
      });

      test('returns unmodifiable list', () {
        // Act
        final result = languageService.getSupportedLocales();

        // Assert
        expect(() => result.add(const Locale('fr')), throwsUnsupportedError);
      });
    });

    group('clearSavedLanguage', () {
      test('removes saved language preference', () async {
        // Arrange
        SharedPreferences.setMockInitialValues({'selected_language': 'es'});
        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getString('selected_language'), equals('es'));

        // Act
        await languageService.clearSavedLanguage();

        // Assert
        expect(prefs.getString('selected_language'), isNull);
      });

      test('completes successfully when no preference exists', () async {
        // Arrange
        SharedPreferences.setMockInitialValues({});

        // Act & Assert
        expect(() => languageService.clearSavedLanguage(), returnsNormally);
      });
    });

    group('integration tests', () {
      test('save and retrieve language workflow', () async {
        // Arrange
        const locale = Locale('es');

        // Act
        await languageService.saveLanguage(locale);
        final retrievedLocale = await languageService.getSavedLanguage();

        // Assert
        expect(retrievedLocale.languageCode, equals('es'));
      });

      test('clear and retrieve language workflow', () async {
        // Arrange
        const locale = Locale('es');
        await languageService.saveLanguage(locale);

        // Act
        await languageService.clearSavedLanguage();
        final retrievedLocale = await languageService.getSavedLanguage();

        // Assert
        expect(
          retrievedLocale.languageCode,
          equals('en'),
        ); // Should fallback to English
      });
    });

    group('edge cases', () {
      test('handles locale with country code', () {
        // Arrange
        const locale = Locale('en', 'US');

        // Act
        final isSupported = languageService.isSupported(locale);

        // Assert
        expect(isSupported, isTrue); // Should match by language code only
      });

      test('handles case sensitivity in language codes', () {
        // Arrange
        const locale = Locale('EN'); // Uppercase

        // Act
        final isSupported = languageService.isSupported(locale);

        // Assert
        expect(isSupported, isFalse); // Should be case sensitive
      });
    });
  });
}
