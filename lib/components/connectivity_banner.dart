import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rumour/config/themes/app_colors.dart';
import 'package:rumour/config/themes/app_typography.dart';
import 'package:rumour/services/network/connectivity_cubit.dart';

class ConnectivityOverlay extends StatefulWidget {
  final Widget child;

  const ConnectivityOverlay({
    super.key,
    required this.child,
  });

  @override
  State<ConnectivityOverlay> createState() => _ConnectivityOverlayState();
}

class _ConnectivityOverlayState extends State<ConnectivityOverlay> {
  bool _isVisible = false;
  bool _isRestored = false;
  Timer? _dismissTimer;

  @override
  void dispose() {
    _dismissTimer?.cancel();
    super.dispose();
  }

  void _handleStateChange(BuildContext context, ConnectivityState state) {
    _dismissTimer?.cancel();

    if (state.isDisconnected) {
      setState(() {
        _isVisible = true;
        _isRestored = false;
      });
    } else if (state.isConnected && state.wasDisconnected) {
      setState(() {
        _isVisible = true;
        _isRestored = true;
      });

      _dismissTimer = Timer(const Duration(milliseconds: 2500), () {
        if (mounted) {
          setState(() {
            _isVisible = false;
            _isRestored = false;
          });
        }
      });
    } else {
      setState(() {
        _isVisible = false;
        _isRestored = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ConnectivityCubit, ConnectivityState>(
      listener: _handleStateChange,
      child: Stack(
        children: [
          widget.child,
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              top: true,
              bottom: false,
              child: AnimatedSlide(
                offset: _isVisible ? const Offset(0, 0) : const Offset(0, -1.5),
                duration: const Duration(milliseconds: 320),
                curve: Curves.easeOutCubic,
                child: AnimatedOpacity(
                  opacity: _isVisible ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 250),
                  child: Material(
                    type: MaterialType.transparency,
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: _isRestored
                            ? const Color(0xFF142416)
                            : const Color(0xFF221417),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _isRestored
                              ? AppColors.primary.s500.withValues(alpha: 0.3)
                              : const Color(0xFFFF5252).withValues(alpha: 0.35),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.4),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: _isRestored
                                  ? AppColors.primary.s500
                                      .withValues(alpha: 0.15)
                                  : const Color(0xFFFF5252)
                                      .withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _isRestored
                                  ? Icons.wifi_rounded
                                  : Icons.wifi_off_rounded,
                              size: 20,
                              color: _isRestored
                                  ? AppColors.primary.s500
                                  : const Color(0xFFFF5252),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _isRestored
                                      ? 'Back Online'
                                      : 'No Internet Connection',
                                  style: AppTypography.titleSmall.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _isRestored
                                      ? 'Reconnected · Messages synced'
                                      : 'Offline mode · Changes will sync when online',
                                  style: AppTypography.caption.copyWith(
                                    color: _isRestored
                                        ? AppColors.primary.s500
                                            .withValues(alpha: 0.9)
                                        : const Color(0xFFFFB4B4),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (!_isRestored)
                            GestureDetector(
                              onTap: () {
                                context
                                    .read<ConnectivityCubit>()
                                    .checkConnection();
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'Retry',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
