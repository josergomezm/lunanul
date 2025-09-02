import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:lunanul/widgets/guide_selector_widget.dart';
import 'package:lunanul/models/enums.dart';
import 'package:lunanul/utils/app_theme.dart';
import 'package:lunanul/l10n/generated/app_localizations.dart';

void main() {
  group('GuideSelectorWidget Tests', () {
    Widget createTestWidget({
      GuideType? selectedGuide,
      ReadingTopic? currentTopic,
      required Function(GuideType) onGuideSelected,
    }) {
      return ProviderScope(
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en', ''), Locale('es', '')],
          home: Scaffold(
            body: SizedBox(
              height: 800, // Provide enough height for the widget
              child: GuideSelectorWidget(
                selectedGuide: selectedGuide,
                currentTopic: currentTopic,
                onGuideSelected: (guide) => onGuideSelected(guide!),
              ),
            ),
          ),
        ),
      );
    }

    testWidgets('displays all four guides', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          onGuideSelected: (guide) {
            // Guide selection callback for testing
          },
        ),
      );

      // Wait for animations to complete
      await tester.pumpAndSettle();

      // Verify all four guides are displayed
      expect(find.text('Zian'), findsOneWidget);
      expect(find.text('Lyra'), findsOneWidget);
      expect(find.text('Kael'), findsOneWidget);
      expect(find.text('Elara'), findsOneWidget);

      // Verify guide titles are displayed
      expect(find.text('The Wise Mystic'), findsOneWidget);
      expect(find.text('The Compassionate Healer'), findsOneWidget);
      expect(find.text('The Practical Strategist'), findsOneWidget);
      expect(find.text('The Creative Muse'), findsOneWidget);
    });

    testWidgets('handles guide selection', (WidgetTester tester) async {
      GuideType? selectedGuide;

      await tester.pumpWidget(
        createTestWidget(
          onGuideSelected: (guide) {
            selectedGuide = guide;
          },
        ),
      );

      await tester.pumpAndSettle();

      // Tap on Zian (The Sage)
      await tester.tap(find.text('Zian'));
      await tester.pumpAndSettle();

      // Verify selection callback was called
      expect(selectedGuide, equals(GuideType.sage));
    });

    testWidgets('shows recommendations for specific topic', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          currentTopic: ReadingTopic.love,
          onGuideSelected: (guide) {},
        ),
      );

      await tester.pumpAndSettle();

      // Verify recommendation banner is shown
      expect(find.textContaining('Recommended for Love'), findsOneWidget);
      expect(find.textContaining('Lyra, Elara'), findsOneWidget);
    });

    testWidgets('displays selection indicator for selected guide', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          selectedGuide: GuideType.healer,
          onGuideSelected: (guide) {},
        ),
      );

      await tester.pumpAndSettle();

      // Verify selection indicator (check icon) is present
      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('expands guide description on long press', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget(onGuideSelected: (guide) {}));

      await tester.pumpAndSettle();

      // Long press on Zian to expand description
      await tester.longPress(find.text('Zian'));
      await tester.pumpAndSettle();

      // Verify expanded content is shown
      expect(find.textContaining('Expertise:'), findsOneWidget);
    });

    testWidgets('shows recommendation badges for recommended guides', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          currentTopic: ReadingTopic.work,
          onGuideSelected: (guide) {},
        ),
      );

      await tester.pumpAndSettle();

      // For work topic, Kael and Zian should be recommended
      // Verify recommendation badges are shown
      expect(find.text('Recommended'), findsAtLeastNWidgets(1));
    });
  });
}
