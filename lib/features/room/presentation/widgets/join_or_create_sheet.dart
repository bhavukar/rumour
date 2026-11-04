import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rumour/components/app_button.dart';
import 'package:rumour/components/shimmer.dart';
import 'package:rumour/config/themes/app_theme_colors.dart';
import 'package:rumour/config/themes/app_typography.dart';
import 'package:rumour/features/room/presentation/widgets/room_code_input.dart';
import 'package:rumour/services/haptics/haptic_service.dart';

class JoinOrCreateSheet extends StatefulWidget {
  final ValueChanged<String> onJoin;
  final VoidCallback onCreate;
  final bool isBusy;
  final String? busyText;
  final String? errorMessage;

  const JoinOrCreateSheet({
    super.key,
    required this.onJoin,
    required this.onCreate,
    this.isBusy = false,
    this.busyText,
    this.errorMessage,
  });

  static Future<void> show({
    required BuildContext context,
    required ValueChanged<String> onJoin,
    required VoidCallback onCreate,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => JoinOrCreateSheet(
        onJoin: onJoin,
        onCreate: onCreate,
      ),
    );
  }

  @override
  State<JoinOrCreateSheet> createState() => _JoinOrCreateSheetState();
}

class _JoinOrCreateSheetState extends State<JoinOrCreateSheet> {
  final TextEditingController _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    final sheetBg = isDark ? const Color(0xFF141923) : colors.surface.s100;
    final dividerColor =
        isDark ? const Color(0xFF222632) : const Color(0xFFE5E7EB);

    return Container(
      decoration: BoxDecoration(
        color: sheetBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom: bottomInset > 0 ? bottomInset + 16 : bottomPadding + 20,
      ),
      child: SingleChildScrollView(
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
            const SizedBox(height: 18),
            Text(
              'Start A Conversation',
              style: AppTypography.headlineSmall.copyWith(
                  color: colors.onSurface.s900, fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              'Create a fresh room or enter a 6-character room code',
              style: AppTypography.captionRegular
                  .copyWith(color: colors.onSurface.s500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (widget.isBusy)
              RoomActionShimmer(
                text: widget.busyText ?? 'Connecting to room...',
              )
            else ...[
              AppButton(
                text: 'Create a New Room',
                backgroundColor: colors.primary.s500,
                foregroundColor: colors.onPrimary,
                onPressed: () {
                  HapticService.selection();
                  FocusManager.instance.primaryFocus?.unfocus();
                  SystemChannels.textInput.invokeMethod('TextInput.hide');
                  widget.onCreate();
                },
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 1,
                      color: dividerColor,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Text(
                      'OR JOIN WITH CODE',
                      style: AppTypography.caption.copyWith(
                          color: colors.onSurface.s500,
                          letterSpacing: 1.0,
                          fontWeight: FontWeight.w600,
                          fontSize: 11),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 1,
                      color: dividerColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              RoomCodeInput(
                controller: _codeController,
                onChanged: (_) {},
                onCompleted: (code) {
                  FocusManager.instance.primaryFocus?.unfocus();
                  SystemChannels.textInput.invokeMethod('TextInput.hide');
                  widget.onJoin(code);
                },
              ),
              if (widget.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    widget.errorMessage!,
                    style: const TextStyle(
                      color: Color(0xFFFF5252),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              const SizedBox(height: 16),
              AppButton(
                text: 'Join Room',
                backgroundColor: colors.surface.s300,
                foregroundColor: colors.primary.s500,
                onPressed: () {
                  FocusManager.instance.primaryFocus?.unfocus();
                  SystemChannels.textInput.invokeMethod('TextInput.hide');
                  final code = _codeController.text.trim();
                  if (code.isNotEmpty) {
                    widget.onJoin(code);
                  }
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
