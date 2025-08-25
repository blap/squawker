import 'package:flutter_test/flutter_test.dart';
import 'package:squawker/utils/data_service.dart';
import 'package:squawker/utils/debounce.dart';

void main() {
  group('DataService', () {
    test('should be a singleton', () {
      // Act
      final instance1 = DataService();
      final instance2 = DataService();

      // Assert
      expect(identical(instance1, instance2), true);
    });

    test('should have an empty map initially', () {
      // Arrange
      final dataService = DataService();

      // Assert
      expect(dataService.map, isEmpty);
    });

    test('should allow storing and retrieving data', () {
      // Arrange
      final dataService = DataService();
      const testKey = 'test_key';
      const testValue = 'test_value';

      // Act
      dataService.map[testKey] = testValue;

      // Assert
      expect(dataService.map[testKey], testValue);
    });

    test('should persist data across instance calls', () {
      // Arrange
      final dataService1 = DataService();
      const testKey = 'persistent_key';
      const testValue = 'persistent_value';

      // Act
      dataService1.map[testKey] = testValue;
      final dataService2 = DataService();

      // Assert
      expect(dataService2.map[testKey], testValue);
    });

    test('should handle complex data types', () {
      // Arrange
      final dataService = DataService();
      final complexData = {
        'list': [1, 2, 3],
        'map': {'nested': 'value'},
        'bool': true,
      };

      // Act
      dataService.map['complex'] = complexData;

      // Assert
      expect(dataService.map['complex'], complexData);
    });

    test('should allow removal of data', () {
      // Arrange
      final dataService = DataService();
      const testKey = 'removable_key';

      // Act
      dataService.map[testKey] = 'value';
      dataService.map.remove(testKey);

      // Assert
      expect(dataService.map.containsKey(testKey), false);
    });

    test('should allow clearing all data', () {
      // Arrange
      final dataService = DataService();

      // Act
      dataService.map['key1'] = 'value1';
      dataService.map['key2'] = 'value2';
      dataService.map.clear();

      // Assert
      expect(dataService.map, isEmpty);
    });
  });

  group('Debouncer', () {
    test('should execute callback after duration', () async {
      // Arrange
      bool callbackExecuted = false;
      const duration = Duration(milliseconds: 100);

      // Act
      Debouncer.debounce('test', duration, () {
        callbackExecuted = true;
      });

      // Wait for debounce to complete
      await Future.delayed(duration + const Duration(milliseconds: 50));

      // Assert
      expect(callbackExecuted, true);
    });

    test('should cancel previous callback when called multiple times', () async {
      // Arrange
      int callbackCount = 0;
      const duration = Duration(milliseconds: 100);

      // Act
      Debouncer.debounce('test', duration, () {
        callbackCount++;
      });

      // Call again before first completes
      await Future.delayed(const Duration(milliseconds: 50));
      Debouncer.debounce('test', duration, () {
        callbackCount++;
      });

      // Wait for second debounce to complete
      await Future.delayed(duration + const Duration(milliseconds: 50));

      // Assert - only the second callback should execute
      expect(callbackCount, 1);
    });

    test('should handle multiple different IDs independently', () async {
      // Arrange
      bool callback1Executed = false;
      bool callback2Executed = false;
      const duration = Duration(milliseconds: 100);

      // Act
      Debouncer.debounce('test1', duration, () {
        callback1Executed = true;
      });

      Debouncer.debounce('test2', duration, () {
        callback2Executed = true;
      });

      // Wait for both to complete
      await Future.delayed(duration + const Duration(milliseconds: 50));

      // Assert
      expect(callback1Executed, true);
      expect(callback2Executed, true);
    });

    test('should handle rapid successive calls', () async {
      // Arrange
      int callbackCount = 0;
      const duration = Duration(milliseconds: 100);

      // Act - call multiple times rapidly
      for (int i = 0; i < 5; i++) {
        Debouncer.debounce('rapid_test', duration, () {
          callbackCount++;
        });
        await Future.delayed(const Duration(milliseconds: 10));
      }

      // Wait for final debounce to complete
      await Future.delayed(duration + const Duration(milliseconds: 50));

      // Assert - only the last callback should execute
      expect(callbackCount, 1);
    });

    test('should handle zero duration', () async {
      // Arrange
      bool callbackExecuted = false;
      const duration = Duration.zero;

      // Act
      Debouncer.debounce('zero_test', duration, () {
        callbackExecuted = true;
      });

      // Wait a bit to ensure callback executes
      await Future.delayed(const Duration(milliseconds: 10));

      // Assert
      expect(callbackExecuted, true);
    });

    test('should handle empty string ID', () async {
      // Arrange
      bool callbackExecuted = false;
      const duration = Duration(milliseconds: 50);

      // Act
      Debouncer.debounce('', duration, () {
        callbackExecuted = true;
      });

      await Future.delayed(duration + const Duration(milliseconds: 10));

      // Assert
      expect(callbackExecuted, true);
    });
  });
}
