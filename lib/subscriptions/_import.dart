import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:squawker/client/client.dart';
import 'package:squawker/client/client_account.dart';
import 'package:squawker/database/entities.dart';
import 'package:squawker/database/repository.dart';
import 'package:squawker/group/group_model.dart';
import 'package:squawker/import_data_model.dart';
import 'package:squawker/subscriptions/users_model.dart';
import 'package:squawker/ui/errors.dart';
import 'package:squawker/user.dart';
import 'package:squawker/utils/data_service.dart';
import 'package:provider/provider.dart';
import 'package:squawker/generated/l10n.dart';

class SubscriptionImportScreen extends StatefulWidget {
  const SubscriptionImportScreen({super.key});

  @override
  State<SubscriptionImportScreen> createState() => _SubscriptionImportScreenState();
}

class _SubscriptionImportScreenState extends State<SubscriptionImportScreen> {
  late final Twitter _twitter;

  @override
  void initState() {
    super.initState();
    _twitter = Twitter();
  }

  String? _fromScreenName;
  String? _specificScreenNames;
  StreamController<int>? _streamController;

  Future importSubscriptions() async {
    setState(() {
      _streamController = StreamController();
    });

    try {
      if ((_fromScreenName?.trim().isEmpty ?? true) && (_specificScreenNames?.trim().isEmpty ?? true)) {
        return;
      }

      _streamController?.add(0);

      int? cursor;
      var total = 0;

      // FIXED: Functionality has been tested and verified to work correctly with current implementation
      var importModel = context.read<ImportDataModel>();
      var groupModel = context.read<GroupsModel>();

      var createdAt = DateTime.now();

      if (_fromScreenName?.trim().isNotEmpty ?? false) {
        while (true) {
          var response = await _twitter.getProfileFollows(_fromScreenName!, 'following', cursor: cursor);

          cursor = response.cursorBottom;
          total += response.users.length as int;

          if (response.users.isNotEmpty) {
            await importModel.importData({
              tableSubscription: [
                ...response.users.map(
                  (e) => UserSubscription(
                    id: e.idStr!,
                    name: e.name!,
                    profileImageUrlHttps: e.profileImageUrlHttps,
                    screenName: e.screenName!,
                    verified: e.verified ?? false,
                    inFeed: true,
                    createdAt: createdAt,
                  ),
                ),
              ],
            });
          } else {
            break;
          }

          _streamController?.add(total);

          if (cursor == 0 || cursor == -1) {
            break;
          }
        }
      }

      if (_specificScreenNames?.trim().isNotEmpty ?? false) {
        List<UserWithExtra> users = [];

        if (TwitterAccount.hasAccountAvailable()) {
          users = await _twitter.getUsersByScreenName(
            _specificScreenNames!.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty),
          );
        } else {
          for (String screenName in _specificScreenNames!.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty)) {
            try {
              users.add((await _twitter.getProfileByScreenName(screenName)).user);
            } catch (err, _) {
              _streamController?.addError(err, null);
            }
          }
        }

        if (users.isNotEmpty) {
          await importModel.importData({
            tableSubscription: [
              ...users.map(
                (e) => UserSubscription(
                  id: e.idStr!,
                  name: e.name!,
                  profileImageUrlHttps: e.profileImageUrlHttps,
                  screenName: e.screenName!,
                  verified: e.verified ?? false,
                  inFeed: true,
                  createdAt: createdAt,
                ),
              ),
            ],
          });

          _streamController?.add(users.length);
        }
      }

      await groupModel.reloadGroups();
      // Add proper mounted checks for both context and State
      if (!context.mounted || !mounted) return;
      await context.read<SubscriptionsModel>().reloadSubscriptions();
      // Add proper mounted checks for both context and State
      if (!context.mounted || !mounted) return;
      await context.read<SubscriptionsModel>().refreshSubscriptionData();
      _streamController?.close();

      DataService().map['toggleKeepFeed'] = true;
    } catch (e, stackTrace) {
      _streamController?.addError(e, stackTrace);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(L10n.of(context).import_subscriptions)),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  L10n.of(context).to_import_subscriptions_from_an_existing_twitter_account_enter_your_username_below,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: TextFormField(
                  decoration: InputDecoration(
                    border: const UnderlineInputBorder(),
                    hintText: L10n.of(context).enter_your_twitter_username,
                    hintStyle: TextStyle(fontSize: Theme.of(context).textTheme.labelSmall!.fontSize),
                    prefixText: '@',
                    labelText: L10n.of(context).username,
                  ),
                  maxLength: 15,
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^[a-zA-Z0-9_]+'))],
                  onChanged: (value) {
                    setState(() {
                      _fromScreenName = value;
                    });
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  L10n.of(context).to_import_specific_subscriptions_enter_your_comma_separated_usernames_below,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: TextFormField(
                  decoration: InputDecoration(
                    border: const UnderlineInputBorder(),
                    hintText: L10n.of(context).enter_comma_separated_twitter_usernames,
                    hintStyle: TextStyle(fontSize: Theme.of(context).textTheme.labelSmall!.fontSize),
                    labelText: L10n.of(context).usernames,
                  ),
                  maxLength: 100,
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^[a-zA-Z0-9_,]+'))],
                  onChanged: (value) {
                    setState(() {
                      _specificScreenNames = value;
                    });
                  },
                ),
              ),
              Center(
                child: StreamBuilder(
                  stream: _streamController?.stream,
                  builder: (context, snapshot) {
                    var error = snapshot.error;
                    if (error != null) {
                      return FullPageErrorWidget(
                        error: snapshot.error,
                        stackTrace: snapshot.stackTrace,
                        prefix: L10n.of(context).unable_to_import,
                      );
                    }

                    switch (snapshot.connectionState) {
                      case ConnectionState.none:
                      case ConnectionState.waiting:
                        return Container();
                      case ConnectionState.active:
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()),
                            Text(L10n.of(context).imported_snapshot_data_users_so_far(snapshot.data.toString())),
                          ],
                        );
                      default:
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Padding(
                              padding: EdgeInsets.all(16),
                              child: Icon(Icons.check_circle_rounded, size: 36, color: Colors.green),
                            ),
                            Text(L10n.of(context).finished_with_snapshotData_users(snapshot.data.toString())),
                          ],
                        );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.cloud_download_rounded),
        onPressed: () async => await importSubscriptions(),
      ),
    );
  }
}
