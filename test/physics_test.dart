import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:squawker/ui/physics.dart';

void main() {
  group('Physics UI Components', () {
    group('LessSensitiveScrollPhysics', () {
      test('should create instance without parent', () {
        // Act
        const physics = LessSensitiveScrollPhysics();

        // Assert
        expect(physics, isNotNull);
        expect(physics.parent, isNull);
      });

      test('should create instance with parent', () {
        // Arrange
        const parentPhysics = BouncingScrollPhysics();

        // Act
        const physics = LessSensitiveScrollPhysics(parent: parentPhysics);

        // Assert
        expect(physics, isNotNull);
        expect(physics.parent, equals(parentPhysics));
      });

      test('applyTo should return new instance with correct parent chain', () {
        // Arrange
        const physics = LessSensitiveScrollPhysics();
        const ancestorPhysics = ClampingScrollPhysics();

        // Act
        final newPhysics = physics.applyTo(ancestorPhysics);

        // Assert
        expect(newPhysics, isA<LessSensitiveScrollPhysics>());
        expect(newPhysics, isNot(same(physics)));
      });

      test('spring should have heavy mass configuration', () {
        // Arrange
        const physics = LessSensitiveScrollPhysics();

        // Act
        final spring = physics.spring;

        // Assert
        expect(spring.mass, equals(50));
        expect(spring.stiffness, equals(100));
        expect(spring.damping, equals(1));
      });

      test('spring should be less sensitive than default', () {
        // Arrange
        const lessPhysics = LessSensitiveScrollPhysics();
        const defaultPhysics = ScrollPhysics();

        // Act
        final lessSpring = lessPhysics.spring;
        final defaultSpring = defaultPhysics.spring;

        // Assert - Higher mass means less sensitive
        expect(lessSpring.mass, greaterThan(defaultSpring.mass));
      });

      test('should maintain physics hierarchy when applied multiple times', () {
        // Arrange
        const physics1 = LessSensitiveScrollPhysics();
        const physics2 = BouncingScrollPhysics();
        const physics3 = ClampingScrollPhysics();

        // Act
        final combined1 = physics1.applyTo(physics2);
        final combined2 = combined1.applyTo(physics3);

        // Assert
        expect(combined1, isA<LessSensitiveScrollPhysics>());
        expect(combined2, isA<LessSensitiveScrollPhysics>());
      });

      testWidgets('should work with PageView widget', (WidgetTester tester) async {
        // Arrange
        final pageController = PageController();

        final widget = MaterialApp(
          home: Scaffold(
            body: PageView(
              controller: pageController,
              physics: const LessSensitiveScrollPhysics(),
              children: const [
                Center(child: Text('Page 1')),
                Center(child: Text('Page 2')),
                Center(child: Text('Page 3')),
              ],
            ),
          ),
        );

        // Act
        await tester.pumpWidget(widget);

        // Assert
        expect(find.text('Page 1'), findsOneWidget);
        expect(find.text('Page 2'), findsNothing);

        // Cleanup
        pageController.dispose();
      });

      testWidgets('should work with ListView widget', (WidgetTester tester) async {
        // Arrange
        final widget = MaterialApp(
          home: Scaffold(
            body: ListView(
              physics: const LessSensitiveScrollPhysics(),
              children: List.generate(20, (index) => ListTile(title: Text('Item $index'))),
            ),
          ),
        );

        // Act
        await tester.pumpWidget(widget);

        // Assert
        expect(find.text('Item 0'), findsOneWidget);
        expect(find.byType(ListView), findsOneWidget);
      });
    });
  });
}
