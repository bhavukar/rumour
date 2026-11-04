import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rumour/config/themes/app_theme_colors.dart';
import 'package:rumour/config/themes/app_typography.dart';

class AppTheme {
  static ThemeData get darkTheme {
    const colors = AppThemeColors.dark;
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: colors.canvas,
      dividerColor: const Color(0xFF222632),
      dividerTheme: const DividerThemeData(
        color: Color(0xFF222632),
        thickness: 1,
        space: 1,
      ),
      colorScheme: ColorScheme.dark(
        primary: colors.primary.s500,
        onPrimary: colors.onPrimary,
        surface: colors.surface.s200,
        onSurface: colors.onSurface.s900,
      ),
      extensions: const [colors],
      textTheme: AppTypography.textThemeDark,
      appBarTheme: AppBarTheme(
        backgroundColor: colors.canvas,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
    );
  }

  static ThemeData get lightTheme {
    const colors = AppThemeColors.light;
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: colors.canvas,
      dividerColor: const Color(0xFFE5E7EB),
      dividerTheme: const DividerThemeData(
        color: Color(0xFFE5E7EB),
        thickness: 1,
        space: 1,
      ),
      colorScheme: ColorScheme.light(
        primary: colors.primary.s500,
        onPrimary: colors.onPrimary,
        surface: colors.surface.s200,
        onSurface: colors.onSurface.s900,
      ),
      extensions: const [colors],
      textTheme: AppTypography.textThemeLight,
      appBarTheme: AppBarTheme(
        backgroundColor: colors.canvas,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
    );
  }
}
