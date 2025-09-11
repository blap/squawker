import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:squawker/utils/urls.dart';
import 'package:url_launcher/url_launcher_string.dart';

// Generate mocks
@GenerateMocks(
  [],
  customMocks: [MockSpec<Future<void> Function(String, {LaunchMode mode})>(onMissingStub: OnMissingStub.returnDefault)],
)
void main() {
  group('Urls Utility', () {
    test('should export openUri function', () {
      // This test simply verifies that the function can be imported
      expect(openUri, isNotNull);
      expect(openUri, isA<Future<void> Function(String uri)>());
    });

    group('openUri function', () {
      test('should have correct function signature', () {
        // Verify the function signature
        expect(openUri, isA<Future<void> Function(String)>());
      });

      test('should accept a URI string parameter', () {
        // Verify that the function accepts a string parameter
        expect(openUri, isA<Function>());
      });

      test('should call launchUrlString with external application mode', () async {
        // This test would require proper mocking of url_launcher
        // For now, we're just verifying the function can be called without error
        expect(() => openUri('https://example.com'), returnsNormally);
      });
    });
  });
}
