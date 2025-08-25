import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'package:squawker/client/client.dart';
import 'package:squawker/generated/l10n.dart'; // Import for L10n.current.user_not_found
import 'package:dart_twitter_api/twitter_api.dart'; // Added missing import

import 'package:flutter/material.dart';

class FakeAbstractTwitterClient implements AbstractTwitterClient {
  http.Response? _mockResponse;
  final Map<String, http.Response> _responseMap = {};

  FakeAbstractTwitterClient([http.Response? defaultResponse]) {
    _mockResponse = defaultResponse;
  }

  void setResponse(http.Response response) {
    _mockResponse = response;
  }

  void setResponseForUri(String uriPattern, http.Response response) {
    _responseMap[uriPattern] = response;
  }

  @override
  Future<http.Response> get(Uri uri, {Map<String, String>? headers, Duration? timeout}) async {
    // Check if we have a specific response for this URI pattern
    for (var pattern in _responseMap.keys) {
      if (uri.toString().contains(pattern)) {
        return _responseMap[pattern]!;
      }
    }
    // Return default response
    return _mockResponse ?? http.Response('', 404);
  }

  @override
  noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }

  @override
  Future<http.Response> multipartRequest(
    Uri uri, {
    Map<String, String>? headers,
    Duration? timeout,
    String? method,
    List<http.MultipartFile>? files,
  }) async {
    // Check if we have a specific response for this URI pattern
    for (var pattern in _responseMap.keys) {
      if (uri.toString().contains(pattern)) {
        return _responseMap[pattern]!;
      }
    }
    // Return default response
    return _mockResponse ?? http.Response('', 404);
  }

  @override
  Future<http.Response> post(
    Uri uri, {
    Map<String, String>? headers,
    Duration? timeout,
    dynamic body,
    Encoding? encoding,
  }) async {
    // Check if we have a specific response for this URI pattern
    for (var pattern in _responseMap.keys) {
      if (uri.toString().contains(pattern)) {
        return _responseMap[pattern]!;
      }
    }
    // Return default response
    return _mockResponse ?? http.Response('', 404);
  }
}

class MockAbstractTwitterClient extends Mock implements AbstractTwitterClient {}

class MockUserService extends Mock implements UserService {}

class MockPaginatedUsers extends Mock implements PaginatedUsers {}

class TestTwitterApi extends TwitterApi {
  FakeAbstractTwitterClient mockClient;
  UserService? mockUserService;

  TestTwitterApi({required this.mockClient, this.mockUserService}) : super(client: mockClient);

  @override
  AbstractTwitterClient get client => mockClient;

  @override
  UserService get userService => mockUserService!;
}

