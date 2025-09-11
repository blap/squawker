import 'package:flutter_test/flutter_test.dart';
import 'package:squawker/profile/profile.dart';
import 'package:flutter/material.dart';

void main() {
  group('ProfileScreen', () {
    test('should be able to import ProfileScreen', () {
      expect(ProfileScreen, isNotNull);
    });

    test('should be able to create ProfileScreen instance', () {
      final screen = ProfileScreen(key: UniqueKey());
      expect(screen, isNotNull);
    });
  });

  group('ProfileScreenArguments', () {
    test('should be able to import ProfileScreenArguments', () {
      expect(ProfileScreenArguments, isNotNull);
    });

    test('should be able to create ProfileScreenArguments from id', () {
      final args = ProfileScreenArguments.fromId('test-id');
      expect(args, isNotNull);
      expect(args.id, 'test-id');
      expect(args.screenName, isNull);
    });

    test('should be able to create ProfileScreenArguments from screen name', () {
      final args = ProfileScreenArguments.fromScreenName('test-screen-name');
      expect(args, isNotNull);
      expect(args.screenName, 'test-screen-name');
      expect(args.id, isNull);
    });
  });

  group('NavigationTab', () {
    test('should be able to import NavigationTab', () {
      expect(NavigationTab, isNotNull);
    });

    test('should be able to create NavigationTab instance', () {
      final tab = NavigationTab('test-id', (context) => 'Test Title');
      expect(tab, isNotNull);
      expect(tab.id, 'test-id');
    });
  });

  group('ProfileScreenBody', () {
    test('should be able to import ProfileScreenBody', () {
      expect(ProfileScreenBody, isNotNull);
    });
  });

  group('TweetContextState', () {
    test('should be able to import TweetContextState', () {
      expect(TweetContextState, isNotNull);
    });

    test('should be able to create TweetContextState instance', () {
      final state = TweetContextState(true);
      expect(state, isNotNull);
      expect(state.hideSensitive, isTrue);
    });

    test('should be able to set hideSensitive state', () {
      final state = TweetContextState(false);
      expect(state.hideSensitive, isFalse);

      state.setHideSensitive(true);
      expect(state.hideSensitive, isTrue);
    });
  });
}
