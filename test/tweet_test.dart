import 'package:flutter_test/flutter_test.dart';
import 'package:squawker/tweet/tweet.dart';
import 'package:squawker/tweet/_entities.dart';

void main() {
  group('Tweet Module', () {
    test('should have TweetTile widget', () {
      // This is a basic test to verify that we can import the tweet module
      expect(TweetTile, isA<Type>());
    });

    test('should have TweetTileState class', () {
      expect(TweetTileState, isA<Type>());
    });

    test('should have tweet entity classes', () {
      expect(TweetEntity, isA<Type>());
      expect(TweetHashtag, isA<Type>());
      expect(TweetUserMention, isA<Type>());
      expect(TweetUrl, isA<Type>());
    });

    test('should have TweetTextPart class', () {
      expect(TweetTextPart, isA<Type>());
    });

    test('should have TranslationStatus enum', () {
      expect(TranslationStatus.values, isNotEmpty);
    });
  });
}
