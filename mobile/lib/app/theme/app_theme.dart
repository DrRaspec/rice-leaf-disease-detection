import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/app_settings_service.dart';

class AppTheme {
  static const _dark = _Palette(
    primary: Color(0xFF73C66D),
    primary700: Color(0xFF509C4E),
    surface: Color(0xFF14281B),
    background: Color(0xFF0D1711),
    card: Color(0xFF17251C),
    cardBorder: Color(0xFF294033),
    textPrimary: Color(0xFFF3F1E8),
    textSecondary: Color(0xFFB3C2B6),
  );

  static const _light = _Palette(
    primary: Color(0xFF4D9A52),
    primary700: Color(0xFF2F6E35),
    surface: Color(0xFFF5F2E8),
    background: Color(0xFFFBF8F1),
    card: Color(0xFFFFFCF6),
    cardBorder: Color(0xFFE3DDCF),
    textPrimary: Color(0xFF223126),
    textSecondary: Color(0xFF617164),
  );

  static const Color warning = Color(0xFFC98B2C);
  static const Color danger = Color(0xFFC45743);
  static const Color earth = Color(0xFFA36A2E);

  static _Palette get _current {
    if (Get.isRegistered<AppSettingsService>()) {
      final mode = Get.find<AppSettingsService>().themeMode.value;
      final systemBrightness =
          WidgetsBinding.instance.platformDispatcher.platformBrightness;
      final isDark = mode == ThemeMode.dark ||
          (mode == ThemeMode.system && systemBrightness == Brightness.dark);
      return isDark ? _dark : _light;
    }
    return Get.isDarkMode ? _dark : _light;
  }

  static Color get primary => _current.primary;
  static Color get primary700 => _current.primary700;
  static Color get surface => _current.surface;
  static Color get background => _current.background;
  static Color get card => _current.card;
  static Color get cardBorder => _current.cardBorder;
  static Color get textPrimary => _current.textPrimary;
  static Color get textSecondary => _current.textSecondary;
  static Color get success => primary;
  static Color get overlay => Get.isDarkMode
      ? const Color(0xFF08100B).withValues(alpha: 0.72)
      : const Color(0xFF223126).withValues(alpha: 0.08);
  static Color get highlight =>
      Get.isDarkMode ? const Color(0xFFE4C977) : const Color(0xFFCC9A39);
  static Color get muted =>
      Get.isDarkMode ? const Color(0xFF203328) : const Color(0xFFF1ECE0);
  static Gradient get heroGradient => LinearGradient(
        colors: Get.isDarkMode
            ? const [Color(0xFF24402F), Color(0xFF121D16)]
            : const [Color(0xFFE7E1C8), Color(0xFFD2E7C6)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
  static Gradient get accentGradient => LinearGradient(
        colors: [highlight, primary],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  static ThemeData dark({
    String? fontFamily,
    List<String> fontFamilyFallback = const [],
  }) =>
      _buildTheme(
        _dark,
        Brightness.dark,
        fontFamily,
        fontFamilyFallback,
      );

  static ThemeData light({
    String? fontFamily,
    List<String> fontFamilyFallback = const [],
  }) =>
      _buildTheme(
        _light,
        Brightness.light,
        fontFamily,
        fontFamilyFallback,
      );

  static ThemeData _buildTheme(
    _Palette palette,
    Brightness brightness,
    String? fontFamily,
    List<String> fontFamilyFallback,
  ) {
    final baseTextTheme = ThemeData(brightness: brightness).textTheme.apply(
          bodyColor: palette.textPrimary,
          displayColor: palette.textPrimary,
          fontFamily: fontFamily,
          fontFamilyFallback: fontFamilyFallback,
        );

    final colorScheme = brightness == Brightness.dark
        ? ColorScheme.dark(
            primary: palette.primary,
            secondary: palette.primary700,
            surface: palette.surface,
            onPrimary: Colors.black,
            onSurface: palette.textPrimary,
          )
        : ColorScheme.light(
            primary: palette.primary,
            secondary: palette.primary700,
            surface: palette.surface,
            onPrimary: Colors.black,
            onSurface: palette.textPrimary,
          );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: fontFamily,
      fontFamilyFallback:
          fontFamilyFallback.isEmpty ? null : fontFamilyFallback,
      scaffoldBackgroundColor: palette.background,
      colorScheme: colorScheme,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: palette.textPrimary),
        titleTextStyle: baseTextTheme.titleLarge?.copyWith(
          fontSize: 19,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
          color: palette.textPrimary,
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: palette.card,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: palette.background,
        selectedColor: palette.primary.withValues(alpha: 0.18),
        disabledColor: palette.cardBorder.withValues(alpha: 0.3),
        side: BorderSide(color: palette.cardBorder),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        labelStyle: baseTextTheme.labelLarge?.copyWith(
          color: palette.textPrimary,
          fontWeight: FontWeight.w600,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: palette.primary,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          minimumSize: const Size(48, 56),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: baseTextTheme.labelLarge?.copyWith(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.1,
          ),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: palette.textPrimary,
          side: BorderSide(color: palette.cardBorder),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          minimumSize: const Size(48, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: baseTextTheme.labelLarge?.copyWith(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: palette.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: palette.cardBorder),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: palette.cardBorder.withValues(alpha: 0.7),
        thickness: 1,
        space: 1,
      ),
      textTheme: baseTextTheme.copyWith(
        displayLarge: baseTextTheme.displayLarge?.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: -1.4,
        ),
        displayMedium: baseTextTheme.displayMedium?.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: -1,
        ),
        displaySmall: baseTextTheme.displaySmall?.copyWith(
          fontSize: 26,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.6,
          height: 1.16,
        ),
        headlineLarge: baseTextTheme.headlineLarge?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: -0.8,
        ),
        headlineMedium: baseTextTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
        headlineSmall: baseTextTheme.headlineSmall?.copyWith(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
          height: 1.28,
        ),
        titleLarge: baseTextTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: -0.4,
        ),
        titleMedium: baseTextTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(
          height: 1.55,
          color: palette.textPrimary,
        ),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(
          height: 1.6,
          color: palette.textSecondary,
        ),
        labelLarge: baseTextTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: palette.textPrimary,
        ),
        labelMedium: baseTextTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
          color: palette.textSecondary,
        ),
      ),
    );
  }
}

class _Palette {
  final Color primary;
  final Color primary700;
  final Color surface;
  final Color background;
  final Color card;
  final Color cardBorder;
  final Color textPrimary;
  final Color textSecondary;

  const _Palette({
    required this.primary,
    required this.primary700,
    required this.surface,
    required this.background,
    required this.card,
    required this.cardBorder,
    required this.textPrimary,
    required this.textSecondary,
  });
}
