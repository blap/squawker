import 'dart:convert';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart';
import 'package:logging/logging.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:squawker/client/client.dart';
import 'package:squawker/client/client_account.dart';
import 'package:squawker/constants.dart';
import 'package:squawker/database/entities.dart';
import 'package:squawker/database/repository.dart';
import 'package:squawker/generated/l10n.dart';
import 'package:squawker/profile/profile.dart';
import 'package:squawker/tweet/_video.dart';
import 'package:squawker/tweet/conversation.dart';
import 'package:squawker/tweet/tweet.dart';
import 'package:squawker/ui/errors.dart';
import 'package:squawker/utils/crypto_util.dart';
import 'package:squawker/utils/iterables.dart';
import 'package:pref/pref.dart';
import 'package:provider/provider.dart';
import 'package:quiver/iterables.dart';
import 'package:synchronized/synchronized.dart';

class SubscriptionGroupFeed extends StatefulWidget {
  final SubscriptionGroupGet group;
  final List<String> searchQueries;
  final bool includeReplies;
  final bool includeRetweets;
  final ItemScrollController? scrollController;

  const SubscriptionGroupFeed({
    super.key,
    required this.group,
    required this.searchQueries,
    required this.includeReplies,
    required this.includeRetweets,
    required this.scrollController,
  });

  @override
  State<SubscriptionGroupFeed> createState() => SubscriptionGroupFeedState();
}

class SubscriptionGroupFeedState extends State<SubscriptionGroupFeed> with WidgetsBindingObserver {
  late final Twitter _twitter;

  static final log = Logger('SubscriptionGroupFeedState');

  static final Lock _lock = Lock();

  final GlobalKey<ScaffoldState> _key = GlobalKey<ScaffoldState>();

