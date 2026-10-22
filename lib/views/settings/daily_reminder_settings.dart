import 'package:material_ui/material_ui.dart';
import 'package:mind_cove/l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../providers/settings.dart';
import '../../services/daily_reminder.dart';

class DailyReminderSettings extends StatelessWidget {
  const DailyReminderSettings({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final localizations = AppLocalizations.of(context)!;
    final remindersSupported = DailyReminderService.instance.isSupported;
    final permissionDenied = settings.get(AppSettings.notificationsPermissionDenied);
    final enabled = remindersSupported && settings.get(AppSettings.notificationsEnabled);

    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.notifications),
          title: Text(localizations.notify_me),
          subtitle: !remindersSupported
              ? Text(localizations.notification_not_supported)
              : permissionDenied
              ? Text(localizations.notification_permission_required)
              : null,
          trailing: Switch(
            value: enabled,
            onChanged: !remindersSupported || permissionDenied
                ? null
                : (value) => DailyReminderService.instance.setEnabled(
                    settings: settings,
                    enabled: value,
                    title: localizations.notify_me,
                    body: localizations.daily_reminder_body,
                  ),
          ),
        ),
        if (enabled)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const SizedBox(width: 24),
            title: Text(localizations.notification_time),
            trailing: TextButton(
              onPressed: () => _selectTime(context, settings, localizations),
              child: Text(_formatTime(context, settings.get(AppSettings.notificationTimeMinutes))),
            ),
          ),
      ],
    );
  }

  Future<void> _selectTime(BuildContext context, SettingsProvider settings, AppLocalizations localizations) async {
    final minutes = settings.get(AppSettings.notificationTimeMinutes);
    final selected = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60),
    );
    if (selected == null) return;

    await DailyReminderService.instance.setTime(
      settings: settings,
      minutesAfterMidnight: selected.hour * 60 + selected.minute,
      title: localizations.notify_me,
      body: localizations.daily_reminder_body,
    );
  }

  String _formatTime(BuildContext context, int minutes) {
    return TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60).format(context);
  }
}
