import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:go_router/go_router.dart';
import 'package:rumour/components/app_badge.dart';
import 'package:rumour/components/loading_indicator.dart';
import 'package:rumour/config/themes/app_theme_colors.dart';
import 'package:rumour/config/themes/app_typography.dart';
import 'package:rumour/services/routes/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _decideInitialRoute();
    });
  }

  Future<void> _decideInitialRoute() async {
    FlutterNativeSplash.remove();

    if (mounted) {
      try {
        context.go(AppRoutes.rooms);
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.surface.s50,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppBadge(
              icon: Icons.key_rounded,
              backgroundColor: colors.surface.s300,
              iconColor: colors.primary.s500,
              size: 68,
              iconSize: 32,
            ),
            const SizedBox(height: 24),
            Text(
              'Rumour',
              style: AppTypography.headlineMedium.copyWith(
                  color: colors.onSurface.s900,
                  letterSpacing: -0.5,
                  fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 32),
            LoadingIndicator(
              size: 26,
              color: colors.primary.s500,
            ),
          ],
        ),
      ),
    );
  }
}
