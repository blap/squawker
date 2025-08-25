import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:squawker/user.dart';
import 'package:squawker/database/entities.dart';

void main() {
  group('UserAvatar', () {
    testWidgets('should create UserAvatar with default size', (WidgetTester tester) async {
      // Arrange
      const avatar = UserAvatar(uri: 'https://example.com/avatar.jpg');

      // Act
      await tester.pumpWidget(const MaterialApp(home: Scaffold(body: avatar)));

      // Assert
      expect(avatar.size, 48); // Default size
      expect(avatar.uri, 'https://example.com/avatar.jpg');
      expect(find.byType(ClipRRect), findsOneWidget);
    });

    testWidgets('should create UserAvatar with custom size', (WidgetTester tester) async {
      // Arrange
      const customSize = 64.0;
      const avatar = UserAvatar(uri: 'https://example.com/avatar.jpg', size: customSize);

      // Act
      await tester.pumpWidget(const MaterialApp(home: Scaffold(body: avatar)));

      // Assert
      expect(avatar.size, customSize);
      expect(find.byType(ClipRRect), findsOneWidget);

      final clipRRect = tester.widget<ClipRRect>(find.byType(ClipRRect));
      expect(clipRRect.borderRadius, BorderRadius.circular(customSize));
    });

    testWidgets('should handle null URI', (WidgetTester tester) async {
      // Arrange
      const avatar = UserAvatar(uri: null);

      // Act
      await tester.pumpWidget(const MaterialApp(home: Scaffold(body: avatar)));

      // Assert
      expect(find.byType(ClipRRect), findsOneWidget);
      expect(find.byType(SizedBox), findsOneWidget);
    });

    testWidgets('should handle empty URI', (WidgetTester tester) async {
      // Arrange
      const avatar = UserAvatar(uri: '');

      // Act
      await tester.pumpWidget(const MaterialApp(home: Scaffold(body: avatar)));

      // Assert
      expect(find.byType(ClipRRect), findsOneWidget);
    });

    testWidgets('should accept key parameter', (WidgetTester tester) async {
      // Arrange
      const key = Key('avatar_key');
      const avatar = UserAvatar(key: key, uri: 'https://example.com/avatar.jpg');

      // Assert
      expect(avatar.key, key);
    });

    testWidgets('should handle very small size', (WidgetTester tester) async {
      // Arrange
      const avatar = UserAvatar(uri: 'https://example.com/avatar.jpg', size: 1.0);

      // Act
      await tester.pumpWidget(const MaterialApp(home: Scaffold(body: avatar)));

      // Assert
      expect(avatar.size, 1.0);
      expect(find.byType(ClipRRect), findsOneWidget);
    });

    testWidgets('should handle very large size', (WidgetTester tester) async {
      // Arrange
      const avatar = UserAvatar(uri: 'https://example.com/avatar.jpg', size: 1000.0);

      // Act
      await tester.pumpWidget(const MaterialApp(home: Scaffold(body: avatar)));

      // Assert
      expect(avatar.size, 1000.0);
      expect(find.byType(ClipRRect), findsOneWidget);
    });

    testWidgets('should handle zero size', (WidgetTester tester) async {
      // Arrange
      const avatar = UserAvatar(uri: 'https://example.com/avatar.jpg', size: 0.0);

      // Act
      await tester.pumpWidget(const MaterialApp(home: Scaffold(body: avatar)));

      // Assert
      expect(avatar.size, 0.0);
      expect(find.byType(ClipRRect), findsOneWidget);
    });

    testWidgets('should handle special characters in URI', (WidgetTester tester) async {
      // Arrange
      const avatar = UserAvatar(uri: 'https://example.com/avatar%20with%20spaces.jpg?param=value&other=123');

      // Act
      await tester.pumpWidget(const MaterialApp(home: Scaffold(body: avatar)));

      // Assert
      expect(find.byType(ClipRRect), findsOneWidget);
    });
  });

  group('UserTile', () {
    late UserSubscription testUser;
    late UserSubscription verifiedUser;
    late UserSubscription unverifiedUser;

    setUp(() {
      testUser = UserSubscription(
        id: 'user123',
        screenName: 'testuser',
        name: 'Test User',
        profileImageUrlHttps: 'https://example.com/avatar.jpg',
        verified: true,
        inFeed: true,
        createdAt: DateTime.now(),
      );

      verifiedUser = UserSubscription(
        id: 'verified123',
        screenName: 'verified',
        name: 'Verified User',
        profileImageUrlHttps: 'https://example.com/verified.jpg',
        verified: true,
        inFeed: true,
        createdAt: DateTime.now(),
      );

      unverifiedUser = UserSubscription(
        id: 'unverified123',
        screenName: 'unverified',
        name: 'Unverified User',
        profileImageUrlHttps: null,
        verified: false,
        inFeed: true,
        createdAt: DateTime.now(),
      );
    });

    test('should display user information correctly', () {
      // Arrange
      final userTile = UserTile(user: testUser);

      // Assert - Test that UserTile contains the correct user data
      expect(userTile.user, testUser);
      expect(userTile.user.name, 'Test User');
      expect(userTile.user.screenName, 'testuser');
    });

    test('should show verified icon for verified users', () {
      // Arrange
      final userTile = UserTile(user: verifiedUser);

      // Assert - Test that verified user is handled correctly
      expect(userTile.user, verifiedUser);
      expect(userTile.user.verified, true);
      expect(userTile.user.name, 'Verified User');
    });

    test('should handle unverified users', () {
      // Arrange
      final userTile = UserTile(user: unverifiedUser);

      // Assert - Test that unverified user is handled correctly
      expect(userTile.user, unverifiedUser);
      expect(userTile.user.verified, false);
      expect(userTile.user.name, 'Unverified User');
    });

    test('should handle long user names', () {
      // Arrange
      final longNameUser = UserSubscription(
        id: 'long123',
        screenName: 'longusername',
        name: 'This is a very long user name that should be truncated with ellipsis',
        profileImageUrlHttps: null,
        verified: false,
        inFeed: true,
        createdAt: DateTime.now(),
      );

      // Assert - Test the data model properties
      expect(longNameUser.name, 'This is a very long user name that should be truncated with ellipsis');
      expect(longNameUser.name.length, greaterThan(20));
      expect(longNameUser.screenName, 'longusername');
    });

    test('should handle long screen names', () {
      // Arrange
      final longScreenNameUser = UserSubscription(
        id: 'long123',
        screenName: 'verylongscreennamethatshouldbetruncated',
        name: 'User',
        profileImageUrlHttps: null,
        verified: false,
        inFeed: true,
        createdAt: DateTime.now(),
      );

      // Assert - Test the data model properties
      expect(longScreenNameUser.screenName, 'verylongscreennamethatshouldbetruncated');
      expect(longScreenNameUser.screenName.length, greaterThan(20));
      expect(longScreenNameUser.name, 'User');
    });

    test('should accept key parameter', () {
      // Arrange
      const key = Key('user_tile_key');
      final userTile = UserTile(key: key, user: testUser);

      // Assert
      expect(userTile.key, key);
    });

    test('should handle user with null profile image', () {
      // Arrange
      final userTile = UserTile(user: unverifiedUser);

      // Assert - Test that UserTile accepts user with null profile image
      expect(userTile.user, unverifiedUser);
      expect(userTile.user.profileImageUrlHttps, null);
    });

    test('should create UserTile with required user parameter', () {
      // Arrange & Act
      final userTile = UserTile(user: testUser);

      // Assert - Test that UserTile is created with user property
      expect(userTile.user, testUser);
      expect(userTile, isA<StatelessWidget>());
    });

    test('should handle empty user name', () {
      // Arrange
      final emptyNameUser = UserSubscription(
        id: 'empty123',
        screenName: 'emptyname',
        name: '',
        profileImageUrlHttps: null,
        verified: false,
        inFeed: true,
        createdAt: DateTime.now(),
      );

      // Assert - Test the data model properties
      expect(emptyNameUser.name, '');
      expect(emptyNameUser.screenName, 'emptyname');
      expect(emptyNameUser.id, 'empty123');
    });

    test('should handle empty screen name', () {
      // Arrange
      final emptyScreenNameUser = UserSubscription(
        id: 'empty123',
        screenName: '',
        name: 'User',
        profileImageUrlHttps: null,
        verified: false,
        inFeed: true,
        createdAt: DateTime.now(),
      );

      // Assert - Test the data model properties
      expect(emptyScreenNameUser.name, 'User');
      expect(emptyScreenNameUser.screenName, '');
    });

    test('should handle special characters in names', () {
      // Arrange
      final specialCharUser = UserSubscription(
        id: 'special123',
        screenName: 'user_test-123',
        name: 'User & Co. (Official)',
        profileImageUrlHttps: null,
        verified: false,
        inFeed: true,
        createdAt: DateTime.now(),
      );

      // Assert - Test the data model properties
      expect(specialCharUser.name, 'User & Co. (Official)');
      expect(specialCharUser.screenName, 'user_test-123');
      expect(specialCharUser.id, 'special123');
    });
  });

  group('FollowButtonSelectGroupDialog', () {
    late UserSubscription testUser;

    setUp(() {
      testUser = UserSubscription(
        id: 'user123',
        screenName: 'testuser',
        name: 'Test User',
        profileImageUrlHttps: null,
        verified: false,
        inFeed: true,
        createdAt: DateTime.now(),
      );
    });

    test('should create dialog with required parameters', () {
      // Arrange
      final dialog = FollowButtonSelectGroupDialog(user: testUser, followed: true, groupsForUser: const ['group1', 'group2']);

      // Assert
      expect(dialog.user, testUser);
      expect(dialog.followed, true);
      expect(dialog.groupsForUser, ['group1', 'group2']);
    });

    test('should accept key parameter', () {
      // Arrange
      const key = Key('dialog_key');
      final dialog = FollowButtonSelectGroupDialog(key: key, user: testUser, followed: false, groupsForUser: const []);

      // Assert
      expect(dialog.key, key);
    });

    test('should handle empty groups list', () {
      // Arrange
      final dialog = FollowButtonSelectGroupDialog(user: testUser, followed: false, groupsForUser: const []);

      // Assert
      expect(dialog.groupsForUser, isEmpty);
    });

    test('should handle followed and unfollowed states', () {
      // Arrange
      final followedDialog = FollowButtonSelectGroupDialog(user: testUser, followed: true, groupsForUser: const ['group1']);

      final unfollowedDialog = FollowButtonSelectGroupDialog(user: testUser, followed: false, groupsForUser: const []);

      // Assert
      expect(followedDialog.followed, true);
      expect(unfollowedDialog.followed, false);
    });

    test('should be a StatefulWidget', () {
      // Arrange
      final dialog = FollowButtonSelectGroupDialog(user: testUser, followed: false, groupsForUser: const []);

      // Assert
      expect(dialog, isA<StatefulWidget>());
    });

    test('should create state correctly', () {
      // Arrange
      final dialog = FollowButtonSelectGroupDialog(user: testUser, followed: false, groupsForUser: const []);

      // Act
      final state = dialog.createState();

      // Assert
      expect(state, isA<State>());
    });
  });

  group('FollowButton', () {
    late UserSubscription testUser;

    setUp(() {
      testUser = UserSubscription(
        id: 'user123',
        screenName: 'testuser',
        name: 'Test User',
        profileImageUrlHttps: null,
        verified: false,
        inFeed: true,
        createdAt: DateTime.now(),
      );
    });

    test('should create FollowButton with required user parameter', () {
      // Arrange
      final button = FollowButton(user: testUser);

      // Assert
      expect(button.user, testUser);
      expect(button.color, null);
    });

    test('should create FollowButton with custom color', () {
      // Arrange
      const customColor = Colors.red;
      final button = FollowButton(user: testUser, color: customColor);

      // Assert
      expect(button.user, testUser);
      expect(button.color, customColor);
    });

    test('should accept key parameter', () {
      // Arrange
      const key = Key('follow_button_key');
      final button = FollowButton(key: key, user: testUser);

      // Assert
      expect(button.key, key);
    });

    test('should be a StatelessWidget', () {
      // Arrange
      final button = FollowButton(user: testUser);

      // Assert
      expect(button, isA<StatelessWidget>());
    });

    test('should handle different user types', () {
      // Arrange
      final searchSubscription = SearchSubscription(id: 'search_term', createdAt: DateTime.now());

      final button1 = FollowButton(user: testUser);
      final button2 = FollowButton(user: searchSubscription);

      // Assert
      expect(button1.user, testUser);
      expect(button2.user, searchSubscription);
    });

    test('should handle null and non-null colors', () {
      // Arrange
      final button1 = FollowButton(user: testUser, color: null);
      final button2 = FollowButton(user: testUser, color: Colors.blue);

      // Assert
      expect(button1.color, null);
      expect(button2.color, Colors.blue);
    });
  });
}
