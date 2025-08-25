import 'package:flutter_test/flutter_test.dart';
import 'package:squawker/utils/iterables.dart';

void main() {
  group('Iterables Extension', () {
    group('firstOrNull', () {
      test('should return first element when list is not empty', () {
        final list = [1, 2, 3, 4, 5];
        expect(list.firstOrNull, 1);
      });

      test('should return null when list is empty', () {
        final List<int> list = [];
        expect(list.firstOrNull, isNull);
      });

      test('should work with different data types', () {
        final stringList = ['hello', 'world'];
        expect(stringList.firstOrNull, 'hello');

        final boolList = [true, false];
        expect(boolList.firstOrNull, true);

        final doubleList = [3.14, 2.71];
        expect(doubleList.firstOrNull, 3.14);
      });

      test('should work with single element list', () {
        final list = [42];
        expect(list.firstOrNull, 42);
      });
    });

    group('firstWhereOrNull', () {
      test('should return first element matching condition', () {
        final list = [1, 2, 3, 4, 5];
        expect(list.firstWhereOrNull((e) => e > 3), 4);
      });

      test('should return null when no element matches condition', () {
        final list = [1, 2, 3];
        expect(list.firstWhereOrNull((e) => e > 10), isNull);
      });

      test('should return null for empty list', () {
        final List<int> list = [];
        expect(list.firstWhereOrNull((e) => e > 0), isNull);
      });

      test('should work with complex conditions', () {
        final list = ['apple', 'banana', 'cherry', 'date'];
        expect(list.firstWhereOrNull((e) => e.length > 5), 'banana');
        expect(list.firstWhereOrNull((e) => e.startsWith('c')), 'cherry');
        expect(list.firstWhereOrNull((e) => e.contains('z')), isNull);
      });

      test('should return first matching element when multiple match', () {
        final list = [2, 4, 6, 8];
        expect(list.firstWhereOrNull((e) => e % 2 == 0), 2);
      });
    });

    group('groupBy', () {
      test('should group elements by key function', () {
        final list = [1, 2, 3, 4, 5, 6];
        final grouped = list.groupBy((e) => e % 2);

        expect(grouped[0], [2, 4, 6]);
        expect(grouped[1], [1, 3, 5]);
      });

      test('should handle empty list', () {
        final List<int> list = [];
        final grouped = list.groupBy((e) => e % 2);

        expect(grouped, isEmpty);
      });

      test('should group strings by length', () {
        final list = ['a', 'bb', 'ccc', 'd', 'ee'];
        final grouped = list.groupBy((e) => e.length);

        expect(grouped[1], ['a', 'd']);
        expect(grouped[2], ['bb', 'ee']);
        expect(grouped[3], ['ccc']);
      });

      test('should handle single group', () {
        final list = [2, 4, 6, 8];
        final grouped = list.groupBy((e) => 'even');

        expect(grouped['even'], [2, 4, 6, 8]);
        expect(grouped.keys.length, 1);
      });

      test('should preserve order within groups', () {
        final list = ['apple', 'ant', 'banana', 'bear', 'cherry'];
        final grouped = list.groupBy((e) => e[0]);

        expect(grouped['a'], ['apple', 'ant']);
        expect(grouped['b'], ['banana', 'bear']);
        expect(grouped['c'], ['cherry']);
      });
    });

    group('getRange', () {
      test('should return range with start and end', () {
        final list = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
        final range = list.getRange(2, 5).toList();

        expect(range, [3, 4, 5]);
      });

      test('should return range from start to end when end is provided', () {
        final list = ['a', 'b', 'c', 'd', 'e'];
        final range = list.getRange(1, 3).toList();

        expect(range, ['b', 'c']);
      });

      test('should handle start at beginning', () {
        final list = [1, 2, 3, 4, 5];
        final range = list.getRange(0, 3).toList();

        expect(range, [1, 2, 3]);
      });

      test('should return empty range when start equals end', () {
        final list = [1, 2, 3, 4, 5];
        final range = list.getRange(2, 2).toList();

        expect(range, isEmpty);
      });

      test('should handle single element range', () {
        final list = [1, 2, 3, 4, 5];
        final range = list.getRange(1, 2).toList();

        expect(range, [2]);
      });
    });

    group('sorted', () {
      test('should sort integers in ascending order', () {
        final list = [3, 1, 4, 1, 5, 9, 2, 6];
        final sorted = list.sorted((a, b) => a.compareTo(b)).toList();

        expect(sorted, [1, 1, 2, 3, 4, 5, 6, 9]);
      });

      test('should sort integers in descending order', () {
        final list = [3, 1, 4, 1, 5, 9, 2, 6];
        final sorted = list.sorted((a, b) => b.compareTo(a)).toList();

        expect(sorted, [9, 6, 5, 4, 3, 2, 1, 1]);
      });

      test('should sort strings alphabetically', () {
        final list = ['banana', 'apple', 'cherry', 'date'];
        final sorted = list.sorted((a, b) => a.compareTo(b)).toList();

        expect(sorted, ['apple', 'banana', 'cherry', 'date']);
      });

      test('should sort strings by length', () {
        final list = ['banana', 'a', 'cherry', 'bb'];
        final sorted = list.sorted((a, b) => a.length.compareTo(b.length)).toList();

        expect(sorted, ['a', 'bb', 'banana', 'cherry']);
      });

      test('should handle empty list', () {
        final List<int> list = [];
        final sorted = list.sorted((a, b) => a.compareTo(b)).toList();

        expect(sorted, isEmpty);
      });

      test('should handle single element list', () {
        final list = [42];
        final sorted = list.sorted((a, b) => a.compareTo(b)).toList();

        expect(sorted, [42]);
      });

      test('should not modify original list', () {
        final list = [3, 1, 4];
        final sorted = list.sorted((a, b) => a.compareTo(b)).toList();

        expect(list, [3, 1, 4]); // Original unchanged
        expect(sorted, [1, 3, 4]); // Sorted copy
      });
    });
  });

  group('MapWithIndex Extension', () {
    group('mapWithIndex', () {
      test('should map with index for simple transformation', () {
        final list = ['a', 'b', 'c'];
        final result = list.mapWithIndex((item, index) => '$item$index');

        expect(result, ['a0', 'b1', 'c2']);
      });

      test('should provide correct indices', () {
        final list = [10, 20, 30, 40];
        final result = list.mapWithIndex((item, index) => item + index);

        expect(result, [10, 21, 32, 43]);
      });

      test('should handle empty list', () {
        final List<String> list = [];
        final result = list.mapWithIndex((item, index) => '$item$index');

        expect(result, isEmpty);
      });

      test('should handle single element list', () {
        final list = ['hello'];
        final result = list.mapWithIndex((item, index) => '$item-$index');

        expect(result, ['hello-0']);
      });

      test('should work with different return types', () {
        final list = ['apple', 'banana', 'cherry'];
        final result = list.mapWithIndex((item, index) => item.length + index);

        expect(result, [5, 7, 8]); // 5+0, 6+1, 6+2
      });

      test('should work with complex transformations', () {
        final list = [1, 2, 3];
        final result = list.mapWithIndex((item, index) => {'value': item, 'index': index, 'doubled': item * 2});

        expect(result[0], {'value': 1, 'index': 0, 'doubled': 2});
        expect(result[1], {'value': 2, 'index': 1, 'doubled': 4});
        expect(result[2], {'value': 3, 'index': 2, 'doubled': 6});
      });

      test('should handle index-only transformations', () {
        final list = ['x', 'y', 'z'];
        final result = list.mapWithIndex((item, index) => index * 10);

        expect(result, [0, 10, 20]);
      });
    });
  });
}
