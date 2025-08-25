import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
// import 'package:system_theme/system_theme.dart';

class AccentUtil {
  static final log = Logger('AccentUtil');

  // static SystemAccentColor? currentAccentColor;
  static FlexSchemeColor? lightAccentColors;
  static FlexSchemeColor? darkAccentColors;

  static Future<void> load() async {
    // if (defaultTargetPlatform.supportsAccentColor) {
    //   await SystemTheme.accentColor.load();
    //   currentAccentColor = SystemTheme.accentColor;
    //   setupFlexColors(currentAccentColor!.accent);
    //   log.info('System accent color is $currentAccentColor.');
    //   SystemTheme.onChange.listen((SystemAccentColor event) {
    //     log.info('System accent color changed to ${event.accent}.');
    //     currentAccentColor = event;
    //     setupFlexColors(currentAccentColor!.accent);
    //   });
    // }
    // else {
    log.info('Accent color not support by system.');
    // }
  }

  static void setupFlexColors(Color accentColor) {
    lightAccentColors = FlexSchemeColor.from(primary: accentColor, brightness: Brightness.light);
    darkAccentColors = FlexSchemeColor.from(primary: accentColor, brightness: Brightness.dark);
  }
}
