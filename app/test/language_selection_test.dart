import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lunanul/widgets/language_selection_widget.dart';
import 'package:lunanul/l10n/generated/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  group('Language Selection Widget Tests', () {
    testWidgets('should display language options', (WidgetTester tester) async {
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
            home: const Scaffold(body: LanguageSelectionWidget()),
          ),
        ),
      );

      // Wait for the widget to build
      await tester.pumpAndSettle();

      // Check if language options are displayed
      expect(find.text('English'), findsWidgets);
      expect(find.text('Español'), findsWidgets);

      // Check if language icon is displayed
      expect(find.byIcon(Icons.language), findsOneWidget);
    });

    testWidgets('should show current language selection', (
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
            home: const Scaffold(body: LanguageSelectionWidget()),
          ),
        ),
      );

      // Wait for the widget to build
      await tester.pumpAndSettle();

      // Check if current language indicator is shown
      expect(find.byIcon(Icons.check_circle), findsWidgets);
    });

    testWidgets('should respond to language option taps', (
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
            home: const Scaffold(body: LanguageSelectionWidget()),
          ),
        ),
      );

      // Wait for the widget to build
      await tester.pumpAndSettle();

      // Find and tap the Spanish option by finding the InkWell containing Spanish text
      final spanishContainer = find.ancestor(
        of: find.text('Español').first,
        matching: find.byType(InkWell),
      );
      expect(spanishContainer, findsOneWidget);

      // Verify the tap doesn't cause errors
      await tester.tap(spanishContainer);
      await tester.pumpAndSettle();

      // Verify the widget is still there after tap
      expect(find.byType(LanguageSelectionWidget), findsOneWidget);
    });
  });
}
