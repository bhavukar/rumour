import 'package:app_settings/app_settings.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:rumour/components/app_back_button.dart';
import 'package:rumour/components/theme_switcher_button.dart';
import 'package:rumour/config/themes/app_theme_colors.dart';
import 'package:rumour/config/themes/app_typography.dart';
import 'package:rumour/features/room/data/model/room_identity_model.dart';
import 'package:rumour/services/analytics/analytics_service.dart';
import 'package:rumour/services/firebase/firebase_service.dart';
import 'package:rumour/services/haptics/haptic_service.dart';
import 'package:rumour/services/notifications/notification_service.dart';
import 'package:rumour/services/routes/app_routes.dart';
import 'package:rumour/services/storage/local_storage_service.dart';

class SettingsScreen extends StatefulWidget {
  final RoomIdentityModel? identity;
  final String? roomCode;

  const SettingsScreen({
    super.key,
    this.identity,
    this.roomCode,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with WidgetsBindingObserver {
  bool _notificationsEnabled = true;
  bool _isResetting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkNotificationPermission();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkNotificationPermission();
    }
  }

  Future<void> _checkNotificationPermission() async {
    try {
      final settings =
          await FirebaseMessaging.instance.getNotificationSettings();
      final enabled =
          settings.authorizationStatus == AuthorizationStatus.authorized ||
              settings.authorizationStatus == AuthorizationStatus.provisional;
      if (mounted) {
        setState(() {
          _notificationsEnabled = enabled;
        });
      }
    } catch (_) {}
  }

  Future<void> _openNotificationSettings() async {
    HapticService.light();
    try {
      await AppSettings.openAppSettings(type: AppSettingsType.notification);
    } catch (_) {
      await AppSettings.openAppSettings();
    }
  }

  void _confirmResetData(AppThemeColors colors) {
    HapticService.medium();
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: colors.surface.s100,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Clear App Data?',
            style: AppTypography.titleLarge.copyWith(
                color: colors.onSurface.s900, fontWeight: FontWeight.w700),
          ),
          content: Text(
            'This will clear your joined rooms, cached messages, and assigned room personas from this device.',
            style:
                AppTypography.bodyMedium.copyWith(color: colors.onSurface.s500),
          ),
          actions: [
            TextButton(
              onPressed: () {
                HapticService.selection();
                Navigator.of(dialogContext).pop();
              },
              child: Text(
                'Cancel',
                style: TextStyle(color: colors.onSurface.s500),
              ),
            ),
            TextButton(
              onPressed: () async {
                HapticService.heavy();
                final storage = context.read<LocalStorageService>();
                final messenger = ScaffoldMessenger.of(context);
                Navigator.of(dialogContext).pop();
                setState(() => _isResetting = true);
                try {
                  final joined = storage.getJoinedRooms();
                  await Future.wait(joined
                      .map((r) => NotificationService.unsubscribeFromRoom(r)));
                  await storage.clearAllSessionData();
                  await NotificationService.clearOnLogout();
                  AnalyticsService.logAppDataCleared();
                } catch (_) {}

                if (mounted) {
                  setState(() => _isResetting = false);
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('App data cleared successfully.'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  context.go(AppRoutes.rooms);
                }
              },
              child: const Text(
                'Clear Everything',
                style: TextStyle(
                  color: Color(0xFFFF5252),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSectionHeader(String title, AppThemeColors colors) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: AppTypography.caption.copyWith(
            color: colors.onSurface.s500,
            letterSpacing: 1.2,
            fontWeight: FontWeight.w700,
            fontSize: 11),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final userId = FirebaseService.currentUser?.uid ?? 'Anonymous';

    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: AppBar(
        backgroundColor: colors.canvas,
        elevation: 0,
        centerTitle: true,
        leadingWidth: 56,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: AppBackButton(
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go(AppRoutes.rooms);
              }
            },
          ),
        ),
        title: Text(
          'Settings',
          style: AppTypography.titleLarge.copyWith(
              color: colors.onSurface.s900, fontWeight: FontWeight.w700),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          // 0. ACCOUNT / USER ID
          _buildSectionHeader('ACCOUNT', colors),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: colors.surface.s100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: colors.surface.s300,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.fingerprint_rounded,
                    color: colors.primary.s500,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Logged In User ID',
                        style: AppTypography.titleSmall.copyWith(
                            color: colors.onSurface.s900,
                            fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        userId,
                        style: AppTypography.caption.copyWith(
                            color: colors.onSurface.s500,
                            fontFamily: 'monospace',
                            fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.copy_rounded,
                    color: colors.onSurface.s500,
                    size: 18,
                  ),
                  tooltip: 'Copy User ID',
                  onPressed: () {
                    HapticService.selection();
                    Clipboard.setData(ClipboardData(text: userId));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('User ID copied to clipboard'),
                        behavior: SnackBarBehavior.floating,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 1. APPEARANCE
          _buildSectionHeader('APPEARANCE', colors),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: colors.surface.s100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: colors.surface.s300,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.palette_rounded,
                    color: colors.primary.s500,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Appearance Theme',
                        style: AppTypography.titleSmall.copyWith(
                            color: colors.onSurface.s900,
                            fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Switch Dark / Light mode',
                        style: AppTypography.caption
                            .copyWith(color: colors.onSurface.s500),
                      ),
                    ],
                  ),
                ),
                const ThemeSwitcherButton(size: 38),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 2. NOTIFICATIONS
          _buildSectionHeader('NOTIFICATIONS', colors),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: colors.surface.s100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: InkWell(
              onTap: _openNotificationSettings,
              borderRadius: BorderRadius.circular(20),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: colors.surface.s300,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.notifications_active_rounded,
                      color: colors.primary.s500,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Push Notifications',
                          style: AppTypography.titleSmall.copyWith(
                              color: colors.onSurface.s900,
                              fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _notificationsEnabled
                              ? 'Notifications are enabled'
                              : 'Tap to enable in Settings',
                          style: AppTypography.caption.copyWith(
                            color: _notificationsEnabled
                                ? colors.primary.s500
                                : const Color(0xFFFF9800),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch.adaptive(
                    value: _notificationsEnabled,
                    activeTrackColor: colors.primary.s500,
                    onChanged: (_) => _openNotificationSettings(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // 3. STORAGE & RESET
          _buildSectionHeader('DATA & STORAGE', colors),
          Material(
            color: colors.surface.s100,
            borderRadius: BorderRadius.circular(20),
            clipBehavior: Clip.antiAlias,
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF5252).withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.delete_sweep_rounded,
                  color: Color(0xFFFF5252),
                  size: 22,
                ),
              ),
              title: const Text(
                'Clear App Data',
                style: TextStyle(
                  color: Color(0xFFFF5252),
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              subtitle: Text(
                'Reset all joined rooms and local cache',
                style: AppTypography.caption
                    .copyWith(color: colors.onSurface.s500),
              ),
              trailing: _isResetting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(
                      Icons.chevron_right_rounded,
                      color: Color(0xFFFF5252),
                    ),
              onTap: () => _confirmResetData(colors),
            ),
          ),
          const SizedBox(height: 24),

          // 4. ABOUT
          _buildSectionHeader('ABOUT', colors),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.surface.s100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: colors.surface.s300,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.info_outline_rounded,
                    color: colors.primary.s500,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Rumour',
                        style: AppTypography.titleSmall.copyWith(
                            color: colors.onSurface.s900,
                            fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Version 1.0.0 • Ephemeral Anonymous Chat',
                        style: AppTypography.caption
                            .copyWith(color: colors.onSurface.s500),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
