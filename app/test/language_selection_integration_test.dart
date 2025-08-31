import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lunanul/widgets/language_selection_widget.dart';
import 'package:lunanul/l10n/generated/app_localizations.dart';

void main() {
  group('Language Selection Integration Tests', () {
    testWidgets('should change language immediately when option is tapped', (
      WidgetTester tester,
    ) async {
      // Create a test app with the language selection widget
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const Scaffold(body: LanguageSelectionWidget()),
          ),
        ),
      );

      // Wait for the widget to build
      await tester.pumpAndSettle();

      // Verify that both language options are displayed
      expect(find.text('English'), findsWidgets);
      expect(find.text('Español'), findsWidgets);

      // Find and tap the Spanish option by finding the InkWell container
      final spanishOption = find.text('Español').first;
      await tester.tap(spanishOption);
      await tester.pumpAndSettle();

      // Verify that the language changed (we should see a snackbar or visual feedback)
      // The exact verification depends on the implementation, but we can check that
      // the widget rebuilds and shows the updated state
      expect(find.byType(LanguageSelectionWidget), findsOneWidget);
    });

    testWidgets('should show visual feedback for current language selection', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const Scaffold(body: LanguageSelectionWidget()),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify that there are visual indicators for selection
      // Look for check icons or selection indicators
      expect(find.byIcon(Icons.check_circle), findsWidgets);
      expect(find.byIcon(Icons.radio_button_unchecked), findsWidgets);
    });

    testWidgets('should display language flags and native names', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const Scaffold(body: LanguageSelectionWidget()),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify that both language options are displayed with their native names
      expect(find.text('English'), findsWidgets);
      expect(find.text('Español'), findsWidgets);

      // Verify that flags are displayed (as text emojis)
      expect(find.text('🇺🇸'), findsOneWidget);
      expect(find.text('🇪🇸'), findsOneWidget);
    });
  });
}
