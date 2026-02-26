import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppTheme {
  static const _dark = _Palette(
    primary: Color(0xFF22C55E),
    primary700: Color(0xFF15803D),
    surface: Color(0xFF0D2E1E),
    background: Color(0xFF0A2015),
    card: Color(0xFF122B1D),
    cardBorder: Color(0xFF1E4030),
    textPrimary: Color(0xFFFFFFFF),
    textSecondary: Color(0xFF9CA3AF),
  );

  static const _light = _Palette(
    primary: Color(0xFF15803D),
    primary700: Color(0xFF166534),
    surface: Color(0xFFEAF7EE),
    background: Color(0xFFF7FCF8),
    card: Color(0xFFFFFFFF),
    cardBorder: Color(0xFFD0E7D5),
    textPrimary: Color(0xFF102418),
    textSecondary: Color(0xFF4B6355),
  );

  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFEF4444);
  static const Color earth = Color(0xFFD97706);

  static _Palette get _current => Get.isDarkMode ? _dark : _light;
  static Color get primary => _current.primary;
  static Color get primary700 => _current.primary700;
  static Color get surface => _current.surface;
  static Color get background => _current.background;
  static Color get card => _current.card;
  static Color get cardBorder => _current.cardBorder;
  static Color get textPrimary => _current.textPrimary;
  static Color get textSecondary => _current.textSecondary;
  static Color get success => primary;

  static ThemeData dark({required String fontFamily}) =>
      _buildTheme(_dark, Brightness.dark, fontFamily);

  static ThemeData light({required String fontFamily}) =>
      _buildTheme(_light, Brightness.light, fontFamily);

  static ThemeData _buildTheme(
    _Palette palette,
    Brightness brightness,
    String fontFamily,
  ) {
    final baseTextTheme = ThemeData(brightness: brightness).textTheme.apply(
      bodyColor: palette.textPrimary,
      displayColor: palette.textPrimary,
      fontFamily: fontFamily,
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
            onPrimary: Colors.white,
            onSurface: palette.textPrimary,
          );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: palette.background,
      colorScheme: colorScheme,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: palette.textPrimary),
        titleTextStyle: baseTextTheme.titleLarge?.copyWith(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
          color: palette.textPrimary,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: palette.primary,
          foregroundColor: brightness == Brightness.dark ? Colors.black : Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: baseTextTheme.labelLarge?.copyWith(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
          elevation: 0,
        ),
      ),
      cardTheme: CardThemeData(
        color: palette.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: palette.cardBorder),
        ),
      ),
      textTheme: baseTextTheme.copyWith(
        displayLarge: baseTextTheme.displayLarge?.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: -1,
        ),
        headlineLarge: baseTextTheme.headlineLarge?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
        headlineMedium: baseTextTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.w700,
        ),
        titleLarge: baseTextTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(height: 1.5),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(
          height: 1.5,
          color: palette.textSecondary,
        ),
        labelLarge: baseTextTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: palette.textPrimary,
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
