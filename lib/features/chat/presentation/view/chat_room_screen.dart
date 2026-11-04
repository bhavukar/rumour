import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rumour/components/app_back_button.dart';
import 'package:rumour/components/date_separator.dart';
import 'package:rumour/components/room_avatar.dart';
import 'package:rumour/components/shimmer.dart';
import 'package:rumour/config/themes/app_theme_colors.dart';
import 'package:rumour/config/themes/app_typography.dart';
import 'package:rumour/features/chat/data/repositories/chat_repository.dart';
import 'package:rumour/features/chat/data/model/chat_message_model.dart';
import 'package:rumour/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:rumour/features/chat/presentation/bloc/chat_event.dart';
import 'package:rumour/features/chat/presentation/bloc/chat_state.dart';
import 'package:rumour/features/chat/presentation/widgets/chat_bubble.dart';
import 'package:rumour/features/chat/presentation/widgets/chat_input_bar.dart';
import 'package:rumour/features/chat/presentation/widgets/swipe_to_reply.dart';
import 'package:rumour/features/room/data/model/room_identity_model.dart';
import 'package:rumour/features/room/data/model/room_member_model.dart';
import 'package:rumour/features/room/data/model/room_model.dart';
import 'package:rumour/features/room/data/repositories/room_repository.dart';
import 'package:rumour/features/room/presentation/widgets/room_members_sheet.dart';
import 'package:rumour/services/haptics/haptic_service.dart';
import 'package:rumour/services/network/connectivity_cubit.dart';
import 'package:rumour/services/notifications/notification_service.dart';
import 'package:rumour/utilities/date_formatter.dart';
import 'package:rumour/utilities/room_name_generator.dart';
import 'package:go_router/go_router.dart';
import 'package:rumour/services/routes/app_routes.dart';
import 'package:rumour/services/storage/local_storage_service.dart';
import 'package:share_plus/share_plus.dart';

class ChatRoomScreen extends StatelessWidget {
  final String roomCode;
  final RoomIdentityModel identity;

  const ChatRoomScreen({
    super.key,
    required this.roomCode,
    required this.identity,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChatBloc(
        chatRepository: context.read<ChatRepository>(),
        roomCode: roomCode,
        currentUserId: identity.id,
      )..add(ChatStarted(roomCode)),
      child: _ChatRoomView(
        roomCode: roomCode,
        identity: identity,
      ),
    );
  }
}

class _ChatRoomView extends StatefulWidget {
  final String roomCode;
  final RoomIdentityModel identity;

  const _ChatRoomView({
    required this.roomCode,
    required this.identity,
  });

  @override
  State<_ChatRoomView> createState() => _ChatRoomViewState();
}

class _ChatRoomViewState extends State<_ChatRoomView> {
  final ScrollController _scrollController = ScrollController();
  final Map<String, RoomMemberModel> _membersMap = {};
  StreamSubscription<List<RoomMemberModel>>? _membersSubscription;
  StreamSubscription<RoomModel?>? _roomSubscription;
  String? _roomCreatorId;
  ChatMessageModel? _replyingToMessage;

  @override
  void initState() {
    super.initState();
    NotificationService.activeVisibleRoomCode = widget.roomCode;
    _scrollController.addListener(_onScroll);
    NotificationService.subscribeToRoom(widget.roomCode);

    _membersSubscription = context
        .read<RoomRepository>()
        .streamRoomMembers(widget.roomCode)
        .listen((members) {
      if (mounted) {
        setState(() {
          for (final member in members) {
            _membersMap[member.id] = member;
          }
        });
      }
    });

    _roomSubscription = context
        .read<RoomRepository>()
        .streamRoom(widget.roomCode)
        .listen((room) {
      if (!mounted) return;
      if (room == null) {
        try {
          final isConnected =
              context.read<ConnectivityCubit>().state.isConnected;
          if (isConnected) {
            _handleRoomDeleted();
          }
        } catch (_) {}
        return;
      }
      if (_roomCreatorId != room.createdBy) {
        setState(() {
          _roomCreatorId = room.createdBy;
        });
      }
    });
  }

  bool _isHandlingRoomDeleted = false;
  void _handleRoomDeleted() {
    if (_isHandlingRoomDeleted || !mounted) return;
    _isHandlingRoomDeleted = true;
    try {
      final storage = context.read<LocalStorageService>();
      storage.removeJoinedRoom(widget.roomCode);
      storage.clearRoomIdentity(widget.roomCode);
      storage.clearCachedMessages(widget.roomCode);
      NotificationService.unsubscribeFromRoom(widget.roomCode);
    } catch (_) {}

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('This room was deleted or closed.'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Color(0xFFD32F2F),
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    if (NotificationService.activeVisibleRoomCode == widget.roomCode) {
      NotificationService.activeVisibleRoomCode = null;
    }
    _roomSubscription?.cancel();
    _membersSubscription?.cancel();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.hasClients) {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;
      if (maxScroll - currentScroll <= 200) {
        context.read<ChatBloc>().add(LoadOlderMessages());
      }
    }
  }

