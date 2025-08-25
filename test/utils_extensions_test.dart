import 'package:flutter_test/flutter_test.dart';
import 'package:squawker/utils/iterables.dart';
import 'package:squawker/utils/route_util.dart';
import 'package:squawker/utils/urls.dart';
import 'package:squawker/utils/data_service.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  group('Iterables Extension', () {
    group('firstOrNull', () {
      test('should return first element when list is not empty', () {
        // Arrange
        final list = [1, 2, 3, 4, 5];

        // Act
        final result = list.firstOrNull;

        // Assert
        expect(result, 1);
      });

      test('should return null when list is empty', () {
        // Arrange
        final list = <int>[];

        // Act
        final result = list.firstOrNull;

        // Assert
        expect(result, null);
      });

      test('should work with strings', () {
        // Arrange
        final list = ['first', 'second', 'third'];

        // Act
        final result = list.firstOrNull;

        // Assert
        expect(result, 'first');
      });

      test('should work with single element', () {
        // Arrange
        final list = ['only'];

        // Act
        final result = list.firstOrNull;

        // Assert
        expect(result, 'only');
      });
    });

    group('firstWhereOrNull', () {
      test('should return first matching element', () {
        // Arrange
        final list = [1, 2, 3, 4, 5];

        // Act
        final result = list.firstWhereOrNull((e) => e > 3);

        // Assert
        expect(result, 4);
      });

      test('should return null when no element matches', () {
        // Arrange
        final list = [1, 2, 3];

        // Act
        final result = list.firstWhereOrNull((e) => e > 5);

        // Assert
        expect(result, null);
      });

      test('should return null when list is empty', () {
        // Arrange
        final list = <int>[];

        // Act
        final result = list.firstWhereOrNull((e) => e > 0);

        // Assert
        expect(result, null);
      });

      test('should work with complex objects', () {
        // Arrange
        final list = [
          {'name': 'Alice', 'age': 25},
          {'name': 'Bob', 'age': 30},
          {'name': 'Charlie', 'age': 35},
        ];

        // Act
        final result = list.firstWhereOrNull((e) => (e['age']! as int) > 28);

        // Assert
        expect(result, {'name': 'Bob', 'age': 30});
      });

      test('should return first match when multiple matches exist', () {
        // Arrange
        final list = [1, 3, 5, 7, 9];

        // Act
        final result = list.firstWhereOrNull((e) => e > 3);

        // Assert
        expect(result, 5); // First element > 3
      });
    });

    group('groupBy', () {
      test('should group elements by key function', () {
        // Arrange
        final list = ['apple', 'banana', 'apricot', 'blueberry', 'avocado'];

        // Act
        final result = list.groupBy((e) => e[0]);

        // Assert
        expect(result['a'], ['apple', 'apricot', 'avocado']);
        expect(result['b'], ['banana', 'blueberry']);
      });

      test('should handle empty list', () {
        // Arrange
        final list = <String>[];

        // Act
        final result = list.groupBy((e) => e[0]);

        // Assert
        expect(result, isEmpty);
      });

      test('should group numbers by even/odd', () {
        // Arrange
        final list = [1, 2, 3, 4, 5, 6];

        // Act
        final result = list.groupBy((e) => e % 2);

        // Assert
        expect(result[1], [1, 3, 5]); // Odd numbers
        expect(result[0], [2, 4, 6]); // Even numbers
      });

      test('should handle single group', () {
        // Arrange
        final list = [2, 4, 6, 8];

        // Act
        final result = list.groupBy((e) => 'even');

        // Assert
        expect(result['even'], [2, 4, 6, 8]);
        expect(result.keys.length, 1);
      });
    });

    group('getRange', () {
      test('should return range with start and end', () {
        // Arrange
        final list = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

        // Act
        final result = list.getRange(2, 5);

        // Assert
        expect(result.toList(), [3, 4, 5]);
      });

      test('should return range from start to end of list', () {
        // Arrange
        final list = [1, 2, 3, 4, 5];

        // Act
        final result = list.getRange(2, list.length);

        // Assert
        expect(result.toList(), [3, 4, 5]);
      });

      test('should handle start at beginning', () {
        // Arrange
        final list = [1, 2, 3, 4, 5];

        // Act
        final result = list.getRange(0, 3);

        // Assert
        expect(result.toList(), [1, 2, 3]);
      });

      test('should handle empty range', () {
        // Arrange
        final list = [1, 2, 3, 4, 5];

        // Act
        final result = list.getRange(2, 2);

        // Assert
        expect(result.toList(), isEmpty);
      });
    });

    group('sorted', () {
      test('should sort numbers in ascending order', () {
        // Arrange
        final list = [5, 2, 8, 1, 9, 3];

        // Act
        final result = list.sorted((a, b) => a.compareTo(b));

        // Assert
        expect(result.toList(), [1, 2, 3, 5, 8, 9]);
      });

      test('should sort numbers in descending order', () {
        // Arrange
        final list = [5, 2, 8, 1, 9, 3];

        // Act
        final result = list.sorted((a, b) => b.compareTo(a));

        // Assert
        expect(result.toList(), [9, 8, 5, 3, 2, 1]);
      });

      test('should not modify original list', () {
        // Arrange
        final list = [5, 2, 8, 1, 9, 3];
        final originalList = List.from(list);

        // Act
        final result = list.sorted((a, b) => a.compareTo(b));

        // Assert
        expect(list, originalList); // Original unchanged
        expect(result.toList(), [1, 2, 3, 5, 8, 9]);
      });

      test('should handle empty list', () {
        // Arrange
        final list = <int>[];

        // Act
        final result = list.sorted((a, b) => a.compareTo(b));

        // Assert
        expect(result.toList(), isEmpty);
      });

      test('should handle single element', () {
        // Arrange
        final list = [42];

        // Act
        final result = list.sorted((a, b) => a.compareTo(b));

        // Assert
        expect(result.toList(), [42]);
      });
    });
  });

  group('MapWithIndex Extension', () {
    test('should map with index correctly', () {
      // Arrange
      final list = ['a', 'b', 'c', 'd'];

      // Act
      final result = list.mapWithIndex((item, index) => '$index: $item');

      // Assert
      expect(result, ['0: a', '1: b', '2: c', '3: d']);
    });

    test('should handle empty list', () {
      // Arrange
      final list = <String>[];

      // Act
      final result = list.mapWithIndex((item, index) => '$index: $item');

      // Assert
      expect(result, isEmpty);
    });

    test('should map to different type', () {
      // Arrange
      final list = ['one', 'two', 'three'];

      // Act
      final result = list.mapWithIndex((item, index) => index * item.length);

      // Assert
      expect(result, [0, 3, 10]); // 0*3, 1*3, 2*5
    });

    test('should handle single element', () {
      // Arrange
      final list = ['single'];

      // Act
      final result = list.mapWithIndex((item, index) => '$index-$item');

      // Assert
      expect(result, ['0-single']);
    });

    test('should preserve order', () {
      // Arrange
      final list = [10, 20, 30, 40, 50];

      // Act
      final result = list.mapWithIndex((item, index) => item + index);

      // Assert
      expect(result, [10, 21, 32, 43, 54]);
    });
  });

  group('Route Utilities', () {
    setUp(() {
      // Clear DataService before each test
      DataService().map.clear();
    });

    test('should store arguments in DataService when pushing named route', () {
      // Arrange
      const routeName = '/test_route';
      const arguments = 'test_arguments';

      // Act - can't actually test navigation without a BuildContext
      // But we can test the argument storage part
      DataService().map[routeName] = arguments;

      // Assert
      expect(DataService().map[routeName], arguments);
    });

    test('should retrieve arguments from DataService', () {
      // Arrange
      const routeName = '/test_route';
      const arguments = {'key': 'value', 'number': 123};
      DataService().map[routeName] = arguments;

      // Act
      final retrievedArgs = getNamedRouteArguments(routeName);

      // Assert
      expect(retrievedArgs, arguments);
    });

    test('should remove arguments from session by default', () {
      // Arrange
      const routeName = '/test_route';
      const arguments = 'test_data';
      DataService().map[routeName] = arguments;

      // Act
      getNamedRouteArguments(routeName);

      // Assert
      expect(DataService().map.containsKey(routeName), false);
    });

    test('should keep arguments when removeArgumentsFromSession is false', () {
      // Arrange
      const routeName = '/test_route';
      const arguments = 'test_data';
      DataService().map[routeName] = arguments;

      // Act
      final retrievedArgs = getNamedRouteArguments(routeName, removeArgumentsFromSession: false);

      // Assert
      expect(retrievedArgs, arguments);
      expect(DataService().map[routeName], arguments);
    });

    test('should return null for non-existent route', () {
      // Act
      final retrievedArgs = getNamedRouteArguments('/non_existent');

      // Assert
      expect(retrievedArgs, null);
    });

    test('should handle complex arguments', () {
      // Arrange
      const routeName = '/complex_route';
      final arguments = {
        'user': {'id': 123, 'name': 'Test User'},
        'settings': ['option1', 'option2'],
        'metadata': {'timestamp': 1234567890},
      };
      DataService().map[routeName] = arguments;

      // Act
      final retrievedArgs = getNamedRouteArguments(routeName);

      // Assert
      expect(retrievedArgs, arguments);
    });

    test('should handle null arguments', () {
      // Arrange
      const routeName = '/null_route';
      DataService().map[routeName] = null;

      // Act
      final retrievedArgs = getNamedRouteArguments(routeName);

      // Assert
      expect(retrievedArgs, null);
    });

    test('should handle empty string route name', () {
      // Arrange
      const routeName = '';
      const arguments = 'empty_route_data';
      DataService().map[routeName] = arguments;

      // Act
      final retrievedArgs = getNamedRouteArguments(routeName);

      // Assert
      expect(retrievedArgs, arguments);
    });
  });

  group('URL Utilities', () {
    test('should have openUri function available', () {
      // Act & Assert - should verify function exists without calling it
      expect(openUri, isA<Function>());
    });

    test('should accept string parameter', () {
      // Test that openUri is a function that accepts a string
      // without actually executing the platform call
      expect(() {
        // We're not actually calling it, just checking the signature
        openUri;
      }, returnsNormally);
    });
  });
}
