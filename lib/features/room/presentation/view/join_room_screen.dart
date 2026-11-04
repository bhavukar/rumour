import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:go_router/go_router.dart';
import 'package:rumour/components/app_badge.dart';
import 'package:rumour/components/app_button.dart';
import 'package:rumour/components/room_avatar.dart';
import 'package:rumour/components/shimmer.dart';
import 'package:rumour/config/themes/app_theme_colors.dart';
import 'package:rumour/config/themes/app_typography.dart';
import 'package:rumour/features/chat/data/repositories/chat_repository.dart';
import 'package:rumour/features/room/data/model/room_identity_model.dart';
import 'package:rumour/features/room/data/model/room_model.dart';
import 'package:rumour/features/room/data/repositories/room_repository.dart';
import 'package:rumour/features/room/presentation/bloc/room_bloc.dart';
import 'package:rumour/features/room/presentation/bloc/room_event.dart';
import 'package:rumour/features/room/presentation/bloc/room_state.dart';
import 'package:rumour/features/room/presentation/widgets/identity_sheet.dart';
import 'package:rumour/features/room/presentation/widgets/join_or_create_sheet.dart';
import 'package:rumour/features/room/presentation/widgets/room_code_input.dart';
import 'package:rumour/services/haptics/haptic_service.dart';
import 'package:rumour/services/notifications/notification_service.dart';
import 'package:rumour/services/routes/app_routes.dart';
import 'package:rumour/services/storage/local_storage_service.dart';
import 'package:rumour/utilities/date_formatter.dart';
import 'package:rumour/utilities/room_name_generator.dart';

class JoinRoomScreen extends StatefulWidget {
  const JoinRoomScreen({super.key});

  @override
  State<JoinRoomScreen> createState() => _JoinRoomScreenState();
}

