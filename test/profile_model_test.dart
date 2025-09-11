import 'package:flutter_test/flutter_test.dart';
import 'package:squawker/profile/profile_model.dart';
import 'package:squawker/user.dart';

void main() {
  group('ProfileModel', () {
    late ProfileModel model;

    setUp(() {
      model = ProfileModel();
    });

    test('should initialize ProfileModel', () {
      expect(model, isNotNull);
    });

    test('should be an instance of expected type', () {
      expect(model, isA<ProfileModel>());
    });

    test('should have initial state with empty user and pinned tweets', () {
      expect(model.state.user, isA<UserWithExtra>());
      expect(model.state.pinnedTweets, isEmpty);
    });

    test('should have loadProfileById method', () {
      expect(model.loadProfileById, isA<Function>());
    });

    test('should have loadProfileByScreenName method', () {
      expect(model.loadProfileByScreenName, isA<Function>());
    });

    test('should have Twitter client initialized', () {
      expect(model, isNotNull);
    });
  });

  group('Profile', () {
    test('should be able to import Profile', () {
      expect(Profile, isNotNull);
    });

    test('should be able to create Profile instance', () {
      final user = UserWithExtra();
      final pinnedTweets = <String>[];
      final profile = Profile(user, pinnedTweets);

      expect(profile, isNotNull);
      expect(profile.user, user);
      expect(profile.pinnedTweets, pinnedTweets);
    });
  });
}
