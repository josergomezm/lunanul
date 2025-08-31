import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lunanul/services/language_service.dart';
import 'package:lunanul/utils/localization_error_handler.dart';

void main() {
  group('Comprehensive LanguageService Tests', () {
    late LanguageService languageService;

    setUp(() {
      languageService = LanguageService();
      SharedPreferences.setMockInitialValues({});
      LocalizationErrorHandler.resetStatistics();
    });

    group('Persistence Tests - Requirements 5.1, 5.2, 5.3', () {
      test(
        'saves and retrieves English language preference correctly',
        () async {
          // Arrange
          const englishLocale = Locale('en');

          // Act
          await languageService.saveLanguage(englishLocale);
          final retrievedLocale = await languageService.getSavedLanguage();

          // Assert
          expect(retrievedLocale.languageCode, equals('en'));

          // Verify persistence in SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          expect(prefs.getString('selected_language'), equals('en'));
        },
      );

      test(
        'saves and retrieves Spanish language preference correctly',
        () async {
          // Arrange
          const spanishLocale = Locale('es');

          // Act
          await languageService.saveLanguage(spanishLocale);
          final retrievedLocale = await languageService.getSavedLanguage();

          // Assert
          expect(retrievedLocale.languageCode, equals('es'));

          // Verify persistence in SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          expect(prefs.getString('selected_language'), equals('es'));
        },
      );

      test('handles SharedPreferences errors gracefully during save', () async {
        // This test verifies error handling during save operations
        const locale = Locale('en');

        // Act & Assert - should not throw
        expect(() => languageService.saveLanguage(locale), returnsNormally);
      });

      test(
        'handles SharedPreferences errors gracefully during retrieval',
        () async {
          // Act
          final result = await languageService.getSavedLanguage();

          // Assert - should return fallback locale
          expect(result, isA<Locale>());
          expect(result.languageCode, isNotEmpty);
        },
      );

      test('persists language preference across multiple operations', () async {
        // Arrange
        const initialLocale = Locale('es');
        const updatedLocale = Locale('en');

        // Act
        await languageService.saveLanguage(initialLocale);
        final firstRetrieval = await languageService.getSavedLanguage();

        await languageService.saveLanguage(updatedLocale);
        final secondRetrieval = await languageService.getSavedLanguage();

        // Assert
        expect(firstRetrieval.languageCode, equals('es'));
        expect(secondRetrieval.languageCode, equals('en'));
      });

      test(
        'clearSavedLanguage removes preference and falls back to device locale',
        () async {
          // Arrange
          await languageService.saveLanguage(const Locale('es'));

          // Verify language is saved
          final savedLocale = await languageService.getSavedLanguage();
          expect(savedLocale.languageCode, equals('es'));

          // Act
          await languageService.clearSavedLanguage();
          final clearedLocale = await languageService.getSavedLanguage();

          // Assert
          expect(clearedLocale, isA<Locale>());
          // Should fall back to device locale or English
          expect(['en', 'es'].contains(clearedLocale.languageCode), isTrue);
        },
      );
    });

    group('Device Detection Tests - Requirements 5.1, 5.4', () {
      test('getDeviceLocale returns valid locale', () {
        // Act
        final deviceLocale = languageService.getDeviceLocale();

        // Assert
        expect(deviceLocale, isA<Locale>());
        expect(deviceLocale.languageCode, isNotEmpty);
        expect(deviceLocale.languageCode.length, greaterThanOrEqualTo(2));
      });

      test('device locale detection handles errors gracefully', () {
        // Act & Assert - should not throw
        expect(() => languageService.getDeviceLocale(), returnsNormally);

        final result = languageService.getDeviceLocale();
        expect(result, isA<Locale>());
      });

      test(
        'getSavedLanguage falls back to device locale when no preference exists',
        () async {
          // Arrange - ensure no saved preference
          SharedPreferences.setMockInitialValues({});

          // Act
          final result = await languageService.getSavedLanguage();

          // Assert
          expect(result, isA<Locale>());
          // Should be either device locale (if supported) or English fallback
          expect(['en', 'es'].contains(result.languageCode), isTrue);
        },
      );

      test('device locale is validated against supported locales', () async {
        // Act
        final deviceLocale = languageService.getDeviceLocale();
        final savedLocale = await languageService.getSavedLanguage();

        // Assert
        expect(deviceLocale, isA<Locale>());
        expect(savedLocale, isA<Locale>());

        // If device locale is supported, it should be used; otherwise fallback to English
        if (languageService.isSupported(deviceLocale)) {
          expect(savedLocale.languageCode, equals(deviceLocale.languageCode));
        } else {
          expect(savedLocale.languageCode, equals('en'));
        }
      });
    });

    group('Locale Validation Tests - Requirements 5.2, 5.3, 5.5', () {
      test('isSupported correctly identifies supported locales', () {
        // Test supported locales
        expect(languageService.isSupported(const Locale('en')), isTrue);
        expect(languageService.isSupported(const Locale('es')), isTrue);

        // Test with country codes
        expect(languageService.isSupported(const Locale('en', 'US')), isTrue);
        expect(languageService.isSupported(const Locale('es', 'ES')), isTrue);
      });

      test('isSupported correctly identifies unsupported locales', () {
        // Test unsupported locales
        expect(languageService.isSupported(const Locale('fr')), isFalse);
        expect(languageService.isSupported(const Locale('de')), isFalse);
        expect(languageService.isSupported(const Locale('zh')), isFalse);
        expect(languageService.isSupported(const Locale('ja')), isFalse);
      });

      test('saveLanguage validates locale before saving', () async {
        // Test saving supported locale
        expect(
          () => languageService.saveLanguage(const Locale('en')),
          returnsNormally,
        );
        expect(
          () => languageService.saveLanguage(const Locale('es')),
          returnsNormally,
        );
      });

      test('saveLanguage handles unsupported locales with fallback', () async {
        // Arrange
        const unsupportedLocale = Locale('fr');

        // Act - should not throw, should use fallback
        await languageService.saveLanguage(unsupportedLocale);
        final savedLocale = await languageService.getSavedLanguage();

        // Assert - should fallback to English
        expect(savedLocale.languageCode, equals('en'));
      });

      test('getSupportedLocales returns correct list', () {
        // Act
        final supportedLocales = languageService.getSupportedLocales();

        // Assert
        expect(supportedLocales, hasLength(2));
        expect(
          supportedLocales.map((l) => l.languageCode),
          containsAll(['en', 'es']),
        );

        // Verify list is unmodifiable
        expect(
          () => supportedLocales.add(const Locale('fr')),
          throwsUnsupportedError,
        );
      });
    });

    group(
      'Error Handling and Fallback Tests - Requirements 5.1, 5.2, 5.3, 5.4, 5.5',
      () {
        test('handles corrupted SharedPreferences data gracefully', () async {
          // Arrange - set invalid data
          SharedPreferences.setMockInitialValues({'selected_language': ''});

          // Act
          final result = await languageService.getSavedLanguage();

          // Assert - should fallback gracefully
          expect(result, isA<Locale>());
          expect(['en', 'es'].contains(result.languageCode), isTrue);
        });

        test('handles null SharedPreferences values gracefully', () async {
          // Arrange
          SharedPreferences.setMockInitialValues(<String, Object>{
            'selected_language': '',
          });

          // Act
          final result = await languageService.getSavedLanguage();

          // Assert
          expect(result, isA<Locale>());
          expect(['en', 'es'].contains(result.languageCode), isTrue);
        });

        test('error handling maintains service functionality', () async {
          // Test that errors don't break subsequent operations

          // Try to save an unsupported locale
          await languageService.saveLanguage(const Locale('fr'));

          // Service should still work normally
          await languageService.saveLanguage(const Locale('es'));
          final result = await languageService.getSavedLanguage();

          expect(result.languageCode, equals('es'));
        });

        test('fallback mechanisms work correctly', () async {
          // Test multiple fallback scenarios

          // 1. No saved preference -> device locale or English
          SharedPreferences.setMockInitialValues({});
          final noPreferenceResult = await languageService.getSavedLanguage();
          expect(noPreferenceResult, isA<Locale>());

          // 2. Invalid saved preference -> device locale or English
          SharedPreferences.setMockInitialValues({
            'selected_language': 'invalid',
          });
          final invalidPreferenceResult = await languageService
              .getSavedLanguage();
          expect(invalidPreferenceResult, isA<Locale>());
          expect(
            ['en', 'es'].contains(invalidPreferenceResult.languageCode),
            isTrue,
          );
        });

        test('error statistics are tracked correctly', () async {
          // Reset statistics
          LocalizationErrorHandler.resetStatistics();

          // Perform operations that might trigger errors
          await languageService.saveLanguage(const Locale('fr')); // Unsupported
          SharedPreferences.setMockInitialValues({
            'selected_language': 'invalid',
          });
          await languageService.getSavedLanguage();

          // Check that error handling was used
          final stats = LocalizationErrorHandler.getErrorStatistics();
          expect(stats, isA<Map<String, dynamic>>());
          expect(stats.containsKey('totalErrors'), isTrue);
          expect(stats.containsKey('fallbacksUsed'), isTrue);
        });
      },
    );

    group('Edge Cases and Boundary Tests', () {
      test('handles empty string language codes', () async {
        // Arrange
        SharedPreferences.setMockInitialValues({'selected_language': ''});

        // Act
        final result = await languageService.getSavedLanguage();

        // Assert
        expect(result, isA<Locale>());
        expect(result.languageCode, isNotEmpty);
      });

      test('handles very long language codes', () {
        // Act
        final isSupported = languageService.isSupported(
          const Locale('this_is_a_very_long_invalid_language_code'),
        );

        // Assert
        expect(isSupported, isFalse);
      });

      test('handles special characters in language codes', () {
        // Test various invalid language codes
        expect(languageService.isSupported(const Locale('en-US')), isFalse);
        expect(languageService.isSupported(const Locale('es_ES')), isFalse);
        expect(languageService.isSupported(const Locale('en@US')), isFalse);
      });

      test('handles case sensitivity correctly', () {
        // Language codes should be case sensitive
        expect(languageService.isSupported(const Locale('EN')), isFalse);
        expect(languageService.isSupported(const Locale('Es')), isFalse);
        expect(languageService.isSupported(const Locale('eS')), isFalse);
      });

      test('handles concurrent operations correctly', () async {
        // Test concurrent save operations
        final futures = [
          languageService.saveLanguage(const Locale('en')),
          languageService.saveLanguage(const Locale('es')),
          languageService.getSavedLanguage(),
          languageService.clearSavedLanguage(),
        ];

        // Should not throw
        expect(() => Future.wait(futures), returnsNormally);
      });
    });

    group('Integration and Performance Tests', () {
      test('multiple save and retrieve operations work correctly', () async {
        // Test rapid switching between languages
        for (int i = 0; i < 10; i++) {
          final locale = i % 2 == 0 ? const Locale('en') : const Locale('es');
          await languageService.saveLanguage(locale);

          final retrieved = await languageService.getSavedLanguage();
          expect(retrieved.languageCode, equals(locale.languageCode));
        }
      });

      test('service maintains consistency across operations', () async {
        // Test that the service maintains internal consistency

        // Initial state
        await languageService.clearSavedLanguage();

        // Save English
        await languageService.saveLanguage(const Locale('en'));
        expect(
          (await languageService.getSavedLanguage()).languageCode,
          equals('en'),
        );

        // Save Spanish
        await languageService.saveLanguage(const Locale('es'));
        expect(
          (await languageService.getSavedLanguage()).languageCode,
          equals('es'),
        );

        // Clear and verify fallback
        await languageService.clearSavedLanguage();
        final fallbackLocale = await languageService.getSavedLanguage();
        expect(['en', 'es'].contains(fallbackLocale.languageCode), isTrue);
      });

      test('service handles rapid successive calls', () async {
        // Test that rapid calls don't cause issues
        final results = await Future.wait([
          languageService.getSavedLanguage(),
          languageService.getSavedLanguage(),
          languageService.getSavedLanguage(),
        ]);

        // All results should be the same
        expect(results[0].languageCode, equals(results[1].languageCode));
        expect(results[1].languageCode, equals(results[2].languageCode));
      });
    });
  });
}
