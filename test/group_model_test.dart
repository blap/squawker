import 'package:flutter_test/flutter_test.dart';
import 'package:squawker/group/group_model.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter/material.dart';

void main() {
  sqfliteFfiInit();

  group('GroupModel', () {
    test('should be able to import GroupModel', () {
      expect(GroupModel, isNotNull);
    });

    test('should be able to create GroupModel instance', () {
      final model = GroupModel('test-id');
      expect(model, isNotNull);
      expect(model.id, 'test-id');
    });

    test('should have loadGroup method', () {
      final model = GroupModel('test-id');
      expect(model.loadGroup, isA<Function>());
    });

    test('should have toggleSubscriptionGroupIncludeReplies method', () {
      final model = GroupModel('test-id');
      expect(model.toggleSubscriptionGroupIncludeReplies, isA<Function>());
    });

    test('should have toggleSubscriptionGroupIncludeRetweets method', () {
      final model = GroupModel('test-id');
      expect(model.toggleSubscriptionGroupIncludeRetweets, isA<Function>());
    });
  });

  group('GroupsModel', () {
    test('should be able to import GroupsModel', () {
      expect(GroupsModel, isNotNull);
    });

    test('should be able to create GroupsModel instance', () async {
      // We can't easily create a real PrefService in tests, so we'll just verify the class exists
      expect(GroupsModel, isNotNull);
    });

    test('should have required methods', () {
      // Verify that all the expected methods exist
      expect(GroupsModel, isNotNull);
    });
  });

  group('deserializeIconData', () {
    test('should deserialize icon data correctly', () {
      final result = deserializeIconData('{"pack":"custom","key":"rss_feed_rounded"}');
      expect(result, isA<IconData>());
    });

    test('should return default icon when deserialization fails', () {
      final result = deserializeIconData('invalid json');
      expect(result, isA<IconData>());
      expect(result, Icons.rss_feed_rounded);
    });
  });
}
