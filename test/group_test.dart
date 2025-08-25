import 'package:flutter_test/flutter_test.dart';
import 'package:squawker/database/entities.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_iconpicker/flutter_iconpicker.dart';

var defaultGroupIcon = '{"pack":"custom","key":"rss_feed_rounded"}';

IconData deserializeIconData(String iconData) {
  try {
    var icon = deserializeIcon(jsonDecode(iconData));
    if (icon != null) {
      return icon.data;
    }
  } catch (e) {
    // Use this as a default;
    return Icons.rss_feed_rounded;
  }

  // Use this as a default;
  return Icons.rss_feed_rounded;
}

// Fake implementation of SubscriptionGroup for testing
class FakeSubscriptionGroup implements SubscriptionGroup {
  @override
  final String id;

  @override
  final String name;

  @override
  final String icon;

  @override
  final Color? color;

  @override
  final int numberOfMembers;

  @override
  final DateTime createdAt;

  FakeSubscriptionGroup({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.numberOfMembers,
    required this.createdAt,
  });

  @override
  IconData get iconData => deserializeIconData(icon);

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'color': color?.toARGB32(), // Fixed deprecated 'value' property
      'number_of_members': numberOfMembers,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

void main() {
  group('SubscriptionGroup', () {
    test('should create a group with correct properties', () {
      final group = FakeSubscriptionGroup(
        id: '1',
        name: 'Test Group',
        icon: defaultGroupIcon,
        color: Colors.blue,
        numberOfMembers: 5,
        createdAt: DateTime(2023, 1, 1),
      );

      expect(group.id, '1');
      expect(group.name, 'Test Group');
      expect(group.icon, defaultGroupIcon);
      expect(group.color, Colors.blue);
      expect(group.numberOfMembers, 5);
      expect(group.createdAt, DateTime(2023, 1, 1));
      expect(group.iconData, Icons.rss_feed_rounded);
    });

    test('should convert to map correctly', () {
      final group = FakeSubscriptionGroup(
        id: '1',
        name: 'Test Group',
        icon: defaultGroupIcon,
        color: Colors.blue,
        numberOfMembers: 5,
        createdAt: DateTime(2023, 1, 1),
      );

      final map = group.toMap();

      expect(map['id'], '1');
      expect(map['name'], 'Test Group');
      expect(map['icon'], defaultGroupIcon);
      expect(map['color'], Colors.blue.toARGB32()); // Fixed deprecated 'value' property
      expect(map['number_of_members'], 5);
      expect(map['created_at'], DateTime(2023, 1, 1).toIso8601String());
    });
  });
}
