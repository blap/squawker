import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:squawker/utils/route_util.dart';
import 'package:squawker/utils/data_service.dart';

void main() {
  group('Route Utilities', () {
    late DataService dataService;

    setUp(() {
      dataService = DataService();
      dataService.map.clear(); // Clear any existing data
    });

    tearDown(() {
      dataService.map.clear();
    });

    group('pushNamedRoute', () {
      testWidgets('should store arguments and navigate', (WidgetTester tester) async {
        // Arrange
        const routeName = '/test-route';
        const arguments = {'key': 'value'};

        final widget = MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => pushNamedRoute(context, routeName, arguments),
              child: const Text('Navigate'),
            ),
          ),
          routes: {routeName: (context) => const Scaffold(body: Text('Test Route'))},
        );

        await tester.pumpWidget(widget);

        // Act
        await tester.tap(find.text('Navigate'));
        await tester.pumpAndSettle();

        // Assert
        expect(dataService.map[routeName], arguments);
        expect(find.text('Test Route'), findsOneWidget);
      });

      testWidgets('should handle null arguments', (WidgetTester tester) async {
        // Arrange
        const routeName = '/test-route';

        final widget = MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => pushNamedRoute(context, routeName, null),
              child: const Text('Navigate'),
            ),
          ),
          routes: {routeName: (context) => const Scaffold(body: Text('Test Route'))},
        );

        await tester.pumpWidget(widget);

        // Act
        await tester.tap(find.text('Navigate'));
        await tester.pumpAndSettle();

        // Assert
        expect(dataService.map[routeName], isNull);
        expect(find.text('Test Route'), findsOneWidget);
      });
    });

    group('getNamedRouteArguments', () {
      test('should retrieve stored arguments', () {
        // Arrange
        const routeName = '/test-route';
        const arguments = {'data': 'test-value'};
        dataService.map[routeName] = arguments;

        // Act
        final result = getNamedRouteArguments(routeName);

        // Assert
        expect(result, arguments);
      });

      test('should remove arguments from session by default', () {
        // Arrange
        const routeName = '/test-route';
        const arguments = {'data': 'test-value'};
        dataService.map[routeName] = arguments;

        // Act
        getNamedRouteArguments(routeName);

        // Assert
        expect(dataService.map.containsKey(routeName), false);
      });

      test('should keep arguments when removeArgumentsFromSession is false', () {
        // Arrange
        const routeName = '/test-route';
        const arguments = {'data': 'test-value'};
        dataService.map[routeName] = arguments;

        // Act
        final result = getNamedRouteArguments(routeName, removeArgumentsFromSession: false);

        // Assert
        expect(result, arguments);
        expect(dataService.map[routeName], arguments);
      });

      test('should return null for non-existent route', () {
        // Arrange
        const routeName = '/non-existent-route';

        // Act
        final result = getNamedRouteArguments(routeName);

        // Assert
        expect(result, isNull);
      });

      test('should handle multiple routes independently', () {
        // Arrange
        const route1 = '/route1';
        const route2 = '/route2';
        const args1 = {'route': '1'};
        const args2 = {'route': '2'};

        dataService.map[route1] = args1;
        dataService.map[route2] = args2;

        // Act
        final result1 = getNamedRouteArguments(route1);
        final result2 = getNamedRouteArguments(route2, removeArgumentsFromSession: false);

        // Assert
        expect(result1, args1);
        expect(result2, args2);
        expect(dataService.map.containsKey(route1), false);
        expect(dataService.map.containsKey(route2), true);
      });

      test('should handle complex argument types', () {
        // Arrange
        const routeName = '/complex-route';
        final complexArgs = {
          'string': 'value',
          'number': 42,
          'list': [1, 2, 3],
          'map': {'nested': 'data'},
          'null': null,
        };
        dataService.map[routeName] = complexArgs;

        // Act
        final result = getNamedRouteArguments(routeName);

        // Assert
        expect(result, complexArgs);
      });
    });
  });
}
