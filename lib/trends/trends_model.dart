import 'dart:convert';

import 'package:dart_twitter_api/twitter_api.dart';
import 'package:flutter_triple/flutter_triple.dart';
import 'package:logging/logging.dart';
import 'package:squawker/client/client.dart';
import 'package:squawker/constants.dart';
import 'package:pref/pref.dart';

class TrendLocationsModel extends Store<List<TrendLocation>> {
  late final Twitter _twitter;

  TrendLocationsModel() : super([]) {
    _twitter = Twitter();
  }

  Future<void> loadLocations() async {
    await execute(() async {
      return (await _twitter.getTrendLocations())..sort((a, b) => a.name!.compareTo(b.name!));
    });
  }
}

class TrendsModel extends Store<List<Trends>> {
  static final log = Logger('TrendsModel');
  late final Twitter _twitter;
  final UserTrendLocationModel userTrendLocationModel;

  TrendsModel(this.userTrendLocationModel) : super([]) {
    _twitter = Twitter();
    // Ensure we reload trends when the saved location changes
    userTrendLocationModel.observer(
      onState: (_) async {
        await loadTrends();
      },
    );
  }

  Future<void> loadTrends() async {
    await execute(() async {
      // Check if WOEID is null and handle gracefully
      final woeid = userTrendLocationModel.state.active.woeid;
      if (woeid == null) {
        log.severe('WOEID is null for location: ${userTrendLocationModel.state.active.name}');
        throw Exception('WOEID is null for location: ${userTrendLocationModel.state.active.name}');
      }

      log.info('Loading trends for location: ${userTrendLocationModel.state.active.name} (WOEID: $woeid)');
      return await _twitter.getTrends(woeid);
    });
  }
}

class UserTrendLocationModel extends Store<UserTrendLocations> {
  static final log = Logger('UserTrendLocationModel');
  final BasePrefService _prefs;

  UserTrendLocationModel(this._prefs) : super(UserTrendLocations());

  Future<void> loadTrendLocation() async {
    await execute(() async {
      try {
        var locationsJson = _prefs.get(optionUserTrendsLocations);
        log.info('Loading trend locations from preferences: $locationsJson');
        var locations = jsonDecode(locationsJson);
        return UserTrendLocations.fromJson(locations);
      } catch (e) {
        // If there's an error loading from preferences, return default locations
        log.warning('Error loading trend locations from preferences, using defaults: $e');
        return UserTrendLocations();
      }
    });
  }

  Future<void> save(UserTrendLocations item) async {
    await execute(() async {
      var json = item.toJson();
      log.info('Saving trend locations to preferences: $json');
      await _prefs.set(optionUserTrendsLocations, json);
      return item;
    });
  }

  Future<void> set(TrendLocation item) async {
    log.info('Setting new trend location: ${item.name} (WOEID: ${item.woeid})');
    state.addLocation(item);
    await save(state);
  }

  Future<void> remove(TrendLocation location) async {
    await execute(() async {
      log.info('Removing trend location: ${location.name} (WOEID: ${location.woeid})');
      state.removeLocation(location);
      await save(state);
      return state;
    });
  }

  Future<void> change(TrendLocation location) async {
    await execute(() async {
      log.info('Changing to trend location: ${location.name} (WOEID: ${location.woeid})');
      state.active = location;
      await save(state);
      return state;
    });
  }
}

class UserTrendLocations {
  static final TrendLocation _default = TrendLocation.fromJson({'name': 'Worldwide', 'woeid': 1});

  TrendLocation active = _default;
  List<TrendLocation> locations = [_default];

  UserTrendLocations();

  UserTrendLocations.fromJson(Map<String, dynamic> userTrendLocations) {
    active = TrendLocation.fromJson(userTrendLocations['active']);
    locations = [...userTrendLocations['locations'].map((e) => TrendLocation.fromJson(e))];
  }

  int get indexOfActive {
    int index = locations.indexWhere((e) => e.woeid == active.woeid);
    return index >= 0 ? index : 0;
  }

  void addLocation(TrendLocation location) {
    active = location;
    if (!locations.any((e) => e.woeid == location.woeid)) {
      locations.add(location);
    }
  }

  void removeLocation(TrendLocation location) {
    int index = locations.indexWhere((e) => e.woeid == location.woeid);

    //make sure list is not empty and 'worldwide' won't get removed
    if (index > 0 && locations[index].woeid != 1) {
      active = locations[index - 1];
      locations.removeAt(index);
    }
  }

  String toJson() {
    return jsonEncode({'active': active.toJson(), 'locations': locations.toJson()});
  }
}

extension Json on List<TrendLocation> {
  List<dynamic> toJson() {
    return [...map((e) => e.toJson())];
  }
}
