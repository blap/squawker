import 'package:flutter/material.dart';
import 'package:pref/pref.dart';

import 'package:squawker/client/client.dart';
import 'package:squawker/client/client_account.dart';
import 'package:squawker/constants.dart';
import 'package:squawker/profile/profile.dart';
import 'package:squawker/tweet/conversation.dart';
import 'package:squawker/ui/errors.dart';
import 'package:squawker/user.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:squawker/generated/l10n.dart';
import 'package:provider/provider.dart';

class ProfileTweets extends StatefulWidget {
  final UserWithExtra user;
  final String type;
  final bool includeReplies;
  final List<String> pinnedTweets;

  const ProfileTweets({
    super.key,
    required this.user,
    required this.type,
    required this.includeReplies,
    required this.pinnedTweets,
  });

  @override
  State<ProfileTweets> createState() => _ProfileTweetsState();
}

class _ProfileTweetsState extends State<ProfileTweets> with AutomaticKeepAliveClientMixin<ProfileTweets> {
  late final Twitter _twitter;
  late final PagingController<String?, TweetChain> _pagingController;

  static const int pageSize = 20;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    _twitter = Twitter();
    _pagingController = PagingController<String?, TweetChain>(
      getNextPageKey: (state) => state.lastPageIsEmpty || state.keys?.isEmpty != false ? null : state.keys!.last,
      fetchPage: (cursor) => _loadTweetsPage(cursor),
    );
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  Future<List<TweetChain>> _loadTweetsPage(String? cursor) async {
    try {
      TweetStatus result;
      if (TwitterAccount.hasAccountAvailable()) {
        if (PrefService.of(context).get(optionEnhancedProfile)) {
          result = await _twitter.getUserWithProfileGraphql(
            widget.user.idStr!,
            widget.type,
            widget.pinnedTweets,
            cursor: cursor,
            count: pageSize,
            includeReplies: widget.includeReplies,
          );
        } else {
          result = await _twitter.getTweets(
            widget.user.idStr!,
            widget.type,
            widget.pinnedTweets,
            cursor: cursor,
            count: pageSize,
            includeReplies: widget.includeReplies,
          );
        }
      } else {
        result = await _twitter.getUserTweets(
          widget.user.idStr!,
          widget.type,
          widget.pinnedTweets,
          count: pageSize,
          includeReplies: widget.includeReplies,
        );
      }

      if (!mounted) {
        return [];
      }

      // Return the chains directly, the pagination logic is handled by the controller
      return result.chains;
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
    TwitterAccount.setCurrentContext(context);

    return Consumer<TweetContextState>(
      builder: (context, model, child) {
        if (model.hideSensitive && (widget.user.possiblySensitive ?? false)) {
          return EmojiErrorWidget(
            emoji: '🍆🙈🍆',
            message: L10n.current.possibly_sensitive,
            errorMessage: L10n.current.possibly_sensitive_profile,
            onRetry: () async => model.setHideSensitive(false),
            retryText: L10n.current.yes_please,
          );
        }

        return RefreshIndicator(
          onRefresh: () async => _pagingController.refresh(),
          child: PagingListener(
            controller: _pagingController,
            builder: (context, state, fetchNextPage) => PagedListView<String?, TweetChain>(
              state: state,
              fetchNextPage: fetchNextPage,
              padding: EdgeInsets.zero,
              addAutomaticKeepAlives: false,
              builderDelegate: PagedChildBuilderDelegate(
                itemBuilder: (context, chain, index) {
                  return TweetConversation(
                    id: chain.id,
                    tweets: chain.tweets,
                    username: widget.user.screenName!,
                    isPinned: chain.isPinned,
                  );
                },
                firstPageErrorIndicatorBuilder: (context) => FullPageErrorWidget(
                  error: state.error ?? Exception('Unknown error'),
                  stackTrace: null,
                  prefix: L10n.of(context).unable_to_load_the_tweets,
                  onRetry: () => _pagingController.refresh(),
                ),
                newPageErrorIndicatorBuilder: (context) => FullPageErrorWidget(
                  error: state.error ?? Exception('Unknown error'),
                  stackTrace: null,
                  prefix: L10n.of(context).unable_to_load_the_next_page_of_tweets,
                  onRetry: () => _pagingController.fetchNextPage(),
                ),
                noItemsFoundIndicatorBuilder: (context) {
                  return Center(child: Text(L10n.of(context).could_not_find_any_tweets_by_this_user));
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
