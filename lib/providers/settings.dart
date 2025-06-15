import 'package:flutter/material.dart';

class SettingsProvider extends ChangeNotifier {
  String _languageCode = 'en';
  Brightness? _brightness;

  String get languageCode => _languageCode;
  Brightness? get brightness => _brightness;

  void setLanguage(String code) {
    if (code != _languageCode) {
      _languageCode = code;
      notifyListeners();
    }
  }

  void setBrightness(Brightness? brightness) {
    _brightness = brightness;
    notifyListeners();
  }
}
