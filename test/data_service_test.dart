import 'package:flutter_test/flutter_test.dart';
import 'package:squawker/utils/data_service.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  group('DataService', () {
    group('Singleton Pattern', () {
      test('should return the same instance when called multiple times', () {
        final instance1 = DataService();
        final instance2 = DataService();

        expect(identical(instance1, instance2), isTrue);
        expect(instance1, equals(instance2));
      });

      test('should maintain singleton across different access patterns', () {
        final instance1 = DataService();
        final instance2 = DataService();
        final instance3 = DataService();

        expect(identical(instance1, instance2), isTrue);
        expect(identical(instance2, instance3), isTrue);
        expect(identical(instance1, instance3), isTrue);
      });
    });

    group('Map Data Storage', () {
      late DataService dataService;

      setUp(() {
        dataService = DataService();
        // Clear the map before each test to ensure clean state
        dataService.map.clear();
      });

      test('should have an empty map initially', () {
        dataService.map.clear(); // Ensure clean state
        expect(dataService.map.isEmpty, isTrue);
        expect(dataService.map.length, equals(0));
      });

      test('should allow storing and retrieving string values', () {
        const key = 'test_key';
        const value = 'test_value';

        dataService.map[key] = value;

        expect(dataService.map[key], equals(value));
        expect(dataService.map.containsKey(key), isTrue);
      });

      test('should allow storing and retrieving different data types', () {
        dataService.map['string_key'] = 'string_value';
        dataService.map['int_key'] = 42;
        dataService.map['double_key'] = 3.14;
        dataService.map['bool_key'] = true;
        dataService.map['list_key'] = [1, 2, 3];
        dataService.map['map_key'] = {'nested': 'value'};

        expect(dataService.map['string_key'], equals('string_value'));
        expect(dataService.map['int_key'], equals(42));
        expect(dataService.map['double_key'], equals(3.14));
        expect(dataService.map['bool_key'], isTrue);
        expect(dataService.map['list_key'], equals([1, 2, 3]));
        expect(dataService.map['map_key'], equals({'nested': 'value'}));
      });

      test('should allow updating existing values', () {
        const key = 'update_key';
        const initialValue = 'initial';
        const updatedValue = 'updated';

        dataService.map[key] = initialValue;
        expect(dataService.map[key], equals(initialValue));

        dataService.map[key] = updatedValue;
        expect(dataService.map[key], equals(updatedValue));
      });

      test('should allow removing values', () {
        const key = 'remove_key';
        const value = 'to_be_removed';

        dataService.map[key] = value;
        expect(dataService.map.containsKey(key), isTrue);

        dataService.map.remove(key);
        expect(dataService.map.containsKey(key), isFalse);
        expect(dataService.map[key], isNull);
      });

      test('should return null for non-existent keys', () {
        const nonExistentKey = 'does_not_exist';

        expect(dataService.map[nonExistentKey], isNull);
        expect(dataService.map.containsKey(nonExistentKey), isFalse);
      });

      test('should handle complex nested data structures', () {
        final complexData = {
          'user': {
            'id': 123,
            'name': 'John Doe',
            'preferences': {
              'theme': 'dark',
              'notifications': true,
              'languages': ['en', 'es', 'fr'],
            },
          },
          'sessions': [
            {'id': 1, 'timestamp': '2023-01-01'},
            {'id': 2, 'timestamp': '2023-01-02'},
          ],
        };

        dataService.map['complex_data'] = complexData;

        final retrieved = dataService.map['complex_data'] as Map<String, dynamic>;
        expect(retrieved['user']['name'], equals('John Doe'));
        expect(retrieved['user']['preferences']['theme'], equals('dark'));
        expect(retrieved['sessions'].length, equals(2));
      });

      test('should maintain data consistency across multiple operations', () {
        // Add multiple items
        for (int i = 0; i < 10; i++) {
          dataService.map['key_$i'] = 'value_$i';
        }

        expect(dataService.map.length, equals(10));

        // Update some items
        for (int i = 0; i < 5; i++) {
          dataService.map['key_$i'] = 'updated_value_$i';
        }

        // Verify updates
        for (int i = 0; i < 5; i++) {
          expect(dataService.map['key_$i'], equals('updated_value_$i'));
        }

        // Verify unchanged items
        for (int i = 5; i < 10; i++) {
          expect(dataService.map['key_$i'], equals('value_$i'));
        }

        expect(dataService.map.length, equals(10));
      });
    });

    group('Data Persistence Across Instances', () {
      test('should maintain data across different singleton instances', () {
        final instance1 = DataService();
        const key = 'persistent_key';
        const value = 'persistent_value';

        instance1.map[key] = value;

        final instance2 = DataService();
        expect(instance2.map[key], equals(value));
        expect(instance2.map.containsKey(key), isTrue);
      });

      test('should reflect changes made through any instance', () {
        final instance1 = DataService();
        final instance2 = DataService();

        const key1 = 'key_from_instance1';
        const key2 = 'key_from_instance2';
        const value1 = 'value_from_instance1';
        const value2 = 'value_from_instance2';

        instance1.map[key1] = value1;
        instance2.map[key2] = value2;

        // Both instances should see both values
        expect(instance1.map[key1], equals(value1));
        expect(instance1.map[key2], equals(value2));
        expect(instance2.map[key1], equals(value1));
        expect(instance2.map[key2], equals(value2));
      });
    });

    group('Edge Cases', () {
      late DataService dataService;

      setUp(() {
        dataService = DataService();
        dataService.map.clear();
      });

      test('should handle empty string keys', () {
        const emptyKey = '';
        const value = 'value_for_empty_key';

        dataService.map[emptyKey] = value;

        expect(dataService.map[emptyKey], equals(value));
        expect(dataService.map.containsKey(emptyKey), isTrue);
      });

      test('should handle null values', () {
        const key = 'null_key';

        dataService.map[key] = null;

        expect(dataService.map[key], isNull);
        expect(dataService.map.containsKey(key), isTrue);
      });

      test('should handle special characters in keys', () {
        const specialKey = '!@#\$%^&*()_+-=[]{}|;:,.<>?~`';
        const value = 'special_value';

        dataService.map[specialKey] = value;

        expect(dataService.map[specialKey], equals(value));
        expect(dataService.map.containsKey(specialKey), isTrue);
      });

      test('should handle unicode characters in keys and values', () {
        const unicodeKey = '🔑_你好_مفتاح';
        const unicodeValue = '🌍_世界_العالم';

        dataService.map[unicodeKey] = unicodeValue;

        expect(dataService.map[unicodeKey], equals(unicodeValue));
        expect(dataService.map.containsKey(unicodeKey), isTrue);
      });

      test('should handle large amounts of data', () {
        const itemCount = 1000;

        // Add many items
        for (int i = 0; i < itemCount; i++) {
          dataService.map['large_key_$i'] = 'large_value_$i' * 10; // Make values longer
        }

        expect(dataService.map.length, equals(itemCount));

        // Verify random items
        expect(dataService.map['large_key_100'], contains('large_value_100'));
        expect(dataService.map['large_key_500'], contains('large_value_500'));
        expect(dataService.map['large_key_999'], contains('large_value_999'));
      });
    });
  });
}
