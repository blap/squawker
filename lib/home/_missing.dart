import 'package:flutter/material.dart';
import 'package:squawker/constants.dart';
import 'package:squawker/generated/l10n.dart';
import 'package:squawker/home/home_screen.dart';
import 'package:squawker/ui/errors.dart';

class MissingScreen extends StatelessWidget {
  const MissingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: createCommonAppBarActions(context),
      ),
      body: EmojiErrorWidget(
        emoji: '🧨',
        message: L10n.current.missing_page,
        errorMessage: L10n.current.two_home_pages_required,
        retryText: L10n.current.choose_pages,
        onRetry: () => Navigator.pushNamed(context, routeSettingsHome),
        showBackButton: false,
      ),
    );
  }
}
