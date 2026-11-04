import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:rumour/components/loading_indicator.dart';
import 'package:rumour/components/user_avatar.dart';
import 'package:rumour/config/themes/app_theme_colors.dart';
import 'package:rumour/config/themes/app_typography.dart';
import 'package:rumour/features/room/data/model/room_member_model.dart';
import 'package:rumour/features/room/data/model/room_model.dart';
import 'package:rumour/features/room/data/repositories/room_repository.dart';
import 'package:rumour/services/analytics/analytics_service.dart';
import 'package:rumour/services/haptics/haptic_service.dart';
import 'package:rumour/services/notifications/notification_service.dart';
import 'package:rumour/services/routes/app_routes.dart';
import 'package:rumour/services/storage/local_storage_service.dart';
import 'package:rumour/utilities/date_formatter.dart';
import 'package:share_plus/share_plus.dart';

class RoomMembersSheet extends StatelessWidget {
  final String roomCode;
  final String currentUserId;
  final String? roomCreatorId;

  const RoomMembersSheet({
    super.key,
    required this.roomCode,
    required this.currentUserId,
    this.roomCreatorId,
  });

  static Future<void> show({
    required BuildContext context,
    required String roomCode,
    required String currentUserId,
    String? roomCreatorId,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => RoomMembersSheet(
        roomCode: roomCode,
        currentUserId: currentUserId,
        roomCreatorId: roomCreatorId,
      ),
    );
  }

  void _copyRoomCode(BuildContext context, AppThemeColors colors) {
    HapticService.selection();
    Clipboard.setData(ClipboardData(text: roomCode));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Room code #$roomCode copied to clipboard!'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _shareRoom() {
    HapticService.selection();
    SharePlus.instance.share(
      ShareParams(
        text:
            'Join my anonymous chat on Rumour!\nRoom Code: $roomCode\nJump in without creating an account.',
        subject: 'Join Room #$roomCode on Rumour',
      ),
    );
  }

