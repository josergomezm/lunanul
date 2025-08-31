import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lunanul/pages/home_page.dart';
import 'package:lunanul/models/models.dart';
import 'package:lunanul/providers/providers.dart';

void main() {
  group('HomePage Tests', () {
    testWidgets('HomePage displays greeting section', (
      WidgetTester tester,
    ) async {
      // Create a test container with mock providers
      final container = ProviderContainer(
        overrides: [
          currentUserProvider.overrideWith(
            (ref) async => User(
              id: 'test-user',
              name: 'Test User',
              createdAt: DateTime.now(),
              lastActiveAt: DateTime.now(),
            ),
          ),
          cardOfTheDayProvider.overrideWith(
            (ref) async => TarotCard(
              id: 'test-card',
              name: 'The Fool',
              suit: TarotSuit.majorArcana,
              imageUrl: 'https://example.com/fool.jpg',
              keywords: ['new beginnings', 'innocence'],
              uprightMeaning: 'New beginnings and fresh starts',
              reversedMeaning: 'Recklessness and poor judgment',
            ),
          ),
          recentReadingsProvider.overrideWith((ref) async => <Reading>[]),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(home: HomePage()),
        ),
      );

      // Wait for async operations to complete
      await tester.pumpAndSettle();

      // Verify greeting section is displayed
      expect(find.text('Good morning'), findsOneWidget);
      expect(find.text('Test User'), findsOneWidget);

      // Verify Card of the Day section is displayed
      expect(find.text('Card of the Day'), findsOneWidget);

      // Verify Recent Readings section is displayed
      expect(find.text('Recent Readings'), findsOneWidget);

      // Verify Daily Reflection section is displayed
      expect(find.text('Daily Reflection'), findsOneWidget);

      container.dispose();
    });

    testWidgets('Card of the Day can be revealed', (WidgetTester tester) async {
      final container = ProviderContainer(
        overrides: [
          currentUserProvider.overrideWith(
            (ref) async => User(
              id: 'test-user',
              name: 'Test User',
              createdAt: DateTime.now(),
              lastActiveAt: DateTime.now(),
            ),
          ),
          cardOfTheDayProvider.overrideWith(
            (ref) async => TarotCard(
              id: 'test-card',
              name: 'The Fool',
              suit: TarotSuit.majorArcana,
              imageUrl: 'https://example.com/fool.jpg',
              keywords: ['new beginnings', 'innocence'],
              uprightMeaning: 'New beginnings and fresh starts',
              reversedMeaning: 'Recklessness and poor judgment',
            ),
          ),
          recentReadingsProvider.overrideWith((ref) async => <Reading>[]),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(home: HomePage()),
        ),
      );

      await tester.pumpAndSettle();

      // Initially should show tap instruction
      expect(
        find.text('Tap the card to reveal your daily guidance'),
        findsOneWidget,
      );

      // Tap the card to reveal it
      await tester.tap(find.byType(GestureDetector).first);
      await tester.pumpAndSettle();

      // Should now show the card name and meaning
      expect(find.text('The Fool'), findsOneWidget);
      expect(find.text('New beginnings and fresh starts'), findsOneWidget);

      container.dispose();
    });
  });
}
