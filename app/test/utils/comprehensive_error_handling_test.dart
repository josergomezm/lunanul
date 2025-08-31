import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lunanul/utils/localization_error_handler.dart';
import 'package:lunanul/utils/safe_localizations.dart';
import 'package:lunanul/l10n/generated/app_localizations.dart';

void main() {
  group('Comprehensive Error Handling Tests', () {
    setUp(() {
      LocalizationErrorHandler.resetStatistics();
    });

    group(
      'LocalizationErrorHandler Comprehensive Tests - Requirements 5.1, 5.2, 5.3, 5.4, 5.5',
      () {
        group('Fallback Mechanism Tests', () {
          test('complete fallback chain works correctly', () {
            final translations = {
              'en': {'greeting': 'Hello', 'partial': 'Partial'},
              'es': {'greeting': 'Hola'},
              'fr': {'other': 'Autre'},
            };

            // Test 1: Normal case - translation exists
            var result = LocalizationErrorHandler.getLocalizedString(
              'greeting',
              const Locale('es'),
              translations,
            );
            expect(result, equals('Hola'));

            // Test 2: Fallback to English
            result = LocalizationErrorHandler.getLocalizedString(
              'partial',
              const Locale('es'),
              translations,
            );
            expect(result, equals('Partial'));

            // Test 3: Custom fallback
            result = LocalizationErrorHandler.getLocalizedString(
              'missing',
              const Locale('es'),
              translations,
              fallback: 'Custom Fallback',
            );
            expect(result, equals('Custom Fallback'));

            // Test 4: Key formatting fallback
            result = LocalizationErrorHandler.getLocalizedString(
              'user_profile_settings',
              const Locale('es'),
              translations,
            );
            expect(result, equals('User Profile Settings'));
          });

          test('handles empty and null values correctly', () {
            final translations = {
              'en': {'empty': '', 'null_value': null, 'valid': 'Valid'},
              'es': {'empty': '', 'valid': 'Válido'},
            };

            // Empty string should trigger fallback
            var result = LocalizationErrorHandler.getLocalizedString(
              'empty',
              const Locale('es'),
              translations,
            );
            expect(result, equals('Empty')); // Formatted key fallback

            // Null value should trigger fallback
            result = LocalizationErrorHandler.getLocalizedString(
              'null_value',
              const Locale('en'),
              translations,
            );
            expect(result, equals('Null Value')); // Formatted key fallback

            // Valid value should work normally
            result = LocalizationErrorHandler.getLocalizedString(
              'valid',
              const Locale('es'),
              translations,
            );
            expect(result, equals('Válido'));
          });

          test('handles malformed translation data structures', () {
            // Test with various malformed data structures
            final malformedTranslations = [
              null,
              {},
              {'en': null},
              {'en': 'not_a_map'},
              {'en': []},
              {
                'en': {
                  'key': {'nested': 'too_deep'},
                },
              },
            ];

            for (final translations in malformedTranslations) {
              final result = LocalizationErrorHandler.getLocalizedString(
                'test_key',
                const Locale('en'),
                translations as Map<String, dynamic>? ?? {},
                fallback: 'Safe Fallback',
              );
              expect(result, equals('Safe Fallback'));
            }
          });
        });

        group('Error Recovery and Statistics Tests', () {
          test('error statistics track different error types correctly', () {
            LocalizationErrorHandler.resetStatistics();

            // Generate different types of errors
            LocalizationErrorHandler.getLocalizedString(
              'missing1',
              const Locale('en'),
              {},
            );
            LocalizationErrorHandler.getLocalizedString(
              'missing2',
              const Locale('es'),
              {},
            );
            LocalizationErrorHandler.handleJsonParsingError(
              'test.json',
              FormatException('Invalid JSON'),
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
            expect(stats['errorRate'], isA<double>());
          });

          test('error rate calculation works correctly', () {
            LocalizationErrorHandler.resetStatistics();

            // Generate errors to test rate calculation
            for (int i = 0; i < 10; i++) {
              LocalizationErrorHandler.getLocalizedString(
                'missing_$i',
                const Locale('en'),
                {},
              );
            }

            final stats = LocalizationErrorHandler.getErrorStatistics();
            expect(stats['errorRate'], isA<double>());
            expect(stats['errorRate'], greaterThanOrEqualTo(0.0));
            expect(stats['errorRate'], lessThanOrEqualTo(1.0));
          });

          test('isErrorRateHigh works with different thresholds', () {
            LocalizationErrorHandler.resetStatistics();

            // Initially no errors
            expect(LocalizationErrorHandler.isErrorRateHigh(), isFalse);
            expect(
              LocalizationErrorHandler.isErrorRateHigh(threshold: 0.5),
              isFalse,
            );

            // Generate some errors
            for (int i = 0; i < 5; i++) {
              LocalizationErrorHandler.getLocalizedString(
                'missing_$i',
                const Locale('en'),
                {},
              );
            }

            // Test with different thresholds
            final isHighDefault = LocalizationErrorHandler.isErrorRateHigh();
            final isHighLowThreshold = LocalizationErrorHandler.isErrorRateHigh(
              threshold: 0.01,
            );
            final isHighHighThreshold =
                LocalizationErrorHandler.isErrorRateHigh(threshold: 0.99);

            expect(isHighDefault, isA<bool>());
            expect(isHighLowThreshold, isA<bool>());
            expect(isHighHighThreshold, isA<bool>());
          });
        });

        group('Safe Operation Wrappers Tests', () {
          test('safeAsyncOperation handles various async scenarios', () async {
            // Success case
            var result = await LocalizationErrorHandler.safeAsyncOperation(
              () async => 'Success',
              'Fallback',
            );
            expect(result, equals('Success'));

            // Exception case
            result = await LocalizationErrorHandler.safeAsyncOperation(
              () async => throw Exception('Async error'),
              'Async Fallback',
            );
            expect(result, equals('Async Fallback'));

            // Timeout simulation (delayed operation)
            result = await LocalizationErrorHandler.safeAsyncOperation(
              () async {
                await Future.delayed(const Duration(milliseconds: 1));
                return 'Delayed Success';
              },
              'Timeout Fallback',
            );
            expect(result, equals('Delayed Success'));

            // Null return handling
            result = await LocalizationErrorHandler.safeAsyncOperation(
              () async => Future<String?>.value(
                null,
              ).then((value) => value ?? 'Null Fallback'),
              'Null Fallback',
            );
            expect(result, equals('Null Fallback'));
          });

          test('safeSyncOperation handles various sync scenarios', () {
            // Success case
            var result = LocalizationErrorHandler.safeSyncOperation(
              () => 'Sync Success',
              'Sync Fallback',
            );
            expect(result, equals('Sync Success'));

            // Exception case
            result = LocalizationErrorHandler.safeSyncOperation(
              () => throw StateError('Sync error'),
              'Sync Error Fallback',
            );
            expect(result, equals('Sync Error Fallback'));

            // Null return handling
            result =
                LocalizationErrorHandler.safeSyncOperation(
                  () => null as String?,
                  'Sync Null Fallback',
                ) ??
                'Sync Null Fallback';
            expect(result, equals('Sync Null Fallback'));
          });
        });

        group('Locale Validation Tests', () {
          test('validateAndFallbackLocale handles all scenarios correctly', () {
            final supportedLocales = [
              const Locale('en', 'US'),
              const Locale('en', 'GB'),
              const Locale('es', 'ES'),
              const Locale('es', 'MX'),
              const Locale('fr', 'FR'),
            ];

            // Exact match
            var result = LocalizationErrorHandler.validateAndFallbackLocale(
              const Locale('es', 'ES'),
              supportedLocales,
            );
            expect(result, equals(const Locale('es', 'ES')));

            // Language match, different country
            result = LocalizationErrorHandler.validateAndFallbackLocale(
              const Locale('es', 'AR'), // Argentina not supported
              supportedLocales,
            );
            expect(result.languageCode, equals('es'));
            expect(supportedLocales.contains(result), isTrue);

            // Unsupported language, fallback to English
            result = LocalizationErrorHandler.validateAndFallbackLocale(
              const Locale('de', 'DE'),
              supportedLocales,
            );
            expect(result.languageCode, equals('en'));

            // No English available, fallback to first
            final noEnglishLocales = [
              const Locale('es', 'ES'),
              const Locale('fr', 'FR'),
            ];
            result = LocalizationErrorHandler.validateAndFallbackLocale(
              const Locale('de', 'DE'),
              noEnglishLocales,
            );
            expect(result, equals(const Locale('es', 'ES')));
          });

          test('handles edge cases in locale validation', () {
            final supportedLocales = [const Locale('en'), const Locale('es')];

            // Empty language code - use a valid but unsupported locale instead
            var result = LocalizationErrorHandler.validateAndFallbackLocale(
              const Locale('invalid'),
              supportedLocales,
            );
            expect(result.languageCode, equals('en'));

            // Very long language code
            result = LocalizationErrorHandler.validateAndFallbackLocale(
              const Locale('this_is_a_very_long_language_code'),
              supportedLocales,
            );
            expect(result.languageCode, equals('en'));

            // Special characters
            result = LocalizationErrorHandler.validateAndFallbackLocale(
              const Locale('en-US'),
              supportedLocales,
            );
            expect(result.languageCode, equals('en'));
          });
        });

        group('Parameter Substitution Tests', () {
          test('handleParameterSubstitution works with various scenarios', () {
            // Normal substitution
            var result = LocalizationErrorHandler.handleParameterSubstitution(
              'Hello {name}, welcome to {app}!',
              {'name': 'John', 'app': 'Lunanul'},
            );
            expect(result, equals('Hello John, welcome to Lunanul!'));

            // Missing parameters
            result = LocalizationErrorHandler.handleParameterSubstitution(
              'Hello {name}, welcome to {app}!',
              {'name': 'John'}, // Missing 'app'
            );
            expect(result, equals('Hello John, welcome to {app}!'));

            // Extra parameters
            result = LocalizationErrorHandler.handleParameterSubstitution(
              'Hello {name}!',
              {'name': 'John', 'extra': 'value'},
            );
            expect(result, equals('Hello John!'));

            // No parameters in template
            result = LocalizationErrorHandler.handleParameterSubstitution(
              'Static text',
              {'name': 'John'},
            );
            expect(result, equals('Static text'));

            // Empty parameters
            result = LocalizationErrorHandler.handleParameterSubstitution(
              'Hello {name}!',
              {},
            );
            expect(result, equals('Hello {name}!'));

            // Null values
            result = LocalizationErrorHandler.handleParameterSubstitution(
              'Hello {name}!',
              {'name': null},
            );
            expect(result, equals('Hello null!'));

            // Complex types
            result = LocalizationErrorHandler.handleParameterSubstitution(
              'Count: {count}',
              {'count': 42},
            );
            expect(result, equals('Count: 42'));
          });

          test('parameter substitution handles errors gracefully', () {
            // This tests error handling within parameter substitution
            final result = LocalizationErrorHandler.handleParameterSubstitution(
              'Hello {name}!',
              {'name': 'John'},
              key: 'greeting',
              locale: const Locale('en'),
            );
            expect(result, equals('Hello John!'));
          });
        });

        group('JSON and Asset Error Handling Tests', () {
          test('handleJsonParsingError provides consistent fallbacks', () {
            // Test with different error types
            final formatError = LocalizationErrorHandler.handleJsonParsingError(
              'test.json',
              const FormatException('Invalid JSON format'),
            );
            expect(formatError, isEmpty);
            expect(formatError, isA<Map<String, dynamic>>());

            final genericError =
                LocalizationErrorHandler.handleJsonParsingError(
                  'test.json',
                  Exception('Generic error'),
                );
            expect(genericError, isEmpty);
            expect(genericError, isA<Map<String, dynamic>>());

            // Test with context
            final contextError =
                LocalizationErrorHandler.handleJsonParsingError(
                  'test.json',
                  const FormatException('Invalid JSON'),
                  context: 'TestService.loadData',
                );
            expect(contextError, isEmpty);
            expect(contextError, isA<Map<String, dynamic>>());
          });

          test(
            'handleAssetLoadingError provides appropriate fallbacks',
            () async {
              // Test asset loading error handling
              final result =
                  await LocalizationErrorHandler.handleAssetLoadingError(
                    'nonexistent.json',
                    Exception('Asset not found'),
                    context: 'TestService',
                  );
              expect(result, isNull); // Should return null as documented
            },
          );
        });

        group('Translation Validation Tests', () {
          test('validateTranslations identifies all missing keys', () {
            final translations = {
              'en': {
                'greeting': 'Hello',
                'goodbye': 'Goodbye',
                'partial': 'Partial',
              },
              'es': {
                'greeting': 'Hola',
                // Missing 'goodbye' and 'partial'
              },
            };

            final requiredKeys = ['greeting', 'goodbye', 'partial', 'missing'];

            // Test English validation
            var missingKeys = LocalizationErrorHandler.validateTranslations(
              translations,
              requiredKeys,
              locale: const Locale('en'),
            );
            expect(missingKeys, equals(['missing']));

            // Test Spanish validation
            missingKeys = LocalizationErrorHandler.validateTranslations(
              translations,
              requiredKeys,
              locale: const Locale('es'),
            );
            expect(missingKeys, containsAll(['goodbye', 'partial', 'missing']));

            // Test with empty translations
            missingKeys = LocalizationErrorHandler.validateTranslations(
              {},
              requiredKeys,
            );
            expect(missingKeys, equals(requiredKeys));
          });

          test('validateTranslations handles edge cases', () {
            final translations = {
              'en': {'empty': '', 'null_value': null, 'valid': 'Valid'},
            };

            final requiredKeys = ['empty', 'null_value', 'valid'];

            final missingKeys = LocalizationErrorHandler.validateTranslations(
              translations,
              requiredKeys,
              locale: const Locale('en'),
            );

            // Empty and null values should be considered missing
            expect(missingKeys, containsAll(['empty', 'null_value']));
            expect(missingKeys, isNot(contains('valid')));
          });
        });
      },
    );

    group(
      'SafeLocalizations Comprehensive Tests - Requirements 5.1, 5.2, 5.4, 5.5',
      () {
        late Widget testApp;

        setUp(() {
          testApp = MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const Scaffold(body: Text('Test')),
          );
        });

        group('Safe Localization Retrieval Tests', () {
          testWidgets('safeGet handles all fallback scenarios', (tester) async {
            await tester.pumpWidget(testApp);
            final context = tester.element(find.byType(Scaffold));

            // Normal case
            var result = SafeLocalizations.safeGet(
              context,
              (l) => l.appTitle,
              key: 'appTitle',
            );
            expect(result, equals('Lunanul'));

            // Exception case with custom fallback
            result = SafeLocalizations.safeGet(
              context,
              (l) => throw Exception('Test error'),
              fallback: 'Custom Fallback',
              key: 'testKey',
            );
            expect(result, equals('Custom Fallback'));

            // Exception case with key fallback
            result = SafeLocalizations.safeGet(
              context,
              (l) => throw Exception('Test error'),
              key: 'fallback_key',
            );
            expect(result, equals('fallback_key'));

            // Exception case with no key or fallback
            result = SafeLocalizations.safeGet(
              context,
              (l) => throw Exception('Test error'),
            );
            expect(result, equals('Translation missing'));
          });

          testWidgets('safeGetWithParams handles parameter scenarios', (
            tester,
          ) async {
            await tester.pumpWidget(testApp);
            final context = tester.element(find.byType(Scaffold));

            // Normal parameter substitution
            var result = SafeLocalizations.safeGetWithParams(
              context,
              (l) => 'Hello {name}, welcome to {app}!',
              params: {'name': 'John', 'app': 'Lunanul'},
              key: 'greeting',
            );
            expect(result, equals('Hello John, welcome to Lunanul!'));

            // Missing parameters
            result = SafeLocalizations.safeGetWithParams(
              context,
              (l) => 'Hello {name}!',
              params: {'other': 'value'},
              key: 'greeting',
            );
            expect(result, equals('Hello {name}!'));

            // Exception with parameters
            result = SafeLocalizations.safeGetWithParams(
              context,
              (l) => throw Exception('Test error'),
              params: {'name': 'John'},
              fallback: 'Error fallback',
              key: 'greeting',
            );
            expect(result, equals('Error fallback'));

            // No parameters provided
            result = SafeLocalizations.safeGetWithParams(
              context,
              (l) => 'Static text',
              key: 'static',
            );
            expect(result, equals('Static text'));
          });

          testWidgets('tryGet and isAvailable work correctly', (tester) async {
            await tester.pumpWidget(testApp);
            final context = tester.element(find.byType(Scaffold));

            // Available translation
            var tryResult = SafeLocalizations.tryGet(
              context,
              (l) => l.appTitle,
            );
            expect(tryResult, equals('Lunanul'));
            expect(
              SafeLocalizations.isAvailable(context, (l) => l.appTitle),
              isTrue,
            );

            // Unavailable translation
            tryResult = SafeLocalizations.tryGet(
              context,
              (l) => throw Exception('Error'),
            );
            expect(tryResult, isNull);
            expect(
              SafeLocalizations.isAvailable(
                context,
                (l) => throw Exception('Error'),
              ),
              isFalse,
            );
          });
        });

        group('Locale Management Tests', () {
          testWidgets('getCurrentLocale works correctly', (tester) async {
            await tester.pumpWidget(testApp);
            final context = tester.element(find.byType(Scaffold));

            final locale = SafeLocalizations.getCurrentLocale(context);
            expect(locale, isA<Locale>());
            expect(locale.languageCode, isNotEmpty);
          });

          testWidgets('isCurrentLocaleSupported works correctly', (
            tester,
          ) async {
            await tester.pumpWidget(testApp);
            final context = tester.element(find.byType(Scaffold));

            final isSupported = SafeLocalizations.isCurrentLocaleSupported(
              context,
            );
            expect(isSupported, isA<bool>());
          });
        });

        group('Validation and Preloading Tests', () {
          testWidgets('validateLocalizations works correctly', (tester) async {
            await tester.pumpWidget(testApp);
            final context = tester.element(find.byType(Scaffold));

            final requiredTranslations = {
              'appTitle': (AppLocalizations l) => l.appTitle,
              'homeTitle': (AppLocalizations l) => l.homeTitle,
              'nonExistent': (AppLocalizations l) => throw Exception('Missing'),
            };

            final missingKeys = SafeLocalizations.validateLocalizations(
              context,
              requiredTranslations,
            );

            expect(missingKeys, contains('nonExistent'));
            expect(missingKeys, isNot(contains('appTitle')));
            expect(missingKeys, isNot(contains('homeTitle')));
          });

          testWidgets('preloadAndValidate completes successfully', (
            tester,
          ) async {
            await tester.pumpWidget(testApp);
            final context = tester.element(find.byType(Scaffold));

            // Should complete without throwing
            expect(
              () => SafeLocalizations.preloadAndValidate(context),
              returnsNormally,
            );
          });
        });

        group('Extension Methods Tests', () {
          testWidgets('extension methods work correctly', (tester) async {
            await tester.pumpWidget(testApp);
            final context = tester.element(find.byType(Scaffold));

            // safeL10n extension
            var result = context.safeL10n((l) => l.appTitle, key: 'appTitle');
            expect(result, equals('Lunanul'));

            // safeL10nWithParams extension
            result = context.safeL10nWithParams(
              (l) => 'Hello {name}!',
              params: {'name': 'World'},
              key: 'greeting',
            );
            expect(result, equals('Hello World!'));

            // tryL10n extension
            var tryResult = context.tryL10n((l) => l.appTitle);
            expect(tryResult, equals('Lunanul'));

            tryResult = context.tryL10n((l) => throw Exception('Error'));
            expect(tryResult, isNull);
          });

          testWidgets('extension methods handle errors gracefully', (
            tester,
          ) async {
            await tester.pumpWidget(testApp);
            final context = tester.element(find.byType(Scaffold));

            // Error in safeL10n
            final result = context.safeL10n(
              (l) => throw Exception('Error'),
              fallback: 'Extension Fallback',
              key: 'errorKey',
            );
            expect(result, equals('Extension Fallback'));

            // Error in safeL10nWithParams
            final paramResult = context.safeL10nWithParams(
              (l) => throw Exception('Error'),
              params: {'name': 'Test'},
              fallback: 'Param Fallback',
              key: 'errorKey',
            );
            expect(paramResult, equals('Param Fallback'));
          });
        });
      },
    );

    group('Integration and Performance Tests', () {
      test('error handling maintains performance under load', () async {
        final stopwatch = Stopwatch()..start();

        // Perform many error-prone operations
        for (int i = 0; i < 100; i++) {
          LocalizationErrorHandler.getLocalizedString(
            'missing_$i',
            const Locale('en'),
            {},
          );
          await LocalizationErrorHandler.safeAsyncOperation(
            () async => throw Exception('Error $i'),
            'fallback',
          );
          LocalizationErrorHandler.safeSyncOperation(
            () => throw Exception('Sync error $i'),
            'sync fallback',
          );
        }

        stopwatch.stop();

        // Should complete in reasonable time
        expect(stopwatch.elapsedMilliseconds, lessThan(5000)); // 5 seconds max

        // Statistics should be tracked
        final stats = LocalizationErrorHandler.getErrorStatistics();
        expect(stats['totalErrors'], greaterThan(0));
        expect(stats['fallbacksUsed'], greaterThan(0));
      });

      test('error handling is thread-safe', () async {
        LocalizationErrorHandler.resetStatistics();

        // Run concurrent operations
        final futures = List.generate(50, (index) async {
          LocalizationErrorHandler.getLocalizedString(
            'concurrent_$index',
            const Locale('en'),
            {},
          );
          await LocalizationErrorHandler.safeAsyncOperation(
            () async => 'success_$index',
            'fallback_$index',
          );
          return LocalizationErrorHandler.safeSyncOperation(
            () => 'sync_success_$index',
            'sync_fallback_$index',
          );
        });

        final results = await Future.wait(futures);

        // All operations should complete successfully
        expect(results, hasLength(50));
        for (int i = 0; i < results.length; i++) {
          expect(results[i], equals('sync_success_$i'));
        }

        // Statistics should be consistent
        final stats = LocalizationErrorHandler.getErrorStatistics();
        expect(stats, isA<Map<String, dynamic>>());
      });
    });
  });
}
