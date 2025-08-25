import 'package:flutter/material.dart';
import 'package:squawker/database/entities.dart';
import 'package:squawker/generated/l10n.dart';
import 'package:squawker/home/_saved.dart';
import 'package:squawker/profile/profile.dart';
import 'package:squawker/saved/saved_tweet_model.dart';
import 'package:squawker/ui/errors.dart';
import 'package:squawker/user.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:provider/provider.dart';

class ProfileSaved extends StatefulWidget {
  final UserWithExtra user;

  const ProfileSaved({super.key, required this.user});

  @override
  State<ProfileSaved> createState() => _ProfileSavedState();
}

class _ProfileSavedState extends State<ProfileSaved> {
  late final PagingController<int?, SavedTweet> _pagingController;

  @override
  void initState() {
    super.initState();

    _pagingController = PagingController<int?, SavedTweet>(
      getNextPageKey: (state) => state.lastPageIsEmpty || state.keys?.isEmpty != false ? null : state.keys!.last,
      fetchPage: (cursor) => _loadTweetsPage(cursor),
    );
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  Future<List<SavedTweet>> _loadTweetsPage(int? cursor) async {
    var model = context.read<SavedTweetModel>();
    await model.listSavedTweets();

    var savedTweets = model.state.where((tweet) => tweet.user == widget.user.idStr).toList();
    return savedTweets;
  }

  @override
  Widget build(BuildContext context) {
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

        return PagingListener(
          controller: _pagingController,
          builder: (context, state, fetchNextPage) => PagedListView<int?, SavedTweet>(
            state: state,
            fetchNextPage: fetchNextPage,
            padding: EdgeInsets.zero,
            addAutomaticKeepAlives: false,
            builderDelegate: PagedChildBuilderDelegate(
              itemBuilder: (context, savedTweet, index) =>
                  SavedTweetTile(id: savedTweet.id, content: savedTweet.content),
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
                return Center(child: Text(L10n.of(context).you_have_not_saved_any_tweets_yet));
              },
            ),
          ),
        );
      },
    );
  }
}
