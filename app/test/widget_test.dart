// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:lunanul/main.dart';

void main() {
  testWidgets('Lunanul app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const LunanulApp());

    // Verify that our app displays the correct title.
    expect(find.text('Lunanul'), findsOneWidget);
    expect(find.text('Your gentle tarot companion'), findsOneWidget);
    expect(find.text('Project structure ready!'), findsOneWidget);
  });
}
