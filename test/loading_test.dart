import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:squawker/loading.dart';

void main() {
  group('LoadingStack', () {
    testWidgets('should display child when not loading', (WidgetTester tester) async {
      // Arrange
      const testChild = Text('Test Content');
      const widget = LoadingStack(loading: false, child: testChild);

      // Act
      await tester.pumpWidget(const MaterialApp(home: Scaffold(body: widget)));

      // Assert
      expect(find.text('Test Content'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Child should be opaque (visible)
      final childOpacity = tester.widget<AnimatedOpacity>(
        find.ancestor(of: find.text('Test Content'), matching: find.byType(AnimatedOpacity)),
      );
      expect(childOpacity.opacity, 1.0);
    });

    testWidgets('should display loading indicator when loading', (WidgetTester tester) async {
      // Arrange
      const testChild = Text('Test Content');
      const widget = LoadingStack(loading: true, child: testChild);

      // Act
      await tester.pumpWidget(const MaterialApp(home: Scaffold(body: widget)));

      // Assert
      expect(find.text('Test Content'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Child should be transparent (hidden)
      final childOpacity = tester.widget<AnimatedOpacity>(
        find.ancestor(of: find.text('Test Content'), matching: find.byType(AnimatedOpacity)),
      );
      expect(childOpacity.opacity, 0.0);
    });

    testWidgets('should show loading indicator with correct opacity when loading', (WidgetTester tester) async {
      // Arrange
      const widget = LoadingStack(loading: true, child: Text('Content'));

      // Act
      await tester.pumpWidget(const MaterialApp(home: Scaffold(body: widget)));

      // Assert
      final loadingOpacity = tester.widget<AnimatedOpacity>(
        find.ancestor(of: find.byType(CircularProgressIndicator), matching: find.byType(AnimatedOpacity)),
      );
      expect(loadingOpacity.opacity, 1.0);
    });

    testWidgets('should hide loading indicator when not loading', (WidgetTester tester) async {
      // Arrange
      const widget = LoadingStack(loading: false, child: Text('Content'));

      // Act
      await tester.pumpWidget(const MaterialApp(home: Scaffold(body: widget)));

      // Assert
      final loadingOpacity = tester.widget<AnimatedOpacity>(
        find.ancestor(of: find.byType(CircularProgressIndicator), matching: find.byType(AnimatedOpacity)),
      );
      expect(loadingOpacity.opacity, 0.0);
    });

    testWidgets('should use correct animation durations', (WidgetTester tester) async {
      // Arrange
      const widget = LoadingStack(loading: true, child: Text('Content'));

      // Act
      await tester.pumpWidget(const MaterialApp(home: Scaffold(body: widget)));

      // Assert
      final childOpacityAnimations = tester.widgetList<AnimatedOpacity>(find.byType(AnimatedOpacity));

      expect(childOpacityAnimations.length, 2);

      // Child opacity animation (500ms)
      final childOpacity = childOpacityAnimations.first;
      expect(childOpacity.duration, const Duration(milliseconds: 500));

      // Loading indicator opacity animation (200ms)
      final loadingOpacity = childOpacityAnimations.last;
      expect(loadingOpacity.duration, const Duration(milliseconds: 200));
    });

    testWidgets('should use Stack with correct fit', (WidgetTester tester) async {
      // Arrange
      const widget = LoadingStack(loading: false, child: Text('Content'));

      // Act
      await tester.pumpWidget(const MaterialApp(home: Scaffold(body: widget)));

      // Assert - Find the Stack that is a direct child of LoadingStack
      final stackFinder = find.descendant(of: find.byType(LoadingStack), matching: find.byType(Stack));
      final stack = tester.widget<Stack>(stackFinder);
      expect(stack.fit, StackFit.loose);
    });

    testWidgets('should have correct padding around loading indicator', (WidgetTester tester) async {
      // Arrange
      const widget = LoadingStack(loading: true, child: Text('Content'));

      // Act
      await tester.pumpWidget(const MaterialApp(home: Scaffold(body: widget)));

      // Assert
      final padding = tester.widget<Padding>(
        find.ancestor(of: find.byType(CircularProgressIndicator), matching: find.byType(Padding)),
      );
      expect(padding.padding, const EdgeInsets.all(64));
    });

    testWidgets('should transition correctly between loading states', (WidgetTester tester) async {
      // Arrange
      Widget buildWidget(bool loading) => MaterialApp(
        home: Scaffold(
          body: LoadingStack(loading: loading, child: const Text('Content')),
        ),
      );

      // Act - start not loading
      await tester.pumpWidget(buildWidget(false));
      await tester.pump();

      // Assert initial state
      var childOpacity = tester.widget<AnimatedOpacity>(
        find.ancestor(of: find.text('Content'), matching: find.byType(AnimatedOpacity)),
      );
      expect(childOpacity.opacity, 1.0);

      // Act - change to loading
      await tester.pumpWidget(buildWidget(true));
      await tester.pump();

      // Assert changed state
      childOpacity = tester.widget<AnimatedOpacity>(
        find.ancestor(of: find.text('Content'), matching: find.byType(AnimatedOpacity)),
      );
      expect(childOpacity.opacity, 0.0);
    });

    testWidgets('should accept any widget as child', (WidgetTester tester) async {
      // Arrange
      const complexChild = Column(
        children: [
          Text('Title'),
          Icon(Icons.star),
          ElevatedButton(onPressed: null, child: Text('Button')),
        ],
      );

      const widget = LoadingStack(loading: false, child: complexChild);

      // Act
      await tester.pumpWidget(const MaterialApp(home: Scaffold(body: widget)));

      // Assert
      expect(find.text('Title'), findsOneWidget);
      expect(find.byIcon(Icons.star), findsOneWidget);
      expect(find.text('Button'), findsOneWidget);
    });
  });
}
