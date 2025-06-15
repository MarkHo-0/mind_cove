import 'package:flutter/material.dart';
import 'package:mind_cove/l10n/generated/app_localizations.dart';
import 'package:mind_cove/views/_share/styles/padding.dart';
import 'package:provider/provider.dart';

import '../../providers/settings.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> with AutomaticKeepAliveClientMixin<SettingsView> {
  @override
  Widget build(BuildContext context) {
    super.build(context);

    final settings = context.watch<SettingsProvider>();

    return Padding(
      padding: pagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Text(
              AppLocalizations.of(context)!.default_username,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),

          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.book),
            title: Text(AppLocalizations.of(context)!.language),
            trailing: DropdownMenu(
              dropdownMenuEntries: AppLocalizations.supportedLocales.map((locale) {
                return DropdownMenuEntry(value: locale.languageCode, label: locale.toString());
              }).toList(),
              onSelected: (value) => settings.setLanguage(value!),
              initialSelection: settings.languageCode,
              inputDecorationTheme: InputDecorationTheme(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
                constraints: BoxConstraints.tight(const Size.fromHeight(40)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.light_mode),
            title: Text(AppLocalizations.of(context)!.theme),
            trailing: DropdownMenu(
              dropdownMenuEntries: [
                DropdownMenuEntry(value: null, label: AppLocalizations.of(context)!.theme_system),
                DropdownMenuEntry(value: Brightness.light, label: AppLocalizations.of(context)!.theme_light),
                DropdownMenuEntry(value: Brightness.dark, label: AppLocalizations.of(context)!.theme_black),
              ],
              onSelected: (value) => settings.setBrightness(value),
              initialSelection: settings.brightness,
              inputDecorationTheme: InputDecorationTheme(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
                constraints: BoxConstraints.tight(const Size.fromHeight(40)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.notifications),
            title: Text(AppLocalizations.of(context)!.notify_me),
            trailing: Switch(
              value: false,
              onChanged: (value) {
                // Implement notification toggle logic here
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
