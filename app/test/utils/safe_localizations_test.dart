import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lunanul/l10n/generated/app_localizations.dart';
import 'package:lunanul/utils/safe_localizations.dart';

void main() {
  group('SafeLocalizations', () {
    late Widget testApp;

    setUp(() {
      testApp = MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(body: Text('Test')),
      );
    });

    testWidgets('safeGet returns localized string when available', (
      tester,
    ) async {
      await tester.pumpWidget(testApp);

      final context = tester.element(find.byType(Scaffold));

      final result = SafeLocalizations.safeGet(
        context,
        (l) => l.appTitle,
        key: 'appTitle',
      );

      expect(result, equals('Lunanul'));
    });

    testWidgets('safeGet returns fallback when getter throws', (tester) async {
      await tester.pumpWidget(testApp);

      final context = tester.element(find.byType(Scaffold));

      final result = SafeLocalizations.safeGet(
        context,
        (l) => throw Exception('Test error'),
        fallback: 'Test Fallback',
        key: 'testKey',
      );

      expect(result, equals('Test Fallback'));
    });

    testWidgets('safeGet returns key as fallback when no custom fallback', (
      tester,
    ) async {
      await tester.pumpWidget(testApp);

      final context = tester.element(find.byType(Scaffold));

      final result = SafeLocalizations.safeGet(
        context,
        (l) => throw Exception('Test error'),
        key: 'testKey',
      );

      expect(result, equals('testKey'));
    });

    testWidgets('safeGetWithParams handles parameter substitution', (
      tester,
    ) async {
      await tester.pumpWidget(testApp);

      final context = tester.element(find.byType(Scaffold));

      final result = SafeLocalizations.safeGetWithParams(
        context,
        (l) => 'Hello {name}, welcome to {app}!',
        params: {'name': 'John', 'app': 'Lunanul'},
        key: 'greeting',
      );

      expect(result, equals('Hello John, welcome to Lunanul!'));
    });

    testWidgets('safeGetWithParams handles parameter substitution errors', (
      tester,
    ) async {
      await tester.pumpWidget(testApp);

      final context = tester.element(find.byType(Scaffold));

      final result = SafeLocalizations.safeGetWithParams(
        context,
        (l) => throw Exception('Test error'),
        fallback: 'Error fallback',
        params: {'name': 'John'},
        key: 'greeting',
      );

      expect(result, equals('Error fallback'));
    });

    testWidgets('tryGet returns null when translation not available', (
      tester,
    ) async {
      await tester.pumpWidget(testApp);

      final context = tester.element(find.byType(Scaffold));

      final result = SafeLocalizations.tryGet(
        context,
        (l) => throw Exception('Test error'),
      );

      expect(result, isNull);
    });

    testWidgets('tryGet returns string when translation available', (
      tester,
    ) async {
      await tester.pumpWidget(testApp);

      final context = tester.element(find.byType(Scaffold));

      final result = SafeLocalizations.tryGet(context, (l) => l.appTitle);

      expect(result, equals('Lunanul'));
    });

    testWidgets('isAvailable returns true when translation exists', (
      tester,
    ) async {
      await tester.pumpWidget(testApp);

      final context = tester.element(find.byType(Scaffold));

      final result = SafeLocalizations.isAvailable(context, (l) => l.appTitle);

      expect(result, isTrue);
    });

    testWidgets('isAvailable returns false when translation throws', (
      tester,
    ) async {
      await tester.pumpWidget(testApp);

      final context = tester.element(find.byType(Scaffold));

      final result = SafeLocalizations.isAvailable(
        context,
        (l) => throw Exception('Test error'),
      );

      expect(result, isFalse);
    });

    testWidgets('getCurrentLocale returns current locale', (tester) async {
      await tester.pumpWidget(testApp);

      final context = tester.element(find.byType(Scaffold));

      final result = SafeLocalizations.getCurrentLocale(context);

      expect(result.languageCode, equals('en'));
    });

    testWidgets('isCurrentLocaleSupported returns true for supported locale', (
      tester,
    ) async {
      await tester.pumpWidget(testApp);

      final context = tester.element(find.byType(Scaffold));

      final result = SafeLocalizations.isCurrentLocaleSupported(context);

      expect(result, isTrue);
    });

    testWidgets('validateLocalizations identifies missing translations', (
      tester,
    ) async {
      await tester.pumpWidget(testApp);

      final context = tester.element(find.byType(Scaffold));

      final requiredTranslations = {
        'appTitle': (AppLocalizations l) => l.appTitle,
        'nonExistent': (AppLocalizations l) => throw Exception('Missing'),
      };

      final missingKeys = SafeLocalizations.validateLocalizations(
        context,
        requiredTranslations,
      );

      expect(missingKeys, contains('nonExistent'));
      expect(missingKeys, isNot(contains('appTitle')));
    });

    group('SafeLocalizationsExtension', () {
      testWidgets('safeL10n extension works correctly', (tester) async {
        await tester.pumpWidget(testApp);

        final context = tester.element(find.byType(Scaffold));

        final result = context.safeL10n((l) => l.appTitle, key: 'appTitle');

        expect(result, equals('Lunanul'));
      });

      testWidgets('safeL10nWithParams extension works correctly', (
        tester,
      ) async {
        await tester.pumpWidget(testApp);

        final context = tester.element(find.byType(Scaffold));

        final result = context.safeL10nWithParams(
          (l) => 'Hello {name}!',
          params: {'name': 'World'},
          key: 'greeting',
        );

        expect(result, equals('Hello World!'));
      });

      testWidgets('tryL10n extension works correctly', (tester) async {
        await tester.pumpWidget(testApp);

        final context = tester.element(find.byType(Scaffold));

        final result = context.tryL10n((l) => l.appTitle);

        expect(result, equals('Lunanul'));
      });

      testWidgets('tryL10n extension returns null on error', (tester) async {
        await tester.pumpWidget(testApp);

        final context = tester.element(find.byType(Scaffold));

        final result = context.tryL10n((l) => throw Exception('Test error'));

        expect(result, isNull);
      });
    });
  });
}
