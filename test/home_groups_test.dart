import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:squawker/home/_groups.dart';

void main() {
  group('GroupsScreen', () {
    test('should be able to import GroupsScreen', () {
      // This test simply verifies that the module can be imported without errors
      expect(GroupsScreen, isNotNull);
    });

    test('should be a StatelessWidget', () {
      // Create an instance and check its runtime type
      final scrollController = ScrollController();
      final groupsScreen = GroupsScreen(scrollController: scrollController);
      expect(groupsScreen, isA<StatelessWidget>());
    });
  });
}
