import 'package:flutter_test/flutter_test.dart';
import 'package:squawker/database/entities.dart';
import 'package:squawker/user.dart';

// Fake implementation of UserSubscription for testing
class FakeUserSubscription implements UserSubscription {
  @override
  final String id;

  @override
  final String screenName;

  @override
  final String name;

  @override
  final String? profileImageUrlHttps;

  @override
  final bool verified;

  @override
  final bool inFeed;

  @override
  final DateTime createdAt;

  FakeUserSubscription({
    required this.id,
    required this.screenName,
    required this.name,
    this.profileImageUrlHttps,
    this.verified = false,
    this.inFeed = true,
    required this.createdAt,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'screen_name': screenName,
      'name': name,
      'profile_image_url_https': profileImageUrlHttps,
      'verified': verified ? 1 : 0,
      'in_feed': inFeed ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  UserWithExtra toUser() {
    return UserWithExtra.fromJson({
      'id_str': id,
      'screen_name': screenName,
      'name': name,
      'profile_image_url_https': profileImageUrlHttps,
      'verified': verified,
    });
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is FakeUserSubscription && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

void main() {
  group('UserSubscription', () {
    test('should create a user subscription with correct properties', () {
      final user = FakeUserSubscription(
        id: '1',
        screenName: 'testuser',
        name: 'Test User',
        profileImageUrlHttps: 'https://example.com/avatar.jpg',
        verified: true,
        inFeed: true,
        createdAt: DateTime(2023, 1, 1),
      );

      expect(user.id, '1');
      expect(user.screenName, 'testuser');
      expect(user.name, 'Test User');
      expect(user.profileImageUrlHttps, 'https://example.com/avatar.jpg');
      expect(user.verified, true);
      expect(user.inFeed, true);
      expect(user.createdAt, DateTime(2023, 1, 1));
    });

    test('should convert to map correctly', () {
      final user = FakeUserSubscription(
        id: '1',
        screenName: 'testuser',
        name: 'Test User',
        profileImageUrlHttps: 'https://example.com/avatar.jpg',
        verified: true,
        inFeed: true,
        createdAt: DateTime(2023, 1, 1),
      );

      final map = user.toMap();

      expect(map['id'], '1');
      expect(map['screen_name'], 'testuser');
      expect(map['name'], 'Test User');
      expect(map['profile_image_url_https'], 'https://example.com/avatar.jpg');
      expect(map['verified'], 1);
      expect(map['in_feed'], 1);
      expect(map['created_at'], DateTime(2023, 1, 1).toIso8601String());
    });

    test('should convert to UserWithExtra correctly', () {
      final user = FakeUserSubscription(
        id: '1',
        screenName: 'testuser',
        name: 'Test User',
        profileImageUrlHttps: 'https://example.com/avatar.jpg',
        verified: true,
        inFeed: true,
        createdAt: DateTime(2023, 1, 1),
      );

      final userWithExtra = user.toUser();

      expect(userWithExtra.idStr, '1');
      expect(userWithExtra.screenName, 'testuser');
      expect(userWithExtra.name, 'Test User');
      expect(userWithExtra.profileImageUrlHttps, 'https://example.com/avatar.jpg');
      expect(userWithExtra.verified, true);
    });

    test('should handle equality correctly', () {
      final user1 = FakeUserSubscription(
        id: '1',
        screenName: 'testuser',
        name: 'Test User',
        createdAt: DateTime(2023, 1, 1),
      );

      final user2 = FakeUserSubscription(
        id: '1',
        screenName: 'testuser',
        name: 'Test User',
        createdAt: DateTime(2023, 1, 1),
      );

      final user3 = FakeUserSubscription(
        id: '2',
        screenName: 'testuser2',
        name: 'Test User 2',
        createdAt: DateTime(2023, 1, 1),
      );

      expect(user1, equals(user2));
      expect(user1, isNot(equals(user3)));
    });
  });
}
