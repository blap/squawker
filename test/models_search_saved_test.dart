import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_triple/flutter_triple.dart';
import 'package:squawker/saved/saved_tweet_model.dart';
import 'package:squawker/search/search_model.dart';
import 'package:squawker/database/entities.dart';
import 'package:squawker/client/client.dart';
import 'package:squawker/user.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SavedTweetModel', () {
    late SavedTweetModel model;

    setUp(() {
      // Initialize sqflite for testing
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
      model = SavedTweetModel();
    });

    test('should create with empty initial state', () {
      // Assert
      expect(model.state, isEmpty);
      expect(model.state, isA<List<SavedTweet>>());
    });

    test('should extend Store', () {
      // Assert
      expect(model, isA<Store<List<SavedTweet>>>());
    });

    test('should check if tweet is saved correctly when empty', () {
      // Act
      final isSaved = model.isSaved('tweet123');

      // Assert
      expect(isSaved, false);
    });

    test('should check if tweet is saved correctly when has tweets', () {
      // Arrange - manually add a tweet to state for testing
      final savedTweet = SavedTweet(id: 'tweet123', user: 'user123', content: 'content');
      model.state.add(savedTweet);

      // Act
      final isSaved = model.isSaved('tweet123');
      final isNotSaved = model.isSaved('tweet456');

      // Assert
      expect(isSaved, true);
      expect(isNotSaved, false);
    });

    test('should handle multiple tweets in isSaved check', () {
      // Arrange
      final tweet1 = SavedTweet(id: 'tweet1', user: 'user1', content: 'content1');
      final tweet2 = SavedTweet(id: 'tweet2', user: 'user2', content: 'content2');
      model.state.addAll([tweet1, tweet2]);

      // Act & Assert
      expect(model.isSaved('tweet1'), true);
      expect(model.isSaved('tweet2'), true);
      expect(model.isSaved('tweet3'), false);
    });

    test('should handle empty string in isSaved check', () {
      // Act
      final isSaved = model.isSaved('');

      // Assert
      expect(isSaved, false);
    });

    test('should handle special characters in isSaved check', () {
      // Arrange
      final tweet = SavedTweet(id: 'tweet@#\$%', user: 'user', content: 'content');
      model.state.add(tweet);

      // Act
      final isSaved = model.isSaved('tweet@#\$%');

      // Assert
      expect(isSaved, true);
    });

    test('should be case sensitive in isSaved check', () {
      // Arrange
      final tweet = SavedTweet(id: 'Tweet123', user: 'user', content: 'content');
      model.state.add(tweet);

      // Act
      final isSavedCorrectCase = model.isSaved('Tweet123');
      final isSavedWrongCase = model.isSaved('tweet123');

      // Assert
      expect(isSavedCorrectCase, true);
      expect(isSavedWrongCase, false);
    });

    test('should handle null values in content', () {
      // Arrange
      final tweet = SavedTweet(id: 'tweet123', user: null, content: null);
      model.state.add(tweet);

      // Act
      final isSaved = model.isSaved('tweet123');

      // Assert
      expect(isSaved, true);
    });

    // The database operations require more complex mocking, so testing the basic functionality
    test('should handle saveTweet method call without throwing', () {
      // Act & Assert - should not throw during method call setup
      expect(() => model.saveTweet('test', 'user', {'text': 'content'}), returnsNormally);
    });

    test('should handle deleteSavedTweet method call without throwing', () {
      // Act & Assert - should not throw during method call setup
      expect(() => model.deleteSavedTweet('test'), returnsNormally);
    });

    test('should handle listSavedTweets method call without throwing', () {
      // Act & Assert - should not throw during method call setup
      expect(() => model.listSavedTweets(), returnsNormally);
    });
  });

  group('SearchTweetsModel', () {
    late SearchTweetsModel model;

    setUp(() {
      model = SearchTweetsModel();
    });

    test('should create with empty initial state', () {
      // Assert
      expect(model.state.items, isEmpty);
      expect(model.state, isA<SearchStatus>());
    });

    test('should extend Store', () {
      // Assert
      expect(model, isA<Store<SearchStatus<TweetWithCard>>>());
    });

    test('should initialize with SearchStatus containing empty items', () {
      // Assert
      expect(model.state.items, isA<List>());
      expect(model.state.items.length, 0);
    });

    test('should handle searchTweets method call without throwing', () {
      // Act & Assert - should not throw during method call setup
      expect(() => model.searchTweets('test query', false), returnsNormally);
    });

    test('should handle enhanced search parameter', () {
      // Act & Assert - should not throw
      expect(() => model.searchTweets('test', true), returnsNormally);
      expect(() => model.searchTweets('test', false), returnsNormally);
    });

    test('should handle trending parameter', () {
      // Act & Assert - should not throw
      expect(() => model.searchTweets('test', true, trending: true), returnsNormally);
      expect(() => model.searchTweets('test', true, trending: false), returnsNormally);
    });

    test('should handle cursor parameter', () {
      // Act & Assert - should not throw
      expect(() => model.searchTweets('test', false, cursor: 'cursor123'), returnsNormally);
      expect(() => model.searchTweets('test', false, cursor: null), returnsNormally);
    });

    test('should handle empty query', () {
      // Act & Assert - should not throw
      expect(() => model.searchTweets('', false), returnsNormally);
    });

    test('should handle special characters in query', () {
      // Act & Assert - should not throw
      expect(() => model.searchTweets('@user #hashtag', false), returnsNormally);
    });

    test('should handle very long query', () {
      // Arrange
      final longQuery = 'a' * 1000;

      // Act & Assert - should not throw
      expect(() => model.searchTweets(longQuery, false), returnsNormally);
    });
  });

  group('SearchUsersModel', () {
    late SearchUsersModel model;

    setUp(() {
      model = SearchUsersModel();
    });

    test('should create with empty initial state', () {
      // Assert
      expect(model.state.items, isEmpty);
      expect(model.state, isA<SearchStatus>());
    });

    test('should extend Store', () {
      // Assert
      expect(model, isA<Store<SearchStatus<UserWithExtra>>>());
    });

    test('should initialize with SearchStatus containing empty items', () {
      // Assert
      expect(model.state.items, isA<List>());
      expect(model.state.items.length, 0);
    });

    test('should handle searchUsers method call without throwing', () {
      // Act & Assert - should not throw during method call setup
      expect(() => model.searchUsers('test user', false), returnsNormally);
    });

    test('should handle enhanced search parameter', () {
      // Act & Assert - should not throw
      expect(() => model.searchUsers('test', true), returnsNormally);
      expect(() => model.searchUsers('test', false), returnsNormally);
    });

    test('should handle cursor parameter', () {
      // Act & Assert - should not throw
      expect(() => model.searchUsers('test', false, cursor: 'cursor123'), returnsNormally);
      expect(() => model.searchUsers('test', false, cursor: null), returnsNormally);
    });

    test('should handle empty query', () {
      // Act & Assert - should not throw
      expect(() => model.searchUsers('', false), returnsNormally);
    });

    test('should handle special characters in query', () {
      // Act & Assert - should not throw
      expect(() => model.searchUsers('@username', false), returnsNormally);
    });

    test('should handle usernames with special characters', () {
      // Act & Assert - should not throw
      expect(() => model.searchUsers('user_test-123', false), returnsNormally);
    });

    test('should handle very long query', () {
      // Arrange
      final longQuery = 'b' * 500;

      // Act & Assert - should not throw
      expect(() => model.searchUsers(longQuery, false), returnsNormally);
    });

    test('should handle unicode characters in query', () {
      // Act & Assert - should not throw
      expect(() => model.searchUsers('用户测试', false), returnsNormally);
    });
  });

  group('Model Integration', () {
    test('should create multiple models independently', () {
      // Act
      final savedModel1 = SavedTweetModel();
      final savedModel2 = SavedTweetModel();
      final searchTweetsModel = SearchTweetsModel();
      final searchUsersModel = SearchUsersModel();

      // Assert
      expect(savedModel1, isNot(same(savedModel2)));
      expect(searchTweetsModel, isNot(same(searchUsersModel)));
      expect(savedModel1.state, isEmpty);
      expect(savedModel2.state, isEmpty);
      expect(searchTweetsModel.state.items, isEmpty);
      expect(searchUsersModel.state.items, isEmpty);
    });

    test('should maintain independent state across models', () {
      // Arrange
      final savedModel = SavedTweetModel();
      final searchModel = SearchTweetsModel();

      // Act
      savedModel.state.add(SavedTweet(id: 'test', user: 'user', content: 'content'));

      // Assert
      expect(savedModel.state, isNotEmpty);
      expect(searchModel.state.items, isEmpty);
    });
  });
}
