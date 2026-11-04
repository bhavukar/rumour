import 'package:flutter/material.dart';
import 'package:rumour/config/themes/app_theme_colors.dart';
import 'package:rumour/utilities/room_name_generator.dart';

class RoomAvatar extends StatelessWidget {
  final String roomCode;
  final double size;
  final bool showBorder;
  final Color? borderColor;

  const RoomAvatar({
    super.key,
    required this.roomCode,
    this.size = 46,
    this.showBorder = false,
    this.borderColor,
  });

  /// Deterministic 2-3 color gradients so the room avatar looks identical across all clients.
  static const List<List<Color>> _gradientPalettes = [
    [
      Color(0xFFA3E635),
      Color(0xFF06B6D4),
      Color(0xFF3B82F6)
    ], // Cyber Lime to Blue
    [Color(0xFF8B5CF6), Color(0xFFEC4899), Color(0xFFF43F5E)], // Purple to Rose
    [Color(0xFFF97316), Color(0xFFF59E0B), Color(0xFFEAB308)], // Orange to Gold
    [Color(0xFF06B6D4), Color(0xFF3B82F6), Color(0xFF6366F1)], // Cyan to Indigo
    [
      Color(0xFF10B981),
      Color(0xFF059669),
      Color(0xFF047857)
    ], // Emerald to Jade
    [
      Color(0xFFD946EF),
      Color(0xFF8B5CF6),
      Color(0xFF4F46E5)
    ], // Fuchsia to Purple
    [
      Color(0xFF2DD4BF),
      Color(0xFF38BDF8),
      Color(0xFF818CF8)
    ], // Aqua to Lavender
    [Color(0xFFF43F5E), Color(0xFFFB7185), Color(0xFFFDA4AF)], // Coral Pink
  ];

  static List<Color> getGradientColors(String code) {
    if (code.isEmpty) return _gradientPalettes[0];
    int hash = 0;
    final upper = code.toUpperCase();
    for (int i = 0; i < upper.length; i++) {
      hash = (hash * 31 + upper.codeUnitAt(i)) & 0x7FFFFFFF;
    }
    return _gradientPalettes[hash % _gradientPalettes.length];
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final initials = RoomNameGenerator.getInitials(roomCode);
    final gradientColors = getGradientColors(roomCode);
    final resolvedBorderColor = borderColor ?? colors.primary.s500;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        border: showBorder
            ? Border.all(color: resolvedBorderColor, width: 1.5)
            : null,
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w900,
          fontSize: size * 0.38,
          letterSpacing: -0.5,
          shadows: const [
            Shadow(
              color: Color(0x66000000),
              blurRadius: 4,
              offset: Offset(0, 1),
            ),
          ],
        ),
      ),
    );
  }
}
