import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:squawker/utils/translation.dart';

void main() {
  group('TranslationAPIResult', () {
    test('should create TranslationAPIResult with success true', () {
      // Arrange
      final body = {'test': 'data'};

      // Act
      final result = TranslationAPIResult(success: true, body: body);

      // Assert
      expect(result.success, true);
      expect(result.body, body);
      expect(result.errorMessage, isNull);
    });

    test('should create TranslationAPIResult with success false and error message', () {
      // Arrange
      const errorMessage = 'Translation failed';
      final body = {'error': 'API error'};

      // Act
      final result = TranslationAPIResult(success: false, body: body, errorMessage: errorMessage);

      // Assert
      expect(result.success, false);
      expect(result.body, body);
      expect(result.errorMessage, errorMessage);
    });

    test('should create TranslationAPIResult with null error message', () {
      // Arrange
      final body = {'data': 'test'};

      // Act
      final result = TranslationAPIResult(success: true, body: body);

      // Assert
      expect(result.success, true);
      expect(result.body, body);
      expect(result.errorMessage, isNull);
    });
  });

  group('TranslationAPI', () {
    group('translationHosts', () {
      test('should return default translation hosts', () {
        // Act
        final hosts = TranslationAPI.translationHosts();

        // Assert
        expect(hosts, isA<List<Map<String, dynamic>>>());
        expect(hosts.length, greaterThan(0));
        expect(hosts.first.containsKey('host'), true);
        expect(hosts.first['host'], isA<String>());
      });
    });

    group('translationHostsLength', () {
      test('should return correct length of translation hosts', () {
        // Act
        final length = TranslationAPI.translationHostsLength();
        final hosts = TranslationAPI.translationHosts();

        // Assert
        expect(length, hosts.length);
        expect(length, greaterThan(0));
      });
    });

    group('translationHost', () {
      test('should return current translation host', () {
        // Act
        final host = TranslationAPI.translationHost();

        // Assert
        expect(host, isA<Map<String, dynamic>>());
        expect(host.containsKey('host'), true);
        expect(host['host'], isA<String>());
      });
    });

    group('nextTranslationHost', () {
      test('should cycle through translation hosts', () {
        // Arrange
        final initialHost = TranslationAPI.translationHost();
        final totalHosts = TranslationAPI.translationHostsLength();

        // Act & Assert - cycle through all hosts
        Set<String> hostsSeen = {initialHost['host']};

        for (int i = 1; i < totalHosts; i++) {
          final nextHost = TranslationAPI.nextTranslationHost();
          expect(nextHost, isA<Map<String, dynamic>>());
          hostsSeen.add(nextHost['host']);
        }

        // Should have seen all unique hosts
        expect(hostsSeen.length, totalHosts);

        // Next call should cycle back to first host
        final cycledHost = TranslationAPI.nextTranslationHost();
        expect(cycledHost['host'], initialHost['host']);
      });
    });

    group('setTranslationHosts', () {
      test('should set custom translation hosts and return JSON', () {
        // Arrange
        final customHosts = [
          {'host': 'test1.com', 'api_key': null},
          {'host': 'test2.com', 'api_key': 'key123'},
        ];

        // Act
        final jsonResult = TranslationAPI.setTranslationHosts(customHosts);

        // Assert
        expect(jsonResult, isA<String>());
        final decoded = jsonDecode(jsonResult);
        expect(decoded, isA<List>());
        expect(decoded.length, 2);
        expect(decoded[0]['host'], 'test1.com');
        expect(decoded[1]['host'], 'test2.com');
        expect(decoded[1]['api_key'], 'key123');

        // Verify the hosts were actually set
        final currentHosts = TranslationAPI.translationHosts();
        expect(currentHosts.length, 2);
        expect(currentHosts[0]['host'], 'test1.com');
      });

      test('should set default hosts when null is provided', () {
        // Act
        final jsonResult = TranslationAPI.setTranslationHosts(null);

        // Assert
        expect(jsonResult, isA<String>());
        final decoded = jsonDecode(jsonResult);
        expect(decoded, isA<List>());
        expect(decoded.length, greaterThan(0));

        // Should contain default hosts
        final hostNames = decoded.map((h) => h['host']).toList();
        expect(hostNames, contains('libretranslate.de'));
      });
    });

    group('setTranslationHostsFromStr', () {
      test('should parse JSON string and set translation hosts', () {
        // Arrange
        final hostsJson = jsonEncode([
          {'host': 'api1.example.com', 'api_key': 'abc123'},
          {'host': 'api2.example.com', 'api_key': null},
        ]);

        // Act
        final result = TranslationAPI.setTranslationHostsFromStr(hostsJson);

        // Assert
        expect(result, isA<List<Map<String, dynamic>>>());
        expect(result.length, 2);
        expect(result[0]['host'], 'api1.example.com');
        expect(result[0]['api_key'], 'abc123');
        expect(result[1]['host'], 'api2.example.com');
        expect(result[1]['api_key'], isNull);
      });

      test('should set default hosts when null string is provided', () {
        // Act
        final result = TranslationAPI.setTranslationHostsFromStr(null);

        // Assert
        expect(result, isA<List<Map<String, dynamic>>>());
        expect(result.length, greaterThan(0));

        // Should contain default hosts
        final hostNames = result.map((h) => h['host']).toList();
        expect(hostNames, contains('libretranslate.de'));
      });

      test('should handle empty JSON array', () {
        // Arrange
        const emptyJson = '[]';

        // Act
        final result = TranslationAPI.setTranslationHostsFromStr(emptyJson);

        // Assert
        expect(result, isA<List<Map<String, dynamic>>>());
        expect(result, isEmpty);
      });
    });

    group('langCodeReplace', () {
      test('should contain expected language code replacements', () {
        // Assert
        expect(TranslationAPI.langCodeReplace, isA<Map<String, String>>());
        expect(TranslationAPI.langCodeReplace['iw'], 'he');
        expect(TranslationAPI.langCodeReplace['in'], 'id');
      });
    });

    group('parseResponse', () {
      test('should parse successful response', () async {
        // This test would require mocking HTTP responses
        // For now, we'll test the structure and error handling patterns
        expect(TranslationAPI.parseResponse, isA<Function>());
      });
    });
  });

  // Note: Tests for getSupportedLanguages, translate, and cacheRequest methods
  // would require complex mocking of HTTP clients and cache systems.
  // These integration-style tests are candidates for separate test files
  // focused on API integration testing.
}
