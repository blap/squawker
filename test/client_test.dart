import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'package:squawker/client/client.dart';
import 'package:squawker/client/client_account.dart';
import 'package:squawker/user.dart';
import 'package:squawker/generated/l10n.dart'; // Import for L10n.current.user_not_found
import 'package:dart_twitter_api/twitter_api.dart'; // Added missing import

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/material.dart';
import 'package:test_api/test_api.dart' show isA;

class FakeAbstractTwitterClient implements AbstractTwitterClient {
  http.Response mockResponse;

  FakeAbstractTwitterClient(this.mockResponse);

  @override
  Future<http.Response> get(Uri uri, {Map<String, String>? headers, Duration? timeout}) async {
    return mockResponse;
  }

  @override
  noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }

  @override
  Future<http.Response> multipartRequest(Uri uri, {Map<String, String>? headers, Duration? timeout, String? method, List<http.MultipartFile>? files}) {
    // TODO: implement multipartRequest
    throw UnimplementedError();
  }

  @override
  Future<http.Response> post(Uri uri, {Map<String, String>? headers, Duration? timeout, dynamic body, Encoding? encoding}) {
    // TODO: implement post
    throw UnimplementedError();
  }
}

class MockAbstractTwitterClient extends Mock implements AbstractTwitterClient {}

class MockUserService extends Mock implements UserService {}

class MockPaginatedUsers extends Mock implements PaginatedUsers {}

class TestTwitterApi extends TwitterApi {
  FakeAbstractTwitterClient mockClient;
  UserService? mockUserService;

  TestTwitterApi({required this.mockClient, this.mockUserService}) : super(
    client: mockClient,
  );

  @override
  AbstractTwitterClient get client => mockClient;

  @override
  UserService get userService => mockUserService!;
}


