import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettingsService extends GetxService {
  static const _themeModeKey = 'settings.themeMode';
  static const _zoomScaleKey = 'settings.zoomScale';
  static const _legacyFontScaleKey = 'settings.fontScale';
  static const _fontSizeKey = 'settings.fontSize';
  static const _fontFamilyKey = 'settings.fontFamily';
  static const _khmerFontFamilyKey = 'settings.khmerFontFamily';
  static const _languageKey = 'settings.language';

  static const String khmerLanguageCode = 'km';
  static const String englishLanguageCode = 'en';
  static const String defaultKhmerFontFamily = 'Noto Sans Khmer';
  static const List<String> khmerFontFamilies = [
    'Noto Sans Khmer',
    'Khmer OS Battambang',
    'Khmer OS Siemreap',
    'Khmer Sangam MN',
    'Khmer MN',
  ];

  static const List<String> fontFamilies = ['Roboto', 'serif', 'monospace'];
  static const List<double> zoomScales = [0.9, 1.0, 1.1];
  static const List<double> fontSizes = [12, 13, 14, 15, 16];

  final Rx<ThemeMode> themeMode = ThemeMode.light.obs;
  final RxDouble zoomScale = 1.0.obs;
  final RxDouble fontSize = 14.0.obs;
  final RxString fontFamily = 'Roboto'.obs;
  final RxString khmerFontFamily = defaultKhmerFontFamily.obs;
  final RxString languageCode = khmerLanguageCode.obs;

  bool get isKhmerLanguage => languageCode.value == khmerLanguageCode;

  String get selectedFontFamily =>
      isKhmerLanguage ? khmerFontFamily.value : fontFamily.value;

  List<String> get visibleFontFamilies =>
      isKhmerLanguage ? khmerFontFamilies : fontFamilies;

  String get activeFontFamily => selectedFontFamily;

  List<String> get activeFontFallbacks {
    if (!isKhmerLanguage) return const [];
    return {
      khmerFontFamily.value,
      ...khmerFontFamilies,
    }.toList(growable: false);
  }

  late SharedPreferences _prefs;

  Future<AppSettingsService> initialize() async {
    _prefs = await SharedPreferences.getInstance();

    final rawMode = _prefs.getString(_themeModeKey);
    themeMode.value = switch (rawMode) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      'system' => ThemeMode.system,
      _ => ThemeMode.light,
    };

    final savedZoom = _prefs.getDouble(_zoomScaleKey) ??
        _prefs.getDouble(_legacyFontScaleKey);
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

    final savedKhmerFamily = _prefs.getString(_khmerFontFamilyKey);
    if (savedKhmerFamily != null &&
        khmerFontFamilies.contains(savedKhmerFamily)) {
      khmerFontFamily.value = savedKhmerFamily;
    }

    final savedLanguage = _prefs.getString(_languageKey);
    if (savedLanguage != null &&
        (savedLanguage == khmerLanguageCode ||
            savedLanguage == englishLanguageCode)) {
      languageCode.value = savedLanguage;
    } else {
      languageCode.value = khmerLanguageCode;
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
    if (isKhmerLanguage) {
      if (!khmerFontFamilies.contains(value)) return;
      khmerFontFamily.value = value;
      await _prefs.setString(_khmerFontFamilyKey, value);
      return;
    }
    if (!fontFamilies.contains(value)) return;
    fontFamily.value = value;
    await _prefs.setString(_fontFamilyKey, value);
  }

  Future<void> setLanguageCode(String value) async {
    if (value != khmerLanguageCode && value != englishLanguageCode) return;
    languageCode.value = value;
    await _prefs.setString(_languageKey, value);
    Get.updateLocale(
      value == khmerLanguageCode
          ? const Locale('km', 'KH')
          : const Locale('en', 'US'),
    );
  }
}
