import 'package:flutter/material.dart';
import 'package:squawker/constants.dart';
import 'package:squawker/generated/l10n.dart';
import 'package:squawker/live_event/live_event.dart';
import 'package:squawker/utils/route_util.dart';
import 'package:squawker/utils/urls.dart';
import 'package:extended_image/extended_image.dart';

class LiveEventScreen extends StatelessWidget {
  const LiveEventScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = getNamedRouteArguments(routeLiveEvent) as LiveEventScreenArguments;

    return _LiveEventScreen(
      url: args.url,
      title: args.title,
      subtitle: args.subtitle,
      user: args.user,
      image: args.image,
    );
  }
}

class _LiveEventScreen extends StatefulWidget {
  final String url;
  final String title;
  final String? subtitle;
  final String? user;
  final Map<String, dynamic>? image;

  const _LiveEventScreen({required this.url, required this.title, this.subtitle, this.user, this.image});

  @override
  _LiveEventScreenState createState() => _LiveEventScreenState();
}

class _LiveEventScreenState extends State<_LiveEventScreen> {
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
            if (widget.image != null)
              _createImage(widget.image!)
            else
              Container(
                height: 200,
                color: Theme.of(context).highlightColor,
                child: const Center(child: Icon(Icons.live_tv, size: 64)),
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.title, style: Theme.of(context).textTheme.headlineSmall),
                  if (widget.subtitle != null) ...[
                    const SizedBox(height: 8),
                    Text(widget.subtitle!, style: Theme.of(context).textTheme.bodyMedium),
                  ],
                  if (widget.user != null) ...[
                    const SizedBox(height: 8),
                    Text(widget.user!, style: Theme.of(context).textTheme.bodySmall),
                  ],
                  const SizedBox(height: 16),
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

  Widget _createImage(Map<String, dynamic> image) {
    var imageUrl = image['url'] as String?;
    if (imageUrl == null) {
      return Container();
    }

    // Using ExtendedImage directly since we don't have access to TweetPhoto
    return ExtendedImage.network(imageUrl, cache: true, fit: BoxFit.cover, width: double.infinity, height: 200);
  }
}
