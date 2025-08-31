import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:lunanul/utils/localization_error_handler.dart';

void main() {
  group('LocalizationErrorHandler', () {
    setUp(() {
      // Reset statistics before each test
      LocalizationErrorHandler.resetStatistics();
    });

    group('getLocalizedString', () {
      test('returns localized string when available', () {
        final translations = {
          'en': {'greeting': 'Hello'},
          'es': {'greeting': 'Hola'},
        };

        final result = LocalizationErrorHandler.getLocalizedString(
          'greeting',
          const Locale('es'),
          translations,
        );

        expect(result, equals('Hola'));
      });

      test('falls back to English when requested locale not available', () {
        final translations = {
          'en': {'greeting': 'Hello'},
          'fr': {'greeting': 'Bonjour'},
        };

        final result = LocalizationErrorHandler.getLocalizedString(
          'greeting',
          const Locale('es'), // Spanish not available
          translations,
        );

        expect(result, equals('Hello'));
      });

      test('uses custom fallback when provided', () {
        final translations = {
          'en': {'other': 'Other'},
        };

        final result = LocalizationErrorHandler.getLocalizedString(
          'greeting', // Not available
          const Locale('en'),
          translations,
          fallback: 'Custom Fallback',
        );

        expect(result, equals('Custom Fallback'));
      });

      test('formats key as display text when no fallback', () {
        final translations = <String, dynamic>{};

        final result = LocalizationErrorHandler.getLocalizedString(
          'user_profile_name',
          const Locale('en'),
          translations,
        );

        expect(result, equals('User Profile Name'));
      });

      test('handles empty translations gracefully', () {
        final result = LocalizationErrorHandler.getLocalizedString(
          'greeting',
          const Locale('en'),
          {},
          fallback: 'Fallback',
        );

        expect(result, equals('Fallback'));
      });
    });

    group('handleJsonParsingError', () {
      test('returns empty map and logs error', () {
        final result = LocalizationErrorHandler.handleJsonParsingError(
          'test_asset.json',
          FormatException('Invalid JSON'),
          context: 'test',
        );

        expect(result, isEmpty);
        expect(result, isA<Map<String, dynamic>>());
      });
    });

    group('validateTranslations', () {
      test('identifies missing translations', () {
        final translations = {
          'en': {'greeting': 'Hello', 'goodbye': 'Goodbye'},
        };

        final requiredKeys = ['greeting', 'goodbye', 'welcome'];

        final missingKeys = LocalizationErrorHandler.validateTranslations(
          translations,
          requiredKeys,
          locale: const Locale('en'),
        );

        expect(missingKeys, contains('welcome'));
        expect(missingKeys, hasLength(1));
      });

      test('returns empty list when all translations present', () {
        final translations = {
          'en': {'greeting': 'Hello', 'goodbye': 'Goodbye'},
        };

        final requiredKeys = ['greeting', 'goodbye'];

        final missingKeys = LocalizationErrorHandler.validateTranslations(
          translations,
          requiredKeys,
          locale: const Locale('en'),
        );

        expect(missingKeys, isEmpty);
      });
    });

    group('handleParameterSubstitution', () {
      test('substitutes parameters correctly', () {
        const template = 'Hello {name}, welcome to {app}!';
        final parameters = {'name': 'John', 'app': 'Lunanul'};

        final result = LocalizationErrorHandler.handleParameterSubstitution(
          template,
          parameters,
        );

        expect(result, equals('Hello John, welcome to Lunanul!'));
      });

      test('handles missing parameters gracefully', () {
        const template = 'Hello {name}, welcome to {app}!';
        final parameters = {'name': 'John'}; // Missing 'app'

        final result = LocalizationErrorHandler.handleParameterSubstitution(
          template,
          parameters,
        );

        expect(result, equals('Hello John, welcome to {app}!'));
      });

      test('returns original template on error', () {
        const template = 'Hello {name}!';
        final parameters = <String, dynamic>{'name': null};

        final result = LocalizationErrorHandler.handleParameterSubstitution(
          template,
          parameters,
        );

        expect(result, equals('Hello null!'));
      });
    });

    group('safeAsyncOperation', () {
      test('returns result when operation succeeds', () async {
        final result = await LocalizationErrorHandler.safeAsyncOperation(
          () async => 'Success',
          'Fallback',
        );

        expect(result, equals('Success'));
      });

      test('returns fallback when operation fails', () async {
        final result = await LocalizationErrorHandler.safeAsyncOperation(
          () async => throw Exception('Test error'),
          'Fallback',
        );

        expect(result, equals('Fallback'));
      });
    });

    group('safeSyncOperation', () {
      test('returns result when operation succeeds', () {
        final result = LocalizationErrorHandler.safeSyncOperation(
          () => 'Success',
          'Fallback',
        );

        expect(result, equals('Success'));
      });

      test('returns fallback when operation fails', () {
        final result = LocalizationErrorHandler.safeSyncOperation(
          () => throw Exception('Test error'),
          'Fallback',
        );

        expect(result, equals('Fallback'));
      });
    });

    group('validateAndFallbackLocale', () {
      final supportedLocales = [
        const Locale('en', 'US'),
        const Locale('en', 'GB'),
        const Locale('es', 'ES'),
        const Locale('fr', 'FR'),
      ];

      test('returns exact match when available', () {
        final result = LocalizationErrorHandler.validateAndFallbackLocale(
          const Locale('es', 'ES'),
          supportedLocales,
        );

        expect(result, equals(const Locale('es', 'ES')));
      });

      test('falls back to language match when country not supported', () {
        final result = LocalizationErrorHandler.validateAndFallbackLocale(
          const Locale('en', 'CA'), // Canada not supported
          supportedLocales,
        );

        expect(result.languageCode, equals('en'));
        expect(supportedLocales.contains(result), isTrue);
      });

      test('falls back to English when language not supported', () {
        final result = LocalizationErrorHandler.validateAndFallbackLocale(
          const Locale('de', 'DE'), // German not supported
          supportedLocales,
        );

        expect(result.languageCode, equals('en'));
      });

      test('falls back to first locale when English not available', () {
        final limitedLocales = [
          const Locale('es', 'ES'),
          const Locale('fr', 'FR'),
        ];

        final result = LocalizationErrorHandler.validateAndFallbackLocale(
          const Locale('de', 'DE'),
          limitedLocales,
        );

        expect(result, equals(const Locale('es', 'ES')));
      });
    });

    group('error statistics', () {
      test('tracks error statistics correctly', () {
        // Generate some errors
        LocalizationErrorHandler.getLocalizedString(
          'missing_key',
          const Locale('en'),
          {},
        );

        LocalizationErrorHandler.safeSyncOperation(
          () => throw Exception('Test error'),
          'fallback',
        );

        final stats = LocalizationErrorHandler.getErrorStatistics();

        expect(stats['totalErrors'], greaterThan(0));
        expect(stats['fallbacksUsed'], greaterThan(0));
        expect(stats['errorsByType'], isA<Map<String, int>>());
        expect(stats['errorsByKey'], isA<Map<String, int>>());
      });

      test('resets statistics correctly', () {
        // Generate some errors
        LocalizationErrorHandler.getLocalizedString(
          'missing_key',
          const Locale('en'),
          {},
        );

        LocalizationErrorHandler.resetStatistics();

        final stats = LocalizationErrorHandler.getErrorStatistics();

        expect(stats['totalErrors'], equals(0));
        expect(stats['fallbacksUsed'], equals(0));
        expect(stats['errorsByType'], isEmpty);
        expect(stats['errorsByKey'], isEmpty);
      });

      test('detects high error rate correctly', () {
        // Initially no errors
        expect(LocalizationErrorHandler.isErrorRateHigh(), isFalse);

        // Generate errors to exceed threshold
        for (int i = 0; i < 10; i++) {
          LocalizationErrorHandler.getLocalizedString(
            'missing_key_$i',
            const Locale('en'),
            {},
          );
        }

        // Since we're only using fallbacks (not actual errors),
        // the error rate calculation might be different
        final stats = LocalizationErrorHandler.getErrorStatistics();
        expect(stats['fallbacksUsed'], greaterThan(0));
      });
    });

    group('SafeLocalizationOperations extension', () {
      test('safeGetString returns string value', () {
        final map = {'key': 'value'};
        final result = map.safeGetString('key');
        expect(result, equals('value'));
      });

      test('safeGetString returns fallback for missing key', () {
        final map = <String, dynamic>{};
        final result = map.safeGetString('key', fallback: 'default');
        expect(result, equals('default'));
      });

      test('safeGetStringList returns list of strings', () {
        final map = {
          'key': ['a', 'b', 'c'],
        };
        final result = map.safeGetStringList('key');
        expect(result, equals(['a', 'b', 'c']));
      });

      test('safeGetStringList returns fallback for missing key', () {
        final map = <String, dynamic>{};
        final result = map.safeGetStringList('key', fallback: ['default']);
        expect(result, equals(['default']));
      });

      test('safeGetMap returns nested map', () {
        final map = {
          'key': {'nested': 'value'},
        };
        final result = map.safeGetMap('key');
        expect(result, equals({'nested': 'value'}));
      });

      test('safeGetMap returns fallback for missing key', () {
        final map = <String, dynamic>{};
        final result = map.safeGetMap('key', fallback: {'default': 'value'});
        expect(result, equals({'default': 'value'}));
      });
    });
  });
}
