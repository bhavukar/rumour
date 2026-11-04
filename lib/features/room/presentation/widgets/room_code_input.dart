import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rumour/config/themes/app_theme_colors.dart';
import 'package:rumour/config/themes/app_typography.dart';
import 'package:rumour/services/haptics/haptic_service.dart';

class RoomCodeInput extends StatefulWidget {
  final int length;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onCompleted;
  final TextEditingController? controller;
  final bool autofocus;

  const RoomCodeInput({
    super.key,
    this.length = 6,
    required this.onChanged,
    required this.onCompleted,
    this.controller,
    this.autofocus = false,
  });

  @override
  State<RoomCodeInput> createState() => _RoomCodeInputState();
}

class _RoomCodeInputState extends State<RoomCodeInput> {
  late final TextEditingController _internalController;
  late final FocusNode _focusNode;

  TextEditingController get _controller =>
      widget.controller ?? _internalController;

  @override
  void initState() {
    super.initState();
    _internalController = TextEditingController();
    _focusNode = FocusNode();
    _controller.addListener(_handleTextChange);
  }

  @override
  void dispose() {
    _controller.removeListener(_handleTextChange);
    if (widget.controller == null) {
      _internalController.dispose();
    }
    _focusNode.dispose();
    super.dispose();
  }

  void _handleTextChange() {
    final text = _controller.text.toUpperCase();
    if (text != _controller.text) {
      _controller.value = _controller.value.copyWith(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
    }
    if (text.isNotEmpty) {
      HapticService.selection();
    }
    widget.onChanged(text);
    if (text.length == widget.length) {
      HapticService.medium();
      _focusNode.unfocus();
      FocusManager.instance.primaryFocus?.unfocus();
      SystemChannels.textInput.invokeMethod('TextInput.hide');
      widget.onCompleted(text);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final currentText = _controller.text;

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = MediaQuery.sizeOf(context).width;
        final availableWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : (screenWidth - 48);
        final horizontalPadding = availableWidth < 320 ? 8.0 : 16.0;

        return GestureDetector(
          onTap: () {
            if (_focusNode.hasFocus) {
              _focusNode.unfocus();
              FocusManager.instance.primaryFocus?.unfocus();
              SystemChannels.textInput.invokeMethod('TextInput.hide');
            } else {
              _focusNode.requestFocus();
            }
          },
          behavior: HitTestBehavior.opaque,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(
                child: Opacity(
                  opacity: 0,
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    autofocus: widget.autofocus,
                    keyboardType: TextInputType.text,
                    textCapitalization: TextCapitalization.characters,
                    maxLength: widget.length,
                    onTap: () {
                      if (_focusNode.hasFocus &&
                          _controller.text.length == widget.length) {
                        _focusNode.unfocus();
                        FocusManager.instance.primaryFocus?.unfocus();
                        SystemChannels.textInput.invokeMethod('TextInput.hide');
                      }
                    },
                    buildCounter: (_,
                            {required currentLength,
                            required isFocused,
                            maxLength}) =>
                        null,
                  ),
                ),
              ),
              Container(
                constraints: const BoxConstraints(maxWidth: 380),
                width: double.infinity,
                height: 56,
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                decoration: BoxDecoration(
                  color: colors.surface.s300,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(widget.length, (index) {
                    final isEntered = index < currentText.length;
                    final char = isEntered ? currentText[index] : '';
                    final isCurrent =
                        index == currentText.length && _focusNode.hasFocus;

                    return Expanded(
                      child: Container(
                        alignment: Alignment.center,
                        child: isEntered
                            ? FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  char,
                                  style: AppTypography.headlineSmall.copyWith(
                                      color: colors.onSurface.s900,
                                      fontWeight: FontWeight.w700),
                                ),
                              )
                            : Container(
                                width: availableWidth < 320 ? 10 : 14,
                                height: 3,
                                decoration: BoxDecoration(
                                  color: isCurrent
                                      ? colors.primary.s500
                                      : colors.onSurface.s500
                                          .withValues(alpha: 0.4),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
