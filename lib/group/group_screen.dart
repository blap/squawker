import 'package:flutter/material.dart';
import 'package:flutter_triple/flutter_triple.dart';
import 'package:pref/pref.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:squawker/constants.dart';
import 'package:squawker/database/entities.dart';
import 'package:squawker/generated/l10n.dart';
import 'package:squawker/group/group_model.dart';
import 'package:squawker/group/_feed.dart';
import 'package:squawker/group/_settings.dart';
import 'package:squawker/ui/errors.dart';
import 'package:squawker/utils/data_service.dart';
import 'package:squawker/utils/iterables.dart';
import 'package:squawker/utils/route_util.dart';

class GroupScreenArguments {
  final String id;
  final String name;

  GroupScreenArguments({required this.id, required this.name});

  @override
  String toString() {
    return 'GroupScreenArguments{id: $id, name: $name}';
  }
}

class GroupScreen extends StatelessWidget {
  const GroupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = getNamedRouteArguments(routeGroup) as GroupScreenArguments;

    return SubscriptionGroupScreen(
      scrollController: ScrollController(),
      id: args.id,
      name: args.name,
      actions: const [],
    );
  }
}

class SubscriptionGroupScreenContent extends StatelessWidget {
  final String id;
  final ItemScrollController? scrollController;

  const SubscriptionGroupScreenContent({super.key, required this.id, this.scrollController});

  String _buildSearchQuery(
    List<Subscription> users,
    bool includeReplies,
    bool includeRetweets,
    List<String> exclusionsFeedLst,
  ) {
    StringBuffer query = StringBuffer();
    bool firstDone = false;

    if (!includeReplies) {
      query.write('-filter:replies AND ');
    }
    if (!includeRetweets) {
      query.write(' -filter:retweets AND ');
    } else {
      query.write('include:nativeretweets AND ');
    }

    for (String exclusion in exclusionsFeedLst) {
      String vExclusion = exclusion;
      if (vExclusion.startsWith('@') || vExclusion.startsWith('#')) {
        vExclusion = vExclusion.substring(1);
      }
      query.write('-@$vExclusion AND ');
    }

    while (users.isNotEmpty) {
      Subscription user = users[0];
      String queryToAdd;

      if (user is UserSubscription) {
        queryToAdd = firstDone ? ' OR from:${user.screenName}' : 'from:${user.screenName}';
      } else {
        // user is SearchSubscription
        queryToAdd = firstDone ? ' OR ${user.id}' : user.id;
      }
      if (query.length + queryToAdd.length > 512) {
        break;
      }
      query.write(queryToAdd);
      users.removeAt(0);
      firstDone = true;
    }

    return query.toString();
  }

  List<String> _buildSearchQueries(
    List<Subscription> users,
    bool includeReplies,
    bool includeRetweets,
    List<String> exclusionsFeedLst,
  ) {
    List<String> searchQueryLst = [];
    while (users.isNotEmpty) {
      String searchQuery = _buildSearchQuery(users, includeReplies, includeRetweets, exclusionsFeedLst);
      searchQueryLst.add(searchQuery);
    }
    return searchQueryLst;
  }

  @override
  Widget build(BuildContext context) {
    return ScopedBuilder<GroupModel, SubscriptionGroupGet>.transition(
      store: context.read<GroupModel>(),
      onLoading: (_) => const Center(child: Text('lad')),
      onError: (_, error) =>
          ScaffoldErrorWidget(error: error, stackTrace: null, prefix: L10n.current.unable_to_load_the_group),
      onState: (_, group) {
        // Split the users into chunks, oldest first, to prevent thrashing of all groups when a new user is added
        var filteredUsers = group.id == '-1' ? group.subscriptions.where((elm) => elm.inFeed) : group.subscriptions;
        var users = filteredUsers.sorted((a, b) => a.createdAt.compareTo(b.createdAt)).toList();
        BasePrefService prefs = PrefService.of(context);

        List<String> exclusionLst = prefs.get(optionExclusionsFeed).split(',');
        if (exclusionLst.last.isEmpty) {
          exclusionLst.removeLast();
        }
        List<String> searchQueries = _buildSearchQueries(
          users,
          group.includeReplies,
          group.includeRetweets,
          exclusionLst,
        );

        String feedKeyName = 'feed_key_${group.id.replaceAll('-', '_')}';
        GlobalKey<SubscriptionGroupFeedState>? sgfKey = DataService().map[feedKeyName];
        if (sgfKey == null) {
          sgfKey = GlobalKey<SubscriptionGroupFeedState>();
          DataService().map[feedKeyName] = sgfKey;
        }

        return SubscriptionGroupFeed(
          key: sgfKey,
          group: group,
          searchQueries: searchQueries,
          includeReplies: group.includeReplies,
          includeRetweets: group.includeRetweets,
          scrollController: scrollController,
        );
      },
    );
  }
}

class SubscriptionGroupScreen extends StatelessWidget {
  final ScrollController scrollController;
  final String id;
  final String name;
  final List<Widget> actions;

  const SubscriptionGroupScreen({
    super.key,
    required this.scrollController,
    required this.id,
    required this.name,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Provider<GroupModel>(
      create: (context) {
        var model = GroupModel(id);
        model.loadGroup();

        return model;
      },
      builder: (context, child) {
        var model = context.read<GroupModel>();
        SubscriptionGroupScreenContent content = SubscriptionGroupScreenContent(
          id: id,
          scrollController: ItemScrollController(),
        );
        return NestedScrollView(
          controller: scrollController,
          floatHeaderSlivers: true,
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                pinned: false,
                snap: true,
                floating: true,
                title: Text(name),
                actions: [
                  IconButton(icon: const Icon(Icons.more_vert), onPressed: () => showFeedSettings(context, model)),
                  IconButton(
                    icon: const Icon(Icons.arrow_upward_rounded),
                    onPressed: () async {
                      await content.scrollController!.scrollTo(
                        index: 0,
                        duration: const Duration(seconds: 1),
                        curve: Curves.easeInOut,
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh_rounded),
                    onPressed: () async {
                      GlobalKey<SubscriptionGroupFeedState>? sgfKey =
                          DataService().map['feed_key_${id.replaceAll('-', '_')}'];
                      if (sgfKey?.currentState != null) {
                        sgfKey!.currentState!.setLoading();
                        await sgfKey.currentState!.reloadData();
                      }
                    },
                  ),
                  ...actions,
                ],
              ),
            ];
          },
          body: content,
        );
      },
    );
  }
}
