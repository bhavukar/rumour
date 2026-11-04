import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:rumour/features/chat/presentation/view/chat_room_screen.dart';
import 'package:rumour/features/room/data/model/room_identity_model.dart';
import 'package:rumour/features/room/data/repositories/room_repository.dart';
import 'package:rumour/features/room/presentation/view/join_room_screen.dart';
import 'package:rumour/features/settings/presentation/view/settings_screen.dart';
import 'package:rumour/services/analytics/analytics_service.dart';
import 'package:rumour/services/logger/logger_service.dart';
import 'package:rumour/services/notifications/notification_service.dart';
import 'package:rumour/services/routes/app_routes.dart';

Page<dynamic> adaptivePage({
  required GoRouterState state,
  required Widget child,
}) {
  if (!kIsWeb && Platform.isIOS) {
    return CupertinoPage(
      key: state.pageKey,
      name: state.name,
      child: child,
    );
  }
  return MaterialPage(
    key: state.pageKey,
    name: state.name,
    child: child,
  );
}

class AppRouter {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: AppRoutes.rooms,
    observers: [
      if (AnalyticsService.observer != null) AnalyticsService.observer!,
    ],
    routes: [
      GoRoute(
        path: AppRoutes.rooms,
        pageBuilder: (context, state) => adaptivePage(
          state: state,
          child: const JoinRoomScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.chatRoom,
        pageBuilder: (context, state) {
          final roomCode =
              (state.pathParameters['roomCode'] ?? '').trim().toUpperCase();
          var identity = state.extra as RoomIdentityModel?;

          if (identity == null && roomCode.isNotEmpty) {
            try {
              final repo = context.read<RoomRepository>();
              identity = repo.getCachedIdentity(roomCode);
            } catch (_) {}
          }

          final child = identity == null
              ? const JoinRoomScreen()
              : ChatRoomScreen(
                  key: ValueKey('chat_room_$roomCode'),
                  roomCode: roomCode,
                  identity: identity,
                );

          return adaptivePage(
            state: state,
            child: child,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.settings,
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return adaptivePage(
            state: state,
            child: SettingsScreen(
              identity: extra?['identity'] as RoomIdentityModel?,
              roomCode: extra?['roomCode'] as String?,
            ),
          );
        },
      ),
    ],
  );

  static void initializeNotificationRouting() {
    NotificationService.onNotificationClicked = (rawRoomCode) async {
      final roomCode = rawRoomCode.trim().toUpperCase();
      if (roomCode.isEmpty) return;

      // Do NOT push a duplicate route if user is ALREADY inside this exact room!
      if (NotificationService.activeVisibleRoomCode?.toUpperCase() ==
          roomCode) {
        LoggerService.info(
          'User is already viewing room $roomCode, ignoring duplicate notification route push',
          tag: 'AppRouter',
        );
        return;
      }

      final context = navigatorKey.currentContext;
      RoomIdentityModel? identity;

      if (context != null) {
        try {
          final repo = context.read<RoomRepository>();
          identity = repo.getCachedIdentity(roomCode);
          if (identity == null) {
            final res = await repo.getOrCreateIdentity(roomCode);
            identity = res.identity;
          }
        } catch (_) {}
      }

      // If user was viewing another chat room, replace it instead of stacking chat rooms
      if (NotificationService.activeVisibleRoomCode != null) {
        router.pushReplacement(
          AppRoutes.chatRoomPath(roomCode),
          extra: identity,
        );
      } else {
        router.push(
          AppRoutes.chatRoomPath(roomCode),
          extra: identity,
        );
      }
    };
  }
}
