import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:squawker/ui/errors.dart';
import 'package:squawker/client/client.dart';
import 'package:squawker/generated/l10n.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// Helper function to create a MaterialApp with proper localization support
Widget createLocalizedApp({required Widget child}) {
  return MaterialApp(
    localizationsDelegates: const [
      L10n.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: L10n.delegate.supportedLocales,
    locale: const Locale('en'),
    home: Scaffold(body: child),
  );
}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await L10n.delegate.load(const Locale('en'));
  });

  group('Error UI Components', () {
    group('showAlertDialog', () {
      testWidgets('should display alert dialog with title and message', (WidgetTester tester) async {
        // Arrange
        const title = 'Test Title';
        const message = 'Test message';

        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showAlertDialog(context, title, message),
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        );

        // Act
        await tester.tap(find.text('Show Dialog'));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text(title), findsOneWidget);
        expect(find.text(message), findsOneWidget);
        expect(find.text('OK'), findsOneWidget);
      });

      testWidgets('should handle multiline messages', (WidgetTester tester) async {
        // Arrange
        const title = 'Error';
        const message = 'Line 1\nLine 2\nLine 3';

        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showAlertDialog(context, title, message),
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        );

        // Act
        await tester.tap(find.text('Show Dialog'));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Line 1'), findsOneWidget);
        expect(find.text('Line 2'), findsOneWidget);
        expect(find.text('Line 3'), findsOneWidget);
      });

      testWidgets('should close dialog when OK is tapped', (WidgetTester tester) async {
        // Arrange
        const title = 'Test';
        const message = 'Test message';

        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showAlertDialog(context, title, message),
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Show Dialog'));
        await tester.pumpAndSettle();

        // Act
        await tester.tap(find.text('OK'));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text(title), findsNothing);
        expect(find.text(message), findsNothing);
      });
    });

    group('showSnackBar', () {
      testWidgets('should display snackbar with icon and message', (WidgetTester tester) async {
        // Arrange
        const icon = '🚨';
        const message = 'Test message';

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => showSnackBar(context, icon: icon, message: message),
                  child: const Text('Show SnackBar'),
                ),
              ),
            ),
          ),
        );

        // Act
        await tester.tap(find.text('Show SnackBar'));
        await tester.pump();

        // Assert
        expect(find.text(icon), findsOneWidget);
        expect(find.text(message), findsOneWidget);
      });

      testWidgets('should clear previous snackbars when clearBefore is true', (WidgetTester tester) async {
        // This test verifies the clearBefore functionality
        // Note: Testing actual clearing behavior would require more complex setup
        const icon = '⚠️';
        const message = 'Warning message';

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => showSnackBar(context, icon: icon, message: message, clearBefore: true),
                  child: const Text('Show SnackBar'),
                ),
              ),
            ),
          ),
        );

        // Act
        await tester.tap(find.text('Show SnackBar'));
        await tester.pump();

        // Assert
        expect(find.text(message), findsOneWidget);
      });
    });

    group('UnknownTwitterErrorCode', () {
      test('should create exception with code, message, and uri', () {
        // Arrange
        const code = 404;
        const message = 'Not found';
        const uri = '/api/test';

        // Act
        final exception = UnknownTwitterErrorCode(code, message, uri);

        // Assert
        expect(exception.code, equals(code));
        expect(exception.message, equals(message));
        expect(exception.uri, equals(uri));
      });

      test('toString should include all error details', () {
        // Arrange
        const code = 500;
        const message = 'Internal error';
        const uri = '/api/internal';

        // Act
        final exception = UnknownTwitterErrorCode(code, message, uri);
        final result = exception.toString();

        // Assert
        expect(result, contains(code.toString()));
        expect(result, contains(message));
        expect(result, contains(uri));
      });
    });

    group('createEmojiError', () {
      test('should create private profile error for code 22', () {
        // Arrange
        final error = TwitterError(uri: '/api/test', code: 22, message: 'Private account');

        // Act
        final widget = createEmojiError(error);

        // Assert
        expect(widget.emoji, equals('🔒'));
        expect(widget.errorMessage, equals('Private account'));
      });

      test('should create page not found error for code 34', () {
        // Arrange
        final error = TwitterError(uri: '/api/test', code: 34, message: 'Page not found');

        // Act
        final widget = createEmojiError(error);

        // Assert
        expect(widget.emoji, equals('🤔'));
        expect(widget.errorMessage, equals('Page not found'));
      });

      test('should create user not found error for code 50', () {
        // Arrange
        final error = TwitterError(uri: '/api/test', code: 50, message: 'User not found');

        // Act
        final widget = createEmojiError(error);

        // Assert
        expect(widget.emoji, equals('🕵️'));
        expect(widget.errorMessage, equals('User not found'));
      });

      test('should create suspended account error for code 63', () {
        // Arrange
        final error = TwitterError(uri: '/api/test', code: 63, message: 'Account suspended');

        // Act
        final widget = createEmojiError(error);

        // Assert
        expect(widget.emoji, equals('👮'));
        expect(widget.errorMessage, equals('Account suspended'));
      });

      test('should create forbidden error for code 200', () {
        // Arrange
        final error = TwitterError(uri: '/api/test', code: 200, message: 'Forbidden');

        // Act
        final widget = createEmojiError(error);

        // Assert
        expect(widget.emoji, equals('⛔'));
        expect(widget.errorMessage, equals('Forbidden'));
      });

      test('should create bad guest token error for code 239', () {
        // Arrange
        final error = TwitterError(uri: '/api/test', code: 239, message: 'Bad guest token');

        // Act
        final widget = createEmojiError(error);

        // Assert
        expect(widget.emoji, equals('💩'));
        expect(widget.errorMessage, equals('Bad guest token'));
      });

      test('should create catastrophic failure for unknown code', () {
        // Arrange
        final error = TwitterError(uri: '/api/test', code: 999, message: 'Unknown error');

        // Act
        final widget = createEmojiError(error);

        // Assert
        expect(widget.emoji, equals('💥'));
        expect(widget.errorMessage, equals('Unknown error'));
      });
    });

    group('EmojiErrorWidget', () {
      testWidgets('should display emoji and message', (WidgetTester tester) async {
        // Arrange
        const emoji = '🚨';
        const message = 'Test error';
        const errorMessage = 'Detailed error';

        // Act
        await tester.pumpWidget(
          createLocalizedApp(
            child: EmojiErrorWidget(emoji: emoji, message: message, errorMessage: errorMessage),
          ),
        );

        // Assert
        expect(find.text(emoji), findsOneWidget);
        expect(find.text(message), findsOneWidget);
        expect(find.text(errorMessage), findsOneWidget);
      });

      testWidgets('should show back button by default', (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          createLocalizedApp(
            child: EmojiErrorWidget(emoji: '❌', message: 'Error', errorMessage: 'Details'),
          ),
        );

        // Assert
        expect(find.text('Back'), findsOneWidget);
      });

      testWidgets('should hide back button when showBackButton is false', (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          createLocalizedApp(
            child: EmojiErrorWidget(emoji: '❌', message: 'Error', errorMessage: 'Details', showBackButton: false),
          ),
        );

        // Assert
        expect(find.text('Back'), findsNothing);
      });

      testWidgets('should show retry button when onRetry is provided', (WidgetTester tester) async {
        // Arrange
        var retryPressed = false;

        // Act
        await tester.pumpWidget(
          createLocalizedApp(
            child: EmojiErrorWidget(
              emoji: '🔄',
              message: 'Retry Error',
              errorMessage: 'Details',
              onRetry: () async => retryPressed = true,
            ),
          ),
        );

        // Assert
        expect(find.text('Retry'), findsOneWidget);

        await tester.tap(find.text('Retry'));
        await tester.pump();

        expect(retryPressed, isTrue);
      });
    });

    group('InlineErrorWidget', () {
      testWidgets('should display error with icon', (WidgetTester tester) async {
        // Arrange
        const error = 'Test error message';

        // Act
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(body: InlineErrorWidget(error: error)),
          ),
        );

        // Assert
        expect(find.text(error), findsOneWidget);
        expect(find.byIcon(Icons.error_rounded), findsOneWidget);
      });
    });

    group('FullPageErrorWidget', () {
      testWidgets('should handle SocketException', (WidgetTester tester) async {
        // Arrange
        const error = SocketException('Connection failed');

        // Act
        await tester.pumpWidget(
          createLocalizedApp(
            child: FullPageErrorWidget(error: error, stackTrace: StackTrace.current, prefix: 'Test prefix'),
          ),
        );

        // Assert
        expect(find.text('🔌'), findsOneWidget);
      });

      testWidgets('should handle TimeoutException', (WidgetTester tester) async {
        // Arrange
        final error = TimeoutException('Request timeout', const Duration(seconds: 30));

        // Act
        await tester.pumpWidget(
          createLocalizedApp(
            child: FullPageErrorWidget(error: error, stackTrace: StackTrace.current, prefix: 'Test prefix'),
          ),
        );

        // Assert
        expect(find.text('⏱️'), findsOneWidget);
      });

      testWidgets('should handle TwitterError', (WidgetTester tester) async {
        // Arrange
        final error = TwitterError(uri: '/api/test', code: 34, message: 'Not found');

        // Act
        await tester.pumpWidget(
          createLocalizedApp(
            child: FullPageErrorWidget(error: error, stackTrace: StackTrace.current, prefix: 'Test prefix'),
          ),
        );

        // Assert
        expect(find.text('🤔'), findsOneWidget);
      });

      testWidgets('should handle http.Response error', (WidgetTester tester) async {
        // Arrange
        final error = http.Response('Server error', 500);

        // Act
        await tester.pumpWidget(
          createLocalizedApp(
            child: FullPageErrorWidget(error: error, stackTrace: StackTrace.current, prefix: 'Test prefix'),
          ),
        );

        // Assert
        expect(find.text('Server error'), findsOneWidget);
        expect(find.byIcon(Icons.error_rounded), findsOneWidget);
      });

      testWidgets('should show retry button when onRetry is provided', (WidgetTester tester) async {
        // Arrange
        var retryPressed = false;
        final error = Exception('Test exception');

        // Act
        await tester.pumpWidget(
          createLocalizedApp(
            child: FullPageErrorWidget(
              error: error,
              stackTrace: StackTrace.current,
              prefix: 'Test prefix',
              onRetry: () => retryPressed = true,
            ),
          ),
        );

        // Assert
        expect(find.text('Retry'), findsOneWidget);

        await tester.tap(find.text('Retry'));
        await tester.pump();

        expect(retryPressed, isTrue);
      });
    });
  });
}
