import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:squawker/database/entities.dart';
import 'package:intl/intl.dart';

void main() {
  group('Database Entities', () {
    group('SavedTweet', () {
      test('should create SavedTweet with required fields', () {
        // Arrange & Act
        final savedTweet = SavedTweet(id: '123', user: 'testuser', content: 'Test tweet content');

        // Assert
        expect(savedTweet.id, '123');
        expect(savedTweet.user, 'testuser');
        expect(savedTweet.content, 'Test tweet content');
      });

      test('should create SavedTweet with null optional fields', () {
        // Arrange & Act
        final savedTweet = SavedTweet(id: '123', user: null, content: null);

        // Assert
        expect(savedTweet.id, '123');
        expect(savedTweet.user, null);
        expect(savedTweet.content, null);
      });

      test('should create from map correctly', () {
        // Arrange
        final map = {'id': 'tweet123', 'user_id': 'user456', 'content': 'Sample content'};

        // Act
        final savedTweet = SavedTweet.fromMap(map);

        // Assert
        expect(savedTweet.id, 'tweet123');
        expect(savedTweet.user, 'user456');
        expect(savedTweet.content, 'Sample content');
      });

      test('should convert to map correctly', () {
        // Arrange
        final savedTweet = SavedTweet(id: 'tweet123', user: 'user456', content: 'Sample content');

        // Act
        final map = savedTweet.toMap();

        // Assert
        expect(map['id'], 'tweet123');
        expect(map['user_id'], 'user456');
        expect(map['content'], 'Sample content');
      });

      test('should handle map with null values', () {
        // Arrange
        final map = {'id': 'tweet123', 'user_id': null, 'content': null};

        // Act
        final savedTweet = SavedTweet.fromMap(map);

        // Assert
        expect(savedTweet.id, 'tweet123');
        expect(savedTweet.user, null);
        expect(savedTweet.content, null);
      });
    });

    group('SearchSubscription', () {
      test('should create SearchSubscription with required fields', () {
        // Arrange
        final createdAt = DateTime.now();

        // Act
        final subscription = SearchSubscription(id: 'search_term', createdAt: createdAt);

        // Assert
        expect(subscription.id, 'search_term');
        expect(subscription.name, 'search_term');
        expect(subscription.screenName, 'search_term');
        expect(subscription.verified, false);
        expect(subscription.inFeed, true);
        expect(subscription.profileImageUrlHttps, null);
        expect(subscription.createdAt, createdAt);
      });

      test('should create from map correctly', () {
        // Arrange
        const dateString = '2023-01-01 12:00:00';
        final map = {'id': 'flutter', 'created_at': dateString};

        // Act
        final subscription = SearchSubscription.fromMap(map);

        // Assert
        expect(subscription.id, 'flutter');
        expect(subscription.createdAt, DateTime.parse(dateString));
      });

      test('should convert to map correctly', () {
        // Arrange
        final createdAt = DateTime(2023, 1, 1, 12, 0, 0);
        final subscription = SearchSubscription(id: 'flutter', createdAt: createdAt);

        // Act
        final map = subscription.toMap();

        // Assert
        expect(map['id'], 'flutter');
        expect(map['created_at'], DateFormat('yyyy-MM-dd hh:mm:ss').format(createdAt));
      });

      test('should implement equality correctly', () {
        // Arrange
        final date = DateTime.now();
        final subscription1 = SearchSubscription(id: 'test', createdAt: date);
        final subscription2 = SearchSubscription(id: 'test', createdAt: date.add(const Duration(hours: 1)));
        final subscription3 = SearchSubscription(id: 'different', createdAt: date);

        // Assert
        expect(subscription1, equals(subscription2)); // Same ID
        expect(subscription1, isNot(equals(subscription3))); // Different ID
        expect(subscription1.hashCode, equals(subscription2.hashCode));
        expect(subscription1.hashCode, isNot(equals(subscription3.hashCode)));
      });
    });

    group('UserSubscription', () {
      test('should create UserSubscription with all fields', () {
        // Arrange
        final createdAt = DateTime.now();

        // Act
        final subscription = UserSubscription(
          id: 'user123',
          screenName: 'testuser',
          name: 'Test User',
          profileImageUrlHttps: 'https://example.com/image.jpg',
          verified: true,
          inFeed: true,
          createdAt: createdAt,
        );

        // Assert
        expect(subscription.id, 'user123');
        expect(subscription.screenName, 'testuser');
        expect(subscription.name, 'Test User');
        expect(subscription.profileImageUrlHttps, 'https://example.com/image.jpg');
        expect(subscription.verified, true);
        expect(subscription.inFeed, true);
        expect(subscription.createdAt, createdAt);
      });

      test('should create from map with integer booleans', () {
        // Arrange
        final map = {
          'id': 'user123',
          'screen_name': 'testuser',
          'name': 'Test User',
          'profile_image_url_https': 'https://example.com/image.jpg',
          'verified': 1,
          'in_feed': 0,
          'created_at': '2023-01-01 12:00:00',
        };

        // Act
        final subscription = UserSubscription.fromMap(map);

        // Assert
        expect(subscription.verified, true);
        expect(subscription.inFeed, false);
      });

      test('should create from map with boolean values', () {
        // Arrange
        final map = {
          'id': 'user123',
          'screen_name': 'testuser',
          'name': 'Test User',
          'profile_image_url_https': null,
          'verified': false,
          'in_feed': true,
          'created_at': '2023-01-01 12:00:00',
        };

        // Act
        final subscription = UserSubscription.fromMap(map);

        // Assert
        expect(subscription.verified, false);
        expect(subscription.inFeed, true);
        expect(subscription.profileImageUrlHttps, null);
      });

      test('should handle null created_at with current time', () {
        // Arrange
        final beforeTime = DateTime.now().subtract(const Duration(milliseconds: 1));
        final map = {
          'id': 'user123',
          'screen_name': 'testuser',
          'name': 'Test User',
          'profile_image_url_https': null,
          'verified': false,
          'in_feed': true,
          'created_at': null,
        };

        // Act
        final subscription = UserSubscription.fromMap(map);
        final afterTime = DateTime.now().add(const Duration(milliseconds: 1));

        // Assert
        expect(
          subscription.createdAt.isAfter(beforeTime) ||
              subscription.createdAt.isAtSameMomentAs(beforeTime.add(const Duration(milliseconds: 1))),
          true,
        );
        expect(
          subscription.createdAt.isBefore(afterTime) ||
              subscription.createdAt.isAtSameMomentAs(afterTime.subtract(const Duration(milliseconds: 1))),
          true,
        );
      });

      test('should convert to map correctly', () {
        // Arrange
        final createdAt = DateTime(2023, 1, 1, 12, 0, 0);
        final subscription = UserSubscription(
          id: 'user123',
          screenName: 'testuser',
          name: 'Test User',
          profileImageUrlHttps: 'https://example.com/image.jpg',
          verified: true,
          inFeed: false,
          createdAt: createdAt,
        );

        // Act
        final map = subscription.toMap();

        // Assert
        expect(map['id'], 'user123');
        expect(map['screen_name'], 'testuser');
        expect(map['name'], 'Test User');
        expect(map['profile_image_url_https'], 'https://example.com/image.jpg');
        expect(map['verified'], 1);
        expect(map['in_feed'], 0);
        expect(map['created_at'], DateFormat('yyyy-MM-dd hh:mm:ss').format(createdAt));
      });

      test('should convert to UserWithExtra correctly', () {
        // Arrange
        final subscription = UserSubscription(
          id: 'user123',
          screenName: 'testuser',
          name: 'Test User',
          profileImageUrlHttps: 'https://example.com/image.jpg',
          verified: true,
          inFeed: true,
          createdAt: DateTime.now(),
        );

        // Act
        final user = subscription.toUser();

        // Assert
        expect(user.idStr, 'user123');
        expect(user.screenName, 'testuser');
        expect(user.name, 'Test User');
        expect(user.profileImageUrlHttps, 'https://example.com/image.jpg');
        expect(user.verified, true);
      });

      test('should implement equality correctly', () {
        // Arrange
        final date = DateTime.now();
        final subscription1 = UserSubscription(
          id: 'user123',
          screenName: 'test1',
          name: 'Test 1',
          profileImageUrlHttps: null,
          verified: false,
          inFeed: true,
          createdAt: date,
        );
        final subscription2 = UserSubscription(
          id: 'user123',
          screenName: 'test2',
          name: 'Test 2',
          profileImageUrlHttps: null,
          verified: true,
          inFeed: false,
          createdAt: date.add(const Duration(days: 1)),
        );
        final subscription3 = UserSubscription(
          id: 'user456',
          screenName: 'test1',
          name: 'Test 1',
          profileImageUrlHttps: null,
          verified: false,
          inFeed: true,
          createdAt: date,
        );

        // Assert
        expect(subscription1, equals(subscription2)); // Same ID
        expect(subscription1, isNot(equals(subscription3))); // Different ID
        expect(subscription1.hashCode, equals(subscription2.hashCode));
        expect(subscription1.hashCode, isNot(equals(subscription3.hashCode)));
      });
    });

    group('SubscriptionGroup', () {
      test('should create SubscriptionGroup with all fields', () {
        // Arrange
        final createdAt = DateTime.now();
        const color = Colors.blue;

        // Act
        final group = SubscriptionGroup(
          id: 'group123',
          name: 'Test Group',
          icon: 'star',
          color: color,
          numberOfMembers: 5,
          createdAt: createdAt,
        );

        // Assert
        expect(group.id, 'group123');
        expect(group.name, 'Test Group');
        expect(group.icon, 'star');
        expect(group.color, color);
        expect(group.numberOfMembers, 5);
        expect(group.createdAt, createdAt);
      });

      test('should create from map correctly', () {
        // Arrange
        final map = {
          'id': 'group123',
          'name': 'Test Group',
          'icon': 'star',
          'color': Colors.red.toARGB32(),
          'number_of_members': 3,
          'created_at': '2023-01-01T12:00:00.000Z',
        };

        // Act
        final group = SubscriptionGroup.fromMap(map);

        // Assert
        expect(group.id, 'group123');
        expect(group.name, 'Test Group');
        expect(group.icon, 'star');
        expect(group.color, Color(Colors.red.toARGB32()));
        expect(group.numberOfMembers, 3);
        expect(group.createdAt, DateTime.parse('2023-01-01T12:00:00.000Z'));
      });

      test('should handle null optional fields in map', () {
        // Arrange
        final map = {
          'id': 'group123',
          'name': 'Test Group',
          'icon': 'star',
          'color': null,
          'number_of_members': null,
          'created_at': '2023-01-01T12:00:00.000Z',
        };

        // Act
        final group = SubscriptionGroup.fromMap(map);

        // Assert
        expect(group.color, null);
        expect(group.numberOfMembers, 0);
      });

      test('should convert to map correctly', () {
        // Arrange
        final createdAt = DateTime(2023, 1, 1, 12, 0, 0);
        final group = SubscriptionGroup(
          id: 'group123',
          name: 'Test Group',
          icon: 'star',
          color: Colors.blue,
          numberOfMembers: 5,
          createdAt: createdAt,
        );

        // Act
        final map = group.toMap();

        // Assert
        expect(map['id'], 'group123');
        expect(map['name'], 'Test Group');
        expect(map['icon'], 'star');
        expect(map['color'], Colors.blue.toARGB32());
        expect(map['created_at'], createdAt.toIso8601String());
      });

      test('should convert to map with null color', () {
        // Arrange
        final createdAt = DateTime(2023, 1, 1, 12, 0, 0);
        final group = SubscriptionGroup(
          id: 'group123',
          name: 'Test Group',
          icon: 'star',
          color: null,
          numberOfMembers: 0,
          createdAt: createdAt,
        );

        // Act
        final map = group.toMap();

        // Assert
        expect(map['color'], null);
      });
    });

    group('SubscriptionGroupGet', () {
      test('should create SubscriptionGroupGet with all fields', () {
        // Arrange
        final subscriptions = [
          SearchSubscription(id: 'search1', createdAt: DateTime.now()),
          UserSubscription(
            id: 'user1',
            screenName: 'test',
            name: 'Test',
            profileImageUrlHttps: null,
            verified: false,
            inFeed: true,
            createdAt: DateTime.now(),
          ),
        ];

        // Act
        final groupGet = SubscriptionGroupGet(
          id: 'group123',
          name: 'Test Group',
          icon: 'star',
          subscriptions: subscriptions,
          includeReplies: true,
          includeRetweets: false,
        );

        // Assert
        expect(groupGet.id, 'group123');
        expect(groupGet.name, 'Test Group');
        expect(groupGet.icon, 'star');
        expect(groupGet.subscriptions, subscriptions);
        expect(groupGet.includeReplies, true);
        expect(groupGet.includeRetweets, false);
      });

      test('should allow modification of boolean fields', () {
        // Arrange
        final groupGet = SubscriptionGroupGet(
          id: 'group123',
          name: 'Test Group',
          icon: 'star',
          subscriptions: [],
          includeReplies: false,
          includeRetweets: false,
        );

        // Act
        groupGet.includeReplies = true;
        groupGet.includeRetweets = true;

        // Assert
        expect(groupGet.includeReplies, true);
        expect(groupGet.includeRetweets, true);
      });
    });

    group('ToMappable mixin', () {
      test('should be implemented by SavedTweet', () {
        // Arrange
        final savedTweet = SavedTweet(id: '1', user: 'test', content: 'content');

        // Assert
        expect(savedTweet, isA<ToMappable>());
        expect(savedTweet.toMap(), isA<Map<String, dynamic>>());
      });

      test('should be implemented by SearchSubscription', () {
        // Arrange
        final subscription = SearchSubscription(id: 'test', createdAt: DateTime.now());

        // Assert
        expect(subscription, isA<ToMappable>());
        expect(subscription.toMap(), isA<Map<String, dynamic>>());
      });

      test('should be implemented by UserSubscription', () {
        // Arrange
        final subscription = UserSubscription(
          id: 'test',
          screenName: 'test',
          name: 'test',
          profileImageUrlHttps: null,
          verified: false,
          inFeed: true,
          createdAt: DateTime.now(),
        );

        // Assert
        expect(subscription, isA<ToMappable>());
        expect(subscription.toMap(), isA<Map<String, dynamic>>());
      });

      test('should be implemented by SubscriptionGroup', () {
        // Arrange
        final group = SubscriptionGroup(
          id: 'test',
          name: 'test',
          icon: 'star',
          color: null,
          numberOfMembers: 0,
          createdAt: DateTime.now(),
        );

        // Assert
        expect(group, isA<ToMappable>());
        expect(group.toMap(), isA<Map<String, dynamic>>());
      });
    });

    group('sqliteDateFormat', () {
      test('should format dates correctly', () {
        // Arrange
        final date = DateTime(2023, 12, 25, 15, 30, 45);

        // Act
        final formatted = sqliteDateFormat.format(date);

        // Assert
        expect(formatted, '2023-12-25 03:30:45');
      });

      test('should be consistent with parsing', () {
        // Arrange
        final originalDate = DateTime(2023, 6, 15, 10, 25, 30);
        final formatted = sqliteDateFormat.format(originalDate);

        // Act
        final parsedDate = DateTime.parse(formatted);

        // Assert - should be the same when ignoring milliseconds
        expect(parsedDate.year, originalDate.year);
        expect(parsedDate.month, originalDate.month);
        expect(parsedDate.day, originalDate.day);
        expect(parsedDate.hour, originalDate.hour);
        expect(parsedDate.minute, originalDate.minute);
        expect(parsedDate.second, originalDate.second);
      });
    });
  });
}
