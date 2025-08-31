import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lunanul/main.dart';
import 'package:lunanul/l10n/generated/app_localizations.dart';

void main() {
  group('AppLocalizations Tests', () {
    testWidgets('AppLocalizations can be accessed in English', (tester) async {
      await tester.pumpWidget(const ProviderScope(child: LunanulApp()));
      await tester.pumpAndSettle();

      // Build a widget that uses AppLocalizations
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('en'),
            home: Builder(
              builder: (context) {
                final l10n = AppLocalizations.of(context);
                return Scaffold(
                  body: Column(
                    children: [
                      Text(l10n.appTitle, key: const Key('app_title')),
                      Text(l10n.homeTitle, key: const Key('home_title')),
                      Text(l10n.cardOfTheDay, key: const Key('card_of_day')),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify English text is displayed
      expect(find.text('Lunanul'), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Card of the Day'), findsOneWidget);
    });

    testWidgets('AppLocalizations can be accessed in Spanish', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('es'),
            home: Builder(
              builder: (context) {
                final l10n = AppLocalizations.of(context);
                return Scaffold(
                  body: Column(
                    children: [
                      Text(l10n.appTitle, key: const Key('app_title')),
                      Text(l10n.homeTitle, key: const Key('home_title')),
                      Text(l10n.cardOfTheDay, key: const Key('card_of_day')),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Spanish text is displayed
      expect(find.text('Lunanul'), findsOneWidget);
      expect(find.text('Inicio'), findsOneWidget);
      expect(find.text('Carta del Día'), findsOneWidget);
    });

    testWidgets(
      'AppLocalizations provides different text for different locales',
      (tester) async {
        // Test English
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              locale: const Locale('en'),
              home: Builder(
                builder: (context) {
                  final l10n = AppLocalizations.of(context);
                  return Text(l10n.goodMorning, key: const Key('greeting'));
                },
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Good morning'), findsOneWidget);

        // Test Spanish
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              locale: const Locale('es'),
              home: Builder(
                builder: (context) {
                  final l10n = AppLocalizations.of(context);
                  return Text(l10n.goodMorning, key: const Key('greeting'));
                },
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Buenos días'), findsOneWidget);
      },
    );
  });
}
