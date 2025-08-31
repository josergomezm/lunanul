import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:lunanul/utils/localization_error_handler.dart';

/// Demonstration test showing the error handling and fallback mechanisms in action
void main() {
  group('Error Handling Demonstration', () {
    setUp(() {
      LocalizationErrorHandler.resetStatistics();
    });

    test('demonstrates complete fallback chain', () {
      // Simulate various error scenarios

      // 1. Missing translation with custom fallback
      final result1 = LocalizationErrorHandler.getLocalizedString(
        'missing_key',
        const Locale('en'),
        {},
        fallback: 'Custom Fallback Message',
        context: 'demo',
      );
      expect(result1, equals('Custom Fallback Message'));

      // 2. Missing translation without custom fallback (uses key formatting)
      final result2 = LocalizationErrorHandler.getLocalizedString(
        'user_profile_settings',
        const Locale('en'),
        {},
        context: 'demo',
      );
      expect(result2, equals('User Profile Settings'));

      // 3. Locale fallback (Spanish to English)
      final translations = {
        'en': {'greeting': 'Hello'},
        'fr': {'greeting': 'Bonjour'},
      };

      final result3 = LocalizationErrorHandler.getLocalizedString(
        'greeting',
        const Locale(
          'es',
        ), // Spanish not available, should fall back to English
        translations,
        context: 'demo',
      );
      expect(result3, equals('Hello'));

      // 4. Parameter substitution with error handling
      final result4 = LocalizationErrorHandler.handleParameterSubstitution(
        'Welcome {name} to {app}!',
        {'name': 'User', 'app': 'Lunanul'},
        context: 'demo',
      );
      expect(result4, equals('Welcome User to Lunanul!'));

      // 5. Safe async operation with fallback
      final asyncResult = LocalizationErrorHandler.safeAsyncOperation(
        () async => throw Exception('Simulated async error'),
        'Async Fallback',
        operationName: 'demo_async',
        context: 'demo',
      );

      asyncResult.then((result) {
        expect(result, equals('Async Fallback'));
      });

      // Check that error statistics were tracked
      final stats = LocalizationErrorHandler.getErrorStatistics();
      expect(stats['fallbacksUsed'], greaterThan(0));

      // Verify demo results
      expect(result1, isNotEmpty);
      expect(result2, isNotEmpty);
      expect(result3, isNotEmpty);
      expect(result4, isNotEmpty);
    });

    test('demonstrates locale validation and fallback', () {
      final supportedLocales = [
        const Locale('en', 'US'),
        const Locale('es', 'ES'),
        const Locale('fr', 'FR'),
      ];

      // Test various locale scenarios
      final scenarios = [
        const Locale('en', 'CA'), // English Canada -> English US
        const Locale('es', 'MX'), // Spanish Mexico -> Spanish ES
        const Locale('de', 'DE'), // German -> English (not supported)
        const Locale('zh', 'CN'), // Chinese -> English (not supported)
      ];

      for (final locale in scenarios) {
        final result = LocalizationErrorHandler.validateAndFallbackLocale(
          locale,
          supportedLocales,
        );

        expect(supportedLocales.contains(result), isTrue);
        expect(result, isA<Locale>());
      }
    });

    test('demonstrates safe map operations', () {
      // Test the extension methods for safe map operations
      final testMap = {
        'validString': 'Hello World',
        'validList': ['item1', 'item2', 'item3'],
        'validMap': {'nested': 'value'},
        'nullValue': null,
        'emptyString': '',
      };

      // Safe string retrieval
      expect(testMap.safeGetString('validString'), equals('Hello World'));
      expect(
        testMap.safeGetString('missingKey', fallback: 'default'),
        equals('default'),
      );
      expect(
        testMap.safeGetString('nullValue', fallback: 'default'),
        equals('default'),
      );

      // Safe list retrieval
      expect(
        testMap.safeGetStringList('validList'),
        equals(['item1', 'item2', 'item3']),
      );
      expect(
        testMap.safeGetStringList('missingKey', fallback: ['default']),
        equals(['default']),
      );

      // Safe map retrieval
      expect(testMap.safeGetMap('validMap'), equals({'nested': 'value'}));
      expect(
        testMap.safeGetMap('missingKey', fallback: {'default': 'value'}),
        equals({'default': 'value'}),
      );

      // Verify safe map operations completed
    });

    test('demonstrates error rate monitoring', () {
      // Generate various types of operations
      for (int i = 0; i < 10; i++) {
        // Some successful operations (no errors)
        LocalizationErrorHandler.getLocalizedString(
          'existing_key',
          const Locale('en'),
          {
            'en': {'existing_key': 'Success'},
          },
        );

        // Some operations requiring fallbacks
        LocalizationErrorHandler.getLocalizedString(
          'missing_key_$i',
          const Locale('en'),
          {},
        );
      }

      final stats = LocalizationErrorHandler.getErrorStatistics();
      final isHighErrorRate = LocalizationErrorHandler.isErrorRateHigh(
        threshold: 0.3,
      );

      // Verify error rate monitoring
      expect(stats['totalErrors'], isA<int>());
      expect(stats['fallbacksUsed'], isA<int>());
      expect(stats['errorRate'], isA<double>());
      expect(isHighErrorRate, isA<bool>());

      expect(stats, isA<Map<String, dynamic>>());
      expect(isHighErrorRate, isA<bool>());
    });
  });
}
