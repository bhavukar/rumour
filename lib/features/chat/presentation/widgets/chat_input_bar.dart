import 'package:flutter/material.dart';
import 'package:rumour/config/themes/app_theme_colors.dart';
import 'package:rumour/config/themes/app_typography.dart';
import 'package:rumour/features/chat/data/model/chat_message_model.dart';
import 'package:rumour/services/haptics/haptic_service.dart';

class ChatInputBar extends StatefulWidget {
  final ValueChanged<String> onSend;
  final bool isSending;
  final ChatMessageModel? replyingTo;
  final VoidCallback? onCancelReply;

  const ChatInputBar({
    super.key,
    required this.onSend,
    this.isSending = false,
    this.replyingTo,
    this.onCancelReply,
  });

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  bool _hasContent = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();
    _controller.addListener(() {
      final hasText = _controller.text.trim().isNotEmpty;
      if (hasText != _hasContent) {
        setState(() => _hasContent = hasText);
      }
    });
  }

  @override
  void didUpdateWidget(covariant ChatInputBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.replyingTo != null && oldWidget.replyingTo == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_focusNode.hasFocus) {
          _focusNode.requestFocus();
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isEmpty || widget.isSending) return;
    HapticService.light();
    widget.onSend(text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final replyingTo = widget.replyingTo;

    final inputBgColor = isDark ? const Color(0xFF131824) : colors.surface.s300;
    final hintColor = isDark ? const Color(0xFF8E9BAE) : colors.onSurface.s500;
    final textColor = colors.onSurface.s900;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final bottomPadding = MediaQuery.paddingOf(context).bottom;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final horizontalPadding = screenWidth < 360 ? 10.0 : 16.0;

    return Container(
      color: colors.canvas,
      padding: EdgeInsets.only(
        left: horizontalPadding,
        right: horizontalPadding,
        top: 8,
        bottom: bottomInset > 0 ? 8 : (bottomPadding > 0 ? bottomPadding : 12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (replyingTo != null) ...[
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: colors.surface.s300,
                borderRadius: BorderRadius.circular(14),
                border: Border(
                  left: BorderSide(
                    color: colors.primary.s500,
                    width: 3.5,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.reply_rounded,
                    size: 18,
                    color: colors.primary.s500,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Replying to ${replyingTo.senderName}',
                          style: AppTypography.labelSmall.copyWith(
                              color: colors.primary.s500,
                              fontWeight: FontWeight.w700),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          replyingTo.text,
                          style: AppTypography.captionRegular.copyWith(
                              color: colors.onSurface.s700, fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      HapticService.selection();
                      widget.onCancelReply?.call();
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: colors.surface.s200,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          Icons.close_rounded,
                          size: 14,
                          color: colors.onSurface.s700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Container(
                  constraints: const BoxConstraints(
                    minHeight: 48,
                    maxHeight: 120,
                  ),
                  decoration: BoxDecoration(
                    color: inputBgColor,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    textAlignVertical: TextAlignVertical.center,
                    textCapitalization: TextCapitalization.sentences,
                    keyboardAppearance:
                        isDark ? Brightness.dark : Brightness.light,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: textColor,
                      height: 1.25,
                    ),
                    minLines: 1,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: replyingTo != null
                          ? 'Type your reply...'
                          : 'Type a message',
                      hintStyle: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: hintColor,
                        height: 1.25,
                      ),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 14,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                    onSubmitted: (_) => _handleSend(),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: _hasContent && !widget.isSending ? _handleSend : null,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: colors.primary.s500,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: widget.isSending
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: colors.onPrimary,
                            ),
                          )
                        : Icon(
                            Icons.near_me_rounded,
                            size: 22,
                            color: colors.onPrimary,
                          ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
