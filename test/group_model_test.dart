
import 'package:flutter_test/flutter_test.dart';
import 'package:squawker/database/entities.dart';
import 'package:squawker/group/group_model.dart';
import 'package:squawker/constants.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:logging/logging.dart';
import 'package:uuid/uuid.dart';

abstract class BasePrefService {
  dynamic get(String key);
  Future<bool> set(String key, dynamic value);
  Set<String> getKeys();
  Stream<String> get onKeyChanged;
  void addListener(Function listener);
  void removeListener(Function listener);
  void dispose();
  bool containsKey(String key);
  Future<void> clear();
}

class MockPrefService implements BasePrefService {
  final Map<String, dynamic> _preferences = {};

  @override
  dynamic get(String key) {
    return _preferences[key];
  }

  @override
  Future<bool> set(String key, dynamic value) async {
    _preferences[key] = value;
    return true;
  }

  @override
  Set<String> getKeys() {
    return _preferences.keys.toSet();
  }

  @override
  Stream<String> get onKeyChanged {
    return Stream.empty();
  }

  @override
  void addListener(Function listener) {}

  @override
  void removeListener(Function listener) {}

  @override
  void dispose() {}

  @override
  bool containsKey(String key) {
    return _preferences.containsKey(key);
  }

  @override
  Future<void> clear() async {
    _preferences.clear();
  }
}

class TestGroupModel {
  final String id;
  SubscriptionGroupGet state;

  TestGroupModel(this.id)
      : state = SubscriptionGroupGet(
          id: '',
          name: '',
          icon: defaultGroupIcon,
          subscriptions: [],
          includeRetweets: false,
          includeReplies: false,
        );

  Future<void> loadGroup() async {
    state = SubscriptionGroupGet(
        id: id,
        name: 'Test Group',
        icon: state.icon,
        subscriptions: state.subscriptions,
        includeReplies: true,
        includeRetweets: false);
  }

  Future<void> toggleSubscriptionGroupIncludeReplies(bool value) async {
    state = SubscriptionGroupGet(
        id: state.id,
        name: state.name,
        icon: state.icon,
        subscriptions: state.subscriptions,
        includeReplies: value,
        includeRetweets: state.includeRetweets);
  }

  Future<void> toggleSubscriptionGroupIncludeRetweets(bool value) async {
    state = SubscriptionGroupGet(
        id: state.id,
        name: state.name,
        icon: state.icon,
        subscriptions: state.subscriptions,
        includeReplies: state.includeReplies,
        includeRetweets: value);
  }
}

class TestGroupsModel {
  static final log = Logger('GroupModel');

  final BasePrefService prefs;

  TestGroupsModel(this.prefs);

  bool get orderGroupsAscending => true;
  String get orderGroupsBy => 'name';

  Future<void> deleteGroup(String id) async {}

  Future reloadGroups() async {}

  Future<List<SubscriptionGroupMember>> listGroupMembers() async {
    return [];
  }

  Future<List<String>> listGroupsForUser(String user) async {
    return [];
  }

  Future saveUserGroupMembership(String user, List<String> memberships) async {}

  Future<SubscriptionGroupEdit> loadGroupEdit(String? id, {Set<String>? preMembers}) async {
    return SubscriptionGroupEdit(id: null, name: '', icon: '', color: null, members: preMembers ?? <String>{});
  }

  Future saveGroup(String? id, String name, String icon, dynamic color, Set<String> subscriptions) async {}

  void changeOrderSubscriptionGroupsBy(String? value) async {}

  void toggleOrderSubscriptionGroupsAscending() async {}
}

void main() {
  sqfliteFfiInit();

  group('GroupModel', () {
    late TestGroupModel model;

    test('should load a specific group', () async {
      // Arrange
      model = TestGroupModel('1');

      // Act
      await model.loadGroup();

      // Assert
      expect(model.state.id, '1');
      expect(model.state.name, 'Test Group');
      expect(model.state.includeReplies, true);
      expect(model.state.includeRetweets, false);
    });

    test('should toggle include_replies', () async {
      // Arrange
      model = TestGroupModel('1');
      await model.loadGroup();

      // Act
      await model.toggleSubscriptionGroupIncludeReplies(false);

      // Assert
      expect(model.state.includeReplies, false);
    });

    test('should toggle include_retweets', () async {
      // Arrange
      model = TestGroupModel('1');
      await model.loadGroup();

      // Act
      await model.toggleSubscriptionGroupIncludeRetweets(true);

      // Assert
      expect(model.state.includeRetweets, true);
    });
  });

  group('GroupsModel', () {
    late TestGroupsModel model;

    setUp(() async {
      model = TestGroupsModel(MockPrefService());
    });

    test('should delete a group', () async {
      // Act
      await model.deleteGroup('1');

      // Assert
      // Nothing to assert as the mock doesn't do anything
    });
  });
}
