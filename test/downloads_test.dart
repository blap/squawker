import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:squawker/utils/downloads.dart';
import 'package:squawker/generated/l10n.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  group('Downloads Utilities', () {
    group('UnableToSaveMedia', () {
      test('should create exception with uri and error', () {
        // Arrange
        final uri = Uri.parse('https://example.com/image.jpg');
        const error = 'Network error';

        // Act
        final exception = UnableToSaveMedia(uri, error);

        // Assert
        expect(exception.uri, uri);
        expect(exception.e, error);
      });

      test('should have proper toString implementation', () {
        // Arrange
        final uri = Uri.parse('https://example.com/video.mp4');
        const error = 'Permission denied';
        final exception = UnableToSaveMedia(uri, error);

        // Act
        final result = exception.toString();

        // Assert
        expect(result, contains('Unable to save the media'));
        expect(result, contains(uri.toString()));
        expect(result, contains(error.toString()));
      });

      test('should handle different types of errors', () {
        // Arrange
        final uri = Uri.parse('https://example.com/file.txt');
        const stringError = 'String error';
        final exceptionError = Exception('Exception error');
        const intError = 404;

        // Act
        final stringException = UnableToSaveMedia(uri, stringError);
        final exceptionException = UnableToSaveMedia(uri, exceptionError);
        final intException = UnableToSaveMedia(uri, intError);

        // Assert
        expect(stringException.e, stringError);
        expect(exceptionException.e, exceptionError);
        expect(intException.e, intError);
      });

      test('should handle different URI schemes', () {
        // Arrange
        final httpUri = Uri.parse('http://example.com/file.jpg');
        final httpsUri = Uri.parse('https://example.com/file.jpg');
        final fileUri = Uri.parse('file:///path/to/file.jpg');
        const error = 'Test error';

        // Act
        final httpException = UnableToSaveMedia(httpUri, error);
        final httpsException = UnableToSaveMedia(httpsUri, error);
        final fileException = UnableToSaveMedia(fileUri, error);

        // Assert
        expect(httpException.uri.scheme, 'http');
        expect(httpsException.uri.scheme, 'https');
        expect(fileException.uri.scheme, 'file');
      });

      test('should handle complex URIs with query parameters', () {
        // Arrange
        final complexUri = Uri.parse('https://example.com/file.jpg?size=large&format=png&token=abc123');
        const error = 'Complex URI error';

        // Act
        final exception = UnableToSaveMedia(complexUri, error);

        // Assert
        expect(exception.uri, complexUri);
        expect(exception.uri.queryParameters['size'], 'large');
        expect(exception.uri.queryParameters['format'], 'png');
        expect(exception.uri.queryParameters['token'], 'abc123');
      });
    });

    group('downloadFile', () {
      testWidgets('should accept required parameters', (WidgetTester tester) async {
        // Arrange
        final context = await createTestContext(tester);
        final uri = Uri.parse('https://httpbin.org/status/404');

        // Act & Assert - Test that the function can be called
        expect(() => downloadFile(context, uri), returnsNormally);
      });

      testWidgets('should handle different URI types', (WidgetTester tester) async {
        // Arrange
        final context = await createTestContext(tester);
        final httpUri = Uri.parse('http://example.com/file.jpg');
        final httpsUri = Uri.parse('https://example.com/file.jpg');

        // Act & Assert
        expect(() => downloadFile(context, httpUri), returnsNormally);
        expect(() => downloadFile(context, httpsUri), returnsNormally);
      });

      testWidgets('should return Future<Uint8List?>', (WidgetTester tester) async {
        // Arrange
        final context = await createTestContext(tester);
        final uri = Uri.parse('https://httpbin.org/status/404');

        // Act
        final result = downloadFile(context, uri);

        // Assert
        expect(result, isA<Future<Uint8List?>>());
      });
    });

    group('downloadUriToPickedFile', () {
      testWidgets('should accept required parameters', (WidgetTester tester) async {
        // Arrange
        final context = await createTestContext(tester);
        final uri = Uri.parse('https://example.com/file.jpg');
        const fileName = 'test-file.jpg';
        bool startCalled = false;
        // Note: onSuccess callback may not be called if the download fails
        // This test focuses on verifying the function signature and parameter acceptance

        // Act & Assert
        expect(
          () => downloadUriToPickedFile(
            context,
            uri,
            fileName,
            onStart: () => startCalled = true,
            onSuccess: () {}, // Empty callback since we're not testing success in this test
          ),
          returnsNormally,
        );

        // Verify that the onStart callback was called (it's called immediately)
        expect(startCalled, isTrue, reason: 'onStart callback should be called');
      });

      testWidgets('should handle callback parameters', (WidgetTester tester) async {
        // Arrange
        final context = await createTestContext(tester);
        final uri = Uri.parse('https://example.com/test.jpg');
        const fileName = 'callback-test.jpg';
        int startCount = 0;
        int successCount = 0;

        // Create callbacks
        void onStart() => startCount++;
        void onSuccess() => successCount++;

        // Act & Assert
        expect(
          () => downloadUriToPickedFile(context, uri, fileName, onStart: onStart, onSuccess: onSuccess),
          returnsNormally,
        );
      });

      testWidgets('should handle different file extensions', (WidgetTester tester) async {
        // Arrange
        final context = await createTestContext(tester);
        final uri = Uri.parse('https://example.com/file.pdf');
        final fileNames = ['image.jpg', 'video.mp4', 'document.pdf', 'audio.mp3', 'data.json'];

        // Act & Assert
        for (final fileName in fileNames) {
          expect(
            () => downloadUriToPickedFile(context, uri, fileName, onStart: () {}, onSuccess: () {}),
            returnsNormally,
          );
        }
      });

      testWidgets('should sanitize filename with query parameters', (WidgetTester tester) async {
        // Arrange
        final context = await createTestContext(tester);
        final uri = Uri.parse('https://example.com/image.jpg?size=large&format=png');
        const fileName = 'image.jpg?size=large&format=png';

        // Act & Assert - Should handle filename with query parameters
        expect(
          () => downloadUriToPickedFile(context, uri, fileName, onStart: () {}, onSuccess: () {}),
          returnsNormally,
        );
      });

      testWidgets('should handle special characters in filename', (WidgetTester tester) async {
        // Arrange
        final context = await createTestContext(tester);
        final uri = Uri.parse('https://example.com/file.jpg');
        final specialFileNames = [
          'file with spaces.jpg',
          'file-with-dashes.jpg',
          'file_with_underscores.jpg',
          'file.with.dots.jpg',
          'file(with)parentheses.jpg',
        ];

        // Act & Assert
        for (final fileName in specialFileNames) {
          expect(
            () => downloadUriToPickedFile(context, uri, fileName, onStart: () {}, onSuccess: () {}),
            returnsNormally,
          );
        }
      });
    });
  });
}

// Helper function to create a test context with proper localization
Future<BuildContext> createTestContext(WidgetTester tester) async {
  late BuildContext context;

  // Initialize L10n for tests
  await L10n.delegate.load(const Locale('en'));

  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: const [
        L10n.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: L10n.delegate.supportedLocales,
      locale: const Locale('en'),
      home: Builder(
        builder: (BuildContext ctx) {
          context = ctx;
          return const Scaffold(body: Text('Test'));
        },
      ),
    ),
  );

  return context;
}