  late VisiblePositionState _visiblePositionState;
  late ItemPositionsListener _itemPositionsListener;
  bool _insertOffset = true;
  bool _keepFeedOffset = false;
  final List<TweetChain> _lastData = [];
  final List<TweetChain> _data = [];
  bool _toScroll = false;
  Response? _errorResponse;
  int? _positionShowing;
  OverlayEntry? _overlayEntry;
  final Map<String, int> _tweetIdxDic = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    _twitter = Twitter();
    WidgetsBinding.instance.addObserver(this);
    _visiblePositionState = VisiblePositionState();
    _itemPositionsListener = ItemPositionsListener.create();
    _itemPositionsListener.itemPositions.addListener(() {
      _checkFetchData();
    });
    Future.delayed(Duration.zero, () {
      _checkFetchData();
    });
  }

  @override
  void dispose() {
    updateOffset();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      updateOffset();
    }
  }

  @override
  Future<AppExitResponse> didRequestAppExit() async {
    updateOffset();
    return super.didRequestAppExit();
  }

  Future<void> _checkFetchData() async {
    if (_data.isEmpty ||
        (_data.length > _lastData.length &&
            (_data.length - _itemPositionsListener.itemPositions.value.first.index) < 20)) {
      await _lock.synchronized(() async {
        if (_data.isEmpty ||
            (_data.length > _lastData.length &&
                (_data.length - _itemPositionsListener.itemPositions.value.first.index) < 20)) {
          _lastData.clear();
          _lastData.addAll(_data);
          await _listTweets();
        }
      });
    }
  }

  Future<void> updateOffset() async {
    try {
      if (_keepFeedOffset && _visiblePositionState.initialized && _visiblePositionState.visibleChainId != null) {
        if (kDebugMode) {
          print(
            '*** _SubscriptionGroupFeedState._updateOffset - widget.group.id=${widget.group.id}, visibleChainId=${_visiblePositionState.visibleChainId}, visibleTweetId=${_visiblePositionState.visibleTweetId}, insert=$_insertOffset',
          );
        }
        var repository = await Repository.writable();
        if (_insertOffset) {
          await repository.insert(tableFeedGroupPositionState, {
            'group_id': widget.group.id,
            'chain_id': _visiblePositionState.visibleChainId,
            'tweet_id': _visiblePositionState.visibleTweetId,
          });
        } else {
          await repository.update(
            tableFeedGroupPositionState,
            {'chain_id': _visiblePositionState.visibleChainId, 'tweet_id': _visiblePositionState.visibleTweetId},
            where: 'group_id = ?',
            whereArgs: [widget.group.id],
          );
        }
      }
    } catch (e, stackTrace) {
      log.warning('*** ERROR _updateOffset');
      log.warning(e);
      log.warning(stackTrace);
    }
  }

  void _resetData() {
    _visiblePositionState.initialized = false;
    _data.clear();
  }

  void refresh() {
    setState(() {});
  }

  Future<void> reloadData() async {
    await updateOffset();
    _resetData();
    _checkFetchData();
  }

  void setLoading() {
    setState(() {
      _isLoading = true;
    });
  }

  @override
  void didUpdateWidget(SubscriptionGroupFeed oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.includeReplies != widget.includeReplies || oldWidget.includeRetweets != widget.includeRetweets) {
      reloadData();
    }
  }

  Future<List<TweetChain>> _listSearchQueryTweets(
    RateFetchContext fetchContext,
    String searchQuery,
    List<Response> errorResponseLst,
  ) async {
    BasePrefService prefs = PrefService.of(context);
    var repository = await Repository.writable();
    List<TweetChain> tweets = <TweetChain>[];
    String hash = await sha1Hash(searchQuery);
    String? searchCursor;
    String? cursorType;
    bool requestToDo = false;

    var storedChunks = await repository.query(
      tableFeedGroupChunk,
      where: 'group_id = ? AND hash = ?',
      whereArgs: [widget.group.id, hash],
      orderBy: 'created_at DESC',
    );
    if (_data.isEmpty) {
      requestToDo = true;
      // Make sure we load any existing stored tweets from the chunk
      var storedChunksTweets = storedChunks
          .map((e) => jsonDecode(e['response'] as String))
          .map((e) => List.from(e))
          .expand((e) => e.map((c) => TweetChain.fromJson(c as Map<String, dynamic>)))
          .toList();

      // avoid duplicates
      for (var cElm in storedChunksTweets) {
        if (tweets.firstWhereOrNull((tElm) => cElm.id == tElm.id) == null) {
          tweets.add(cElm);
        }
      }

      // Use the latest chunk's top cursor to load any new tweets since the last time we checked
      var latestChunk = storedChunks.firstOrNull;
      if (latestChunk != null) {
        searchCursor = latestChunk['cursor_top'] as String;
        cursorType = 'cursor_top';
      } else {
        // Otherwise we need to perform a fresh load from scratch for this chunk
        searchCursor = null;
      }
    } else {
      // We're currently at the end of our current feed, so get the oldest chunk's bottom cursor to load older tweets.
      if (storedChunks.isNotEmpty) {
        requestToDo = true;
        searchCursor = storedChunks.last['cursor_bottom'] as String;
        cursorType = 'cursor_bottom';
      }
    }

    if (requestToDo) {
      // Perform our search for the next page of results for this chunk, and add those tweets to our collection
      TweetStatus result;
      try {
        if (prefs.get(optionEnhancedFeeds)) {
          result = await _twitter.searchTweetsGraphql(
            searchQuery,
            widget.includeReplies,
            limit: 100,
            cursor: searchCursor,
            leanerFeeds: prefs.get(optionLeanerFeeds),
            fetchContext: fetchContext,
          );
        } else {
          result = await _twitter.searchTweets(
            searchQuery,
            widget.includeReplies,
            limit: 100,
            cursor: searchCursor,
            cursorType: cursorType,
            leanerFeeds: prefs.get(optionLeanerFeeds),
            fetchContext: fetchContext,
          );
        }
      } catch (rsp) {
        if (rsp is Exception) {
          log.severe(rsp.toString());
        }
        errorResponseLst.add(rsp is Exception ? ExceptionResponse(rsp) : rsp as Response);
        return tweets;
      }

      if (result.chains.isNotEmpty) {
        // avoid duplicates
        for (var cElm in result.chains) {
          if (tweets.firstWhereOrNull((tElm) => cElm.id == tElm.id) == null) {
            tweets.add(cElm);
          }
        }

        // Make sure we insert the set of cursors for this latest chunk, ready for the next time we paginate
        await repository.insert(tableFeedGroupChunk, {
          'group_id': widget.group.id,
          'hash': hash,
          'cursor_top': result.cursorTop,
          'cursor_bottom': result.cursorBottom,
          'response': jsonEncode(result.chains.map((e) => e.toJson()).toList()),
        });
      }
    } else {
      await fetchContext.fetchNoResponse();
    }

    return tweets;
  }

  void _checkForRateLimitException(List<Response> errorResponseLst) {
    if (_errorResponse == null && errorResponseLst.isNotEmpty) {
      for (Response rsp in errorResponseLst) {
        if (rsp is ExceptionResponse) {
          ExceptionResponse errRsp = rsp;
          if (errRsp.exception is RateLimitException) {
            _errorResponse = errRsp;
            break;
          }
        }
      }
      _errorResponse ??= errorResponseLst[0];
    }
  }

  Future<List<TweetChain>> _listParallelTweets(List<String> searchQueries) async {
    BasePrefService prefs = PrefService.of(context);
    List<Future<List<TweetChain>>> futures = [];
    List<Response> errorResponseLst = [];

    RateFetchContext fetchContext = RateFetchContext(
      prefs.get(optionEnhancedFeeds) ? Twitter.graphqlSearchTimelineUriPath : Twitter.searchTweetsUriPath,
      searchQueries.length,
    );
    await fetchContext.init();

    for (String searchQuery in searchQueries) {
      futures.add(_listSearchQueryTweets(fetchContext, searchQuery, errorResponseLst));
    }

    // Wait for all our searches to complete, then build our list of tweet conversations
    List<List<TweetChain>> result = await Future.wait(futures);
    _checkForRateLimitException(errorResponseLst);
    return result.expand((e) => e).toList();
  }

  /// Search for our next "page" of tweets.
  ///
  /// Here, each page is actually a set of mappings, where the ID of each set is the hash of all the user IDs in that
  /// set. We store this along with the top and bottom pagination cursors, which we use to perform pagination for all
  /// sets at the same time, allowing us to create a feed made up of individual search queries.
  Future<void> _listTweets() async {
    try {
      BasePrefService prefs = PrefService.of(context);
      _keepFeedOffset = prefs.get(optionKeepFeedOffset);
      var repository = await Repository.writable();

      String? positionedChainId;
      String? positionedTweetId;
      if (_keepFeedOffset) {
        var positionStateData = await repository.query(
          tableFeedGroupPositionState,
          where: 'group_id = ?',
          whereArgs: [widget.group.id],
        );
        _insertOffset = positionStateData.isEmpty;
        if (positionStateData.isNotEmpty) {
          positionedChainId = positionStateData[0]['chain_id'] as String?;
          positionedTweetId = positionStateData[0]['tweet_id'] as String?;
          if (kDebugMode) {
            print(
              '*** _SubscriptionGroupFeedState._listTweets - repository.query - positionedChainId=$positionedChainId, positionedTweetId=$positionedTweetId',
            );
          }
        }
      }

      _errorResponse = null;
      List<TweetChain> threads = [];
      // no more than 5 parallel executions
      List<List<String>> partSearchQueries = partition(widget.searchQueries, 5).toList();
      for (int i = 0; _errorResponse == null && i < partSearchQueries.length; i++) {
        List<String> searchQueries = partSearchQueries[i];
        List<TweetChain> parallelThreads = await _listParallelTweets(searchQueries);
        threads.addAll(parallelThreads);
      }

      threads.sort((a, b) {
        var aCreatedAt = a.tweets[0].createdAt;
        var bCreatedAt = b.tweets[0].createdAt;

        if (aCreatedAt == null || bCreatedAt == null) {
          return 0;
        }

        return bCreatedAt.compareTo(aCreatedAt);
      });

      if (!mounted) {
        return;
      }

      // this block is executed only at the first initialisation (or re-initialisation)
      if (positionedChainId != null && !_visiblePositionState.initialized) {
        int positionedChainIdx = threads.indexWhere((e) => e.id == positionedChainId);
        int positionedTweetIdx = -1;
        if (positionedChainIdx > -1 && positionedTweetId != null) {
          positionedTweetIdx = threads[positionedChainIdx].tweets.indexWhere((e) => e.idStr == positionedTweetId);
        }
        if (positionedChainIdx == -1 && threads.isNotEmpty) {
          // find the nearest conversation
          int refId = int.parse(positionedChainId);
          TweetChain tc = threads.lastWhere(
            (e) {
              int id = int.parse(e.id);
              return id > refId;
            },
            orElse: () {
              return threads[threads.length - 1];
            },
          );
          positionedChainIdx = threads.indexWhere((e) => e.id == tc.id);
        }
        _visiblePositionState.scrollChainIdx = positionedChainIdx > -1 ? positionedChainIdx : null;
        _visiblePositionState.scrollTweetIdx = positionedTweetIdx > -1 ? positionedTweetIdx : null;
        if (kDebugMode) {
          print(
            '*** _SubscriptionGroupFeedState._listTweets - setPositionIndexes - _visiblePositionState.scrollChainIdx=${_visiblePositionState.scrollChainIdx}, _visiblePositionState.scrollTweetIdx=${_visiblePositionState.scrollTweetIdx}',
          );
        }
      }

      _positionShowing = null;

      setState(() {
        _data.addAll(threads);
        _isLoading = false;
      });

      _tweetIdxDic.clear();
      int idx = 0;
      for (var cElm in _data) {
        for (var tElm in cElm.tweets) {
          _tweetIdxDic[tElm.idStr!] = idx;
          idx++;
        }
      }

      _toScroll = false;
      if (threads.isNotEmpty && !_visiblePositionState.initialized && _visiblePositionState.scrollChainIdx != null) {
        _toScroll = true;
      }
    } catch (e) {
      if (e is Exception) {
        log.severe(e.toString());
        setState(() {
          _errorResponse ??= ExceptionResponse(e);
          _isLoading = false;
        });
      }
      if (mounted) {
        // probably something to do
      }
    } finally {
      if (_isLoading) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showOverlay(BuildContext context) {
    //print('*** _showOverlay - _visiblePositionState.visibleChainIdx=${_visiblePositionState.visibleChainIdx}');
    if (_overlayEntry == null) {
      RenderBox renderBoxWindow = _key.currentContext!.findRenderObject() as RenderBox;
      Offset positionWindow = renderBoxWindow.localToGlobal(Offset.zero);
      _overlayEntry = OverlayEntry(
        builder: (context) {
          return Positioned(
            right: 5, // MediaQuery.of(context).size.width * 0.05,
            top: positionWindow.dy + 5, // MediaQuery.of(context).size.height * 0.15,
            child: Material(
              child: Text(
                _positionShowing == null ? '' : _positionShowing!.toString(),
                style: TextStyle(fontSize: Theme.of(context).textTheme.titleMedium!.fontSize),
              ),
            ),
          );
        },
      );
      Overlay.of(context).insert(_overlayEntry!);
    } else {
      _overlayEntry!.markNeedsBuild();
    }
  }

  @override
  Widget build(BuildContext context) {
    TwitterAccount.setCurrentContext(context);
    BasePrefService prefs = PrefService.of(context, listen: false);
    _keepFeedOffset = prefs.get(optionKeepFeedOffset);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_toScroll) {
        _toScroll = false;
        if (kDebugMode) {
          print(
            '*** _SubscriptionGroupFeedState._listTweets - scrollController.jumpTo - index=${_visiblePositionState.scrollChainIdx}, widget.group.id=${widget.group.id}',
          );
        }
        widget.scrollController!.jumpTo(index: _visiblePositionState.scrollChainIdx!);
      }
      if (_errorResponse != null &&
          _data.isNotEmpty &&
          (_errorResponse!.statusCode < 200 || _errorResponse!.statusCode >= 300)) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_errorResponse!.body)));
        _errorResponse = null;
      }
    });

    if (_errorResponse != null &&
        _data.isEmpty &&
        (_errorResponse!.statusCode < 200 || _errorResponse!.statusCode >= 300)) {
      var errorPage = Scaffold(
        body: FullPageErrorWidget(error: _errorResponse, prefix: 'Error request Twitter/X', stackTrace: null),
      );
      _errorResponse = null;
      return errorPage;
    }

    if (widget.searchQueries.isEmpty) {
      return Scaffold(body: Center(child: Text(L10n.of(context).this_group_contains_no_subscriptions)));
    }

    return Stack(
      children: [
        Scaffold(
          key: _key,
          body: RefreshIndicator(
            onRefresh: () async {
              setState(() {
                _isLoading = true;
              });
              await reloadData();
            },
            child: MultiProvider(
              providers: [
                ChangeNotifierProvider<TweetContextState>(
                  create: (_) => TweetContextState(prefs.get(optionTweetsHideSensitive)),
                ),
                ChangeNotifierProvider<VideoContextState>(
                  create: (_) => VideoContextState(prefs.get(optionMediaDefaultMute)),
                ),
              ],
              child: NotificationListener<ScrollNotification>(
                onNotification: (ScrollNotification notification) {
                  if (notification is UserScrollNotification) {
                    if (!_keepFeedOffset || !_visiblePositionState.initialized) {
                      return false;
                    }
                    if (notification.direction == ScrollDirection.forward) {
                      if (_visiblePositionState.visibleTweetIdx != null && mounted) {
                        _positionShowing = _visiblePositionState.visibleTweetIdx!;
                        _showOverlay(context);
                      }
                    } else if (notification.direction == ScrollDirection.idle) {
                      _positionShowing = null;
                      // Store the mounted status before the async gap
                      final isMounted = mounted;
                      Future.delayed(const Duration(seconds: 2), () {
                        // Use the stored mounted status
                        if (_positionShowing == null && isMounted) {
                          // Only call _hideOverlay if we still need to (widget is still mounted)
                          // We don't pass context across the async gap
                          if (_overlayEntry != null) {
                            _overlayEntry!.remove();
                            _overlayEntry = null;
                          }
                        }
                      });
                    }
                  }
                  return false;
                },
                child: ScrollablePositionedList.builder(
                  itemCount: _data.length,
                  itemBuilder: (context, index) {
                    TweetChain tc = _data[index];
                    return TweetConversation(
                      key: ValueKey(tc.id),
                      id: tc.id,
                      username: null,
                      isPinned: tc.isPinned,
                      tweets: tc.tweets,
                      tweetIdxDic: _tweetIdxDic,
                      visiblePositionState: _visiblePositionState,
                    );
                  },
                  itemScrollController: widget.scrollController,
                  itemPositionsListener: _itemPositionsListener,
                  padding: const EdgeInsets.only(top: 4),
                ),
              ),
            ),
          ),
        ),
        if (_isLoading) const Opacity(opacity: 0.5, child: ModalBarrier(dismissible: false, color: Colors.black)),
        if (_isLoading) const Center(child: CircularProgressIndicator()),
      ],
    );
  }
}
