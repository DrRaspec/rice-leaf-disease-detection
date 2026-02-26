import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettingsService extends GetxService {
  static const _themeModeKey = 'settings.themeMode';
  static const _fontScaleKey = 'settings.fontScale';
  static const _fontFamilyKey = 'settings.fontFamily';

  static const List<String> fontFamilies = ['Roboto', 'serif', 'monospace'];
  static const List<double> fontScales = [0.9, 1.0, 1.15];

  final Rx<ThemeMode> themeMode = ThemeMode.dark.obs;
  final RxDouble fontScale = 1.0.obs;
  final RxString fontFamily = 'Roboto'.obs;

  late SharedPreferences _prefs;

  Future<AppSettingsService> initialize() async {
    _prefs = await SharedPreferences.getInstance();

    final rawMode = _prefs.getString(_themeModeKey);
    themeMode.value = switch (rawMode) {
      'light' => ThemeMode.light,
      'system' => ThemeMode.system,
      _ => ThemeMode.dark,
    };

    final savedScale = _prefs.getDouble(_fontScaleKey);
    if (savedScale != null && fontScales.contains(savedScale)) {
      fontScale.value = savedScale;
    }

    final savedFamily = _prefs.getString(_fontFamilyKey);
    if (savedFamily != null && fontFamilies.contains(savedFamily)) {
      fontFamily.value = savedFamily;
    }

    return this;
  }

  Future<void> setThemeMode(ThemeMode value) async {
    themeMode.value = value;
    final encoded = switch (value) {
      ThemeMode.light => 'light',
      ThemeMode.system => 'system',
      ThemeMode.dark => 'dark',
    };
    await _prefs.setString(_themeModeKey, encoded);
  }

  Future<void> setFontScale(double value) async {
    fontScale.value = value;
    await _prefs.setDouble(_fontScaleKey, value);
  }

  Future<void> setFontFamily(String value) async {
    fontFamily.value = value;
    await _prefs.setString(_fontFamilyKey, value);
  }
}
