import 'package:flutter/material.dart';

class Surface {
  final Color s50;
  final Color s100;
  final Color s200;
  final Color s300;
  final Color s500;

  const Surface({
    required this.s50,
    required this.s100,
    required this.s200,
    required this.s300,
    required this.s500,
  });
}

class ColorShades {
  final Color s50;
  final Color s100;
  final Color s200;
  final Color s300;
  final Color s400;
  final Color s500;
  final Color s600;
  final Color s700;
  final Color s800;
  final Color s900;

  const ColorShades({
    required this.s50,
    required this.s100,
    required this.s200,
    required this.s300,
    required this.s400,
    required this.s500,
    required this.s600,
    required this.s700,
    required this.s800,
    required this.s900,
  });
}

abstract class AppColors {
  static const Color primary500 = Color(0xFFC6FE1E);
  static const Color primary600 = Color(0xFFD4FF4D);
  static const Color primary400 = Color(0xFF9BD41B);

  static const Color surface50 = Color(0xFF0C0D11);
  static const Color surface100 = Color(0xFF12141A);
  static const Color surface200 = Color(0xFF14161D);
  static const Color surface300 = Color(0xFF1A1D26);
  static const Color surface500 = Color(0xFF181A22);

  static const Color onSurface900 = Color(0xFFFFFFFF);
  static const Color onSurface500 = Color(0xFF8E92A2);
  static const Color onSurface400 = Color(0xFF6B7080);

  static const Color secondary100 = Color(0xFF222634);
  static const Color secondary600 = Color(0xFFB0B5C6);

  static const Color onPrimary = Color(0xFF000000);

  static const ColorShades primary = ColorShades(
    s50: Color(0xFF151D04),
    s100: Color(0xFF263507),
    s200: Color(0xFF4C6B0E),
    s300: Color(0xFF73A015),
    s400: primary400,
    s500: primary500,
    s600: primary600,
    s700: Color(0xFFE2FF80),
    s800: Color(0xFFEFFFAD),
    s900: Color(0xFFF7FFD6),
  );

  static const ColorShades secondary = ColorShades(
    s50: Color(0xFF1A1D26),
    s100: secondary100,
    s200: Color(0xFF2E3346),
    s300: Color(0xFF454B62),
    s400: onSurface400,
    s500: onSurface500,
    s600: secondary600,
    s700: Color(0xFFD0D5E4),
    s800: Color(0xFFEAEFF9),
    s900: onSurface900,
  );

  static const Surface surface = Surface(
    s50: surface50,
    s100: surface100,
    s200: surface200,
    s300: surface300,
    s500: surface500,
  );

  static const ColorShades onSurface = ColorShades(
    s50: Color(0xFF1A1D26),
    s100: Color(0xFF272B36),
    s200: Color(0xFF383E4C),
    s300: Color(0xFF4E5466),
    s400: onSurface400,
    s500: onSurface500,
    s600: secondary600,
    s700: Color(0xFFD0D5E4),
    s800: Color(0xFFEAEFF9),
    s900: onSurface900,
  );

  static const Color primaryColor = primary500;
  static const Color background = surface50;
  static const Color card = surface200;
  static const Color surfaceVariant = surface300;
  static const Color inputBackground = surface500;
  static const Color incomingBubble = surface500;
  static const Color modalBackground = surface100;
  static const Color datePillBackground = surface300;
  static const Color borderSubtle = secondary100;
  static const Color keyBadgeBackground = surface300;

  static const Color textPrimary = onSurface900;
  static const Color textSecondary = onSurface500;
  static const Color textMuted = onSurface400;
  static const Color handleIncoming = secondary600;
  static const Color handleOutgoing = onSurface500;

  static const Color neonLime = primary500;
  static const Color neonLimeHover = primary600;
  static const Color neonLimePressed = primary400;
  static const Color textOnLime = onPrimary;
  static const Color overlay = Color(0x99000000);
}
