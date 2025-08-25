// This is a basic Flutter widget test for the Squawker app.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Squawker app initializes', (WidgetTester tester) async {
    // Build a simple MaterialApp to verify the testing framework works
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: Text('Squawker Test'))));

    // Verify that the text is found
    expect(find.text('Squawker Test'), findsOneWidget);
  });
}