  void _confirmLeaveRoom(BuildContext context, AppThemeColors colors) {
    HapticService.medium();
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: colors.surface.s100,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Leave Room?',
            style: AppTypography.titleLarge.copyWith(
                color: colors.onSurface.s900, fontWeight: FontWeight.w700),
          ),
          content: Text(
            'You will leave Room #$roomCode. You can always rejoin using the room code.',
            style:
                AppTypography.bodyMedium.copyWith(color: colors.onSurface.s500),
          ),
          actions: [
            TextButton(
              onPressed: () {
                HapticService.selection();
                Navigator.of(dialogContext).pop();
              },
              child: Text(
                'Cancel',
                style: TextStyle(color: colors.onSurface.s500),
              ),
            ),
            TextButton(
              onPressed: () async {
                final nav = Navigator.of(dialogContext);
                final sheetNav = Navigator.of(context);
                final storage = context.read<LocalStorageService>();
                HapticService.heavy();
                nav.pop();
                sheetNav.pop();
                NotificationService.clearOnLogout(roomCode: roomCode);
                try {
                  await storage.clearActiveRoom();
                  await storage.removeJoinedRoom(roomCode);
                  AnalyticsService.logRoomLeft(roomCode);
                } catch (_) {}
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Left Room #$roomCode. You can always rejoin using the room code.'),
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 3),
                    ),
                  );
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  } else {
                    context.go(AppRoutes.rooms);
                  }
                }
              },
              child: const Text(
                'Leave Room',
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
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final roomRepo = context.read<RoomRepository>();
    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface.s100,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 14,
        bottom: bottomPadding > 0 ? bottomPadding + 12 : 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: colors.secondary.s100,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header Row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Room Members',
                      style: AppTypography.titleLarge.copyWith(
                          color: colors.onSurface.s900,
                          fontWeight: FontWeight.w700),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: () => _copyRoomCode(context, colors),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Room #$roomCode',
                            style: AppTypography.captionRegular.copyWith(
                                color: colors.primary.s500,
                                fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.copy_rounded,
                            size: 12,
                            color: colors.primary.s500,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: _shareRoom,
                icon: Icon(
                  Icons.share_rounded,
                  color: colors.onSurface.s700,
                  size: 20,
                ),
                tooltip: 'Share Room Code',
                style: IconButton.styleFrom(
                  backgroundColor: colors.surface.s300,
                  padding: const EdgeInsets.all(8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Members List
          StreamBuilder<RoomModel?>(
            stream: roomRepo.streamRoom(roomCode),
            builder: (context, roomSnapshot) {
              final effectiveCreatorId =
                  roomSnapshot.data?.createdBy ?? roomCreatorId;

              return StreamBuilder<List<RoomMemberModel>>(
                stream: roomRepo.streamRoomMembers(roomCode),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting &&
                      !snapshot.hasData) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: LoadingIndicator(color: colors.primary.s500),
                    );
                  }

                  final rawMembers = snapshot.data ?? [];
                  if (rawMembers.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: Text(
                          'No members found',
                          style: AppTypography.bodyMedium
                              .copyWith(color: colors.onSurface.s500),
                        ),
                      ),
                    );
                  }

                  final effectiveAdminId = effectiveCreatorId ??
                      (rawMembers.isNotEmpty
                          ? rawMembers
                              .reduce((a, b) =>
                                  a.joinedAt.isBefore(b.joinedAt) ? a : b)
                              .id
                          : null);

                  final members = List<RoomMemberModel>.from(rawMembers);
                  members.sort((a, b) {
                    final aIsAdmin =
                        effectiveAdminId != null && a.id == effectiveAdminId;
                    final bIsAdmin =
                        effectiveAdminId != null && b.id == effectiveAdminId;
                    if (aIsAdmin && !bIsAdmin) return -1;
                    if (!aIsAdmin && bIsAdmin) return 1;
                    return a.joinedAt.compareTo(b.joinedAt);
                  });

                  return ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.sizeOf(context).height * 0.42,
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: members.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final member = members[index];
                        final isSelf = member.id == currentUserId;
                        final isAdmin = effectiveAdminId != null &&
                            member.id == effectiveAdminId;

                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: colors.surface.s300,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              UserAvatar(
                                avatarUrl: member.avatarUrl,
                                displayName: member.displayName,
                                size: 40,
                                showBorder: isSelf || isAdmin,
                                borderColor: colors.primary.s500,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Flexible(
                                          child: Text(
                                            member.displayName,
                                            style: AppTypography.titleMedium
                                                .copyWith(
                                                    color:
                                                        colors.onSurface.s900,
                                                    fontWeight:
                                                        FontWeight.w700),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        if (isAdmin) ...[
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 7,
                                              vertical: 2.5,
                                            ),
                                            decoration: BoxDecoration(
                                              color: colors.primary.s500,
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.shield_rounded,
                                                  size: 10,
                                                  color: colors.onPrimary,
                                                ),
                                                const SizedBox(width: 3),
                                                Text(
                                                  'ADMIN',
                                                  style: TextStyle(
                                                    color: colors.onPrimary,
                                                    fontSize: 9.5,
                                                    fontWeight: FontWeight.w800,
                                                    letterSpacing: 0.5,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                        if (isSelf) ...[
                                          const SizedBox(width: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: colors.surface.s500,
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              'YOU',
                                              style: TextStyle(
                                                color: colors.onSurface.s900,
                                                fontSize: 9,
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Row(
                                      children: [
                                        if (isAdmin) ...[
                                          Text(
                                            'Room Admin • ',
                                            style: AppTypography.captionRegular
                                                .copyWith(
                                                    color: colors.primary.s500,
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 12),
                                          ),
                                        ],
                                        Text(
                                          'Joined ${DateFormatter.formatMessageTime(member.joinedAt)}',
                                          style: AppTypography.captionRegular
                                              .copyWith(
                                                  color: colors.onSurface.s500,
                                                  fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          ),
          const SizedBox(height: 18),

          // Leave Room Action Button
          Material(
            color: const Color(0xFFFF5252).withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
            clipBehavior: Clip.antiAlias,
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
              leading: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF5252).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  color: Color(0xFFFF5252),
                  size: 18,
                ),
              ),
              title: const Text(
                'Leave Room',
                style: TextStyle(
                  color: Color(0xFFFF5252),
                  fontWeight: FontWeight.w700,
                  fontSize: 14.5,
                ),
              ),
              subtitle: Text(
                'Exit Room #$roomCode',
                style: AppTypography.caption
                    .copyWith(color: colors.onSurface.s500),
              ),
              trailing: const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFFFF5252),
                size: 20,
              ),
              onTap: () => _confirmLeaveRoom(context, colors),
            ),
          ),
        ],
      ),
    );
  }
}
