import 'package:flutter/material.dart';
import 'package:flutter_triple/flutter_triple.dart';
import 'package:pref/pref.dart';
import 'package:squawker/constants.dart';
import 'package:squawker/database/entities.dart';
import 'package:squawker/search/search.dart';
import 'package:squawker/subscriptions/users_model.dart';
import 'package:squawker/ui/errors.dart';
import 'package:squawker/utils/route_util.dart';
import 'package:squawker/user.dart';
import 'package:provider/provider.dart';
import 'package:squawker/generated/l10n.dart';

class SubscriptionUsers extends StatefulWidget {
  const SubscriptionUsers({super.key});

  @override
  State<SubscriptionUsers> createState() => _SubscriptionUsersState();
}

class _SubscriptionUsersState extends State<SubscriptionUsers> {
  final GlobalKey<SubscriptionUsersListState> _key = GlobalKey<SubscriptionUsersListState>();

  @override
  Widget build(BuildContext context) {
    var model = context.read<SubscriptionsModel>();

    return ScopedBuilder<SubscriptionsModel, List<Subscription>>.transition(
      store: model,
      onLoading: (_) => const Center(child: CircularProgressIndicator()),
      onError: (_, e) =>
          FullPageErrorWidget(error: e, stackTrace: null, prefix: L10n.of(context).unable_to_refresh_the_subscriptions),
      onState: (_, state) {
        if (state.isEmpty) {
          return Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: const Text('¯\\_(ツ)_/¯', style: TextStyle(fontSize: 32)),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(L10n.of(context).no_subscriptions_try_searching_or_importing_some,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Theme.of(context).hintColor,
                          )),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ElevatedButton(
                        child: Text(L10n.of(context).import_from_twitter),
                        onPressed: () => Navigator.pushNamed(context, routeSubscriptionsImport),
                      ),
                    )
                  ]));
        }

        return SubscriptionUsersList(key: _key, subscriptions: state);
      },
    );
  }
}

class SubscriptionUsersList extends StatefulWidget {
  final List<Subscription> subscriptions;

  const SubscriptionUsersList({super.key, required this.subscriptions});

  @override
  State<SubscriptionUsersList> createState() => SubscriptionUsersListState();
}

class SubscriptionUsersListState extends State<SubscriptionUsersList> {
  final List<Subscription> subLst = [];

  @override
  Widget build(BuildContext context) {
    BasePrefService prefs = PrefService.of(context);
    String subscriptionOrderCustom = prefs.get(optionSubscriptionOrderCustom);
    subLst.clear();
    if (subscriptionOrderCustom.isNotEmpty) {
      subLst.addAll(subscriptionOrderCustom.split(',').map((sn) => widget.subscriptions.firstWhere((s) => s.screenName == sn)));
    } else {
      subLst.addAll(widget.subscriptions);
    }
    return ReorderableListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: subLst.length,
        itemBuilder: (context, i) {
          var user = subLst[i];
          if (user is UserSubscription) {
            return UserTile(key: Key(user.screenName), user: user);
          }

          return ListTile(
            key: Key(user.screenName),
            dense: true,
                          leading: const SizedBox(width: 48, child: Icon(Icons.search_rounded)),
            title: Text(user.name, maxLines: 1, overflow: TextOverflow.ellipsis),
            subtitle: Text(L10n.current.search_term),
            trailing: SizedBox(
              width: 36,
              child: FollowButton(user: user),
            ),
            onTap: () {
              pushNamedRoute(context, routeSearch, SearchArguments(1, focusInputOnOpen: false, query: user.id));
            },
          );
        },
        onReorder: (oldIndex, newIndex) async {
          if (oldIndex < newIndex) {
            Subscription s = subLst.removeAt(oldIndex);
            subLst.insert(newIndex - 1, s);
          } else {
            Subscription s = subLst.removeAt(oldIndex);
            subLst.insert(newIndex, s);
          }
          await prefs.set(optionSubscriptionOrderCustom, subLst.map((s) => s.screenName).join(','));
        });
  }
}
