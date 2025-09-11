import 'package:flutter_test/flutter_test.dart';
import 'package:ffcache/ffcache.dart';
import 'package:squawker/utils/cache.dart';

// Mock implementation of FFCache for testing
class MockFFCache implements FFCache {
  final Map<String, dynamic> _cache = {};
  final Map<String, DateTime> _expiry = {};

  @override
  Future<bool> has(String key) async {
    if (!_cache.containsKey(key)) return false;
    if (_expiry.containsKey(key) && DateTime.now().isAfter(_expiry[key]!)) {
      _cache.remove(key);
      _expiry.remove(key);
      return false;
    }
    return true;
  }

  @override
  Future<String> getJSON(String key) async {
    return _cache[key] as String;
  }

  @override
  Future<void> setJSONWithTimeout(String key, dynamic value, Duration duration) async {
    _cache[key] = value;
    _expiry[key] = DateTime.now().add(duration);
  }

  // Implement other required methods with minimal implementation
  @override
  Future<void> clear() async => _cache.clear();

  Future<void> delete(String key) async => _cache.remove(key);

  Future<void> deleteAll(List<String> keys) async {
    for (final key in keys) {
      _cache.remove(key);
    }
  }

  Future<void> deleteWithPattern(String pattern) async {}

  Future<Map<String, dynamic>> getAll(List<String> keys) async => {};

  Future<List<String>> getKeys() async => [];

  @override
  Future<void> setStringWithTimeout(String key, String value, Duration duration) async {}

  @override
  Future<String> getString(String key) async => '';

  Future<bool> hasString(String key) async => false;

  @override
  Future<void> setJSON(String key, dynamic data) async {
    _cache[key] = data;
  }

  @override
  Future<void> setString(String key, String value) async {}

  @override
  Future<Duration?> ageForKey(String key) async => null;

  @override
  Future<List<int>?> getBytes(String key) async => null;

  @override
  Future<void> init() async {}

  @override
  Duration remainingDurationForKey(String key) {
    return Duration.zero;
  }

  @override
  Future<bool> remove(String key) async => false;

  @override
  Future<void> setBytes(String key, List<int> bytes) async {}

  @override
  Future<void> setBytesWithTimeout(String key, List<int> bytes, Duration duration) async {}
}

void main() {
  group('CacheHelper', () {
    late MockFFCache mockCache;

    setUp(() {
      mockCache = MockFFCache();
    });

    test('should return cached value when it exists and is not expired', () async {
      // Arrange
      final key = 'test_key';
      final cachedValue = '{"data": "cached_value"}';
      await mockCache.setJSONWithTimeout(key, cachedValue, Duration(minutes: 5));

      bool createCalled = false;
      Future<String> create() async {
        createCalled = true;
        return '{"data": "new_value"}';
      }

      // Act
      final result = await mockCache.getOrCreateAsJSON(key, Duration(minutes: 5), create);

      // Assert
      expect(result, cachedValue);
      expect(createCalled, false);
    });

    test('should call create function when key does not exist', () async {
      // Arrange
      final key = 'test_key';
      final newValue = '{"data": "new_value"}';

      bool createCalled = false;
      Future<String> create() async {
        createCalled = true;
        return newValue;
      }

      // Act
      final result = await mockCache.getOrCreateAsJSON(key, Duration(minutes: 5), create);

      // Assert
      expect(result, newValue);
      expect(createCalled, true);
    });

    test('should call create function when key exists but is expired', () async {
      // Arrange
      final key = 'test_key';
      final cachedValue = '{"data": "cached_value"}';
      final newValue = '{"data": "new_value"}';

      // Set an expired value
      await mockCache.setJSONWithTimeout(key, cachedValue, Duration(seconds: -1));

      bool createCalled = false;
      Future<String> create() async {
        createCalled = true;
        return newValue;
      }

      // Act
      final result = await mockCache.getOrCreateAsJSON(key, Duration(minutes: 5), create);

      // Assert
      expect(result, newValue);
      expect(createCalled, true);
    });

    test('should cache the newly created value', () async {
      // Arrange
      final key = 'test_key';
      final newValue = '{"data": "new_value"}';

      Future<String> create() async => newValue;

      // Act
      await mockCache.getOrCreateAsJSON(key, Duration(minutes: 5), create);

      // Assert
      final exists = await mockCache.has(key);
      expect(exists, true);

      final cachedValue = await mockCache.getJSON(key);
      expect(cachedValue, newValue);
    });
  });
}
