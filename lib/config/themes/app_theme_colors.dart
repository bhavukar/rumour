import 'package:flutter/material.dart';
import 'package:rumour/config/themes/app_colors.dart';

@immutable
class AppThemeColors extends ThemeExtension<AppThemeColors> {
  final Surface surface;
  final ColorShades onSurface;
  final ColorShades primary;
  final ColorShades secondary;
  final Color onPrimary;

  const AppThemeColors({
    required this.surface,
    required this.onSurface,
    required this.primary,
    required this.secondary,
    required this.onPrimary,
  });

  Color get canvas => surface.s50;
  Color get background => surface.s50;
  Color get card => surface.s200;
  Color get surfaceVariant => surface.s300;
  Color get inputBackground => surface.s500;
  Color get incomingBubble => surface.s500;
  Color get modalBackground => surface.s100;
  Color get datePillBackground => surface.s300;
  Color get borderSubtle => secondary.s100;
  Color get keyBadgeBackground => surface.s300;

  Color get primaryColor => primary.s500;
  Color get neonLime => primary.s500;
  Color get textOnLime => onPrimary;

  Color get textPrimary => onSurface.s900;
  Color get textSecondary => onSurface.s500;
  Color get textMuted => onSurface.s400;
  Color get handleIncoming => secondary.s600;
  Color get handleOutgoing => onSurface.s500;

  static const dark = AppThemeColors(
    surface: Surface(
      s50: Color(0xFF0C0D11),
      s100: Color(0xFF12141A),
      s200: Color(0xFF14161D),
      s300: Color(0xFF1A1D26),
      s500: Color(0xFF181A22),
    ),
    onSurface: ColorShades(
      s50: Color(0xFF1A1D26),
      s100: Color(0xFF272B36),
      s200: Color(0xFF383E4C),
      s300: Color(0xFF4E5466),
      s400: Color(0xFF6B7080),
      s500: Color(0xFF8E92A2),
      s600: Color(0xFFB0B5C6),
      s700: Color(0xFFD0D5E4),
      s800: Color(0xFFEAEFF9),
      s900: Color(0xFFFFFFFF),
    ),
    primary: ColorShades(
      s50: Color(0xFF151D04),
      s100: Color(0xFF263507),
      s200: Color(0xFF4C6B0E),
      s300: Color(0xFF73A015),
      s400: Color(0xFF9BD41B),
      s500: Color(0xFFC6FE1E),
      s600: Color(0xFFD4FF4D),
      s700: Color(0xFFE2FF80),
      s800: Color(0xFFEFFFAD),
      s900: Color(0xFFF7FFD6),
    ),
    secondary: ColorShades(
      s50: Color(0xFF1A1D26),
      s100: Color(0xFF222634),
      s200: Color(0xFF2E3346),
      s300: Color(0xFF454B62),
      s400: Color(0xFF6B7080),
      s500: Color(0xFF8E92A2),
      s600: Color(0xFFB0B5C6),
      s700: Color(0xFFD0D5E4),
      s800: Color(0xFFEAEFF9),
      s900: Color(0xFFFFFFFF),
    ),
    onPrimary: Color(0xFF000000),
  );

  static const light = AppThemeColors(
    surface: Surface(
      s50: Color(0xFFF6F7FA),
      s100: Color(0xFFFFFFFF),
      s200: Color(0xFFECEFF5),
      s300: Color(0xFFE2E6F0),
      s500: Color(0xFFE5E9F2),
    ),
    onSurface: ColorShades(
      s50: Color(0xFFF6F7FA),
      s100: Color(0xFFECEFF5),
      s200: Color(0xFFDCE2ED),
      s300: Color(0xFFB8C2D4),
      s400: Color(0xFF868C9E),
      s500: Color(0xFF5A6072),
      s600: Color(0xFF43495B),
      s700: Color(0xFF2E3342),
      s800: Color(0xFF1E212B),
      s900: Color(0xFF111318),
    ),
    primary: ColorShades(
      s50: Color(0xFFF7FFE0),
      s100: Color(0xFFEEFFB8),
      s200: Color(0xFFDFFF85),
      s300: Color(0xFFCEFF4D),
      s400: Color(0xFFC0F726),
      s500: Color(0xFFB5F200),
      s600: Color(0xFF98CC00),
      s700: Color(0xFF7CA600),
      s800: Color(0xFF5F8000),
      s900: Color(0xFF425900),
    ),
    secondary: ColorShades(
      s50: Color(0xFFECEFF5),
      s100: Color(0xFFD8DDE8),
      s200: Color(0xFFC0C7D6),
      s300: Color(0xFFA8B0C4),
      s400: Color(0xFF868C9E),
      s500: Color(0xFF5A6072),
      s600: Color(0xFF43495B),
      s700: Color(0xFF2E3342),
      s800: Color(0xFF1E212B),
      s900: Color(0xFF111318),
    ),
    onPrimary: Color(0xFF000000),
  );

  @override
  AppThemeColors copyWith({
    Surface? surface,
    ColorShades? onSurface,
    ColorShades? primary,
    ColorShades? secondary,
    Color? onPrimary,
  }) {
    return AppThemeColors(
      surface: surface ?? this.surface,
      onSurface: onSurface ?? this.onSurface,
      primary: primary ?? this.primary,
      secondary: secondary ?? this.secondary,
      onPrimary: onPrimary ?? this.onPrimary,
    );
  }

  @override
  AppThemeColors lerp(
    covariant ThemeExtension<AppThemeColors>? other,
    double t,
  ) {
    if (other is! AppThemeColors) return this;
    if (t < 0.5) return this;
    return other;
  }
}

extension BuildContextThemeColors on BuildContext {
  AppThemeColors get colors =>
      Theme.of(this).extension<AppThemeColors>() ?? AppThemeColors.dark;

  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
}
