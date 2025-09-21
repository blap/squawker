import 'package:flutter/material.dart';
import 'package:squawker/client/client.dart';
import 'package:squawker/constants.dart';
import 'package:squawker/generated/l10n.dart';
import 'package:squawker/live_event/live_event.dart';
import 'package:squawker/tweet/_photo.dart';
import 'package:squawker/tweet/_video.dart';
import 'package:squawker/utils/route_util.dart';
import 'package:squawker/utils/urls.dart';

class BroadcastScreen extends StatelessWidget {
  const BroadcastScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = getNamedRouteArguments(routeBroadcast) as BroadcastScreenArguments;

    return _BroadcastScreen(
      url: args.url,
      title: args.title,
      username: args.username,
      broadcastKey: args.broadcastKey,
      image: args.image,
      width: args.width,
      height: args.height,
    );
  }
}

class _BroadcastScreen extends StatefulWidget {
  final String url;
  final String title;
  final String? username;
  final String? broadcastKey;
  final Map<String, dynamic>? image;
  final double? width;
  final double? height;

  const _BroadcastScreen({
    required this.url,
    required this.title,
    this.username,
    this.broadcastKey,
    this.image,
    this.width,
    this.height,
  });

  @override
  _BroadcastScreenState createState() => _BroadcastScreenState();
}

class _BroadcastScreenState extends State<_BroadcastScreen> {
  late final Twitter _twitter;

  @override
  void initState() {
    super.initState();
    _twitter = Twitter();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(L10n.of(context).live), // Using existing localization
        actions: [IconButton(icon: const Icon(Icons.open_in_browser), onPressed: () => openUri(widget.url))],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.broadcastKey != null)
              _createVideo()
            else if (widget.image != null)
              _createImage(widget.image!)
            else
              Container(
                height: 200,
                color: Theme.of(context).highlightColor,
                child: const Center(child: Icon(Icons.video_call, size: 64)),
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.title, style: Theme.of(context).textTheme.headlineSmall),
                  if (widget.username != null) ...[
                    const SizedBox(height: 8),
                    Text(widget.username!, style: Theme.of(context).textTheme.bodyMedium),
                  ],
                  const SizedBox(height: 16),
                  if (widget.broadcastKey != null)
                    ElevatedButton.icon(
                      onPressed: () {
                        // Video should play automatically in the player above
                      },
                      icon: const Icon(Icons.play_arrow),
                      label: Text(L10n.of(context).open_in_browser), // Using existing localization
                    )
                  else
                    ElevatedButton.icon(
                      onPressed: () => openUri(widget.url),
                      icon: const Icon(Icons.play_arrow),
                      label: Text(L10n.of(context).open_in_browser), // Using existing localization
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _createVideo() {
    var aspectRatio = (widget.width != null && widget.height != null) ? widget.width! / widget.height! : 16 / 9;

    var imageUrl = widget.image?['url'] as String?;

    return TweetVideo(
      username: widget.username ?? 'broadcast',
      loop: false,
      metadata: TweetVideoMetadata(null, aspectRatio, imageUrl, () async {
        if (widget.broadcastKey == null) {
          return TweetVideoUrls(widget.url, null);
        }

        var broadcast = await _twitter.getBroadcastDetails(widget.broadcastKey!);
        return TweetVideoUrls(broadcast['source']['noRedirectPlaybackUrl'], null);
      }),
    );
  }

  Widget _createImage(Map<String, dynamic> image) {
    var imageUrl = image['url'] as String?;
    if (imageUrl == null) {
      return Container();
    }

    return TweetPhoto(
      uri: imageUrl,
      fit: BoxFit.cover,
      pullToClose: false,
      inPageView: false,
    );
  }
}
