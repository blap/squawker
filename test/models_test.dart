import 'package:flutter_test/flutter_test.dart';
import 'package:squawker/models.dart';

void main() {
  group('Country', () {
    test('should create Country with flag and name', () {
      // Arrange & Act
      final country = Country('🇺🇸', 'United States');

      // Assert
      expect(country.flag, '🇺🇸');
      expect(country.name, 'United States');
    });

    test('should handle empty values', () {
      // Arrange & Act
      final country = Country('', '');

      // Assert
      expect(country.flag, '');
      expect(country.name, '');
    });

    test('should handle special characters', () {
      // Arrange & Act
      final country = Country('🏳️‍🌈', 'Pride Flag');

      // Assert
      expect(country.flag, '🏳️‍🌈');
      expect(country.name, 'Pride Flag');
    });
  });

  group('Instance', () {
    test('should create Instance with hostname and country', () {
      // Arrange & Act
      final instance = Instance('example.com', 'US');

      // Assert
      expect(instance.hostname, 'example.com');
      expect(instance.country, 'US');
    });

    test('should handle empty values', () {
      // Arrange & Act
      final instance = Instance('', '');

      // Assert
      expect(instance.hostname, '');
      expect(instance.country, '');
    });

    test('should handle complex hostnames', () {
      // Arrange & Act
      final instance = Instance('sub.domain.example.com:8080', 'USA');

      // Assert
      expect(instance.hostname, 'sub.domain.example.com:8080');
      expect(instance.country, 'USA');
    });
  });
}
