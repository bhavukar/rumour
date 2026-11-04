import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rumour/config/themes/app_theme_colors.dart';
import 'package:rumour/features/room/data/model/room_identity_model.dart';
import 'package:rumour/services/haptics/haptic_service.dart';

class IdentitySheet extends StatelessWidget {
  final RoomIdentityModel identity;
  final VoidCallback onAcknowledge;

  const IdentitySheet({
    super.key,
    required this.identity,
    required this.onAcknowledge,
  });

  static Future<void> show({
    required BuildContext context,
    required RoomIdentityModel identity,
    required VoidCallback onAcknowledge,
  }) {
    FocusManager.instance.primaryFocus?.unfocus();
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      builder: (sheetContext) => MediaQuery.removeViewInsets(
        removeBottom: true,
        context: sheetContext,
        child: IdentitySheet(
          identity: identity,
          onAcknowledge: onAcknowledge,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final name = identity.displayName;
    final formattedName =
        name.contains(' ') ? name.replaceFirst(' ', '\n') : name;

    final size = MediaQuery.sizeOf(context);
    final screenHeight = size.height;
    final screenWidth = size.width;
    final isCompact = screenHeight < 720;
    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    final sheetBg = isDark ? const Color(0xFF141923) : colors.surface.s100;
    final subtitleColor =
        isDark ? const Color(0xFF8E9BAE) : colors.onSurface.s500;
    const limeAccent = Color(0xFFA3E635);

    return PopScope(
      canPop: false,
      child: SafeArea(
        top: false,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: sheetBg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: EdgeInsets.fromLTRB(
            screenWidth < 360 ? 18 : 24,
            12,
            screenWidth < 360 ? 18 : 24,
            bottomPadding > 0 ? bottomPadding + 12 : 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.onSurface.s500.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              SizedBox(height: isCompact ? 18 : 24),
              Text(
                'For this room, you are',
                style: TextStyle(
                  fontSize: isCompact ? 13 : 14,
                  fontWeight: FontWeight.w400,
                  color: subtitleColor,
                  letterSpacing: 0.1,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: isCompact ? 14 : 20),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  formattedName,
                  style: TextStyle(
                    fontSize: isCompact ? 40 : 48,
                    fontWeight: FontWeight.w900,
                    height: 1.05,
                    letterSpacing: -1.0,
                    color: limeAccent,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                ),
              ),
              SizedBox(height: isCompact ? 14 : 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  'This is your anonymous identifier, visible only to others in this room.',
                  style: TextStyle(
                    fontSize: isCompact ? 13 : 14,
                    fontWeight: FontWeight.w400,
                    color: subtitleColor,
                    height: 1.35,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: isCompact ? 20 : 28),
              SizedBox(
                height: isCompact ? 50 : 54,
                child: ElevatedButton(
                  onPressed: () {
                    HapticService.medium();
                    onAcknowledge();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: limeAccent,
                    foregroundColor: const Color(0xFF0F141C),
                    elevation: 0,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Text(
                    'Acknowledge and continue',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                      color: Color(0xFF0F141C),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
