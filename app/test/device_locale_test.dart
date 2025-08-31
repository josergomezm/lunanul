import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lunanul/main.dart';
import 'package:lunanul/l10n/generated/app_localizations.dart';

void main() {
  group('Device Locale Tests', () {
    testWidgets('App handles English device locale', (tester) async {
      // Set device locale to English
      tester.view.platformDispatcher.localeTestValue = const Locale('en', 'US');

      await tester.pumpWidget(const ProviderScope(child: LunanulApp()));
      await tester.pumpAndSettle();

      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));

      // Verify app starts without errors
      expect(find.byType(MaterialApp), findsOneWidget);

      // Verify locale resolution works
      expect(materialApp.localeResolutionCallback, isNotNull);
    });

    testWidgets('App handles Spanish device locale', (tester) async {
      // Set device locale to Spanish
      tester.view.platformDispatcher.localeTestValue = const Locale('es', 'ES');

      await tester.pumpWidget(const ProviderScope(child: LunanulApp()));
      await tester.pumpAndSettle();

      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));

      // Verify app starts without errors
      expect(find.byType(MaterialApp), findsOneWidget);

      // Verify supported locales include Spanish
      expect(materialApp.supportedLocales, contains(const Locale('es')));
    });

    testWidgets('App handles unsupported device locale', (tester) async {
      // Set device locale to French (unsupported)
      tester.view.platformDispatcher.localeTestValue = const Locale('fr', 'FR');

      await tester.pumpWidget(const ProviderScope(child: LunanulApp()));
      await tester.pumpAndSettle();

      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      final localeResolutionCallback = materialApp.localeResolutionCallback;

      // Test that unsupported locale falls back to English
      final resolvedLocale = localeResolutionCallback!(
        const Locale('fr', 'FR'),
        AppLocalizations.supportedLocales,
      );

      expect(resolvedLocale, equals(const Locale('en')));
    });

    testWidgets('App handles null device locale', (tester) async {
      await tester.pumpWidget(const ProviderScope(child: LunanulApp()));
      await tester.pumpAndSettle();

      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      final localeResolutionCallback = materialApp.localeResolutionCallback;

      // Test that null locale returns null (uses system default)
      final resolvedLocale = localeResolutionCallback!(
        null,
        AppLocalizations.supportedLocales,
      );

      expect(resolvedLocale, isNull);
    });

    testWidgets('Locale resolution handles partial matches', (tester) async {
      await tester.pumpWidget(const ProviderScope(child: LunanulApp()));
      await tester.pumpAndSettle();

      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      final localeResolutionCallback = materialApp.localeResolutionCallback;

      // Test Spanish with different country code
      final resolvedLocale = localeResolutionCallback!(
        const Locale('es', 'MX'), // Spanish Mexico
        AppLocalizations.supportedLocales,
      );

      // Should resolve to Spanish (ignoring country code)
      expect(resolvedLocale, equals(const Locale('es')));
    });
  });
}
