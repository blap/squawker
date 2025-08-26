import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:squawker/group/_feed.dart';
import 'package:squawker/database/entities.dart';
import 'package:pref/pref_service.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'dart:io';

void main() {
  group('SubscriptionGroupFeed', () {
    testWidgets('should display a list of tweets', (WidgetTester tester) async {
      // Arrange
      final group = SubscriptionGroupGet(
        id: '1',
        name: 'Test Group',
        icon: '',
        subscriptions: [],
        includeReplies: true,
        includeRetweets: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: PrefService(
            child: SubscriptionGroupFeed(
              group: group,
              searchQueries: [],
              includeReplies: true,
              includeRetweets: true,
              scrollController: ItemScrollController(),
            ),
            prefService: PrefService(PrefStore(store: {})),
          ),
        ),
      );

      // Assert
      expect(find.byType(ScrollablePositionedList), findsOneWidget);
    });
  });

  final script = Platform.script;
  print('Current script path: ${script.toFilePath()}');
}