import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:yaml/yaml.dart';

import '../constants.dart' show savingFolderName, settingsFileName;

class Setting<T> {
  const Setting({required this.key, required this.defaultValue, this.legacyKeys = const []});

  final String key;
  final T defaultValue;
  final List<String> legacyKeys;
}

class AppSettings {
  static const languageCode = Setting<String>(key: 'languageCode', defaultValue: 'en');

  static const brightness = Setting<Brightness?>(key: 'brightness', defaultValue: null);

  static const notificationsEnabled = Setting<bool>(key: 'notificationsEnabled', defaultValue: false);

  static const allSettings = <Setting<Object?>>[languageCode, brightness, notificationsEnabled];
}

class SettingsProvider extends ChangeNotifier {
  final Map<Setting<Object?>, Object?> _values = {
    for (final setting in AppSettings.allSettings) setting: setting.defaultValue,
  };
  Future<void> _saveQueue = Future<void>.value();
  bool _hasLocalChanges = false;

  SettingsProvider() {
    unawaited(_load());
  }

  T get<T>(Setting<T> setting) => _values[setting] as T;

  void set<T>(Setting<T> setting, T value) {
    if (get(setting) == value) return;
    _values[setting] = value;
    _hasLocalChanges = true;
    notifyListeners();
    unawaited(_save());
  }

  Future<File> _settingsFile() async {
    final applicationDirectory = await getApplicationDocumentsDirectory();
    final settingsDirectory = Directory(p.join(applicationDirectory.path, savingFolderName));
    await settingsDirectory.create(recursive: true);
    final file = File(p.join(settingsDirectory.path, settingsFileName));
    _settingsFilePath = file.path;
    return file;
  }

  Future<void> _load() async {
    try {
      final file = await _settingsFile();
      if (!await file.exists()) {
        await _save();
        return;
      }

      final document = loadYaml(await file.readAsString());
      if (document is! YamlMap) {
        throw const FormatException('Settings YAML must contain a mapping');
      }

      var shouldMigrate = false;
      if (!_hasLocalChanges) {
        for (final setting in AppSettings.allSettings) {
          final hasCurrentKey = document.containsKey(setting.key);
          final rawValue = document[setting.key] ?? nextOrNull(setting.legacyKeys.map((key) => document[key]));
          if (rawValue != null) {
            _values[setting] = _decode(setting, rawValue);
            shouldMigrate = shouldMigrate || !hasCurrentKey;
          }
        }
        notifyListeners();
      }
      if (shouldMigrate) await _save();
    } on YamlException catch (error) {
      debugPrint('Failed to parse settings YAML: $error');
    } on FormatException catch (error) {
      debugPrint('Failed to read settings: $error');
    } on IOException catch (error) {
      debugPrint('Failed to read settings: $error');
    }
  }

  Future<void> _save() {
    _saveQueue = _saveQueue.then((_) => _writeSettings()).catchError((error, stackTrace) {
      debugPrint('Failed to save settings to $_settingsFilePath: $error');
    });
    return _saveQueue;
  }

  String? _settingsFilePath;

  Future<void> _writeSettings() async {
    final file = await _settingsFile();
    final lines = AppSettings.allSettings.map((setting) {
      final value = _encode(setting, _values[setting]);
      return '${setting.key}: ${_yamlScalar(value)}';
    });
    await file.writeAsString('${lines.join('\n')}\n');
  }

  String _yamlScalar(Object? value) {
    if (value is String) return jsonEncode(value);
    return '$value';
  }

  Object? _decode(Setting<Object?> setting, Object? value) {
    if (setting is Setting<String>) {
      if (value is! String) throw const FormatException('Value must be a string');
      return value;
    }
    if (setting is Setting<bool>) {
      if (value is! bool) throw const FormatException('Value must be a boolean');
      return value;
    }
    if (setting is Setting<Brightness?>) {
      return switch (value) {
        null || 'system' => null,
        'light' => Brightness.light,
        'dark' => Brightness.dark,
        _ => throw FormatException('Unsupported brightness: $value'),
      };
    }
    throw UnsupportedError('No YAML decoder for ${setting.runtimeType}');
  }

  Object? _encode(Setting<Object?> setting, Object? value) {
    if (setting is Setting<String> || setting is Setting<bool>) return value;
    if (setting is Setting<Brightness?>) {
      return switch (value) {
        null => 'system',
        Brightness.light => 'light',
        Brightness.dark => 'dark',
        _ => throw FormatException('Unsupported brightness: $value'),
      };
    }
    throw UnsupportedError('No YAML encoder for ${setting.runtimeType}');
  }
}

T? nextOrNull<T>(Iterable<T> values) {
  for (final value in values) {
    if (value != null) return value;
  }
  return null;
}
