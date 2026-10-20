import 'package:material_ui/material_ui.dart';
import 'package:mind_cove/l10n/generated/app_localizations.dart';
import 'package:mind_cove/views/_share/styles/padding.dart';
import 'package:provider/provider.dart';

import '../../providers/settings.dart';
import 'edit_username_popup.dart';

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
    final localizations = AppLocalizations.of(context)!;
    final username = settings.get(AppSettings.username).isEmpty
        ? localizations.default_username
        : settings.get(AppSettings.username);

    return Padding(
      padding: pagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: InkWell(
              onTap: () => showDialog<String>(
                context: context,
                builder: (context) => EditUsernamePopup(
                  currentUsername: username,
                  onSubmit: (newUsername) => settings.set(AppSettings.username, newUsername),
                ),
              ),
              borderRadius: BorderRadius.circular(4),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Text(username, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              ),
            ),
          ),

          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.book),
            title: Text(localizations.language),
            trailing: DropdownMenu(
              dropdownMenuEntries: AppLocalizations.supportedLocales.map((locale) {
                return DropdownMenuEntry(value: locale.languageCode, label: locale.toString());
              }).toList(),
              onSelected: (value) => settings.set(AppSettings.languageCode, value!),
              initialSelection: settings.get(AppSettings.languageCode),
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
            title: Text(localizations.theme),
            trailing: DropdownMenu(
              dropdownMenuEntries: [
                DropdownMenuEntry(value: null, label: localizations.theme_system),
                DropdownMenuEntry(value: Brightness.light, label: localizations.theme_light),
                DropdownMenuEntry(value: Brightness.dark, label: localizations.theme_black),
              ],
              onSelected: (value) => settings.set(AppSettings.brightness, value),
              initialSelection: settings.get(AppSettings.brightness),
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
            title: Text(localizations.notify_me),
            trailing: Switch(
              value: settings.get(AppSettings.notificationsEnabled),
              onChanged: (value) => settings.set(AppSettings.notificationsEnabled, value),
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
