import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rumour/config/themes/app_theme_colors.dart';
import 'package:rumour/services/haptics/haptic_service.dart';
import 'package:rumour/services/theme/theme_cubit.dart';

class ThemeSwitcherButton extends StatelessWidget {
  final double size;

  const ThemeSwitcherButton({
    super.key,
    this.size = 38,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, themeMode) {
        final isDark = themeMode == ThemeMode.dark;

        return GestureDetector(
          onTap: () {
            HapticService.selection();
            context.read<ThemeCubit>().toggleTheme();
          },
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: context.colors.surface.s300,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                transitionBuilder: (child, animation) {
                  return RotationTransition(
                    turns: animation,
                    child: FadeTransition(opacity: animation, child: child),
                  );
                },
                child: Icon(
                  isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                  key: ValueKey(isDark),
                  color: isDark
                      ? context.colors.primary.s500
                      : const Color(0xFFF59E0B),
                  size: 20,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
