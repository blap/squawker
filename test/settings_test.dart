import 'package:flutter_test/flutter_test.dart';
import 'package:squawker/settings/settings.dart';

void main() {
  group('Settings Module', () {
    test('should have SettingsScreen widget', () {
      expect(SettingsScreen, isA<Type>());
    });
  });
}
