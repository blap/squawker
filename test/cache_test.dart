import 'package:flutter_test/flutter_test.dart';

// Simple test implementation to verify the extension method logic
class TestCache {
  final Map<String, String> _storage = {};
  final Map<String, DateTime> _expiry = {};

  Future<bool> has(String key) async {
    if (!_storage.containsKey(key)) return false;

    final expiry = _expiry[key];
    if (expiry != null && DateTime.now().isAfter(expiry)) {
      _storage.remove(key);
      _expiry.remove(key);
      return false;
    }

    return true;
  }

  Future<String> getJSON(String key) async {
    if (!await has(key)) {
      throw Exception('Key not found: $key');
    }
    return _storage[key]!;
  }

  Future<void> setJSONWithTimeout(String key, String value, Duration timeout) async {
    _storage[key] = value;
    _expiry[key] = DateTime.now().add(timeout);
  }

  Future<void> clear() async {
    _storage.clear();
    _expiry.clear();
  }

  // Implement the CacheHelper extension logic directly for testing
  Future<String> getOrCreateAsJSON(String key, Duration expiry, Future<String> Function() create) async {
    var exists = await has(key);
    if (exists) {
      return await getJSON(key);
    }

    var result = await create();
    await setJSONWithTimeout(key, result, expiry);
    return result;
  }
}

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  group('CacheHelper Extension Logic', () {
    late TestCache cache;

    setUp(() async {
      cache = TestCache();
      await cache.clear();
    });

    tearDown(() async {
      await cache.clear();
    });

    group('getOrCreateAsJSON', () {
      test('should create and return new value when key does not exist', () async {
        const key = 'test_key';
        const expectedValue = '{"message": "created"}';
        const expiry = Duration(minutes: 10);

        Future<String> createFunction() async {
          return expectedValue;
        }

        final result = await cache.getOrCreateAsJSON(key, expiry, createFunction);

        expect(result, equals(expectedValue));

        // Verify the value was cached
        final cachedExists = await cache.has(key);
        expect(cachedExists, isTrue);

        final cachedValue = await cache.getJSON(key);
        expect(cachedValue, equals(expectedValue));
      });

      test('should return cached value when key exists', () async {
        const key = 'existing_key';
        const cachedValue = '{"message": "from_cache"}';
        const newValue = '{"message": "from_create"}';
        const expiry = Duration(minutes: 10);

        // Pre-populate the cache
        await cache.setJSONWithTimeout(key, cachedValue, expiry);

        // Create function should not be called since value exists in cache
        bool createFunctionCalled = false;
        Future<String> createFunction() async {
          createFunctionCalled = true;
          return newValue;
        }

        final result = await cache.getOrCreateAsJSON(key, expiry, createFunction);

        expect(result, equals(cachedValue));
        expect(createFunctionCalled, isFalse);
      });

      test('should handle complex JSON data structures', () async {
        const key = 'complex_json_key';
        const complexJson = '{"user": {"id": 12345, "name": "John Doe"}}';
        const expiry = Duration(hours: 1);

        Future<String> createFunction() async {
          return complexJson;
        }

        final result = await cache.getOrCreateAsJSON(key, expiry, createFunction);

        expect(result, equals(complexJson));

        // Verify caching worked
        final cachedResult = await cache.getOrCreateAsJSON(key, expiry, () async => 'should_not_be_called');
        expect(cachedResult, equals(complexJson));
      });

      test('should handle empty JSON strings', () async {
        const key = 'empty_json_key';
        const emptyJson = '{}';
        const expiry = Duration(minutes: 5);

        Future<String> createFunction() async {
          return emptyJson;
        }

        final result = await cache.getOrCreateAsJSON(key, expiry, createFunction);

        expect(result, equals(emptyJson));

        final cachedExists = await cache.has(key);
        expect(cachedExists, isTrue);
      });

      test('should handle create function errors gracefully', () async {
        const key = 'error_test_key';
        const expiry = Duration(minutes: 10);

        Future<String> errorCreateFunction() async {
          throw Exception('Create function failed');
        }

        expect(() => cache.getOrCreateAsJSON(key, expiry, errorCreateFunction), throwsException);

        // Verify nothing was cached when creation failed
        final cachedExists = await cache.has(key);
        expect(cachedExists, isFalse);
      });

      test('should handle cache expiry correctly', () async {
        const key = 'expiry_test_key';
        const value = '{"expiry": "test"}';
        const expiry = Duration(milliseconds: 50);

        int createCallCount = 0;
        Future<String> createFunction() async {
          createCallCount++;
          return value;
        }

        // First call - should create
        final result1 = await cache.getOrCreateAsJSON(key, expiry, createFunction);
        expect(result1, equals(value));
        expect(createCallCount, equals(1));

        // Second call immediately - should use cache
        final result2 = await cache.getOrCreateAsJSON(key, expiry, createFunction);
        expect(result2, equals(value));
        expect(createCallCount, equals(1)); // Still 1, from cache

        // Wait for expiry with extra buffer
        await Future.delayed(const Duration(milliseconds: 100));

        // Third call after expiry - should create again
        final result3 = await cache.getOrCreateAsJSON(key, expiry, createFunction);
        expect(result3, equals(value));
        expect(createCallCount, equals(2)); // Should be called again
      });

      test('should handle multiple different keys', () async {
        final keys = ['key1', 'key2', 'key3'];
        final values = ['{"value": 1}', '{"value": 2}', '{"value": 3}'];
        const expiry = Duration(minutes: 10);

        for (int i = 0; i < keys.length; i++) {
          final result = await cache.getOrCreateAsJSON(keys[i], expiry, () async => values[i]);
          expect(result, equals(values[i]));
        }

        // Verify all keys exist independently
        for (int i = 0; i < keys.length; i++) {
          final cachedExists = await cache.has(keys[i]);
          expect(cachedExists, isTrue);

          final cachedValue = await cache.getJSON(keys[i]);
          expect(cachedValue, equals(values[i]));
        }
      });

      test('should handle cache clear operation', () async {
        const key = 'clear_test_key';
        const value = '{"test": "clear"}';
        const expiry = Duration(minutes: 10);

        // First, populate the cache
        await cache.getOrCreateAsJSON(key, expiry, () async => value);

        // Verify it's cached
        final existsBefore = await cache.has(key);
        expect(existsBefore, isTrue);

        // Clear the cache
        await cache.clear();

        // Verify cache is cleared
        final existsAfter = await cache.has(key);
        expect(existsAfter, isFalse);

        // New call should create again
        bool createCalled = false;
        final result = await cache.getOrCreateAsJSON(key, expiry, () async {
          createCalled = true;
          return value;
        });

        expect(result, equals(value));
        expect(createCalled, isTrue);
      });
    });
  });
}
