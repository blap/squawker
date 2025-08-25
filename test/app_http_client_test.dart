import 'package:flutter_test/flutter_test.dart';
import 'package:squawker/client/app_http_client.dart';

void main() {
  group('AppHttpClient', () {
    test('should have AppHttpClient class available', () {
      expect(AppHttpClient, isNotNull);
    });

    test('should have httpGet method', () {
      // Test that the httpGet method exists and can be called
      expect(AppHttpClient.httpGet, isA<Function>());
    });

    test('should handle different URI types', () {
      // Test URI parameter validation
      final httpUri = Uri.parse('http://example.com');
      final httpsUri = Uri.parse('https://example.com');

      // Verify URIs are created properly
      expect(httpUri.scheme, 'http');
      expect(httpsUri.scheme, 'https');

      // Test that methods accept URI parameters without throwing
      expect(() => AppHttpClient.httpGet(httpUri), returnsNormally);
      expect(() => AppHttpClient.httpGet(httpsUri), returnsNormally);
    });

    test('should handle URI with query parameters', () {
      final uriWithQuery = Uri.parse('https://api.example.com/data?key=value&format=json');

      expect(uriWithQuery.queryParameters['key'], 'value');
      expect(uriWithQuery.queryParameters['format'], 'json');
      expect(() => AppHttpClient.httpGet(uriWithQuery), returnsNormally);
    });

    test('should handle URI with path segments', () {
      final uriWithPath = Uri.parse('https://api.example.com/v1/users/123');

      expect(uriWithPath.pathSegments, contains('v1'));
      expect(uriWithPath.pathSegments, contains('users'));
      expect(uriWithPath.pathSegments, contains('123'));
      expect(() => AppHttpClient.httpGet(uriWithPath), returnsNormally);
    });
  });
}
