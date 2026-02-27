import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettingsService extends GetxService {
  static const _themeModeKey = 'settings.themeMode';
  static const _zoomScaleKey = 'settings.zoomScale';
  static const _legacyFontScaleKey = 'settings.fontScale';
  static const _fontSizeKey = 'settings.fontSize';
  static const _fontFamilyKey = 'settings.fontFamily';
  static const _languageKey = 'settings.language';

  static const List<String> fontFamilies = ['Roboto', 'serif', 'monospace'];
  static const List<double> zoomScales = [0.9, 1.0, 1.1];
  static const List<double> fontSizes = [12, 13, 14, 15, 16];

  final Rx<ThemeMode> themeMode = ThemeMode.light.obs;
  final RxDouble zoomScale = 1.0.obs;
  final RxDouble fontSize = 14.0.obs;
  final RxString fontFamily = 'Roboto'.obs;
  final RxString languageCode = 'km'.obs;

  late SharedPreferences _prefs;

  Future<AppSettingsService> initialize() async {
    _prefs = await SharedPreferences.getInstance();

    final rawMode = _prefs.getString(_themeModeKey);
    themeMode.value = switch (rawMode) {
      'light' => ThemeMode.light,
      'system' => ThemeMode.system,
      _ => ThemeMode.light,
    };

    final savedZoom =
        _prefs.getDouble(_zoomScaleKey) ?? _prefs.getDouble(_legacyFontScaleKey);
    if (savedZoom != null && zoomScales.contains(savedZoom)) {
      zoomScale.value = savedZoom;
    }

    final savedFontSize = _prefs.getDouble(_fontSizeKey);
    if (savedFontSize != null && fontSizes.contains(savedFontSize)) {
      fontSize.value = savedFontSize;
    }

    final savedFamily = _prefs.getString(_fontFamilyKey);
    if (savedFamily != null && fontFamilies.contains(savedFamily)) {
      fontFamily.value = savedFamily;
    }

    final savedLanguage = _prefs.getString(_languageKey);
    if (savedLanguage != null && (savedLanguage == 'km' || savedLanguage == 'en')) {
      languageCode.value = savedLanguage;
    } else {
      languageCode.value = 'km';
    }

    return this;
  }

  Future<void> setThemeMode(ThemeMode value) async {
    themeMode.value = value;
    Get.changeThemeMode(value);
    final encoded = switch (value) {
      ThemeMode.light => 'light',
      ThemeMode.system => 'system',
      ThemeMode.dark => 'dark',
    };
    await _prefs.setString(_themeModeKey, encoded);
  }

  Future<void> setZoomScale(double value) async {
    zoomScale.value = value;
    await _prefs.setDouble(_zoomScaleKey, value);
  }

  Future<void> setFontSize(double value) async {
    fontSize.value = value;
    await _prefs.setDouble(_fontSizeKey, value);
  }

  Future<void> setFontFamily(String value) async {
    fontFamily.value = value;
    await _prefs.setString(_fontFamilyKey, value);
  }

  Future<void> setLanguageCode(String value) async {
    if (value != 'km' && value != 'en') return;
    languageCode.value = value;
    await _prefs.setString(_languageKey, value);
    Get.updateLocale(value == 'km' ? const Locale('km', 'KH') : const Locale('en', 'US'));
  }
}
