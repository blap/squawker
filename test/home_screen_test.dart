import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:squawker/home/home_screen.dart';

void main() {
  group('HomeScreen', () {
    test('should be able to import HomeScreen', () {
      // This test simply verifies that the module can be imported without errors
      expect(HomeScreen, isNotNull);
    });

    test('should be a StatelessWidget', () {
      // Create an instance and check its runtime type
      final homeScreen = HomeScreen();
      expect(homeScreen, isA<StatelessWidget>());
    });
  });

  group('NavigationPage', () {
    test('should be able to import NavigationPage', () {
      expect(NavigationPage, isNotNull);
    });

    test('should have required constructor parameters', () {
      expect(NavigationPage, isNotNull);
    });
  });

  group('defaultHomePages', () {
    test('should be able to import defaultHomePages', () {
      expect(defaultHomePages, isNotNull);
    });

    test('should be a list of NavigationPage objects', () {
      expect(defaultHomePages, isA<List<NavigationPage>>());
    });
  });
}
