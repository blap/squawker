import 'package:flutter_test/flutter_test.dart';
import 'package:squawker/tweet/_photo.dart';
import 'package:flutter/material.dart';

void main() {
  group('Photo Module', () {
    test('should have TweetPhoto widget', () {
      expect(TweetPhoto, isA<Type>());
    });

    group('TweetPhoto', () {
      test('should create TweetPhoto with required parameters', () {
        final photo = TweetPhoto(uri: 'https://example.com/image.jpg', pullToClose: true, inPageView: false);

        expect(photo.uri, equals('https://example.com/image.jpg'));
        expect(photo.pullToClose, isTrue);
        expect(photo.inPageView, isFalse);
      });

      test('should create TweetPhoto with optional parameters', () {
        final photo = TweetPhoto(
          uri: 'https://example.com/image.jpg',
          fit: BoxFit.cover,
          size: 'large',
          pullToClose: false,
          inPageView: true,
        );

        expect(photo.uri, equals('https://example.com/image.jpg'));
        expect(photo.fit, equals(BoxFit.cover));
        expect(photo.size, equals('large'));
        expect(photo.pullToClose, isFalse);
        expect(photo.inPageView, isTrue);
      });
    });
  });
}
