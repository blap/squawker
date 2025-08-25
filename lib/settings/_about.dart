import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:squawker/generated/l10n.dart';
import 'package:squawker/utils/misc.dart';
import 'package:squawker/utils/urls.dart';
import 'package:pref/pref.dart';

class SettingsAboutFragment extends StatelessWidget {
  final String appVersion;

  const SettingsAboutFragment({super.key, required this.appVersion});

  Future<void> _appInfo(BuildContext context) async {
    // Capture the locale before async operations
    final localeCode = Localizations.localeOf(context).languageCode;

    var deviceInfo = DeviceInfoPlugin();
    var packageInfo = await PackageInfo.fromPlatform();
    Map<String, Object> metadata;

    if (Platform.isAndroid) {
      var info = await deviceInfo.androidInfo;

      metadata = {
        'abis': info.supportedAbis,
        'device': info.device,
        'flavor': getFlavor(),
        'locale': localeCode, // Use captured value
        'os': 'android',
        'system': info.version.sdkInt.toString(),
        'version': packageInfo.buildNumber,
      };
    } else {
      var info = await deviceInfo.iosInfo;

      metadata = {
        'abis': [],
        'device': info.utsname.machine,
        'flavor': getFlavor(),
        'locale': localeCode, // Use captured value
        'os': 'ios',
        'system': info.systemVersion,
        'version': packageInfo.buildNumber,
      };
    }

    // Check if context is still mounted before showing dialog
    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (context) {
        // Check if context is still mounted before using it
        if (!context.mounted) return const AlertDialog();

        var content = JsonEncoder.withIndent(' ' * 2).convert(metadata);
        final l10n = L10n.of(context);

        return AlertDialog(
          actions: [
            TextButton(
              onPressed: () {
                // Check if context is still mounted before using it
                if (!context.mounted) return;
                Navigator.pop(context);
              },
              child: Text(l10n.ok),
            ), // Use captured l10n
          ],
          title: Text(l10n.app_info), // Use captured l10n
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Text(content, style: const TextStyle(fontFamily: 'monospace')),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(L10n.current.about)),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: ListView(
          children: [
            InkWell(
              child: PrefLabel(
                leading: const Icon(Icons.info),
                title: Text(L10n.of(context).version),
                subtitle: Text(appVersion),
              ),
              onLongPress: () async {
                await Clipboard.setData(ClipboardData(text: appVersion));

                // Check if context is still mounted before using it
                if (!context.mounted) return;

                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(L10n.of(context).copied_version_to_clipboard)));
              },
              onTap: () => _appInfo(context),
            ),
            PrefLabel(
              leading: const Icon(Icons.favorite),
              title: Text(L10n.of(context).contribute),
              subtitle: Text(L10n.of(context).help_make_fritter_even_better),
              onTap: () => openUri('https://github.com/j-fbriere/squawker'),
            ),
            PrefLabel(
              leading: const Icon(Icons.bug_report),
              title: Text(L10n.of(context).report_a_bug),
              subtitle: Text(L10n.of(context).let_the_developers_know_if_something_is_broken),
              onTap: () => openUri('https://github.com/j-fbriere/squawker/issues'),
            ),
            PrefLabel(
              leading: const Icon(Icons.copyright),
              title: Text(L10n.of(context).licenses),
              subtitle: Text(L10n.of(context).all_the_great_software_used_by_fritter),
              onTap: () {
                // Check if context is still mounted before using it
                if (!context.mounted) return;

                final l10n = L10n.of(context);

                showLicensePage(
                  context: context,
                  applicationName: l10n.fritter, // Use captured l10n
                  applicationVersion: appVersion,
                  applicationLegalese: l10n.released_under_the_mit_license, // Use captured l10n
                  applicationIcon: Container(
                    margin: const EdgeInsets.all(12),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(48.0),
                      child: Image.asset('assets/icon.png', height: 48.0, width: 48.0),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
