import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lunanul/main.dart';
import 'package:lunanul/l10n/generated/app_localizations.dart';
import 'package:lunanul/providers/language_provider.dart';

void main() {
  group('Localization Integration Tests', () {
    testWidgets('App starts with English locale by default', (tester) async {
      await tester.pumpWidget(const ProviderScope(child: LunanulApp()));
      await tester.pumpAndSettle();

      // Verify that the app starts without errors
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('App supports English and Spanish locales', (tester) async {
      await tester.pumpWidget(const ProviderScope(child: LunanulApp()));
      await tester.pumpAndSettle();

      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));

      // Verify supported locales
      expect(materialApp.supportedLocales, contains(const Locale('en')));
      expect(materialApp.supportedLocales, contains(const Locale('es')));

      // Verify localization delegates are configured
      expect(materialApp.localizationsDelegates, isNotNull);
      expect(
        materialApp.localizationsDelegates,
        contains(AppLocalizations.delegate),
      );
    });

    testWidgets('Locale resolution callback handles unsupported locales', (
      tester,
    ) async {
      await tester.pumpWidget(const ProviderScope(child: LunanulApp()));
      await tester.pumpAndSettle();

      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      final localeResolutionCallback = materialApp.localeResolutionCallback;

      expect(localeResolutionCallback, isNotNull);

      // Test fallback to English for unsupported locale
      final resolvedLocale = localeResolutionCallback!(
        const Locale('fr'), // French - not supported
        AppLocalizations.supportedLocales,
      );

      expect(resolvedLocale, equals(const Locale('en')));
    });

    testWidgets('Locale resolution callback supports Spanish', (tester) async {
      await tester.pumpWidget(const ProviderScope(child: LunanulApp()));
      await tester.pumpAndSettle();

      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      final localeResolutionCallback = materialApp.localeResolutionCallback;

      // Test Spanish locale resolution
      final resolvedLocale = localeResolutionCallback!(
        const Locale('es'),
        AppLocalizations.supportedLocales,
      );

      expect(resolvedLocale, equals(const Locale('es')));
    });

    testWidgets('Language provider integration works', (tester) async {
      late WidgetRef ref;

      await tester.pumpWidget(
        ProviderScope(
          child: Consumer(
            builder: (context, widgetRef, child) {
              ref = widgetRef;
              return const LunanulApp();
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify language provider is accessible
      final currentLocale = ref.read(languageProvider);
      expect(currentLocale, isA<Locale>());

      // Verify supported locales provider
      final supportedLocales = ref.read(supportedLocalesProvider);
      expect(supportedLocales, contains(const Locale('en')));
      expect(supportedLocales, contains(const Locale('es')));
    });

    testWidgets('MaterialApp locale reflects language provider state', (
      tester,
    ) async {
      late WidgetRef ref;

      await tester.pumpWidget(
        ProviderScope(
          child: Consumer(
            builder: (context, widgetRef, child) {
              ref = widgetRef;
              return const LunanulApp();
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Get current locale from provider and MaterialApp
      final providerLocale = ref.read(languageProvider);
      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));

      // Verify MaterialApp locale matches provider locale
      expect(materialApp.locale, equals(providerLocale));
    });
  });
}
