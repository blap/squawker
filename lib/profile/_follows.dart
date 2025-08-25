import 'package:flutter/material.dart';

import 'package:squawker/client/client.dart';
import 'package:squawker/database/entities.dart';
import 'package:squawker/ui/errors.dart';
import 'package:squawker/user.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:squawker/generated/l10n.dart';

class ProfileFollows extends StatefulWidget {
  final UserWithExtra user;
  final String type;

  const ProfileFollows({super.key, required this.user, required this.type});

  @override
  State<ProfileFollows> createState() => _ProfileFollowsState();
}

class _ProfileFollowsState extends State<ProfileFollows> with AutomaticKeepAliveClientMixin<ProfileFollows> {
  late final Twitter _twitter;
  late final PagingController<int?, UserWithExtra> _pagingController;

  final int _pageSize = 200;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    _twitter = Twitter();
    _pagingController = PagingController<int?, UserWithExtra>(
      getNextPageKey: (state) => state.lastPageIsEmpty || state.keys?.isEmpty != false ? null : state.keys!.last,
      fetchPage: (cursor) => _loadFollowsPage(cursor),
    );
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  Future<List<UserWithExtra>> _loadFollowsPage(int? cursor) async {
    try {
      var result = await _twitter.getProfileFollows(
        widget.user.screenName!,
        widget.type,
        cursor: cursor,
        count: _pageSize,
      );

      if (!mounted) {
        return [];
      }

      // Return the users directly, the pagination logic is handled by the controller
      return result.users;
    } catch (e) {
      if (mounted) {
        // Re-throw the error so the controller can handle it
        rethrow;
      }
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      appBar: AppBar(title: Text(widget.type == 'following' ? L10n.of(context).following : L10n.of(context).followers)),
      body: PagingListener(
        controller: _pagingController,
        builder: (context, state, fetchNextPage) => PagedListView<int?, UserWithExtra>(
          state: state,
          fetchNextPage: fetchNextPage,
          padding: EdgeInsets.zero,
          addAutomaticKeepAlives: false,
          builderDelegate: PagedChildBuilderDelegate(
            itemBuilder: (context, user, index) => UserTile(user: UserSubscription.fromUser(user)),
            firstPageErrorIndicatorBuilder: (context) => FullPageErrorWidget(
              error: state.error ?? Exception('Unknown error'),
              stackTrace: null,
              prefix: L10n.of(context).unable_to_load_the_list_of_follows,
              onRetry: () => _pagingController.refresh(),
            ),
            newPageErrorIndicatorBuilder: (context) => FullPageErrorWidget(
              error: state.error ?? Exception('Unknown error'),
              stackTrace: null,
              prefix: L10n.of(context).unable_to_load_the_next_page_of_follows,
              onRetry: () => _pagingController.fetchNextPage(),
            ),
            noItemsFoundIndicatorBuilder: (context) {
              var text = widget.type == 'following'
                  ? L10n.of(context).this_user_does_not_follow_anyone
                  : L10n.of(context).this_user_does_not_have_anyone_following_them;

              return Center(child: Text(text));
            },
          ),
        ),
      ),
    );
  }
}
