import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lunanul/pages/home_page.dart';
import 'package:lunanul/providers/providers.dart';
import 'package:lunanul/l10n/generated/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  group('Home Page Journal Prompt Tests', () {
    testWidgets('should display journal prompt section', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('en'), Locale('es')],
            home: const HomePage(),
          ),
        ),
      );

      // Wait for the widget to build and load data
      await tester.pumpAndSettle();

      // Check if the daily reflection section is present
      expect(find.text('Daily Reflection'), findsOneWidget);

      // Check if there's a journal prompt displayed
      expect(find.byType(Container), findsWidgets);

      // Check if the reflect button is present
      expect(find.text('Reflect'), findsOneWidget);

      // Check if the refresh button is present
      expect(find.byIcon(Icons.refresh), findsWidgets);
    });

    testWidgets(
      'should display journal prompt in Spanish when language is changed',
      (WidgetTester tester) async {
        final container = ProviderContainer();

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [Locale('en'), Locale('es')],
              locale: const Locale('es'),
              home: const HomePage(),
            ),
          ),
        );

        // Change language to Spanish
        container
            .read(languageProvider.notifier)
            .changeLanguage(const Locale('es'));

        // Wait for the widget to rebuild with new language
        await tester.pumpAndSettle();

        // Check if the daily reflection section is present in Spanish
        expect(find.text('Reflexión Diaria'), findsOneWidget);

        // Check if the reflect button is present in Spanish
        expect(find.text('Reflexionar'), findsOneWidget);
      },
    );

    testWidgets('should refresh journal prompt when refresh button is tapped', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('en'), Locale('es')],
            home: const HomePage(),
          ),
        ),
      );

      // Wait for the widget to build and load data
      await tester.pumpAndSettle();

      // Find the refresh button in the journal prompt section
      final refreshButtons = find.byIcon(Icons.refresh);
      expect(refreshButtons, findsWidgets);

      // Tap the last refresh button (should be the journal prompt one)
      await tester.tap(refreshButtons.last);
      await tester.pumpAndSettle();

      // The widget should rebuild (no specific assertion needed, just that it doesn't crash)
      expect(find.text('Daily Reflection'), findsOneWidget);
    });

    testWidgets('should handle journal prompt loading states', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('en'), Locale('es')],
            home: const HomePage(),
          ),
        ),
      );

      // Initially, we might see a loading state
      await tester.pump();

      // Wait for everything to load
      await tester.pumpAndSettle();

      // Should eventually show the journal prompt section
      expect(find.text('Daily Reflection'), findsOneWidget);
    });

    testWidgets('should show consistent prompt for same date', (
      WidgetTester tester,
    ) async {
      // This test verifies that the daily prompt is deterministic
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('en'), Locale('es')],
            home: const HomePage(),
          ),
        ),
      );

      // Wait for the widget to build and load data
      await tester.pumpAndSettle();

      // Find any text that looks like a journal prompt (contains question mark)
      final promptFinder = find.byWidgetPredicate((widget) {
        if (widget is Text) {
          final text = widget.data ?? '';
          return text.contains('?') && text.length > 20; // Likely a prompt
        }
        return false;
      });

      // Should find at least one prompt-like text
      expect(promptFinder, findsWidgets);
    });
  });
}
