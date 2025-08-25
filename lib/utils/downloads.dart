import 'dart:io';
import 'dart:typed_data';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:media_scanner/media_scanner.dart';
import 'package:squawker/client/app_http_client.dart';
import 'package:squawker/constants.dart';
import 'package:squawker/generated/l10n.dart';
import 'package:squawker/ui/errors.dart';
import 'package:path/path.dart' as p;
import 'package:permission_handler/permission_handler.dart';
import 'package:pref/pref.dart';

Future<void> downloadUriToPickedFile(
  BuildContext context,
  Uri uri,
  String fileName, {
  required Function() onStart,
  required Function() onSuccess,
}) async {
  var sanitizedFilename = fileName.split("?")[0];

  try {
    onStart();
    Future<Uint8List?> responseTask = downloadFile(context, uri);

    DeviceInfoPlugin plugin = DeviceInfoPlugin();
    AndroidDeviceInfo android = await plugin.androidInfo;
    var storagePermission = android.version.sdkInt < 30
        ? await Permission.storage.request()
        : await Permission.manageExternalStorage.request();

    // Check if context is still mounted after async operations
    if (!context.mounted) return;

    var response = await responseTask;
    if (response == null) {
      return;
    }

    // Check if context is still mounted before accessing PrefService
    if (!context.mounted) return;

    final downloadType = PrefService.of(context).get(optionDownloadType);
    final downloadPath = PrefService.of(context).get(optionDownloadPath);

    // If the user wants to pick a file every time a download happens
    if (downloadType == optionDownloadTypeAsk || downloadPath == '') {
      // Check if context is still mounted before showing dialog
      if (!context.mounted) return;

      var fileInfo = await FlutterFileDialog.saveFile(
        params: SaveFileDialogParams(fileName: sanitizedFilename, data: response),
      );

      // Check if context is still mounted after async operation
      if (!context.mounted) return;

      if (fileInfo == null) {
        return;
      }

      onSuccess();
      return;
    }

    // Otherwise, check we have the storage permission
    if (!storagePermission.isGranted) {
      // Check if context is still mounted before showing snackbar
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(L10n.current.permission_not_granted),
          action: SnackBarAction(label: L10n.current.open_app_settings, onPressed: openAppSettings),
        ),
      );

      // Check if context is still mounted before opening settings
      if (!context.mounted) return;

      await openAppSettings();
      return;
    }

    // Finally, save to the user-defined directory
    var savedFile = p.join(downloadPath, sanitizedFilename);
    await File(savedFile).writeAsBytes(response);
    if (Platform.isAndroid) {
      MediaScanner.loadMedia(path: savedFile);
    }

    // Check if context is still mounted before calling onSuccess
    if (!context.mounted) return;

    onSuccess();
  } catch (e) {
    // Check if context is still mounted before showing snackbar
    if (!context.mounted) return;

    showSnackBar(context, icon: '🙊', message: e.toString());
  }
}

class UnableToSaveMedia {
  final Uri uri;
  final Object e;

  UnableToSaveMedia(this.uri, this.e);

  @override
  String toString() {
    return 'Unable to save the media {uri: $uri, e: $e}';
  }
}

Future<Uint8List?> downloadFile(BuildContext context, Uri uri) async {
  var response = await AppHttpClient.httpGet(uri);
  if (response.statusCode == 200) {
    return response.bodyBytes;
  }

  // Check if context is still mounted before showing snackbar
  if (!context.mounted) return null;

  ScaffoldMessenger.of(context).clearSnackBars();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        L10n.of(context).unable_to_save_the_media_twitter_returned_a_status_of_response_statusCode(response.statusCode),
      ),
    ),
  );

  return null;
}
