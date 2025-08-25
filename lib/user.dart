import 'package:dart_twitter_api/twitter_api.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_triple/flutter_triple.dart';
import 'package:squawker/constants.dart';
import 'package:squawker/database/entities.dart';
import 'package:squawker/generated/l10n.dart';
import 'package:squawker/group/group_model.dart';
import 'package:squawker/profile/profile.dart';
import 'package:squawker/subscriptions/_groups.dart';
import 'package:squawker/subscriptions/users_model.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:provider/provider.dart';
import 'package:squawker/utils/data_service.dart';
import 'package:squawker/utils/route_util.dart';
import 'package:intl/intl.dart';

import 'group/_feed.dart';

/// Creates a [DateTime] from a Twitter timestamp.
///
/// Returns `null`, if [twitterDateString] is `null` or was unable to be
/// parsed.
DateTime? convertTwitterDateString(String? twitterDateString) {
  if (twitterDateString == null) {
    return null;
  }

  try {
    return DateTime.parse(twitterDateString);
  } catch (e) {
    try {
      final dateString = formatTwitterDateString(twitterDateString);
      return DateFormat('E MMM dd HH:mm:ss yyyy', 'en_US').parse(dateString, true);
    } catch (e) {
      return null;
    }
  }
}

/// Removes the timezone to allow [DateTime] to parse the string.
///
/// The date strings are always in UTC and the timezone difference is 0,
/// therefore no information is lost by removing the timezone.
String formatTwitterDateString(String twitterDateString) {
  final sanitized = twitterDateString.split(' ')..removeWhere((part) => part.startsWith('+'));
  return sanitized.join(' ');
}

Widget _createUserAvatar(String? uri, double size) {
  if (uri == null) {
    return SizedBox(width: size, height: size);
  } else {
    // Implement SWR-like error handling for profile images
    // If the image fails to load, we'll try to reload it with a fallback mechanism
    return ExtendedImage.network(
      uri.replaceAll('normal', '200x200'),
      width: size,
      height: size,
      loadStateChanged: (state) {
        switch (state.extendedImageLoadState) {
          case LoadState.failed:
            // Return a default icon when image loading fails
            return const Icon(Icons.account_circle, size: 48);
          default:
            return state.completedWidget;
        }
      },
      // Add retry mechanism for failed images
      retries: 3,
      timeLimit: const Duration(seconds: 30),
    );
  }
}

class UserAvatar extends StatelessWidget {
  final String? uri;
  final double size;

  const UserAvatar({super.key, required this.uri, this.size = 48});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(borderRadius: BorderRadius.circular(size), child: _createUserAvatar(uri, size));
  }
}

class UserTile extends StatelessWidget {
  final Subscription user;

  const UserTile({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    // Capture theme values before any potential async operations
    var primaryColor = Theme.of(context).primaryColor;

    return ListTile(
      dense: true,
      leading: UserAvatar(uri: user.profileImageUrlHttps),
      title: Row(
        children: [
          Flexible(child: Text(user.name, maxLines: 1, overflow: TextOverflow.ellipsis)),
          if (user.verified) const SizedBox(width: 6),
          if (user.verified) Icon(Icons.verified, size: 14, color: primaryColor),
        ],
      ),
      subtitle: Text('@${user.screenName}', maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: SizedBox(width: 36, child: FollowButton(user: user)),
      onTap: () {
        pushNamedRoute(context, routeProfile, ProfileScreenArguments(user.id, user.screenName));
      },
    );
  }
}

class FollowButtonSelectGroupDialog extends StatefulWidget {
  final Subscription user;
  final bool followed;
  final List<String> groupsForUser;

  const FollowButtonSelectGroupDialog({
    super.key,
    required this.user,
    required this.followed,
    required this.groupsForUser,
  });

  @override
  State<FollowButtonSelectGroupDialog> createState() => _FollowButtonSelectGroupDialogState();
}

class _FollowButtonSelectGroupDialogState extends State<FollowButtonSelectGroupDialog> {
  @override
  Widget build(BuildContext context) {
    var groupModel = context.read<GroupsModel>();
    var subscriptionsModel = context.read<SubscriptionsModel>();

    // Capture all theme and localized values before any async operations
    var brightness = Theme.of(context).brightness;
    var color = brightness == Brightness.dark ? Colors.white70 : Colors.black54;
    var selectText = L10n.of(context).select;
    var searchText = L10n.of(context).search;
    var okText = L10n.of(context).ok;
    var cancelText = L10n.of(context).cancel;
    var textTheme = Theme.of(context).textTheme;
    var colorScheme = Theme.of(context).colorScheme;

    return MultiSelectDialog(
      title: Row(
        children: [
          Text(selectText),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // Extract all necessary parameters before any async operations
              final userId = widget.user.id;

              // Schedule the dialog to open after the current frame
              WidgetsBinding.instance.addPostFrameCallback((_) {
                // Open the dialog without passing context directly to async function
                openSubscriptionGroupDialog(
                  context, // Use context directly here since we're in the post-frame callback
                  null,
                  '',
                  defaultGroupIcon,
                  preMembers: {userId},
                ).then((_) {
                  // Check both context and state mounted status
                  if (context.mounted && mounted) {
                    Navigator.pop(context, 'reload');
                  }
                });
              });
            },
          ),
        ],
      ),
      searchHint: searchText,
      confirmText: Text(okText),
      cancelText: Text(cancelText),
      searchIcon: Icon(Icons.search_rounded, color: color),
      closeSearchIcon: Icon(Icons.close_rounded, color: color),
      itemsTextStyle: textTheme.bodyLarge,
      selectedColor: colorScheme.secondary,
      unselectedColor: color,
      selectedItemsTextStyle: textTheme.bodyLarge,
      items: groupModel.state.map((e) => MultiSelectItem(e.id, e.name)).toList(),
      initialValue: widget.groupsForUser,
      onConfirm: (List<String> memberships) async {
        // If we're not currently following the user, follow them first
        if (widget.followed == false) {
          await subscriptionsModel.toggleSubscribe(widget.user, widget.followed);
        }

        // Then add them to all the selected groups
        await groupModel.saveUserGroupMembership(widget.user.id, memberships);
      },
    );
  }
}

