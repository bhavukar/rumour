import 'package:flutter/material.dart';
import 'package:rumour/config/themes/app_theme_colors.dart';
import 'package:rumour/services/haptics/haptic_service.dart';

class SwipeToReply extends StatefulWidget {
  final Widget child;
  final VoidCallback onReply;
  final bool isMine;

  const SwipeToReply({
    super.key,
    required this.child,
    required this.onReply,
    this.isMine = false,
  });

  @override
  State<SwipeToReply> createState() => _SwipeToReplyState();
}

class _SwipeToReplyState extends State<SwipeToReply>
    with SingleTickerProviderStateMixin {
  static const double _triggerThreshold = 40.0;
  static const double _maxDragOffset = 72.0;

  late final AnimationController _animController;
  late Animation<double> _animOffset;

  double _dragOffset = 0.0;
  bool _hapticTriggered = false;

  @override
  void initState() {
    super.initState();
    _animOffset = const AlwaysStoppedAnimation<double>(0.0);
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    )..addListener(() {
        if (!mounted) return;
        setState(() {
          _dragOffset = _animOffset.value;
        });
      });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    if (_animController.isAnimating) return;

    final delta = details.primaryDelta ?? 0.0;
    final newOffset =
        (_dragOffset + delta).clamp(-_maxDragOffset, _maxDragOffset);

    if (newOffset != _dragOffset) {
      setState(() {
        _dragOffset = newOffset;
      });

      if (_dragOffset.abs() >= _triggerThreshold && !_hapticTriggered) {
        _hapticTriggered = true;
        HapticService.light();
      } else if (_dragOffset.abs() < _triggerThreshold) {
        _hapticTriggered = false;
      }
    }
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    if (_dragOffset.abs() >= _triggerThreshold) {
      HapticService.medium();
      widget.onReply();
    }
    _animateBack();
  }

  void _onHorizontalDragCancel() {
    _animateBack();
  }

  void _animateBack() {
    _hapticTriggered = false;
    _animOffset = Tween<double>(
      begin: _dragOffset,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutBack,
    ));
    _animController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final progress = (_dragOffset.abs() / _triggerThreshold).clamp(0.0, 1.0);

    return GestureDetector(
      onHorizontalDragUpdate: _onHorizontalDragUpdate,
      onHorizontalDragEnd: _onHorizontalDragEnd,
      onHorizontalDragCancel: _onHorizontalDragCancel,
      behavior: HitTestBehavior.translucent,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (_dragOffset > 4)
            Positioned(
              left: 16 + (_dragOffset * 0.15),
              child: Opacity(
                opacity: progress,
                child: Transform.scale(
                  scale: 0.6 + (progress * 0.4),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: progress >= 1.0
                          ? colors.primary.s500
                          : colors.surface.s300,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        Icons.reply_rounded,
                        size: 18,
                        color: progress >= 1.0
                            ? colors.onPrimary
                            : colors.onSurface.s700,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          if (_dragOffset < -4)
            Positioned(
              right: 16 + (-_dragOffset * 0.15),
              child: Opacity(
                opacity: progress,
                child: Transform.scale(
                  scale: 0.6 + (progress * 0.4),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: progress >= 1.0
                          ? colors.primary.s500
                          : colors.surface.s300,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        Icons.reply_rounded,
                        size: 18,
                        color: progress >= 1.0
                            ? colors.onPrimary
                            : colors.onSurface.s700,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          Transform.translate(
            offset: Offset(_dragOffset, 0),
            child: widget.child,
          ),
        ],
      ),
    );
  }
}
