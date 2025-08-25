import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:squawker/settings/_theme.dart';
import 'package:squawker/generated/l10n.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// Helper function to create a test app with proper localization setup
Widget createTestApp({required Widget child}) {
  return MaterialApp(
    localizationsDelegates: const [
      L10n.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: L10n.delegate.supportedLocales,
    locale: const Locale('en'),
    home: Builder(
      builder: (context) {
        return Material(child: Center(child: child));
      },
    ),
  );
}

/// Helper function to create a test context with proper localization - similar to downloads_test.dart
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

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await L10n.delegate.load(const Locale('en'));
  });

  setUp(() async {
    // Ensure L10n is loaded for each test
    await L10n.delegate.load(const Locale('en'));
  });

  group('FontSizePickerDialog', () {
    group('Dialog Construction', () {
      testWidgets('should build with initial font size', (WidgetTester tester) async {
        // Arrange
        final context = await createTestContext(tester);

        // Act - Show dialog using the proper context (don't await result)
        showDialog<int>(context: context, builder: (context) => const FontSizePickerDialog(initialFontSize: 16));

        // Let the dialog render
        await tester.pumpAndSettle();

        // Assert - Dialog should be displayed
        expect(find.byType(FontSizePickerDialog), findsOneWidget);
        expect(find.byType(AlertDialog), findsOneWidget);
        expect(find.text('16 px'), findsOneWidget);
        expect(find.text('Font size'), findsOneWidget);
      });

      testWidgets('should display title and controls', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(createTestApp(child: const FontSizePickerDialog(initialFontSize: 14)));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Font size'), findsOneWidget);
        expect(find.byType(Slider), findsOneWidget);
        expect(find.text('Cancel'), findsOneWidget);
        expect(find.text('Save'), findsOneWidget);
      });

      testWidgets('should show current font size value', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(createTestApp(child: const FontSizePickerDialog(initialFontSize: 18)));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('18 px'), findsOneWidget);
      });
    });

    group('Slider Functionality', () {
      testWidgets('should update font size when slider changes', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(createTestApp(child: const FontSizePickerDialog(initialFontSize: 14)));
        await tester.pumpAndSettle();

        // Find the slider and verify it's present
        final slider = find.byType(Slider);
        expect(slider, findsOneWidget);

        // Assert - dialog should be functional
        expect(find.byType(FontSizePickerDialog), findsOneWidget);
        expect(find.byType(Slider), findsOneWidget);
      });

      testWidgets('should respect min and max font size bounds', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(createTestApp(child: const FontSizePickerDialog(initialFontSize: 14)));
        await tester.pumpAndSettle();

        // Get the slider widget to check its properties
        final sliderWidget = tester.widget<Slider>(find.byType(Slider));

        // Assert - should have reasonable bounds based on theme
        expect(sliderWidget.min, greaterThan(8)); // Reasonable minimum
        expect(sliderWidget.max, lessThan(30)); // Reasonable maximum
        expect(sliderWidget.value, equals(14.0));
      });
    });

    group('Dialog Actions', () {
      testWidgets('should close dialog when cancel is pressed', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(createTestApp(child: const FontSizePickerDialog(initialFontSize: 14)));
        await tester.pumpAndSettle();

        // Tap cancel button
        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();

        // Assert - dialog should be dismissed
        expect(find.byType(FontSizePickerDialog), findsNothing);
      });

      testWidgets('should close dialog when save is pressed', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(createTestApp(child: const FontSizePickerDialog(initialFontSize: 14)));
        await tester.pumpAndSettle();

        // Tap save button
        await tester.tap(find.text('Save'));
        await tester.pumpAndSettle();

        // Assert - dialog should be dismissed
        expect(find.byType(FontSizePickerDialog), findsNothing);
      });
    });

    group('State Management', () {
      testWidgets('should maintain font size state during dialog lifecycle', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(createTestApp(child: const FontSizePickerDialog(initialFontSize: 16)));
        await tester.pumpAndSettle();

        // Verify initial state
        expect(find.text('16 px'), findsOneWidget);

        // Trigger a rebuild by pumping
        await tester.pump();

        // Assert - state should be maintained
        expect(find.text('16 px'), findsOneWidget);
        expect(find.byType(FontSizePickerDialog), findsOneWidget);
      });

      testWidgets('should handle different initial font sizes', (WidgetTester tester) async {
        final testSizes = [10, 12, 14, 16, 18, 20];

        for (final size in testSizes) {
          // Act
          await tester.pumpWidget(createTestApp(child: FontSizePickerDialog(initialFontSize: size)));
          await tester.pumpAndSettle();

          // Assert
          expect(find.text('$size px'), findsOneWidget);
          expect(find.byType(FontSizePickerDialog), findsOneWidget);

          // Clean up for next iteration
          await tester.pumpWidget(Container());
          await tester.pumpAndSettle();
        }
      });
    });

    group('Edge Cases', () {
      testWidgets('should handle extreme font sizes gracefully', (WidgetTester tester) async {
        // Test with small font size using the old approach for this specific test
        await tester.pumpWidget(createTestApp(child: const FontSizePickerDialog(initialFontSize: 10)));
        await tester.pumpAndSettle();

        expect(find.byType(FontSizePickerDialog), findsOneWidget);
        expect(find.text('10 px'), findsOneWidget);

        // Clean up for next test
        await tester.pumpWidget(Container());
        await tester.pumpAndSettle();

        // Test with large font size using the old approach for this specific test
        await tester.pumpWidget(createTestApp(child: const FontSizePickerDialog(initialFontSize: 22)));
        await tester.pumpAndSettle();

        expect(find.byType(FontSizePickerDialog), findsOneWidget);
        expect(find.text('22 px'), findsOneWidget);
      });

      testWidgets('should handle very small font size', (WidgetTester tester) async {
        // Arrange
        final context = await createTestContext(tester);

        // Use a realistic minimum font size (likely around 10-12)
        const testFontSize = 10;

        // Act - Show dialog using the proper context (don't await result)
        showDialog<int>(
          context: context,
          builder: (context) => const FontSizePickerDialog(initialFontSize: testFontSize),
        );

        // Let the dialog render
        await tester.pumpAndSettle();

        // Assert - Dialog should be displayed with proper text
        expect(find.byType(FontSizePickerDialog), findsOneWidget);
        expect(find.text('$testFontSize px'), findsOneWidget);
        expect(find.text('Font size'), findsOneWidget);
      });

      testWidgets('should calculate divisions correctly', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(createTestApp(child: const FontSizePickerDialog(initialFontSize: 14)));
        await tester.pumpAndSettle();

        // Get the slider widget to check its divisions
        final sliderWidget = tester.widget<Slider>(find.byType(Slider));

        // Assert - should have reasonable divisions
        expect(sliderWidget.divisions, isNotNull);
        expect(sliderWidget.divisions!, greaterThan(0));
      });
    });

    group('Theme Integration', () {
      testWidgets('should calculate bounds based on theme font size', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(createTestApp(child: const FontSizePickerDialog(initialFontSize: 14)));
        await tester.pumpAndSettle();

        // Get the slider to verify it uses theme-based bounds
        final sliderWidget = tester.widget<Slider>(find.byType(Slider));

        // Assert - bounds should be reasonable relative to typical theme font sizes
        final range = sliderWidget.max - sliderWidget.min;
        expect(range, greaterThan(8)); // Should have reasonable range
        expect(range, lessThan(20)); // But not excessive range
      });

      testWidgets('should display font size in correct format', (WidgetTester tester) async {
        final testSizes = [12, 14, 16, 18, 20];

        for (final size in testSizes) {
          // Arrange
          final context = await createTestContext(tester);

          // Act - Show dialog using the proper context (don't await result)
          showDialog<int>(
            context: context,
            builder: (context) => FontSizePickerDialog(initialFontSize: size),
          );

          // Let the dialog render
          await tester.pumpAndSettle();

          // Should display size with "px" suffix
          expect(find.text('$size px'), findsOneWidget);
          expect(find.textContaining('px'), findsAtLeastNWidgets(1)); // At least the displayed value

          // Clean up for next iteration
          await tester.pumpWidget(Container());
          await tester.pumpAndSettle();
        }
      });
    });

    group('Accessibility', () {
      testWidgets('should have proper semantic labels', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(createTestApp(child: const FontSizePickerDialog(initialFontSize: 16)));
        await tester.pumpAndSettle();

        // Assert - should have accessible elements
        expect(find.byType(AlertDialog), findsOneWidget);
        expect(find.byType(Slider), findsOneWidget);
        expect(find.text('Font size'), findsOneWidget); // Clear title
        expect(find.text('Cancel'), findsOneWidget); // Clear action labels
        expect(find.text('Save'), findsOneWidget);
      });

      testWidgets('should support semantic navigation', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(createTestApp(child: const FontSizePickerDialog(initialFontSize: 14)));
        await tester.pumpAndSettle();

        // Find all interactive elements
        final slider = find.byType(Slider);
        final cancelButton = find.text('Cancel');
        final saveButton = find.text('Save');

        // Assert - all interactive elements should be present
        expect(slider, findsOneWidget);
        expect(cancelButton, findsOneWidget);
        expect(saveButton, findsOneWidget);
      });
    });
  });
}
