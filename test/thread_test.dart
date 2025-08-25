import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:squawker/client/client.dart';
import 'package:squawker/generated/l10n.dart';
import 'package:flutter/widgets.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  L10n.delegate.load(const Locale('en'));
  testWidgets('Converting a list of tweets and replies to a list of threads', (WidgetTester tester) async {
    final twitter = Twitter();
    var content = jsonDecode(File('test/tweets-carmack-replies.json').readAsStringSync());

    var tweets = twitter.createUnconversationedChains(content, 'tweet', 'homeConversation', ['1296180686215417856'], true);

    // Ensure we have the previous and next page cursors
    expect(tweets.cursorBottom, equals('HBaMgL2dt42W+SYAAA=='));
    expect(tweets.cursorTop, equals('HCaAgICkv9/9/SYAAA=='));

    expect(tweets.chains.length, equals(13));
  });

  testWidgets('Converting a list of tweets to a list of threads', (WidgetTester tester) async {
    final twitter = Twitter();
    var content = jsonDecode(File('test/tweets-carmack.json').readAsStringSync());

    var tweets = twitter.createUnconversationedChains(content, 'tweet', 'homeConversation', ['1296180686215417856'], true);

    // Ensure we have the previous and next page cursors
    expect(tweets.cursorBottom, equals('HBaEwLDBmpX46yYAAA=='));
    expect(tweets.cursorTop, equals('HCaAgIDkneTC+SYAAA=='));

    expect(tweets.chains.length, equals(17));
  });
}