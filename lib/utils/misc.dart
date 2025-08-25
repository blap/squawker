import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:squawker/client/app_http_client.dart';

const androidChannel = MethodChannel('squawker/android_info');

List<String>? _supportedTextActivityList;

const _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
Random _rnd = Random();

String getRandomString(int length) =>
    String.fromCharCodes(Iterable.generate(length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

String? cachedPublicIp;
String? _cachedSystemLocale;

// reference: https://stackoverflow.com/questions/60180934/how-to-get-public-ip-in-flutter
Future<String?> getPublicIP() async {
  try {
    if (cachedPublicIp != null) {
      return cachedPublicIp;
    }
    var url = Uri.parse('https://api.ipify.org');
    var response = await AppHttpClient.httpGet(url);
    if (response.statusCode == 200) {
      // The response body is the IP in plain text, so just
      // return it as-is.
      cachedPublicIp = response.body;
      return cachedPublicIp;
    } else {
      // The request failed with a non-200 code
      // The ipify.org API has a lot of guaranteed uptime
      // promises, so this shouldn't ever actually happen.
      debugPrint('getPublicIP failed with status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');
      return null;
    }
  } catch (e) {
    // Request failed due to an error, most likely because
    // the phone isn't connected to the internet.
    debugPrint('getPublicIP error: $e');
    return null;
  }
}

// values used: dev, github, fdroid, play
String getFlavor() {
  const flavor = String.fromEnvironment('app.flavor');

  if (flavor == '') {
    return 'dev';
  }

  return flavor;
}

bool findInJSONArray(List arr, String key, String value) {
  for (var item in arr) {
    if (item[key] == value) {
      return true;
    }
  }
  return false;
}

bool isTranslatable(String? lang, String? text) {
  if (lang == null || lang == 'und') {
    return false;
  }

  if (lang != getShortSystemLocale()) {
    return true;
  }

  return false;
}

String getShortSystemLocale() {
  // Cache the system locale to avoid repeated computations
  if (_cachedSystemLocale != null) {
    return _cachedSystemLocale!;
  }

  _cachedSystemLocale = Platform.localeName.split("_")[0];
  return _cachedSystemLocale!;
}

Future<List<String>> getSupportedTextActivityList() async {
  if (!Platform.isAndroid) {
    return [];
  }
  if (_supportedTextActivityList != null) {
    return _supportedTextActivityList!;
  }
  _supportedTextActivityList = (await androidChannel.invokeMethod('supportedTextActivityList') as List<Object?>)
      .map((e) => e.toString())
      .toList();
  /*
  debugPrint('*** supported text activities:');
  _supportedTextActivityList!.forEach((e) { debugPrint('***   $e'); });
  */
  return _supportedTextActivityList!;
}

Future<String?> processTextActivity(int index, String value, bool readonly) async {
  if (!Platform.isAndroid) {
    return null;
  }
  String? newValue =
      await androidChannel.invokeMethod('processTextActivity', {'id': index, 'value': value, 'readonly': readonly})
          as String?;
  return newValue;
}

Future requestPostNotificationsPermissions(AsyncCallback callback) async {
  if (!Platform.isAndroid) {
    callback();
    return;
  }
  androidChannel.setMethodCallHandler((MethodCall call) async {
    if (call.method == 'requestPostNotificationsPermissionsCallback') {
      bool granted = call.arguments;
      if (granted) {
        callback();
      }
    }
    return true;
  });
  await androidChannel.invokeMethod('requestPostNotificationsPermissions');
}
