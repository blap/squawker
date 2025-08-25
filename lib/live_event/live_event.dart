class LiveEventScreenArguments {
  final String url;
  final String title;
  final String? subtitle;
  final String? user;
  final Map<String, dynamic>? image;

  LiveEventScreenArguments({required this.url, required this.title, this.subtitle, this.user, this.image});

  @override
  String toString() {
    return 'LiveEventScreenArguments{url: $url, title: $title, subtitle: $subtitle, user: $user}';
  }
}

class BroadcastScreenArguments {
  final String url;
  final String title;
  final String? username;
  final String? broadcastKey;
  final Map<String, dynamic>? image;
  final double? width;
  final double? height;

  BroadcastScreenArguments({
    required this.url,
    required this.title,
    this.username,
    this.broadcastKey,
    this.image,
    this.width,
    this.height,
  });

  @override
  String toString() {
    return 'BroadcastScreenArguments{url: $url, title: $title, username: $username, broadcastKey: $broadcastKey}';
  }
}
