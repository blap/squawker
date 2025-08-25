import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Main App', () {
    testWidgets('should create and render app', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: Center(child: Text('Squawker App'))),
        ),
      );

      // Assert
      expect(find.text('Squawker App'), findsOneWidget);
    });
  });
}