class _JoinRoomScreenState extends State<JoinRoomScreen>
    with WidgetsBindingObserver {
  final TextEditingController _codeController = TextEditingController();
  List<String> _joinedRooms = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    FlutterNativeSplash.remove();
    _loadJoinedRooms();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadJoinedRooms();
    }
  }

  void _loadJoinedRooms() {
    try {
      final storage = context.read<LocalStorageService>();
      final rooms = storage.getJoinedRooms();
      setState(() {
        _joinedRooms = rooms;
      });
      for (final code in rooms) {
        NotificationService.subscribeToRoom(code);
      }
      _syncRooms();
    } catch (_) {}
  }

  Future<void> _syncRooms() async {
    try {
      final roomRepo = context.read<RoomRepository>();
      final storage = context.read<LocalStorageService>();
      final currentRooms = storage.getJoinedRooms();
      if (currentRooms.isEmpty) return;

      final pruned = await roomRepo
          .syncAndPruneJoinedRooms(currentRooms)
          .timeout(const Duration(seconds: 3));
      if (mounted) {
        setState(() {
          _joinedRooms = pruned;
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _codeController.dispose();
    super.dispose();
  }

  void _navigateToChat(String roomCode, RoomIdentityModel identity) {
    try {
      final storage = context.read<LocalStorageService>();
      storage.saveActiveRoom(roomCode);
      NotificationService.subscribeToRoom(roomCode);
      _loadJoinedRooms();
    } catch (_) {}

    context
        .push(
      AppRoutes.chatRoomPath(roomCode),
      extra: identity,
    )
        .then((_) {
      if (mounted) {
        _loadJoinedRooms();
      }
    });
  }

  void _openJoinOrCreateSheet(BuildContext context) {
    HapticService.selection();
    FocusManager.instance.primaryFocus?.unfocus();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return JoinOrCreateSheet(
          onJoin: (code) {
            FocusManager.instance.primaryFocus?.unfocus();
            Navigator.of(sheetContext).pop();
            context.read<RoomBloc>().add(JoinRoomSubmitted(code));
          },
          onCreate: () {
            FocusManager.instance.primaryFocus?.unfocus();
            Navigator.of(sheetContext).pop();
            context.read<RoomBloc>().add(const CreateRoomSubmitted());
          },
        );
      },
    );
  }

  Future<void> _leaveRoom(String roomCode) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final colors = context.colors;
        return AlertDialog(
          backgroundColor: colors.surface.s200,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Leave Room #$roomCode?',
            style: AppTypography.titleMedium.copyWith(
                color: colors.onSurface.s900, fontWeight: FontWeight.w700),
          ),
          content: Text(
            'You will leave Room #$roomCode. You can always rejoin using the room code.',
            style:
                AppTypography.bodySmall.copyWith(color: colors.onSurface.s500),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(
                'Cancel',
                style: TextStyle(color: colors.onSurface.s500),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text(
                'Leave',
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

    if (confirmed == true && mounted) {
      final storage = context.read<LocalStorageService>();
      await storage.removeJoinedRoom(roomCode);
      await NotificationService.unsubscribeFromRoom(roomCode);
      HapticService.medium();
      setState(() {
        _joinedRooms = storage.getJoinedRooms();
      });
      _loadJoinedRooms();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Left Room #$roomCode. You can always rejoin using the room code.'),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dividerColor =
        isDark ? const Color(0xFF222632) : const Color(0xFFE5E7EB);

    final storage = context.read<LocalStorageService>();
    final currentSaved = storage.getJoinedRooms();
    if (_joinedRooms.length != currentSaved.length) {
      _joinedRooms = currentSaved;
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
        SystemChannels.textInput.invokeMethod('TextInput.hide');
      },
      child: Scaffold(
        backgroundColor: colors.canvas,
        body: SafeArea(
          child: BlocConsumer<RoomBloc, RoomState>(
            listener: (context, state) {
              if (state is RoomJoinedSuccess) {
                FocusManager.instance.primaryFocus?.unfocus();
                SystemChannels.textInput.invokeMethod('TextInput.hide');
                if (state.isNewIdentity) {
                  IdentitySheet.show(
                    context: context,
                    identity: state.identity,
                    onAcknowledge: () {
                      Navigator.of(context).pop();
                      _navigateToChat(state.room.code, state.identity);
                    },
                  );
                } else {
                  _navigateToChat(state.room.code, state.identity);
                }
              } else if (state is RoomJoinFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.error),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: const Color(0xFFFF5252),
                  ),
                );
              }
            },
            builder: (context, state) {
              final isJoining = state is RoomJoining;
              final isCreating = state is RoomCreating;
              final isBusy = isJoining || isCreating;
              final errorMessage =
                  state is RoomJoinFailure ? state.error : null;

              final mainContent = _joinedRooms.isNotEmpty
                  ? _buildRoomsListView(colors, isDark)
                  : _buildEmptyOnboardingView(
                      colors: colors,
                      dividerColor: dividerColor,
                      isBusy: isBusy,
                      isCreating: isCreating,
                      errorMessage: errorMessage,
                    );

              return Stack(
                children: [
                  mainContent,
                  if (isBusy)
                    _buildFullScreenLoader(
                      colors: colors,
                      isCreating: isCreating,
                    ),
                ],
              );
            },
          ),
        ),
        floatingActionButton: _joinedRooms.isNotEmpty
            ? FloatingActionButton(
                onPressed: () => _openJoinOrCreateSheet(context),
                backgroundColor: colors.primary.s500,
                foregroundColor: colors.onPrimary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(Icons.add_rounded, size: 28),
              )
            : null,
      ),
    );
  }

  Widget _buildFullScreenLoader({
    required AppThemeColors colors,
    required bool isCreating,
  }) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.75),
        alignment: Alignment.center,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 32),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 26),
          decoration: BoxDecoration(
            color: colors.surface.s100,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 44,
                height: 44,
                child: CircularProgressIndicator(
                  strokeWidth: 3.5,
                  color: colors.primary.s500,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                isCreating ? 'Creating Anonymous Room' : 'Connecting to Room',
                style: AppTypography.titleMedium.copyWith(
                    color: colors.onSurface.s900, fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                isCreating
                    ? 'Generating random persona & allocating code...'
                    : 'Verifying code & retrieving chat history...',
                style: AppTypography.bodySmall
                    .copyWith(color: colors.onSurface.s500),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoomsListView(AppThemeColors colors, bool isDark) {
    final roomRepo = context.read<RoomRepository>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 12, 12),
          child: Row(
            children: [
              AppBadge(
                icon: Icons.key_rounded,
                backgroundColor: colors.surface.s300,
                iconColor: colors.primary.s500,
                size: 40,
                iconSize: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rumour',
                      style: AppTypography.headlineSmall.copyWith(
                          color: colors.onSurface.s900,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5),
                    ),
                    Text(
                      '${_joinedRooms.length} ${_joinedRooms.length == 1 ? 'room' : 'rooms'} active',
                      style: AppTypography.captionRegular
                          .copyWith(color: colors.onSurface.s500, fontSize: 12),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.settings_outlined,
                  color: colors.onSurface.s500,
                  size: 22,
                ),
                onPressed: () {
                  HapticService.light();
                  context.push(AppRoutes.settingsPath);
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              HapticService.selection();
              await _syncRooms();
            },
            color: colors.primary.s500,
            backgroundColor: colors.surface.s200,
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _joinedRooms.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final code = _joinedRooms[index];
                final identity = roomRepo.getCachedIdentity(code);
                final chatRepo = context.read<ChatRepository>();
                final cachedLatest =
                    chatRepo.getCachedMessages(code).firstOrNull;

                return StreamBuilder<RoomModel?>(
                  stream: roomRepo.streamRoom(code),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.active &&
                        !snapshot.hasData) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) {
                          final storage = context.read<LocalStorageService>();
                          storage.removeJoinedRoom(code);
                          setState(() {
                            _joinedRooms.remove(code);
                          });
                        }
                      });
                      return const SizedBox.shrink();
                    }

                    final room = snapshot.data;
                    final memberCount = room?.memberCount ?? 1;
                    final lastTime = room?.lastMessageAt != null
                        ? DateFormatter.formatRelativeTime(room!.lastMessageAt!)
                        : (room?.createdAt != null
                            ? DateFormatter.formatRelativeTime(room!.createdAt)
                            : '');

                    String? senderHandle;
                    String messageText = '';
                    if (room?.lastMessageText != null &&
                        room!.lastMessageText!.isNotEmpty) {
                      final isMyMsg = identity != null &&
                          room.lastMessageSenderId == identity.id;
                      if (isMyMsg) {
                        senderHandle = '@You';
                      } else if (room.lastMessageSender != null &&
                          room.lastMessageSender!.isNotEmpty) {
                        final raw = room.lastMessageSender!;
                        senderHandle = raw.startsWith('@') ? raw : '@$raw';
                      }
                      messageText = room.lastMessageText!;
                    } else if (cachedLatest != null &&
                        cachedLatest.text.isNotEmpty) {
                      final isMyMsg =
                          identity != null && cachedLatest.isMine(identity.id);
                      if (isMyMsg) {
                        senderHandle = '@You';
                      } else if (cachedLatest.senderName.isNotEmpty &&
                          cachedLatest.senderName != 'Anonymous') {
                        final raw = cachedLatest.senderName;
                        senderHandle = raw.startsWith('@') ? raw : '@$raw';
                      }
                      messageText = cachedLatest.text;
                    } else {
                      messageText = 'No messages yet';
                    }

                    return Dismissible(
                      key: ValueKey('dismiss_room_$code'),
                      direction: DismissDirection.endToStart,
                      confirmDismiss: (_) async {
                        await _leaveRoom(code);
                        return false;
                      },
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        decoration: BoxDecoration(
                          color:
                              const Color(0xFFFF5252).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Icon(
                          Icons.delete_outline_rounded,
                          color: Color(0xFFFF5252),
                          size: 24,
                        ),
                      ),
                      child: Material(
                        color: colors.surface.s200,
                        borderRadius: BorderRadius.circular(18),
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: () {
                            HapticService.light();
                            FocusManager.instance.primaryFocus?.unfocus();
                            SystemChannels.textInput
                                .invokeMethod('TextInput.hide');
                            if (identity != null) {
                              _navigateToChat(code, identity);
                            } else {
                              context
                                  .read<RoomBloc>()
                                  .add(JoinRoomSubmitted(code));
                            }
                          },
                          onLongPress: () => _leaveRoom(code),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            child: Row(
                              children: [
                                RoomAvatar(
                                  roomCode: code,
                                  size: 46,
                                  showBorder: true,
                                  borderColor: colors.surface.s300,
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              '${RoomNameGenerator.generateRoomName(code)} #$code',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: AppTypography.titleMedium
                                                  .copyWith(
                                                      color:
                                                          colors.onSurface.s900,
                                                      fontWeight:
                                                          FontWeight.w700),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          if (lastTime.isNotEmpty)
                                            Text(
                                              lastTime,
                                              style: AppTypography
                                                  .captionRegular
                                                  .copyWith(
                                                      color:
                                                          colors.onSurface.s500,
                                                      fontSize: 11),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text.rich(
                                              TextSpan(
                                                children: [
                                                  if (senderHandle != null) ...[
                                                    TextSpan(
                                                      text: '$senderHandle : ',
                                                      style: AppTypography
                                                          .bodySmall
                                                          .copyWith(
                                                              color: colors
                                                                  .primary.s500,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700,
                                                              fontSize: 13),
                                                    ),
                                                  ],
                                                  TextSpan(
                                                    text: messageText,
                                                    style: AppTypography
                                                        .bodySmall
                                                        .copyWith(
                                                      color: messageText ==
                                                              'No messages yet'
                                                          ? colors
                                                              .onSurface.s500
                                                              .withValues(
                                                                  alpha: 0.6)
                                                          : colors
                                                              .onSurface.s500,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.people_outline_rounded,
                                                size: 13,
                                                color: colors.onSurface.s500
                                                    .withValues(alpha: 0.6),
                                              ),
                                              const SizedBox(width: 3),
                                              Text(
                                                '$memberCount',
                                                style: AppTypography
                                                    .captionRegular
                                                    .copyWith(
                                                  color: colors.onSurface.s500
                                                      .withValues(alpha: 0.6),
                                                  fontSize: 11,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  size: 14,
                                  color: colors.onSurface.s500
                                      .withValues(alpha: 0.4),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyOnboardingView({
    required AppThemeColors colors,
    required Color dividerColor,
    required bool isBusy,
    required bool isCreating,
    required String? errorMessage,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenSize = MediaQuery.sizeOf(context);
        final screenWidth = screenSize.width;
        final screenHeight = screenSize.height;
        final isNarrow = screenWidth < 360;
        final isShort = screenHeight < 680;
        final horizontalPadding = isNarrow ? 16.0 : 24.0;

        return RefreshIndicator(
          onRefresh: () async {
            HapticService.selection();
            await _syncRooms();
          },
          color: colors.primary.s500,
          backgroundColor: colors.surface.s200,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: isShort ? 12 : 16,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight.isFinite
                      ? constraints.maxHeight
                      : screenHeight,
                  maxWidth: 440,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    AppBadge(
                      icon: Icons.key_rounded,
                      backgroundColor: colors.surface.s300,
                      iconColor: colors.primary.s500,
                    ),
                    SizedBox(height: isShort ? 18 : 28),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'Join A Room',
                        style: AppTypography.headlineMedium.copyWith(
                            color: colors.onSurface.s900,
                            fontSize: isShort ? 24 : 28),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Enter the code to join the anon chat\nroom, or create a brand new room',
                      style: AppTypography.captionRegular
                          .copyWith(color: colors.onSurface.s500),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: isShort ? 22 : 32),
                    RoomCodeInput(
                      controller: _codeController,
                      onChanged: (code) {
                        context.read<RoomBloc>().add(RoomCodeChanged(code));
                      },
                      onCompleted: (code) {
                        FocusManager.instance.primaryFocus?.unfocus();
                        SystemChannels.textInput.invokeMethod('TextInput.hide');
                        if (!isBusy) {
                          context.read<RoomBloc>().add(JoinRoomSubmitted(code));
                        }
                      },
                    ),
                    SizedBox(height: isShort ? 20 : 28),
                    if (isBusy)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: RoomActionShimmer(
                          text: isCreating
                              ? 'Creating anonymous room...'
                              : 'Connecting to room #${_codeController.text.trim()}...',
                        ),
                      )
                    else ...[
                      if (errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Text(
                            errorMessage,
                            style: const TextStyle(
                              color: Color(0xFFFF5252),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      AppButton(
                        text: 'Join Room',
                        backgroundColor: colors.primary.s500,
                        foregroundColor: colors.onPrimary,
                        onPressed: () {
                          FocusManager.instance.primaryFocus?.unfocus();
                          SystemChannels.textInput
                              .invokeMethod('TextInput.hide');
                          final code = _codeController.text.trim();
                          if (code.isNotEmpty) {
                            context
                                .read<RoomBloc>()
                                .add(JoinRoomSubmitted(code));
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Please enter a room code or create a room below.'),
                                duration: Duration(seconds: 2),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 16),
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
                              'OR',
                              style: AppTypography.caption.copyWith(
                                  color: colors.onSurface.s500,
                                  letterSpacing: 1.2,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                          Expanded(
                            child: Container(height: 1, color: dividerColor),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      AppButton(
                        text: 'Create a Room',
                        backgroundColor: colors.surface.s300,
                        foregroundColor: colors.primary.s500,
                        onPressed: () {
                          FocusManager.instance.primaryFocus?.unfocus();
                          SystemChannels.textInput
                              .invokeMethod('TextInput.hide');
                          context
                              .read<RoomBloc>()
                              .add(const CreateRoomSubmitted());
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
