import 'package:flutter_triple/flutter_triple.dart';
import 'package:squawker/client/client.dart';
import 'package:squawker/user.dart';

class SearchTweetsModel extends Store<SearchStatus<TweetWithCard>> {
  late final Twitter _twitter;

  SearchTweetsModel() : super(SearchStatus(items: [])) {
    _twitter = Twitter();
  }

  Future<void> searchTweets(String query, bool enhanced, {bool trending = false, String? cursor}) async {
    await execute(() async {
      if (query.isEmpty) {
        return SearchStatus(items: []);
      } else {
        if (enhanced) {
          TweetStatus ts = await _twitter.searchTweetsGraphql(query, true, trending: trending, cursor: cursor);
          return SearchStatus(items: ts.chains.map((e) => e.tweets).expand((e) => e).toList(), cursorBottom: ts.cursorBottom);
        }
        else {
          TweetStatus ts = await _twitter.searchTweets(query, true, cursor: cursor, cursorType: cursor != null ? 'cursor_bottom' : null);
          return SearchStatus(items: ts.chains.map((e) => e.tweets).expand((e) => e).toList(), cursorBottom: ts.cursorBottom);
        }
      }
    });
  }
}

class SearchUsersModel extends Store<SearchStatus<UserWithExtra>> {
  late final Twitter _twitter;

  SearchUsersModel() : super(SearchStatus(items: [])) {
    _twitter = Twitter();
  }

  Future<void> searchUsers(String query, bool enhanced, {String? cursor}) async {
    await execute(() async {
      if (query.isEmpty) {
        return SearchStatus(items: []);
      } else {
        if (enhanced) {
          return await _twitter.searchUsersGraphql(query, limit: 100, cursor: cursor);
        }
        else {
          return await _twitter.searchUsers(query, limit: 100);
        }
      }
    });
  }
}