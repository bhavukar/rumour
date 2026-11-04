import 'package:flutter/material.dart';
import 'package:rumour/config/themes/app_theme_colors.dart';

class AppBadge extends StatelessWidget {
  final IconData icon;
  final double size;
  final double iconSize;
  final Color? backgroundColor;
  final Color? iconColor;
  final double angle;

  const AppBadge({
    super.key,
    required this.icon,
    this.size = 68,
    this.iconSize = 32,
    this.backgroundColor,
    this.iconColor,
    this.angle = -0.6,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final bg = backgroundColor ?? colors.surface.s300;
    final ic = iconColor ?? colors.primary.s500;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Transform.rotate(
          angle: angle,
          child: Icon(
            icon,
            color: ic,
            size: iconSize,
          ),
        ),
      ),
    );
  }
}
