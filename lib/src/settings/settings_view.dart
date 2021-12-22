import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'settings_controller.dart';

/// Displays the various settings that can be customized by the user.
///
/// When a user changes a setting, the SettingsController is updated and
/// Widgets that listen to the SettingsController are rebuilt.
class SettingsView extends StatelessWidget {
  const SettingsView({Key? key, required this.controller}) : super(key: key);

  static const routeName = '/settings';

  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.settingsTitle),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        // Glue the SettingsController to the theme selection DropdownButton.
        //
        // When a user selects a theme from the dropdown list, the
        // SettingsController is updated, which rebuilds the MaterialApp.
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              localizations.settingsAppearanceLabel,
              style: TextStyle(
                fontSize: Theme.of(context).textTheme.subtitle1!.fontSize,
              ),
            ),
            DropdownButton<ThemeMode>(
              // Read the selected themeMode from the controller
              value: controller.themeMode,
              // Call the updateThemeMode method any time the user selects a theme.
              onChanged: controller.updateThemeMode,
              items: [
                DropdownMenuItem(
                  value: ThemeMode.system,
                  child: Text(localizations.themeSystem),
                ),
                DropdownMenuItem(
                  value: ThemeMode.light,
                  child: Text(localizations.themeLight),
                ),
                DropdownMenuItem(
                  value: ThemeMode.dark,
                  child: Text(localizations.themeDark),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