// Helper to mock http.Response
http.Response createMockResponse(int statusCode, String body) {
  return http.Response(body, statusCode);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  L10n.delegate.load(const Locale('en'));

  group('Twitter', () {
    late FakeAbstractTwitterClient fakeClient;
    late MockUserService mockUserService;
    late TestTwitterApi testTwitterApi;

    setUp(() {
      fakeClient = FakeAbstractTwitterClient(createMockResponse(200, '')); // Initialize with a default empty response
      mockUserService = MockUserService();
      testTwitterApi = TestTwitterApi(mockClient: fakeClient, mockUserService: mockUserService);
    });

    // Test cases for getProfileById
    group('getProfileById', () {
      test('should return Profile on successful retrieval', () async {
        final mockResponse = createMockResponse(
          200,
          jsonEncode({
            "data": {
              "user": {
                "result": {
                  "__typename": "User",
                  "rest_id": "123",
                  "is_blue_verified": false,
                  "legacy": {"pinned_tweet_ids_str": [], "screen_name": "testuser", "name": "Test User"},
                },
              },
            },
          }),
        );

        fakeClient.setResponse(mockResponse);

        final twitter = Twitter(twitterApi: testTwitterApi);
        final profile = await twitter.getProfileById('123');

        expect(profile.user.idStr, '123');
        expect(profile.user.screenName, 'testuser');
        expect(profile.user.name, 'Test User');
        expect(profile.pinnedTweets, isEmpty);
      });

      test('should throw TwitterError on empty response body', () async {
        final mockResponse = createMockResponse(200, '');
        fakeClient.setResponse(mockResponse);

        final twitter = Twitter(twitterApi: testTwitterApi);
        expectLater(() => twitter.getProfileById('123'), throwsA(isA<TwitterError>()));
      });

      test('should throw TwitterError on API error', () async {
        final mockResponse = createMockResponse(
          200,
          jsonEncode({
            "errors": [
              {"code": 123, "message": "Error message"},
            ],
          }),
        );
        fakeClient.setResponse(mockResponse);

        final twitter = Twitter(twitterApi: testTwitterApi);
        expectLater(() => twitter.getProfileById('123'), throwsA(isA<TwitterError>()));
      });

      test('should throw TwitterError for suspended user', () async {
        final mockResponse = createMockResponse(
          200,
          jsonEncode({
            "data": {
              "user": {
                "result": {"__typename": "UserUnavailable", "reason": "Suspended"},
              },
            },
          }),
        );
        fakeClient.setResponse(mockResponse);

        final twitter = Twitter(twitterApi: testTwitterApi);
        expectLater(() => twitter.getProfileById('123'), throwsA(isA<TwitterError>()));
      });

      test('should throw TwitterError for other UserUnavailable reasons', () async {
        final mockResponse = createMockResponse(
          200,
          jsonEncode({
            "data": {
              "user": {
                "result": {"__typename": "UserUnavailable", "reason": "Other"},
              },
            },
          }),
        );
        fakeClient.setResponse(mockResponse);

        final twitter = Twitter(twitterApi: testTwitterApi);
        expectLater(() => twitter.getProfileById('123'), throwsA(isA<TwitterError>()));
      });

      test('should throw TwitterError when result is null', () async {
        final mockResponse = createMockResponse(
          200,
          jsonEncode({
            "data": {
              "user": {"result": null},
            },
          }),
        );
        fakeClient.setResponse(mockResponse);

        final twitter = Twitter(twitterApi: testTwitterApi);
        expectLater(() => twitter.getProfileById('123'), throwsA(isA<TwitterError>()));
      });
    });

    group('getProfileByScreenName', () {
      test('should return Profile on successful retrieval', () async {
        final mockResponse = createMockResponse(
          200,
          jsonEncode({
            "data": {
              "user": {
                "result": {
                  "__typename": "User",
                  "rest_id": "123",
                  "is_blue_verified": false,
                  "legacy": {"pinned_tweet_ids_str": [], "screen_name": "testuser", "name": "Test User"},
                },
              },
            },
          }),
        );

        fakeClient.setResponse(mockResponse);

        final twitter = Twitter(twitterApiAllowUnauthenticated: testTwitterApi);
        final profile = await twitter.getProfileByScreenName('testuser');

        expect(profile.user.idStr, '123');
        expect(profile.user.screenName, 'testuser');
        expect(profile.user.name, 'Test User');
        expect(profile.pinnedTweets, isEmpty);
      });

      test('should throw TwitterError on empty response body', () async {
        final mockResponse = createMockResponse(200, '');
        fakeClient.setResponse(mockResponse);

        final twitter = Twitter(twitterApiAllowUnauthenticated: testTwitterApi);
        expectLater(() => twitter.getProfileByScreenName('testuser'), throwsA(isA<TwitterError>()));
      });

      test('should throw TwitterError on API error', () async {
        final mockResponse = createMockResponse(
          200,
          jsonEncode({
            "errors": [
              {"code": 123, "message": "Error message"},
            ],
          }),
        );
        fakeClient.setResponse(mockResponse);

        final twitter = Twitter(twitterApiAllowUnauthenticated: testTwitterApi);
        expectLater(() => twitter.getProfileByScreenName('testuser'), throwsA(isA<TwitterError>()));
      });

      test('should throw TwitterError for suspended user', () async {
        final mockResponse = createMockResponse(
          200,
          jsonEncode({
            "data": {
              "user": {
                "result": {"__typename": "UserUnavailable", "reason": "Suspended"},
              },
            },
          }),
        );
        fakeClient.setResponse(mockResponse);

        final twitter = Twitter(twitterApiAllowUnauthenticated: testTwitterApi);
        expectLater(() => twitter.getProfileByScreenName('testuser'), throwsA(isA<TwitterError>()));
      });

      test('should throw TwitterError for other UserUnavailable reasons', () async {
        final mockResponse = createMockResponse(
          200,
          jsonEncode({
            "data": {
              "user": {
                "result": {"__typename": "UserUnavailable", "reason": "Other"},
              },
            },
          }),
        );
        fakeClient.setResponse(mockResponse);

        final twitter = Twitter(twitterApiAllowUnauthenticated: testTwitterApi);
        expectLater(() => twitter.getProfileByScreenName('testuser'), throwsA(isA<TwitterError>()));
      });

      test('should throw TwitterError when result is null', () async {
        final mockResponse = createMockResponse(
          200,
          jsonEncode({
            "data": {
              "user": {"result": null},
            },
          }),
        );
        fakeClient.setResponse(mockResponse);

        final twitter = Twitter(twitterApiAllowUnauthenticated: testTwitterApi);
        expectLater(() => twitter.getProfileByScreenName('testuser'), throwsA(isA<TwitterError>()));
      });
    });
  });
}