class FollowButton extends StatelessWidget {
  final Subscription user;
  final Color? color;

  const FollowButton({super.key, required this.user, this.color});

  @override
  Widget build(BuildContext context) {
    var model = context.read<SubscriptionsModel>();

    return ScopedBuilder<SubscriptionsModel, List<Subscription>>(
      store: model,
      onState: (_, state) {
        var followed = state.any((element) => element.id == user.id);
        var inFeed = followed ? state.any((element) => element.id == user.id && element.inFeed) : false;

        // Capture all theme and localized values before any async operations
        var textSub = followed ? L10n.of(context).unsubscribe : L10n.of(context).subscribe;
        var textAddToGroup = L10n.of(context).add_to_group;
        var textFeed = followed ? (inFeed ? L10n.of(context).remove_from_feed : L10n.of(context).add_to_feed) : null;

        var icon = followed
            ? (inFeed
                  ? Icon(Icons.person_remove_rounded, color: color)
                  : const Icon(Icons.person_remove_rounded, color: Colors.red))
            : Icon(Icons.person_add_rounded, color: color);

        return PopupMenuButton<String>(
          icon: icon,
          itemBuilder: (context) => [
            PopupMenuItem(value: 'toggle_subscribe', child: Text(textSub)),
            PopupMenuItem(value: 'add_to_group', child: Text(textAddToGroup)),
            if (textFeed != null) PopupMenuItem(value: 'toggle_feed', child: Text(textFeed)),
          ],
          onSelected: (value) async {
            switch (value) {
              case 'add_to_group':
                dynamic resp = 'reload';
                while (resp is String && resp == 'reload') {
                  // Check if context is still valid before proceeding
                  if (!context.mounted) {
                    resp = null;
                    break;
                  }

                  // Get the groups model and user ID before the async gap
                  final groupsModel = context.read<GroupsModel>();
                  final userId = user.id;

                  // Get the groups first
                  final groupsFuture = groupsModel.listGroupsForUser(userId);

                  // Wait for the groups and then show the dialog
                  final groups = await groupsFuture;

                  // Show the dialog and await its result - check context validity before use
                  if (context.mounted) {
                    final dialogResult = await showDialog(
                      context: context,
                      builder: (_) =>
                          FollowButtonSelectGroupDialog(user: user, followed: followed, groupsForUser: groups),
                    );
                    resp = dialogResult;
                  } else {
                    // Context is no longer valid, break the loop
                    resp = null;
                  }
                }
                break;
              case 'toggle_subscribe':
                GlobalKey<SubscriptionGroupFeedState>? sgfKey = DataService().map['feed_key__1'];
                if (sgfKey?.currentState != null) {
                  await sgfKey!.currentState!.updateOffset();
                }
                await model.toggleSubscribe(user, followed);
                break;
              case 'toggle_feed':
                GlobalKey<SubscriptionGroupFeedState>? sgfKey = DataService().map['feed_key__1'];
                if (sgfKey?.currentState != null) {
                  await sgfKey!.currentState!.updateOffset();
                }
                await model.toggleFeed(user, inFeed);
                break;
            }
          },
        );
      },
    );
  }
}

class UserWithExtra extends User {
  Map<String, dynamic>? card;
  bool? possiblySensitive;

  UserWithExtra();

  @override
  Map<String, dynamic> toJson() {
    var json = super.toJson();
    json['potentiallySensitive'] = possiblySensitive;

    return json;
  }

  factory UserWithExtra.fromJson(Map<String, dynamic> json) {
    var userWithExtra = UserWithExtra()
      ..idStr = json['id_str'] as String?
      ..name = json['name'] as String?
      ..screenName = json['screen_name'] as String?
      ..location = json['location'] as String?
      ..derived = json['derived'] == null ? null : Derived.fromJson(json['derived'] as Map<String, dynamic>)
      ..url = json['url'] as String?
      ..entities = json['entities'] == null ? null : UserEntities.fromJson(json['entities'] as Map<String, dynamic>)
      ..description = json['description'] as String?
      ..protected = json['protected'] as bool?
      ..verified = json['verified_type'] == 'Business'
          ? true
          : json['ext_is_blue_verified'] ?? json['verified'] ?? json['is_blue_verified'] as bool?
      ..status = json['status'] == null ? null : Tweet.fromJson(json['status'] as Map<String, dynamic>)
      ..followersCount = json['followers_count'] as int?
      ..friendsCount = json['friends_count'] as int?
      ..listedCount = json['listed_count'] as int?
      ..favoritesCount = json['favorites_count'] as int?
      ..statusesCount = json['statuses_count'] as int?
      ..createdAt =
          convertTwitterDateString(json['created_at'] as String?) // Updated function name
      ..profileBannerUrl = json['profile_banner_url'] as String?
      ..profileImageUrlHttps = json['profile_image_url_https'] as String?
      ..defaultProfile = json['default_profile'] as bool?
      ..defaultProfileImage = json['default_profile_image'] as bool?
      ..withheldInCountries = (json['withheld_in_countries'] as List<dynamic>?)?.map((e) => e as String).toList()
      ..withheldScope = json['withheld_scope'] as String?;

    userWithExtra.possiblySensitive = json['possibly_sensitive'] as bool?;

    return userWithExtra;
  }
}
