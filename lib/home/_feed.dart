import 'package:flutter/material.dart';
import 'package:squawker/group/_feed.dart';
import 'package:squawker/group/group_screen.dart';
import 'package:squawker/home/home_screen.dart';
import 'package:squawker/utils/data_service.dart';


class FeedScreen extends StatefulWidget {
  final ScrollController scrollController;
  final String id;
  final String name;

  const FeedScreen({super.key, required this.scrollController, required this.id, required this.name});

  @override
  State<FeedScreen> createState() => FeedScreenState();
}

class FeedScreenState extends State<FeedScreen> with AutomaticKeepAliveClientMixin<FeedScreen> {

  Future<void> checkUpdateOrRefreshFeed() async {
    if (DataService().map.containsKey('toggleKeepFeed')) {
      setState(() {
        DataService().map.remove('toggleKeepFeed');
        DataService().map['keepFeed'] = false;
        updateKeepAlive();
      });
    }
    if (DataService().map.containsKey('toggleRefreshFeed')) {
      DataService().map.remove('toggleRefreshFeed');
      GlobalKey<SubscriptionGroupFeedState>? sgfKey = DataService().map['feed_key_${widget.id.replaceAll('-', '_')}'];
      if (sgfKey?.currentState != null) {
        sgfKey!.currentState!.refresh();
      }
    }
  }

  @override
  bool get wantKeepAlive {
    bool ret = true;
    if (DataService().map.containsKey('keepFeed')) {
      ret = DataService().map['keepFeed'] as bool;
    }
    return ret;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    DataService().map['keepFeed'] = true;
    return SubscriptionGroupScreen(
        scrollController: widget.scrollController,
        id: widget.id,
        name: widget.name,
        actions: createCommonAppBarActions(context));
  }
}
