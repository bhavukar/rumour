import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rumour/config/themes/app_theme_colors.dart';
import 'package:rumour/services/haptics/haptic_service.dart';
import 'package:rumour/services/routes/app_routes.dart';

class AppBackButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final double size;

  const AppBackButton({
    super.key,
    this.onPressed,
    this.size = 40.0,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final circleColor = isDark ? const Color(0xFF202634) : colors.surface.s300;

    return Center(
      child: Material(
        color: circleColor,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            HapticService.light();
            if (onPressed != null) {
              onPressed!();
            } else if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.go(AppRoutes.joinRoom);
            }
          },
          child: SizedBox(
            width: size,
            height: size,
            child: Center(
              child: Transform.translate(
                offset: const Offset(-1, 0),
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: colors.onSurface.s900,
                  size: 18,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
