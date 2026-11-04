import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rumour/config/themes/app_theme_colors.dart';
import 'package:rumour/config/themes/app_typography.dart';
import 'package:rumour/features/chat/data/model/chat_message_model.dart';
import 'package:rumour/services/haptics/haptic_service.dart';
import 'package:rumour/utilities/date_formatter.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessageModel message;
  final bool isMine;
  final String? avatarUrl;
  final bool isAdmin;
  final bool isFirstInGroup;
  final bool isLastInGroup;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isMine,
    this.avatarUrl,
    this.isAdmin = false,
    this.isFirstInGroup = true,
    this.isLastInGroup = true,
  });

  void _copyText(BuildContext context, AppThemeColors colors) {
    HapticService.medium();
    Clipboard.setData(ClipboardData(text: message.text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Message copied to clipboard'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        backgroundColor: colors.surfaceVariant,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final timeStr = DateFormatter.formatMessageTime(message.createdAt);

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth =
            constraints.maxWidth.isFinite ? constraints.maxWidth : screenWidth;
        final isNarrow = availableWidth < 360;
        final maxBubbleWidth = availableWidth * (isNarrow ? 0.80 : 0.74);
        final sideOffset = isNarrow ? 28.0 : 48.0;

        if (isMine) {
          return Padding(
            padding: EdgeInsets.only(
              left: sideOffset,
              right: 16,
              bottom: isLastInGroup ? 14 : 3,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isFirstInGroup)
                        Padding(
                          padding: const EdgeInsets.only(right: 4, bottom: 4),
                          child: Text(
                            'You',
                            style: AppTypography.labelMedium.copyWith(
                              color: isDark
                                  ? const Color(0xFF8E9BAE)
                                  : colors.onSurface.s500,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      GestureDetector(
                        onLongPress: () => _copyText(context, colors),
                        child: Container(
                          constraints: BoxConstraints(
                            minWidth: 54,
                            maxWidth: maxBubbleWidth,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFA3E635),
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(18),
                              bottomLeft: const Radius.circular(18),
                              topRight:
                                  Radius.circular(isFirstInGroup ? 18 : 6),
                              bottomRight:
                                  Radius.circular(isLastInGroup ? 18 : 6),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (message.isReply)
                                Container(
                                  width: double.infinity,
                                  margin: const EdgeInsets.only(bottom: 6),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0F141C)
                                        .withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(8),
                                    border: const Border(
                                      left: BorderSide(
                                        color: Color(0xFF0F141C),
                                        width: 3,
                                      ),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        message.replyToSenderName ?? 'Reply',
                                        style:
                                            AppTypography.labelSmall.copyWith(
                                          color: const Color(0xFF0F141C),
                                          fontWeight: FontWeight.w700,
                                          fontSize: 11,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        message.replyToText!,
                                        style: AppTypography.captionRegular
                                            .copyWith(
                                          color: const Color(0xFF0F141C)
                                              .withValues(alpha: 0.85),
                                          fontSize: 12,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              Text(
                                message.text,
                                textAlign: TextAlign.start,
                                softWrap: true,
                                style: const TextStyle(
                                  color: Color(0xFF0F141C),
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w500,
                                  height: 1.35,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    timeStr,
                                    style: const TextStyle(
                                      color: Color(0xFF365314),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  if (message.isPending) ...[
                                    const SizedBox(width: 4),
                                    const Icon(
                                      Icons.access_time_rounded,
                                      size: 11,
                                      color: Color(0xFF365314),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        } else {
          final handleText = message.senderMention.isNotEmpty
              ? message.senderMention
              : '@${message.senderName.replaceAll(' ', '')}';

          final incomingBg =
              isDark ? const Color(0xFF101522) : colors.surface.s200;
          final incomingTextColor =
              isDark ? const Color(0xFFFFFFFF) : colors.onSurface.s900;
          final incomingTimeColor = isDark
              ? const Color(0xFF8E9BAE).withValues(alpha: 0.75)
              : colors.onSurface.s400;

          return Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: sideOffset,
              bottom: isLastInGroup ? 14 : 3,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isFirstInGroup)
                        Padding(
                          padding: const EdgeInsets.only(left: 4, bottom: 4),
                          child: Text(
                            handleText,
                            style: TextStyle(
                              color: isDark
                                  ? const Color(0xFFFFFFFF)
                                  : colors.onSurface.s900,
                              fontWeight: FontWeight.w700,
                              fontSize: 13.5,
                            ),
                          ),
                        ),
                      GestureDetector(
                        onLongPress: () => _copyText(context, colors),
                        child: Container(
                          constraints: BoxConstraints(
                            minWidth: 54,
                            maxWidth: maxBubbleWidth,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: incomingBg,
                            borderRadius: BorderRadius.only(
                              topRight: const Radius.circular(18),
                              bottomRight: const Radius.circular(18),
                              topLeft: Radius.circular(isFirstInGroup ? 18 : 6),
                              bottomLeft:
                                  Radius.circular(isLastInGroup ? 18 : 6),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (message.isReply)
                                Container(
                                  width: double.infinity,
                                  margin: const EdgeInsets.only(bottom: 6),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: colors.surface.s300
                                        .withValues(alpha: 0.6),
                                    borderRadius: BorderRadius.circular(8),
                                    border: const Border(
                                      left: BorderSide(
                                        color: Color(0xFFA3E635),
                                        width: 3,
                                      ),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        message.replyToSenderName ?? 'Reply',
                                        style:
                                            AppTypography.labelSmall.copyWith(
                                          color: const Color(0xFFA3E635),
                                          fontWeight: FontWeight.w700,
                                          fontSize: 11,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        message.replyToText!,
                                        style: AppTypography.captionRegular
                                            .copyWith(
                                                color: colors.onSurface.s700,
                                                fontSize: 12),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              Text(
                                message.text,
                                textAlign: TextAlign.start,
                                softWrap: true,
                                style: TextStyle(
                                  color: incomingTextColor,
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w400,
                                  height: 1.35,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                timeStr,
                                style: TextStyle(
                                  color: incomingTimeColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
