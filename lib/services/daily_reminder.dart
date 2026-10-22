import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:path/path.dart' as p;
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../constants.dart';
import '../providers/settings.dart';

enum DailyReminderEnableResult { enabled, permissionDenied, unsupported }

class DailyReminderService {
  DailyReminderService._();

  static final instance = DailyReminderService._();
  static const _notificationId = 1;
  static const _channelId = 'daily_diary_reminder';

  final _notifications = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  bool get isSupported => Platform.isAndroid || Platform.isIOS || Platform.isMacOS || Platform.isWindows;

  Future<void> _ensureInitialized() async {
    if (_initialized) return;

    tz.initializeTimeZones();
    final timezone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timezone.identifier));
    final initializationSettings = InitializationSettings(
      android: const AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
      windows: const WindowsInitializationSettings(
        appName: windowsNotificationAppName,
        appUserModelId: windowsNotificationAppUserModelId,
        guid: windowsNotificationGuid,
      ),
    );
    await _notifications.initialize(settings: initializationSettings);
    _initialized = true;
  }

  Future<bool> requestPermission() async {
    if (!isSupported) return false;
    await _ensureInitialized();

    if (defaultTargetPlatform == TargetPlatform.android) {
      final android = _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      final enabled = await android?.areNotificationsEnabled();
      if (enabled == true) return true;
      return await android?.requestNotificationsPermission() ?? false;
    }
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final ios = _notifications.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
      return await ios?.requestPermissions(alert: true, badge: true, sound: true) ?? true;
    }
    return true;
  }

  Future<void> schedule({required int minutesAfterMidnight, required String title, required String body}) async {
    if (Platform.isWindows) {
      await _createWindowsTask(minutesAfterMidnight);
      return;
    }

    await _ensureInitialized();
    await _notifications.cancel(id: _notificationId);

    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      minutesAfterMidnight ~/ 60,
      minutesAfterMidnight % 60,
    );
    if (!scheduledDate.isAfter(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _notifications.zonedSchedule(
      id: _notificationId,
      title: title,
      body: body,
      scheduledDate: scheduledDate,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          'Daily diary reminder',
          channelDescription: 'Reminds you to write in your diary every day.',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<DailyReminderEnableResult> enable({
    required int minutesAfterMidnight,
    required String title,
    required String body,
  }) async {
    if (!isSupported) return DailyReminderEnableResult.unsupported;
    if (!await requestPermission()) return DailyReminderEnableResult.permissionDenied;

    await schedule(minutesAfterMidnight: minutesAfterMidnight, title: title, body: body);
    return DailyReminderEnableResult.enabled;
  }

  Future<DailyReminderEnableResult> setEnabled({
    required SettingsProvider settings,
    required bool enabled,
    required String title,
    required String body,
  }) async {
    if (!enabled) {
      await cancel();
      settings.set(AppSettings.notificationsEnabled, false);
      return DailyReminderEnableResult.enabled;
    }

    final result = await enable(
      minutesAfterMidnight: settings.get(AppSettings.notificationTimeMinutes),
      title: title,
      body: body,
    );
    settings.set(AppSettings.notificationsPermissionDenied, result == DailyReminderEnableResult.permissionDenied);
    settings.set(AppSettings.notificationsEnabled, result == DailyReminderEnableResult.enabled);
    return result;
  }

  Future<void> updateTime({required int minutesAfterMidnight, required String title, required String body}) {
    return schedule(minutesAfterMidnight: minutesAfterMidnight, title: title, body: body);
  }

  Future<void> setTime({
    required SettingsProvider settings,
    required int minutesAfterMidnight,
    required String title,
    required String body,
  }) async {
    await updateTime(minutesAfterMidnight: minutesAfterMidnight, title: title, body: body);
    settings.set(AppSettings.notificationTimeMinutes, minutesAfterMidnight);
  }

  Future<void> cancel() async {
    if (Platform.isWindows) {
      await _deleteWindowsTask();
      return;
    }

    await _ensureInitialized();
    await _notifications.cancel(id: _notificationId);
  }

  Future<void> showNow({required String title, required String body}) async {
    await _ensureInitialized();
    await _notifications.show(
      id: _notificationId,
      title: title,
      body: body,
      notificationDetails: const NotificationDetails(windows: WindowsNotificationDetails()),
    );
  }

  Future<void> _createWindowsTask(int minutesAfterMidnight) async {
    final executable = Platform.resolvedExecutable;
    final schtasks = _windowsSystemExecutable('schtasks.exe');
    if (!await File(executable).exists()) {
      throw StateError('The reminder executable was not found: $executable');
    }
    final time =
        '${(minutesAfterMidnight ~/ 60).toString().padLeft(2, '0')}:'
        '${(minutesAfterMidnight % 60).toString().padLeft(2, '0')}';
    final result = await Process.run(schtasks, [
      '/Create',
      '/TN',
      windowsDailyReminderTaskName,
      '/TR',
      '"$executable" --daily-reminder',
      '/SC',
      'DAILY',
      '/ST',
      time,
      '/F',
    ]);
    if (result.exitCode != 0) {
      throw ProcessException(
        schtasks,
        [
          '/Create',
          '/TN',
          windowsDailyReminderTaskName,
          '/TR',
          '"$executable" --daily-reminder',
          '/SC',
          'DAILY',
          '/ST',
          time,
          '/F',
        ],
        'Failed to create Windows reminder task: ${result.stderr}',
        result.exitCode,
      );
    }
  }

  Future<void> _deleteWindowsTask() async {
    final schtasks = _windowsSystemExecutable('schtasks.exe');
    final result = await Process.run(schtasks, ['/Delete', '/TN', windowsDailyReminderTaskName, '/F']);
    final output = '${result.stdout}\n${result.stderr}';
    if (result.exitCode != 0 && !output.contains('does not exist')) {
      throw ProcessException(
        'schtasks.exe',
        ['/Delete', '/TN', windowsDailyReminderTaskName, '/F'],
        'Failed to remove Windows reminder task: $output',
        result.exitCode,
      );
    }
  }

  String _windowsSystemExecutable(String executable) {
    final windowsDirectory = Platform.environment['WINDIR'];
    if (windowsDirectory == null || windowsDirectory.isEmpty) {
      throw StateError('The Windows directory could not be determined.');
    }
    return p.join(windowsDirectory, 'System32', executable);
  }
}
