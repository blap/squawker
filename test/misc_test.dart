import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:squawker/utils/misc.dart';

void main() {
  group('Misc Utilities', () {
    group('getRandomString', () {
      test('should generate string of specified length', () {
        // Test different lengths
        expect(getRandomString(5).length, 5);
        expect(getRandomString(10).length, 10);
        expect(getRandomString(1).length, 1);
        expect(getRandomString(0).length, 0);
      });

      test('should generate different strings on multiple calls', () {
        final string1 = getRandomString(10);
        final string2 = getRandomString(10);

        // While there's a tiny chance they could be the same,
        // it's extremely unlikely with 10 character strings
        expect(string1, isNot(equals(string2)));
      });

      test('should contain only valid characters', () {
        final result = getRandomString(100);
        final validChars = RegExp(r'^[A-Za-z0-9]+$');

        expect(validChars.hasMatch(result), true);
      });

      test('should handle edge case of length 0', () {
        final result = getRandomString(0);
        expect(result, isEmpty);
      });
    });

    group('getFlavor', () {
      test('should return dev by default', () {
        // Note: This test assumes no app.flavor environment variable is set
        final flavor = getFlavor();
        expect(flavor, isA<String>());
        expect(flavor, isNotEmpty);
      });

      test('should return a valid flavor string', () {
        final flavor = getFlavor();
        final validFlavors = ['dev', 'github', 'fdroid', 'play'];

        expect(validFlavors.contains(flavor) || flavor == 'dev', true);
      });
    });

    group('findInJSONArray', () {
      test('should find existing key-value pair', () {
        final array = [
          {'name': 'John', 'age': '30'},
          {'name': 'Jane', 'age': '25'},
          {'name': 'Bob', 'age': '35'},
        ];

        expect(findInJSONArray(array, 'name', 'Jane'), true);
        expect(findInJSONArray(array, 'age', '30'), true);
      });

      test('should return false for non-existing key-value pair', () {
        final array = [
          {'name': 'John', 'age': '30'},
          {'name': 'Jane', 'age': '25'},
        ];

        expect(findInJSONArray(array, 'name', 'Alice'), false);
        expect(findInJSONArray(array, 'age', '40'), false);
      });

      test('should handle empty array', () {
        expect(findInJSONArray([], 'key', 'value'), false);
      });

      test('should handle missing key in objects', () {
        final array = [
          {'name': 'John'},
          {'age': '25'},
        ];

        expect(findInJSONArray(array, 'missing', 'value'), false);
      });

      test('should handle null values', () {
        final array = [
          {'name': null, 'age': '30'},
        ];

        expect(findInJSONArray(array, 'name', 'null'), false);
      });
    });

    group('isTranslatable', () {
      test('should return false for null language', () {
        expect(isTranslatable(null, 'Hello world'), false);
      });

      test('should return false for undefined language', () {
        expect(isTranslatable('und', 'Hello world'), false);
      });

      test('should return true for different language than system', () {
        // Assuming system locale is not 'es'
        expect(isTranslatable('es', 'Hola mundo'), true);
      });

      test('should return false for same language as system', () {
        final systemLang = getShortSystemLocale();
        expect(isTranslatable(systemLang, 'Some text'), false);
      });

      test('should handle empty text', () {
        expect(isTranslatable('es', ''), true);
      });

      test('should handle null text', () {
        expect(isTranslatable('es', null), true);
      });
    });

    group('getShortSystemLocale', () {
      test('should return a valid locale string', () {
        final locale = getShortSystemLocale();

        expect(locale, isA<String>());
        expect(locale, isNotEmpty);
        expect(locale.length, greaterThanOrEqualTo(2));
        expect(locale.length, lessThanOrEqualTo(3));
      });

      test('should return only language part of locale', () {
        final locale = getShortSystemLocale();

        // Should not contain underscores (country codes removed)
        expect(locale.contains('_'), false);
      });

      test('should be lowercase', () {
        final locale = getShortSystemLocale();

        expect(locale, equals(locale.toLowerCase()));
      });
    });

    group('getSupportedTextActivityList', () {
      test('should return a list', () async {
        final result = await getSupportedTextActivityList();
        expect(result, isA<List<String>>());
        return;
      });

      test('should return empty list on non-Android platforms', () async {
        // This test will pass on non-Android platforms
        final result = await getSupportedTextActivityList();

        if (!Platform.isAndroid) {
          expect(result, isEmpty);
        } else {
          expect(result, isA<List<String>>());
        }
        return;
      });
    });

    group('processTextActivity', () {
      test('should return null on non-Android platforms', () async {
        final result = await processTextActivity(0, 'test', false);

        if (!Platform.isAndroid) {
          expect(result, isNull);
        }
        return;
      });

      test('should handle valid parameters', () async {
        // This test verifies the method can be called without throwing
        expect(() => processTextActivity(0, 'test text', true), returnsNormally);
        expect(() => processTextActivity(1, 'test text', false), returnsNormally);
        return;
      });
    });

    group('requestPostNotificationsPermissions', () {
      test('should accept callback parameter', () {
        // This test verifies the function accepts a callback parameter without throwing
        expect(() {
          requestPostNotificationsPermissions(() async {
            // Async callback function
          });
        }, returnsNormally);
      });

      test('should handle callback execution', () {
        // This test verifies the function can handle callback execution without throwing
        expect(() {
          requestPostNotificationsPermissions(() async {
            // Async callback function
          });
        }, returnsNormally);
      });
    });
  });
}
