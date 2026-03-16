import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:squawker/client/client.dart';

void main() {
  testWidgets('Converting a list of tweets and replies to a list of threads', (WidgetTester tester) async {
    var content = jsonDecode(File('test/tweets-carmack-replies.json').readAsStringSync());

    var tweets = Twitter.createUnconversationedChains(content, 'tweet', 'homeConversation', ['1296180686215417856'], true);

    // Ensure we have the previous and next page cursors
    expect(tweets.cursorBottom, equals('HBaMgL2dt42W+SYAAA=='));
    expect(tweets.cursorTop, equals('HCaAgICkv9/9/SYAAA=='));

    expect(tweets.chains.length, equals(9));

    // TODO: Quoted tweets, cards

    expect(tweets.chains[0].isPinned, equals(true));
    expect(tweets.chains[0].id, equals('1296180686215417856'));
    expect(tweets.chains[0].tweets.length, equals(1));
    expect(tweets.chains[0].tweets[0].fullText, contains('I still feel pretty good'));
    expect(tweets.chains[0].tweets[0].idStr, contains('1296180686215417856'));
  });

  testWidgets('Converting a list of tweets to a list of threads', (WidgetTester tester) async {
    var content = jsonDecode(File('test/tweets-carmack.json').readAsStringSync());

    var tweets = Twitter.createUnconversationedChains(content, 'tweet', 'homeConversation', ['1296180686215417856'], true);

    expect(tweets.cursorBottom, equals('HBaEwLDBmpX46yYAAA=='));
    expect(tweets.cursorTop, equals('HCaAgIDkneTC+SYAAA=='));

    expect(tweets.chains.length, equals(14));

    expect(tweets.chains[0].isPinned, equals(true));
    expect(tweets.chains[0].id, equals('1296180686215417856'));
    expect(tweets.chains[0].tweets.length, equals(1));
    expect(tweets.chains[0].tweets[0].fullText, contains('I still feel pretty good'));
    expect(tweets.chains[0].tweets[0].idStr, contains('1296180686215417856'));
  });
}
