import 'package:flutter_test/flutter_test.dart';
import 'package:squawker/search/search.dart';
import 'package:flutter/material.dart';

void main() {
  group('SearchArguments', () {
    test('should be able to import SearchArguments', () {
      expect(SearchArguments, isNotNull);
    });

    test('should be able to create SearchArguments instance', () {
      final args = SearchArguments(0);
      expect(args, isNotNull);
      expect(args.initialTab, 0);
      expect(args.query, isNull);
      expect(args.focusInputOnOpen, isFalse);
    });

    test('should be able to create SearchArguments with query', () {
      final args = SearchArguments(1, query: 'test query');
      expect(args, isNotNull);
      expect(args.initialTab, 1);
      expect(args.query, 'test query');
      expect(args.focusInputOnOpen, isFalse);
    });

    test('should be able to create SearchArguments with focusInputOnOpen', () {
      final args = SearchArguments(2, focusInputOnOpen: true);
      expect(args, isNotNull);
      expect(args.initialTab, 2);
      expect(args.query, isNull);
      expect(args.focusInputOnOpen, isTrue);
    });
  });

  group('SearchScreen', () {
    test('should be able to import SearchScreen', () {
      expect(SearchScreen, isNotNull);
    });

    test('should be able to create SearchScreen instance', () {
      final screen = SearchScreen(key: Key('test-key'));
      expect(screen, isNotNull);
    });
  });

  group('TweetSearchResultList', () {
    test('should be able to import TweetSearchResultList', () {
      expect(TweetSearchResultList, isNotNull);
    });
  });

  group('TweetSearchResultListState', () {
    test('should be able to import TweetSearchResultListState', () {
      expect(TweetSearchResultListState, isNotNull);
    });
  });
}
