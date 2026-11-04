import 'package:flutter/material.dart';
import 'package:rumour/config/themes/app_theme_colors.dart';

class Shimmer extends StatefulWidget {
  final Widget child;
  final Color? baseColor;
  final Color? highlightColor;
  final Duration duration;

  const Shimmer({
    super.key,
    required this.child,
    this.baseColor,
    this.highlightColor,
    this.duration = const Duration(milliseconds: 1400),
  });

  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final base = widget.baseColor ?? colors.surface.s300;
    final highlight =
        widget.highlightColor ?? colors.surface.s500.withValues(alpha: 0.5);

    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            final value = _controller.value;
            return LinearGradient(
              begin: Alignment(value * 4 - 2, -0.3),
              end: Alignment(value * 4, 0.3),
              colors: [
                base,
                highlight,
                base,
              ],
              stops: const [0.0, 0.5, 1.0],
            ).createShader(bounds);
          },
          child: child,
        );
      },
    );
  }
}

class ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;
  final Color? color;

  const ShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color ?? colors.surface.s300,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

class RoomActionShimmer extends StatelessWidget {
  final String text;

  const RoomActionShimmer({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Shimmer(
      baseColor: colors.surface.s200,
      highlightColor: colors.surface.s500.withValues(alpha: 0.4),
      child: Container(
        height: 54,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: colors.surface.s200,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const ShimmerBox(width: 18, height: 18, borderRadius: 9),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: colors.onSurface.s900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatLoadingSkeleton extends StatelessWidget {
  const ChatLoadingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Shimmer(
      baseColor: colors.surface.s200,
      highlightColor: colors.surface.s500.withValues(alpha: 0.35),
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        children: [
          _buildIncomingSkeleton(width: 220, lines: 2),
          const SizedBox(height: 16),
          _buildOutgoingSkeleton(width: 180, lines: 1),
          const SizedBox(height: 16),
          _buildIncomingSkeleton(width: 260, lines: 3),
          const SizedBox(height: 16),
          _buildOutgoingSkeleton(width: 210, lines: 2),
          const SizedBox(height: 16),
          _buildIncomingSkeleton(width: 140, lines: 1),
        ],
      ),
    );
  }

  Widget _buildIncomingSkeleton({required double width, required int lines}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const ShimmerBox(width: 32, height: 32, borderRadius: 16),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ShimmerBox(width: 80, height: 10, borderRadius: 4),
            const SizedBox(height: 6),
            ShimmerBox(
              width: width,
              height: 24.0 * lines + 16,
              borderRadius: 18,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOutgoingSkeleton({required double width, required int lines}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const ShimmerBox(width: 40, height: 10, borderRadius: 4),
            const SizedBox(height: 6),
            ShimmerBox(
              width: width,
              height: 24.0 * lines + 16,
              borderRadius: 18,
            ),
          ],
        ),
        const SizedBox(width: 8),
        const ShimmerBox(width: 32, height: 32, borderRadius: 16),
      ],
    );
  }
}
