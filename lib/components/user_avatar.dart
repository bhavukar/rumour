import 'package:flutter/material.dart';
import 'package:rumour/config/themes/app_theme_colors.dart';

class UserAvatar extends StatelessWidget {
  final String? avatarUrl;
  final String displayName;
  final double size;
  final bool showBorder;
  final Color? borderColor;

  const UserAvatar({
    super.key,
    this.avatarUrl,
    required this.displayName,
    this.size = 36.0,
    this.showBorder = false,
    this.borderColor,
  });

  static const List<List<Color>> _avatarGradients = [
    [Color(0xFF6366F1), Color(0xFF4F46E5)],
    [Color(0xFFEC4899), Color(0xFFDB2777)],
    [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
    [Color(0xFF10B981), Color(0xFF059669)],
    [Color(0xFFF59E0B), Color(0xFFD97706)],
    [Color(0xFF06B6D4), Color(0xFF0891B2)],
    [Color(0xFFF97316), Color(0xFFEA580C)],
    [Color(0xFF14B8A6), Color(0xFF0D9488)],
    [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
    [Color(0xFFE11D48), Color(0xFFBE123C)],
  ];

  String _extractInitials() {
    final clean = displayName.replaceAll('@', '').trim();
    if (clean.isEmpty) return 'AN';

    final words = clean.split(RegExp(r'\s+'));
    if (words.length >= 2) {
      final first = words[0].isNotEmpty ? words[0][0] : '';
      final second = words[1].isNotEmpty ? words[1][0] : '';
      final combined = '$first$second'.toUpperCase();
      if (combined.isNotEmpty) return combined;
    }

    if (clean.length >= 2) {
      return clean.substring(0, 2).toUpperCase();
    }
    return clean[0].toUpperCase();
  }

  List<Color> _resolveGradient() {
    final clean = displayName.trim().toLowerCase();
    final index = clean.hashCode.abs() % _avatarGradients.length;
    return _avatarGradients[index];
  }

  Widget _buildInitials() {
    final gradient = _resolveGradient();
    final initials = _extractInitials();
    final fontSize = size * 0.40;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
        ),
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            color: Colors.white,
            fontSize: fontSize,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasValidUrl = avatarUrl != null &&
        avatarUrl!.trim().isNotEmpty &&
        avatarUrl!.startsWith(RegExp(r'https?://'));

    Widget avatarContent = _buildInitials();

    if (hasValidUrl) {
      final pixelSize = (size * 2.5).round().clamp(48, 160);
      avatarContent = Image.network(
        avatarUrl!.trim(),
        width: size,
        height: size,
        fit: BoxFit.cover,
        cacheWidth: pixelSize,
        cacheHeight: pixelSize,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildInitials();
        },
        errorBuilder: (context, error, stackTrace) {
          return _buildInitials();
        },
      );
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: showBorder
            ? Border.all(
                color: borderColor ?? context.colors.primary.s500,
                width: 2.0,
              )
            : null,
      ),
      child: ClipOval(
        child: avatarContent,
      ),
    );
  }
}
