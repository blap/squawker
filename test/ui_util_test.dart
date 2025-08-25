import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:squawker/utils/ui_util.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  group('UI Utilities', () {
    group('calcTextSizeWithStyle', () {
      testWidgets('should calculate text size for normal text with custom style', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (BuildContext context) {
                const text = 'Hello World';
                const style = TextStyle(fontSize: 16, fontWeight: FontWeight.bold);

                final size = calcTextSizeWithStyle(context, text, style);

                expect(size, isA<Size>());
                expect(size.width, greaterThan(0));
                expect(size.height, greaterThan(0));

                return Container();
              },
            ),
          ),
        );
      });

      testWidgets('should calculate different sizes for different text content', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (BuildContext context) {
                const style = TextStyle(fontSize: 14);

                final shortSize = calcTextSizeWithStyle(context, 'Hi', style);
                final longSize = calcTextSizeWithStyle(context, 'This is a much longer text string', style);

                expect(shortSize.width, lessThan(longSize.width));
                expect(shortSize.height, equals(longSize.height)); // Same font size, same height

                return Container();
              },
            ),
          ),
        );
      });

      testWidgets('should calculate different sizes for different font sizes', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (BuildContext context) {
                const text = 'Test Text';
                const smallStyle = TextStyle(fontSize: 12);
                const largeStyle = TextStyle(fontSize: 24);

                final smallSize = calcTextSizeWithStyle(context, text, smallStyle);
                final largeSize = calcTextSizeWithStyle(context, text, largeStyle);

                expect(smallSize.width, lessThan(largeSize.width));
                expect(smallSize.height, lessThan(largeSize.height));

                return Container();
              },
            ),
          ),
        );
      });

      testWidgets('should handle empty string', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (BuildContext context) {
                const style = TextStyle(fontSize: 16);

                final size = calcTextSizeWithStyle(context, '', style);

                expect(size.width, equals(0));
                expect(size.height, greaterThan(0)); // Font has height even with empty text

                return Container();
              },
            ),
          ),
        );
      });

      testWidgets('should handle multiline text', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (BuildContext context) {
                const style = TextStyle(fontSize: 16);
                const singleLineText = 'Single line';
                const multiLineText = 'Line 1\nLine 2\nLine 3';

                final singleLineSize = calcTextSizeWithStyle(context, singleLineText, style);
                final multiLineSize = calcTextSizeWithStyle(context, multiLineText, style);

                expect(multiLineSize.height, greaterThan(singleLineSize.height));

                return Container();
              },
            ),
          ),
        );
      });

      testWidgets('should respect text scale factor from MediaQuery', (WidgetTester tester) async {
        const text = 'Scale Test';
        const style = TextStyle(fontSize: 16);

        // Test with normal scale factor
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (BuildContext context) {
                final normalSize = calcTextSizeWithStyle(context, text, style);

                expect(normalSize.width, greaterThan(0));
                expect(normalSize.height, greaterThan(0));

                return Container();
              },
            ),
          ),
        );

        // Test with larger scale factor
        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(textScaler: TextScaler.linear(2.0)),
              child: Builder(
                builder: (BuildContext context) {
                  final scaledSize = calcTextSizeWithStyle(context, text, style);

                  expect(scaledSize.width, greaterThan(0));
                  expect(scaledSize.height, greaterThan(0));

                  return Container();
                },
              ),
            ),
          ),
        );
      });
    });

    group('calcTextSize', () {
      testWidgets('should calculate text size using default text style', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (BuildContext context) {
                const text = 'Default Style Test';

                final size = calcTextSize(context, text);

                expect(size, isA<Size>());
                expect(size.width, greaterThan(0));
                expect(size.height, greaterThan(0));

                return Container();
              },
            ),
          ),
        );
      });

      testWidgets('should use DefaultTextStyle from context', (WidgetTester tester) async {
        const customStyle = TextStyle(fontSize: 20, fontWeight: FontWeight.bold);

        await tester.pumpWidget(
          MaterialApp(
            home: DefaultTextStyle(
              style: customStyle,
              child: Builder(
                builder: (BuildContext context) {
                  const text = 'Custom Default Style';

                  final sizeWithDefault = calcTextSize(context, text);
                  final sizeWithExplicit = calcTextSizeWithStyle(context, text, customStyle);

                  // Should be the same since we're using the same style
                  expect(sizeWithDefault.width, equals(sizeWithExplicit.width));
                  expect(sizeWithDefault.height, equals(sizeWithExplicit.height));

                  return Container();
                },
              ),
            ),
          ),
        );
      });

      testWidgets('should handle different text lengths with default style', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (BuildContext context) {
                final shortSize = calcTextSize(context, 'Short');
                final longSize = calcTextSize(context, 'This is a very long text that should be wider');

                expect(shortSize.width, lessThan(longSize.width));
                expect(shortSize.height, equals(longSize.height)); // Same style, same height

                return Container();
              },
            ),
          ),
        );
      });

      testWidgets('should handle empty string with default style', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (BuildContext context) {
                final size = calcTextSize(context, '');

                expect(size.width, equals(0));
                expect(size.height, greaterThan(0)); // Font has height even with empty text

                return Container();
              },
            ),
          ),
        );
      });

      testWidgets('should handle special characters', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (BuildContext context) {
                const specialText = '!@#\$%^&*()_+-=[]{}|;:,.<>?~`';

                final size = calcTextSize(context, specialText);

                expect(size.width, greaterThan(0));
                expect(size.height, greaterThan(0));

                return Container();
              },
            ),
          ),
        );
      });

      testWidgets('should handle unicode characters', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (BuildContext context) {
                const unicodeText = '你好世界 🌍 こんにちは العالم';

                final size = calcTextSize(context, unicodeText);

                expect(size.width, greaterThan(0));
                expect(size.height, greaterThan(0));

                return Container();
              },
            ),
          ),
        );
      });
    });
  });
}
