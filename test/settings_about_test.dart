import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:squawker/settings/_about.dart';

void main() {
  group('SettingsAboutFragment', () {
    test('should be able to import SettingsAboutFragment', () {
      // This test simply verifies that the module can be imported without errors
      expect(SettingsAboutFragment, isNotNull);
    });

    test('should be a StatelessWidget', () {
      // Create an instance and check its runtime type
      final settingsAboutFragment = SettingsAboutFragment(appVersion: '1.0.0');
      expect(settingsAboutFragment, isA<StatelessWidget>());
    });
  });
}
