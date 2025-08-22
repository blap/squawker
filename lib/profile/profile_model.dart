import 'package:flutter_triple/flutter_triple.dart';
import 'package:squawker/client/client.dart';
import 'package:squawker/user.dart';

class Profile {
  final UserWithExtra user;
  final List<String> pinnedTweets;

  Profile(this.user, this.pinnedTweets);
}

class ProfileModel extends Store<Profile> {
  late final Twitter _twitter;

  ProfileModel() : super(Profile(UserWithExtra(), [])) {
    _twitter = Twitter();
  }

  Future<void> loadProfileById(String id) async {
    await execute(() async => await _twitter.getProfileById(id));
  }

  Future<void> loadProfileByScreenName(String screenName) async {
    await execute(() async => await _twitter.getProfileByScreenName(screenName));
  }
}