  void _onReplyToMessage(ChatMessageModel message) {
    HapticService.light();
    setState(() {
      _replyingToMessage = message;
    });
  }

  void _cancelReply() {
    HapticService.selection();
    setState(() {
      _replyingToMessage = null;
    });
  }

  void _handleSendMessage(String text) {
    final replyTo = _replyingToMessage;
    context.read<ChatBloc>().add(
          MessageSent(
            sender: widget.identity,
            text: text,
            replyTo: replyTo,
          ),
        );
    if (_replyingToMessage != null) {
      setState(() {
        _replyingToMessage = null;
      });
    }
  }

  void _shareRoomCode(String roomCode) {
    HapticService.light();
    SharePlus.instance.share(
      ShareParams(
        text:
            'Join my anonymous chat on Rumour!\nRoom Code: $roomCode\nJump in anonymously without an account.',
        subject: 'Join Room #$roomCode on Rumour',
      ),
    );
  }

  void _copyRoomCode(
      BuildContext context, String roomCode, AppThemeColors colors) {
    HapticService.medium();
    Clipboard.setData(ClipboardData(text: roomCode));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Room code #$roomCode copied to clipboard!'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: colors.surfaceVariant,
      ),
    );
  }

  void _openMembersSheet(BuildContext context) {
    HapticService.selection();
    RoomMembersSheet.show(
      context: context,
      roomCode: widget.roomCode,
      currentUserId: widget.identity.id,
      roomCreatorId: _roomCreatorId,
    );
  }

  void _handleBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.rooms);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final roomRepo = context.read<RoomRepository>();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _handleBack(context);
      },
      child: Scaffold(
        backgroundColor: colors.canvas,
        appBar: AppBar(
          backgroundColor: colors.canvas,
          elevation: 0,
          centerTitle: true,
          leadingWidth: 56,
          leading: Padding(
            padding: const EdgeInsets.only(left: 16),
            child: AppBackButton(
              onPressed: () => _handleBack(context),
            ),
          ),
          title: GestureDetector(
            onTap: () => _openMembersSheet(context),
            onLongPress: () => _copyRoomCode(context, widget.roomCode, colors),
            child: StreamBuilder(
              stream: roomRepo.streamRoom(widget.roomCode),
              builder: (context, snapshot) {
                final room = snapshot.data;
                final memberCount = room?.memberCount ??
                    (_membersMap.isNotEmpty ? _membersMap.length : 1);

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            '${RoomNameGenerator.generateRoomName(widget.roomCode)} #${widget.roomCode}',
                            style: AppTypography.titleLarge.copyWith(
                                color: colors.onSurface.s900,
                                fontWeight: FontWeight.w700),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.copy_rounded,
                          size: 13,
                          color: colors.primary.s500,
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$memberCount ${memberCount == 1 ? 'member' : 'members'}',
                      style: AppTypography.captionRegular
                          .copyWith(color: colors.onSurface.s500),
                    ),
                  ],
                );
              },
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: GestureDetector(
                  onTap: () => _openMembersSheet(context),
                  child: RoomAvatar(
                    roomCode: widget.roomCode,
                    size: 38,
                    showBorder: true,
                    borderColor: colors.surface.s300,
                  ),
                ),
              ),
            ),
          ],
        ),
        body: SafeArea(
          bottom: false,
          child: BlocConsumer<ChatBloc, ChatState>(
            listener: (context, state) {
              if (state is ChatLoaded && state.errorMessage != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.errorMessage!),
                    backgroundColor: const Color(0xFFD32F2F),
                  ),
                );
              }
            },
            builder: (context, state) {
              final isLoading = state is ChatLoading;
              final isSending = state is ChatLoaded && state.isSending;
              final List<ChatMessageModel> messages =
                  state is ChatLoaded ? state.messages : const [];
              final isLoadingOlder =
                  state is ChatLoaded && state.isLoadingOlder;
              final messageIdToIndex = {
                for (int i = 0; i < messages.length; i++) messages[i].id: i,
              };

              return Column(
                children: [
                  Expanded(
                    child: isLoading
                        ? const ChatLoadingSkeleton()
                        : RefreshIndicator(
                            onRefresh: () async {
                              HapticService.selection();
                              context
                                  .read<ChatBloc>()
                                  .add(ChatStarted(widget.roomCode));
                            },
                            color: colors.primary.s500,
                            backgroundColor: colors.surface.s200,
                            child: messages.isEmpty
                                ? Center(
                                    child: SingleChildScrollView(
                                      physics:
                                          const AlwaysScrollableScrollPhysics(),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 16,
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          DateSeparator(date: DateTime.now()),
                                          const SizedBox(height: 12),
                                          Text(
                                            'No messages yet in Room #${widget.roomCode}',
                                            style: AppTypography.bodyMedium
                                                .copyWith(
                                                    color:
                                                        colors.onSurface.s500),
                                            textAlign: TextAlign.center,
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            'Share this code with others so they can join:',
                                            style: AppTypography.captionRegular
                                                .copyWith(
                                                    color:
                                                        colors.onSurface.s400),
                                            textAlign: TextAlign.center,
                                          ),
                                          const SizedBox(height: 16),
                                          GestureDetector(
                                            onTap: () =>
                                                _shareRoomCode(widget.roomCode),
                                            child: Container(
                                              constraints: const BoxConstraints(
                                                  maxWidth: 320),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 16,
                                                vertical: 10,
                                              ),
                                              decoration: BoxDecoration(
                                                color: colors.surface.s300,
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.share_rounded,
                                                    size: 16,
                                                    color: colors.primary.s500,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Flexible(
                                                    child: Text(
                                                      'Share Room Code #${widget.roomCode}',
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: AppTypography
                                                          .labelMedium
                                                          .copyWith(
                                                              color: colors
                                                                  .primary.s500,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                : ListView.builder(
                                    physics:
                                        const AlwaysScrollableScrollPhysics(),
                                    controller: _scrollController,
                                    reverse: true,
                                    scrollCacheExtent:
                                        const ScrollCacheExtent.pixels(500.0),
                                    addAutomaticKeepAlives: false,
                                    addRepaintBoundaries: true,
                                    findChildIndexCallback: (Key key) {
                                      if (key is ValueKey<String>) {
                                        return messageIdToIndex[key.value];
                                      }
                                      return null;
                                    },
                                    padding: const EdgeInsets.only(
                                        top: 16, bottom: 8),
                                    itemCount: messages.length +
                                        (isLoadingOlder ? 1 : 0),
                                    itemBuilder: (context, index) {
                                      if (isLoadingOlder &&
                                          index == messages.length) {
                                        return const KeyedSubtree(
                                          key: ValueKey(
                                              'loading_older_indicator'),
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 12),
                                            child: Shimmer(
                                              child: Row(
                                                children: [
                                                  ShimmerBox(
                                                      width: 32,
                                                      height: 32,
                                                      borderRadius: 16),
                                                  SizedBox(width: 8),
                                                  ShimmerBox(
                                                      width: 140,
                                                      height: 36,
                                                      borderRadius: 18),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      }

                                      final message = messages[index];

                                      bool showDateSeparator = false;
                                      if (index == messages.length - 1) {
                                        showDateSeparator = true;
                                      } else {
                                        final nextOlderMessage =
                                            messages[index + 1];
                                        showDateSeparator =
                                            !DateFormatter.isSameDay(
                                          message.createdAt,
                                          nextOlderMessage.createdAt,
                                        );
                                      }

                                      if (message.isSystem) {
                                        return KeyedSubtree(
                                          key: ValueKey(message.id),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              if (showDateSeparator)
                                                DateSeparator(
                                                    date: message.createdAt),
                                              Center(
                                                child: Container(
                                                  margin: const EdgeInsets
                                                      .symmetric(vertical: 8),
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 14,
                                                      vertical: 5),
                                                  decoration: BoxDecoration(
                                                    color: colors
                                                        .datePillBackground,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            16),
                                                  ),
                                                  child: Text(
                                                    message.text,
                                                    style: AppTypography
                                                        .labelSmall
                                                        .copyWith(
                                                            color: colors
                                                                .textSecondary,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }

                                      final isMine =
                                          message.isMine(widget.identity.id);

                                      final resolvedAvatar =
                                          message.senderAvatarUrl ??
                                              _membersMap[message.senderId]
                                                  ?.avatarUrl ??
                                              (isMine
                                                  ? widget.identity.avatarUrl
                                                  : null);

                                      bool isFirstInGroup = true;
                                      if (index < messages.length - 1 &&
                                          !showDateSeparator) {
                                        final olderMessage =
                                            messages[index + 1];
                                        if (olderMessage.senderId ==
                                                message.senderId &&
                                            DateFormatter.isSameDay(
                                              message.createdAt,
                                              olderMessage.createdAt,
                                            )) {
                                          isFirstInGroup = false;
                                        }
                                      }

                                      bool isLastInGroup = true;
                                      if (index > 0) {
                                        final newerMessage =
                                            messages[index - 1];
                                        final newerHasDateSeparator =
                                            !DateFormatter.isSameDay(
                                          newerMessage.createdAt,
                                          message.createdAt,
                                        );
                                        if (newerMessage.senderId ==
                                                message.senderId &&
                                            !newerHasDateSeparator) {
                                          isLastInGroup = false;
                                        }
                                      }

                                      return KeyedSubtree(
                                        key: ValueKey(message.id),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            if (showDateSeparator)
                                              DateSeparator(
                                                  date: message.createdAt),
                                            SwipeToReply(
                                              isMine: isMine,
                                              onReply: () =>
                                                  _onReplyToMessage(message),
                                              child: ChatBubble(
                                                message: message,
                                                isMine: isMine,
                                                avatarUrl: resolvedAvatar,
                                                isAdmin:
                                                    _roomCreatorId != null &&
                                                        message.senderId ==
                                                            _roomCreatorId,
                                                isFirstInGroup: isFirstInGroup,
                                                isLastInGroup: isLastInGroup,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                          ),
                  ),
                  ChatInputBar(
                    onSend: _handleSendMessage,
                    isSending: isSending,
                    replyingTo: _replyingToMessage,
                    onCancelReply: _cancelReply,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
