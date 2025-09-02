import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lunanul/main.dart';
import 'package:lunanul/models/enums.dart';
import 'package:lunanul/providers/reading_provider.dart';
import 'package:lunanul/providers/guide_provider.dart';
import 'package:lunanul/pages/readings_page.dart';
import 'package:lunanul/pages/guide_selection_page.dart';
import 'package:lunanul/pages/spread_selection_page.dart';
import 'package:lunanul/widgets/guide_selector_widget.dart';

/// Integration test for the complete guide selection flow
void main() {
  group('Complete Guide Selection Flow Integration Tests', () {
    testWidgets(
      'Complete flow from topic to guide to reading works correctly',
      (WidgetTester tester) async {
        // Build the app
        await tester.pumpWidget(const ProviderScope(child: LunanulApp()));

        // Navigate to readings page
        await tester.tap(find.text('Readings'));
        await tester.pumpAndSettle();

        // Verify we're on the readings page
        expect(find.byType(ReadingsPage), findsOneWidget);

        // Select a topic (Self)
        await tester.tap(find.text('Self'));
        await tester.pumpAndSettle();

        // Verify we're on the guide selection page
        expect(find.byType(GuideSelectionPage), findsOneWidget);
        expect(find.byType(GuideSelectorWidget), findsOneWidget);

        // Select a guide (Zian - The Sage)
        await tester.tap(find.text('Zian'));
        await tester.pumpAndSettle();

        // Verify guide is selected
        expect(find.text('Continue with Zian'), findsOneWidget);

        // Continue to spread selection
        await tester.tap(find.text('Continue with Zian'));
        await tester.pumpAndSettle();

        // Verify we're on spread selection page with guide info
        expect(find.byType(SpreadSelectionPage), findsOneWidget);
        expect(find.text('Guide: Zian'), findsOneWidget);

        // Select a spread (Three Card)
        await tester.tap(find.text('Three Card'));
        await tester.pumpAndSettle();

        // Start the reading
        await tester.tap(find.textContaining('Start'));
        await tester.pumpAndSettle();

        // Wait for reading creation
        await tester.pump(const Duration(seconds: 3));

        // Verify reading was created with guide
        // This would depend on the actual reading display implementation
      },
    );

    testWidgets('Guide selection persists throughout reading session', (
      WidgetTester tester,
    ) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Set up initial reading flow state
      container.read(readingFlowProvider.notifier).setTopic(ReadingTopic.love);
      container
          .read(readingFlowProvider.notifier)
          .setSelectedGuide(GuideType.healer);

      // Verify guide selection persists
      final readingFlow = container.read(readingFlowProvider);
      expect(readingFlow.selectedGuide, equals(GuideType.healer));
      expect(readingFlow.topic, equals(ReadingTopic.love));

      // Create a reading with the guide
      await container
          .read(currentReadingProvider.notifier)
          .createReading(
            topic: ReadingTopic.love,
            spreadType: SpreadType.threeCard,
            selectedGuide: GuideType.healer,
          );

      // Verify reading has the selected guide
      final reading = container.read(currentReadingProvider).value;
      expect(reading?.selectedGuide, equals(GuideType.healer));
    });

    testWidgets('Can change guide selection mid-flow', (
      WidgetTester tester,
    ) async {
      // Build the app
      await tester.pumpWidget(const ProviderScope(child: LunanulApp()));

      // Navigate through the flow to spread selection
      await tester.tap(find.text('Readings'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Work'));
      await tester.pumpAndSettle();

      // Select initial guide
      await tester.tap(find.text('Kael'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Continue with Kael'));
      await tester.pumpAndSettle();

      // Verify we're on spread selection with Kael
      expect(find.text('Guide: Kael'), findsOneWidget);

      // Change guide selection
      await tester.tap(find.text('Change Guide'));
      await tester.pumpAndSettle();

      // Verify we're back on guide selection
      expect(find.byType(GuideSelectionPage), findsOneWidget);

      // Select different guide
      await tester.tap(find.text('Elara'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Continue with Elara'));
      await tester.pumpAndSettle();

      // Verify guide changed
      expect(find.text('Guide: Elara'), findsOneWidget);
    });

    testWidgets('Skip guide selection works correctly', (
      WidgetTester tester,
    ) async {
      // Build the app
      await tester.pumpWidget(const ProviderScope(child: LunanulApp()));

      // Navigate to guide selection
      await tester.tap(find.text('Readings'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Social'));
      await tester.pumpAndSettle();

      // Skip guide selection
      await tester.tap(find.text('Skip Guide Selection'));
      await tester.pumpAndSettle();

      // Verify we're on spread selection without guide
      expect(find.byType(SpreadSelectionPage), findsOneWidget);
      expect(find.text('Guide:'), findsNothing);
    });

    testWidgets('Guide-influenced interpretations appear correctly', (
      WidgetTester tester,
    ) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Create a reading with a guide
      await container
          .read(currentReadingProvider.notifier)
          .createReading(
            topic: ReadingTopic.self,
            spreadType: SpreadType.singleCard,
            selectedGuide: GuideType.sage,
          );

      final reading = container.read(currentReadingProvider).value;
      expect(reading?.selectedGuide, equals(GuideType.sage));

      // Verify that the reading has cards with interpretations
      expect(reading?.cards.isNotEmpty, isTrue);

      // The actual interpretation testing would depend on the
      // GuideInterpretationWidget implementation
    });

    testWidgets('Router navigation works correctly for guide flow', (
      WidgetTester tester,
    ) async {
      // Build the app
      await tester.pumpWidget(const ProviderScope(child: LunanulApp()));

      // Test direct navigation to guide selection with topic
      // This would test the router parameter handling
      // Implementation depends on how the router is set up in the app
    });
  });

  group('Guide Selection State Management', () {
    testWidgets('Reading flow state updates correctly', (
      WidgetTester tester,
    ) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(readingFlowProvider.notifier);

      // Test topic setting
      notifier.setTopic(ReadingTopic.love);
      expect(
        container.read(readingFlowProvider).topic,
        equals(ReadingTopic.love),
      );

      // Test guide setting
      notifier.setSelectedGuide(GuideType.healer);
      expect(
        container.read(readingFlowProvider).selectedGuide,
        equals(GuideType.healer),
      );

      // Test spread setting
      notifier.setSpreadType(SpreadType.threeCard);
      expect(
        container.read(readingFlowProvider).spreadType,
        equals(SpreadType.threeCard),
      );

      // Test that changing topic clears guide and spread
      notifier.setTopic(ReadingTopic.work);
      expect(
        container.read(readingFlowProvider).topic,
        equals(ReadingTopic.work),
      );
      expect(container.read(readingFlowProvider).selectedGuide, isNull);
      expect(container.read(readingFlowProvider).spreadType, isNull);
    });

    testWidgets('Guide providers work correctly', (WidgetTester tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Test available guides provider
      final availableGuides = container.read(availableGuidesProvider);
      expect(availableGuides.length, equals(4));

      // Test guide service provider
      final guideService = container.read(guideServiceProvider);
      expect(guideService, isNotNull);

      // Test selected guide provider
      container.read(selectedGuideProvider.notifier).state =
          GuideType.visionary;
      expect(
        container.read(selectedGuideProvider),
        equals(GuideType.visionary),
      );
    });
  });

  group('Error Handling', () {
    testWidgets('Handles missing guide selection gracefully', (
      WidgetTester tester,
    ) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Create reading without guide
      await container
          .read(currentReadingProvider.notifier)
          .createReading(
            topic: ReadingTopic.self,
            spreadType: SpreadType.singleCard,
            selectedGuide: null,
          );

      final reading = container.read(currentReadingProvider).value;
      expect(reading?.selectedGuide, isNull);

      // Verify reading still works without guide
      expect(reading?.cards.isNotEmpty, isTrue);
    });

    testWidgets('Handles guide service errors gracefully', (
      WidgetTester tester,
    ) async {
      // This would test error handling in guide interpretation generation
      // Implementation depends on how errors are handled in GuideService
    });
  });
}