void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  L10n.delegate.load(const Locale('en'));

  group('Twitter', () {
    late FakeAbstractTwitterClient fakeClient;
    late MockUserService mockUserService;

    setUp(() {
      fakeClient = FakeAbstractTwitterClient(createMockResponse(200, '')); // Initialize with a default empty response
      mockUserService = MockUserService();
      testTwitterApi = TestTwitterApi(mockClient: fakeClient, mockUserService: mockUserService);
    });

    // Helper to mock http.Response
    http.Response createMockResponse(int statusCode, String body) {
      return http.Response(body, statusCode);
    }


    // Test cases for getProfileById
    group('getProfileById', () {
      test('should return Profile on successful retrieval', () async {
        final mockResponse = createMockResponse(200, jsonEncode({
          "data": {
            "user": {
              "result": {
                "__typename": "User",
                "rest_id": "123",
                "is_blue_verified": false,
                "legacy": {
                  "pinned_tweet_ids_str": [],
                  "screen_name": "testuser",
                  "name": "Test User"
                }
              }
            }
          }
        }));

        when(mockClient.get(any() as Uri, headers: any(), timeout: any())).thenAnswer((_) async => mockResponse);


        final twitter = Twitter(twitterApi: testTwitterApi);
        final profile = await twitter.getProfileById('123');

        expect(profile.user.idStr, '123');
        expect(profile.user.screenName, 'testuser');
        expect(profile.user.name, 'Test User');
        expect(profile.pinnedTweets, isEmpty);
      });

      test('should throw TwitterError on empty response body', () async {
        final mockResponse = createMockResponse(200, '');
        when(mockClient.get(any() as Uri, headers: any(), timeout: any())).thenAnswer((_) async => mockResponse);

        final twitter = Twitter(twitterApi: testTwitterApi);
        expectLater(() => twitter.getProfileById('123'), throwsA(isA<TwitterError>()));
      });

      test('should throw TwitterError on API error', () async {
        final mockResponse = createMockResponse(200, jsonEncode({
          "errors": [
            {"code": 123, "message": "Error message"}
          ]
        }));
        when(mockClient.get(any() as Uri, headers: any(), timeout: any())).thenAnswer((_) async => mockResponse);

        final twitter = Twitter(twitterApi: testTwitterApi);
        expectLater(() => twitter.getProfileById('123'), throwsA(isA<TwitterError>()));
      });

      test('should throw TwitterError for suspended user', () async {
        final mockResponse = createMockResponse(200, jsonEncode({
          "data": {
            "user": {
              "result": {
                "__typename": "UserUnavailable",
                "reason": "Suspended"
              }
            }
          }
        }));
        when(mockClient.get(any() as Uri, headers: any(), timeout: any())).thenAnswer((_) async => mockResponse);

        final twitter = Twitter(twitterApi: testTwitterApi);
        expectLater(() => twitter.getProfileById('123'), throwsA(isA<TwitterError>()));
      });

      test('should throw TwitterError for other UserUnavailable reasons', () async {
        final mockResponse = createMockResponse(200, jsonEncode({
          "data": {
            "user": {
              "result": {
                "__typename": "UserUnavailable",
                "reason": "Other"
              }
            }
          }
        }));
        when(mockClient.get(any() as Uri, headers: any(), timeout: any())).thenAnswer((_) async => mockResponse);

        final twitter = Twitter(twitterApi: testTwitterApi);
        expectLater(() => twitter.getProfileById('123'), throwsA(isA<TwitterError>()));
      });

      test('should throw TwitterError when result is null', () async {
        final mockResponse = createMockResponse(200, jsonEncode({
          "data": {
            "user": {
              "result": null
            }
          }
        }));
        when(mockClient.get(any() as Uri, headers: any(), timeout: any())).thenAnswer((_) async => mockResponse);

        final twitter = Twitter(twitterApi: testTwitterApi);
        expectLater(() => twitter.getProfileById('123'), throwsA(isA<TwitterError>()));
      });
    });

    group('getProfileByScreenName', () {
      test('should return Profile on successful retrieval', () async {
        final mockResponse = createMockResponse(200, jsonEncode({
          "data": {
            "user": {
              "result": {
                "__typename": "User",
                "rest_id": "123",
                "is_blue_verified": false,
                "legacy": {
                  "pinned_tweet_ids_str": [],
                  "screen_name": "testuser",
                  "name": "Test User"
                }
              }
            }
          }
        }));

        when(mockClient.get(any() as Uri, headers: any(), timeout: any())).thenAnswer((_) async => mockResponse);


        final twitter = Twitter(twitterApiAllowUnauthenticated: testTwitterApi);
        final profile = await twitter.getProfileByScreenName('testuser');

        expect(profile.user.idStr, '123');
        expect(profile.user.screenName, 'testuser');
        expect(profile.user.name, 'Test User');
        expect(profile.pinnedTweets, isEmpty);
      });

      test('should throw TwitterError on empty response body', () async {
        final mockResponse = createMockResponse(200, '');
        when(mockClient.get(any() as Uri, headers: any(), timeout: any())).thenAnswer((_) async => mockResponse);

        final twitter = Twitter(twitterApiAllowUnauthenticated: testTwitterApi);
        expectLater(() => twitter.getProfileByScreenName('testuser'), throwsA(isA<TwitterError>()));
      });

      test('should throw TwitterError on API error', () async {
        final mockResponse = createMockResponse(200, jsonEncode({
          "errors": [
            {"code": 123, "message": "Error message"}
          ]
        }));
        when(mockClient.get(any() as Uri, headers: any(), timeout: any())).thenAnswer((_) async => mockResponse);

        final twitter = Twitter(twitterApiAllowUnauthenticated: testTwitterApi);
        expectLater(() => twitter.getProfileByScreenName('testuser'), throwsA(isA<TwitterError>()));
      });

      test('should throw TwitterError for suspended user', () async {
        final mockResponse = createMockResponse(200, jsonEncode({
          "data": {
            "user": {
              "result": {
                "__typename": "UserUnavailable",
                "reason": "Suspended"
              }
            }
          }
        }));
        when(mockClient.get(any() as Uri, headers: any(), timeout: any())).thenAnswer((_) async => mockResponse);

        final twitter = Twitter(twitterApiAllowUnauthenticated: testTwitterApi);
        expectLater(() => twitter.getProfileByScreenName('testuser'), throwsA(isA<TwitterError>()));
      });

      test('should throw TwitterError for other UserUnavailable reasons', () async {
        final mockResponse = createMockResponse(200, jsonEncode({
          "data": {
            "user": {
              "result": {
                "__typename": "UserUnavailable",
                "reason": "Other"
              }
            }
          }
        }));
        when(mockClient.get(any() as Uri, headers: any(), timeout: any())).thenAnswer((_) async => mockResponse);

        final twitter = Twitter(twitterApiAllowUnauthenticated: testTwitterApi);
        expectLater(() => twitter.getProfileByScreenName('testuser'), throwsA(isA<TwitterError>()));
      });

      test('should throw TwitterError when result is null', () async {
        final mockResponse = createMockResponse(200, jsonEncode({
          "data": {
            "user": {
              "result": null
            }
          }
        }));
        when(mockClient.get(any() as Uri, headers: any(), timeout: any())).thenAnswer((_) async => mockResponse);

        final twitter = Twitter(twitterApiAllowUnauthenticated: testTwitterApi);
        expectLater(() => twitter.getProfileByScreenName('testuser'), throwsA(isA<TwitterError>()));
      });
    });

    group('getProfileFollows', () {
      late MockUserService mockUserService;

      setUp(() {
        mockUserService = MockUserService();
        testTwitterApi.mockUserService = mockUserService;
      });

      test('should return Follows on successful retrieval of followers', () async {
        // Mock the response from followersList
        final mockFollowersResponse = MockPaginatedUsers();
        when(mockFollowersResponse.users).thenReturn([
          User.fromJson({"id_str": "1", "screen_name": "user1"}),
          User.fromJson({"id_str": "2", "screen_name": "user2"}),
        ]);
        when(mockFollowersResponse.nextCursorStr).thenReturn('123');
        when(mockFollowersResponse.previousCursorStr).thenReturn('456');

        when(mockUserService.followersList(
          screenName: anyNamed('screenName'),
          cursor: anyNamed('cursor'),
          count: anyNamed('count'),
          skipStatus: anyNamed('skipStatus'),
        )).thenAnswer((_) async => mockFollowersResponse);

        final twitter = Twitter(
          twitterApiAllowUnauthenticated: testTwitterApi,
        );

        final follows = await twitter.getProfileFollows('testuser', 'followers');

        expect(follows.users.length, 2);
        expect(follows.users[0].screenName, 'user1');
        expect(follows.users[1].screenName, 'user2');
        expect(follows.cursorBottom, 123);
        expect(follows.cursorTop, 456);
      });

      test('should return Follows on successful retrieval of following', () async {
        // Mock the response from friendsList
        final mockFriendsResponse = MockPaginatedUsers();
        when(mockFriendsResponse.users).thenReturn([
          User.fromJson({"id_str": "3", "screen_name": "user3"}),
          User.fromJson({"id_str": "4", "screen_name": "user4"}),
        ]);
        when(mockFriendsResponse.nextCursorStr).thenReturn('789');
        when(mockFriendsResponse.previousCursorStr).thenReturn('012');

        when(mockUserService.friendsList(
          screenName: anyNamed('screenName'),
          cursor: anyNamed('cursor'),
          count: anyNamed('count'),
          skipStatus: anyNamed('skipStatus'),
        )).thenAnswer((_) async => mockFriendsResponse);

        final twitter = Twitter(
          twitterApiAllowUnauthenticated: testTwitterApi,
        );

        final follows = await twitter.getProfileFollows('testuser', 'following');

        expect(follows.users.length, 2);
        expect(follows.users[0].screenName, 'user3');
        expect(follows.users[1].screenName, 'user4');
        expect(follows.cursorBottom, 789);
        expect(follows.cursorTop, 12);
      });
    });
  });
}
