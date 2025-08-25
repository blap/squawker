import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:squawker/ui/physics.dart';
import 'package:squawker/ui/dates.dart';

void main() {
  group('LessSensitiveScrollPhysics', () {
    test('should create instance with default constructor', () {
      // Act
      const physics = LessSensitiveScrollPhysics();

      // Assert
      expect(physics, isA<LessSensitiveScrollPhysics>());
      expect(physics, isA<ScrollPhysics>());
    });

    test('should create instance with parent physics', () {
      // Arrange
      const parentPhysics = ClampingScrollPhysics();

      // Act
      const physics = LessSensitiveScrollPhysics(parent: parentPhysics);

      // Assert
      expect(physics, isA<LessSensitiveScrollPhysics>());
      expect(physics.parent, parentPhysics);
    });

    test('should return correct spring description with high mass', () {
      // Arrange
      const physics = LessSensitiveScrollPhysics();

      // Act
      final spring = physics.spring;

      // Assert
      expect(spring.mass, 50);
      expect(spring.stiffness, 100);
      expect(spring.damping, 1);
    });

    test('should apply to ancestor physics correctly', () {
      // Arrange
      const physics = LessSensitiveScrollPhysics();
      const ancestor = BouncingScrollPhysics();

      // Act
      final applied = physics.applyTo(ancestor);

      // Assert
      expect(applied, isA<LessSensitiveScrollPhysics>());
      expect(applied, isNot(same(physics))); // Should create new instance
    });

    test('should handle null ancestor in applyTo', () {
      // Arrange
      const physics = LessSensitiveScrollPhysics();

      // Act
      final applied = physics.applyTo(null);

      // Assert
      expect(applied, isA<LessSensitiveScrollPhysics>());
    });
  });

  group('Dates', () {
    group('createRelativeDate', () {
      test('should create relative date string', () {
        // Arrange
        final testDate = DateTime.now().subtract(const Duration(minutes: 5));

        // Act
        final result = createRelativeDate(testDate);

        // Assert
        expect(result, isA<String>());
        expect(result, isNotEmpty);
      });

      test('should handle past dates', () {
        // Arrange
        final pastDate = DateTime.now().subtract(const Duration(days: 1));

        // Act
        final result = createRelativeDate(pastDate);

        // Assert
        expect(result, isA<String>());
        expect(result, isNotEmpty);
      });
    });

    group('absoluteDateFormat', () {
      test('should format dates correctly', () {
        // Arrange
        final testDate = DateTime(2023, 12, 25, 15, 30, 45);

        // Act
        final formatted = absoluteDateFormat.format(testDate);

        // Assert
        expect(formatted, isNotEmpty);
        expect(formatted, contains('2023'));
        expect(formatted, contains('Dec'));
        expect(formatted, contains('25'));
      });
    });

    group('Timestamp Widget', () {
      testWidgets('should display container for null timestamp', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(const MaterialApp(home: Scaffold(body: Timestamp(timestamp: null))));

        // Assert
        expect(find.byType(Container), findsOneWidget);
        expect(find.byType(Text), findsNothing);
      });

      testWidgets('should display text for valid timestamp', (WidgetTester tester) async {
        // Arrange
        final timestamp = DateTime.now().subtract(const Duration(minutes: 5));

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: Timestamp(timestamp: timestamp)),
          ),
        );

        // Assert
        expect(find.byType(Text), findsOneWidget);
        expect(find.byType(GestureDetector), findsOneWidget);

        final textWidget = tester.widget<Text>(find.byType(Text));
        expect(textWidget.data, isNotEmpty);
      });

      testWidgets('should be tappable', (WidgetTester tester) async {
        // Arrange
        final timestamp = DateTime.now().subtract(const Duration(hours: 1));

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: Timestamp(timestamp: timestamp)),
          ),
        );

        // Assert
        expect(find.byType(GestureDetector), findsOneWidget);

        // Should not throw when tapped
        await tester.tap(find.byType(GestureDetector));
        await tester.pump();
      });
    });
  });
}
