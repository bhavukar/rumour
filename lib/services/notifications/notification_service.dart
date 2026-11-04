import 'dart:async';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rumour/services/logger/logger_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
  } catch (_) {}

  final data = message.data;
  LoggerService.info(
    'FCM background message received: ${message.messageId} data: $data',
    tag: 'FCMBackground',
  );

  final roomCode = (data['roomCode'] ?? '').toString().trim().toUpperCase();
  if (roomCode.isEmpty) return;

  final senderId = (data['senderId'] ?? '').toString().trim();
  final senderName = (data['senderName'] ?? '').toString().trim();
  final text =
      (data['text'] ?? data['body'] ?? message.notification?.body ?? '')
          .toString()
          .trim();

  try {
    final prefs = await SharedPreferences.getInstance();

    // 1. SUPPRESS IF MESSAGE WAS SENT BY CURRENT USER / THIS DEVICE:
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    if (currentUid != null && currentUid.isNotEmpty && senderId == currentUid) {
      LoggerService.info(
        'FCM suppressed: sender is current user ($senderId)',
        tag: 'FCMBackground',
      );
      return;
    }

    final identityJson = prefs.getString('room_identity_$roomCode');
    if (identityJson != null) {
      try {
        final decoded = json.decode(identityJson);
        if (decoded['id'] == senderId) {
          LoggerService.info(
            'FCM suppressed: sender matches local room identity ($senderId)',
            tag: 'FCMBackground',
          );
          return;
        }
      } catch (_) {}
    }

    // 2. SUPPRESS IF USER HAS LEFT THIS ROOM:
    final joinedRooms = prefs.getStringList('joined_room_codes') ?? [];
    if (!joinedRooms.contains(roomCode)) {
      LoggerService.info(
        'FCM suppressed: user has left room #$roomCode. Unsubscribing.',
        tag: 'FCMBackground',
      );
      try {
        await FirebaseMessaging.instance.unsubscribeFromTopic('room_$roomCode');
      } catch (_) {}
      return;
    }

    // 3. DISPLAY LOCAL NOTIFICATION:
    final localNotifications = FlutterLocalNotificationsPlugin();
    const androidDetails = AndroidNotificationDetails(
      'rumour_chat_notifications',
      'Rumour Chat Messages',
      channelDescription: 'Notifications for new room chat messages',
      importance: Importance.max,
      priority: Priority.high,
      color: Color(0xFFC6FE1E),
      showWhen: true,
      enableLights: true,
      enableVibration: true,
      playSound: true,
    );
    const details = NotificationDetails(android: androidDetails);
    final title = 'Room #$roomCode';
    final body = senderName.isNotEmpty && !text.startsWith('$senderName:')
        ? '$senderName: $text'
        : (text.isNotEmpty ? text : 'New message received');

    await localNotifications.show(
      id: roomCode.hashCode.remainder(100000),
      title: title,
      body: body,
      notificationDetails: details,
      payload: roomCode,
    );
  } catch (e, stackTrace) {
    LoggerService.error('Error handling background FCM: $e',
        tag: 'FCMBackground', error: e, stackTrace: stackTrace);
  }
}

class NotificationService {
  NotificationService._();

  static const String _tag = 'NotificationService';
  static const String _channelId = 'rumour_chat_notifications';
  static const String _channelName = 'Rumour Chat Messages';
  static const String _channelDescription =
      'Notifications for new room chat messages';

  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static String? activeVisibleRoomCode;

  static FirebaseMessaging get _fcm => FirebaseMessaging.instance;

  static void Function(String roomCode)? onNotificationClicked;

  static Future<void> initialize() async {
    try {
      LoggerService.info('Initializing Notifications Service...', tag: _tag);

      const androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _localNotifications.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          final payload = response.payload;
          LoggerService.info('Notification tapped with payload: $payload',
              tag: _tag);
          if (payload != null && payload.isNotEmpty) {
            onNotificationClicked?.call(payload);
          }
        },
      );

      final androidPlugin =
          _localNotifications.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        await androidPlugin.requestNotificationsPermission();
        const channel = AndroidNotificationChannel(
          _channelId,
          _channelName,
          description: _channelDescription,
          importance: Importance.max,
          playSound: true,
          enableVibration: true,
          showBadge: true,
        );
        await androidPlugin.createNotificationChannel(channel);
        LoggerService.info('Android notification channel created: $_channelId',
            tag: _tag);
      }

      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      try {
        final settings = await _fcm
            .requestPermission(
              alert: true,
              badge: true,
              sound: true,
              provisional: false,
            )
            .timeout(const Duration(seconds: 2));
        LoggerService.info(
            'FCM permission authorization status: ${settings.authorizationStatus}',
            tag: _tag);
      } catch (e) {
        LoggerService.warn('FCM requestPermission skipped or timed out: $e',
            tag: _tag);
      }

      try {
        await _fcm
            .setForegroundNotificationPresentationOptions(
              alert: true,
              badge: true,
              sound: true,
            )
            .timeout(const Duration(seconds: 1));
      } catch (_) {}

      FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
        final data = message.data;
        LoggerService.info(
          'FCM foreground message received: ${message.messageId} data: $data',
          tag: _tag,
        );

        final roomCode =
            (data['roomCode'] ?? '').toString().trim().toUpperCase();
        if (roomCode.isEmpty) return;

        // 1. SUPPRESS IF ACTIVELY VIEWING THIS ROOM:
        if (activeVisibleRoomCode != null &&
            activeVisibleRoomCode!.toUpperCase() == roomCode) {
          LoggerService.debug(
              'Suppressed foreground notification: actively viewing room $roomCode',
              tag: _tag);
          return;
        }

        final senderId = (data['senderId'] ?? '').toString().trim();
        final senderName = (data['senderName'] ?? '').toString().trim();
        final text =
            (data['text'] ?? data['body'] ?? message.notification?.body ?? '')
                .toString()
                .trim();

        // 2. SUPPRESS IF SENT BY CURRENT USER / THIS DEVICE:
        final currentUid = FirebaseAuth.instance.currentUser?.uid;
        if (currentUid != null &&
            currentUid.isNotEmpty &&
            senderId == currentUid) {
          LoggerService.debug(
              'Suppressed foreground notification: message was sent by current user ($senderId)',
              tag: _tag);
          return;
        }

        try {
          final prefs = await SharedPreferences.getInstance();

          final identityJson = prefs.getString('room_identity_$roomCode');
          if (identityJson != null) {
            try {
              final decoded = json.decode(identityJson);
              if (decoded['id'] == senderId) {
                LoggerService.debug(
                    'Suppressed foreground notification: sender matches room identity ($senderId)',
                    tag: _tag);
                return;
              }
            } catch (_) {}
          }

          // 3. SUPPRESS IF USER HAS LEFT THIS ROOM:
          final joinedRooms = prefs.getStringList('joined_room_codes') ?? [];
          if (!joinedRooms.contains(roomCode)) {
            LoggerService.debug(
                'Suppressed foreground notification: user is not in room $roomCode. Unsubscribing.',
                tag: _tag);
            unsubscribeFromRoom(roomCode);
            return;
          }
        } catch (_) {}

        final title = 'Room #$roomCode';
        final body = senderName.isNotEmpty && !text.startsWith('$senderName:')
            ? '$senderName: $text'
            : (text.isNotEmpty ? text : 'New message received');

        showLocalNotification(
          title: title,
          body: body,
          payload: roomCode,
          id: roomCode.hashCode.remainder(100000),
        );
      });

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        final roomCode = message.data['roomCode'] ?? message.data['roomId'];
        LoggerService.info(
            'App opened from FCM notification with room: $roomCode',
            tag: _tag);
        if (roomCode != null && roomCode is String && roomCode.isNotEmpty) {
          onNotificationClicked?.call(roomCode);
        }
      });

      try {
        final initialMessage =
            await _fcm.getInitialMessage().timeout(const Duration(seconds: 2));
        if (initialMessage != null) {
          final roomCode =
              initialMessage.data['roomCode'] ?? initialMessage.data['roomId'];
          LoggerService.info('Initial message from terminated state: $roomCode',
              tag: _tag);
          if (roomCode != null && roomCode is String && roomCode.isNotEmpty) {
            onNotificationClicked?.call(roomCode);
          }
        }
      } catch (_) {}

      // ignore: deprecated_member_use
      _fcm.getToken().then((token) {
        LoggerService.info('FCM Device Token: $token', tag: _tag);
      }).catchError((e, stackTrace) {
        LoggerService.warn('Could not retrieve FCM token: $e',
            tag: _tag, error: e, stackTrace: stackTrace);
      });
    } catch (e, stackTrace) {
      LoggerService.warn(
        'NotificationService init warning (expected in test/simulator without APNs/GooglePlay): $e',
        tag: _tag,
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  static Future<void> showLocalNotification({
    required String title,
    required String body,
    String? payload,
    int? id,
  }) async {
    if (payload != null &&
        payload.isNotEmpty &&
        activeVisibleRoomCode != null &&
        payload.toUpperCase() == activeVisibleRoomCode!.toUpperCase()) {
      LoggerService.debug(
        'Suppressed notification because user is actively viewing room $payload',
        tag: _tag,
      );
      return;
    }

    try {
      const androidDetails = AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.max,
        priority: Priority.high,
        color: Color(0xFFC6FE1E),
        showWhen: true,
        enableLights: true,
        enableVibration: true,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      final notificationId =
          id ?? DateTime.now().millisecondsSinceEpoch.remainder(100000);

      await _localNotifications.show(
        id: notificationId,
        title: title,
        body: body,
        notificationDetails: details,
        payload: payload,
      );

      LoggerService.info(
          'Displayed local notification id=$notificationId: "$title" - "$body"',
          tag: _tag);
    } catch (e, stackTrace) {
      LoggerService.error('Failed to display local notification: $e',
          tag: _tag, error: e, stackTrace: stackTrace);
    }
  }

  static Future<void> subscribeToRoom(String roomCode) async {
    final clean = roomCode.trim().toUpperCase();
    if (clean.isEmpty) return;
    try {
      await _fcm
          .subscribeToTopic('room_$clean')
          .timeout(const Duration(seconds: 2));
      LoggerService.info('Subscribed to FCM topic: room_$clean', tag: _tag);
    } catch (e, stackTrace) {
      LoggerService.warn('Failed to subscribe to FCM topic room_$clean: $e',
          tag: _tag, error: e, stackTrace: stackTrace);
    }
  }

  static Future<void> unsubscribeFromRoom(String roomCode) async {
    final clean = roomCode.trim().toUpperCase();
    if (clean.isEmpty) return;
    try {
      await _fcm
          .unsubscribeFromTopic('room_$clean')
          .timeout(const Duration(seconds: 2));
      LoggerService.info('Unsubscribed from FCM topic: room_$clean', tag: _tag);
    } catch (e, stackTrace) {
      LoggerService.warn('Failed to unsubscribe from FCM topic room_$clean: $e',
          tag: _tag, error: e, stackTrace: stackTrace);
    }
  }

  static Future<void> clearOnLogout({String? roomCode}) async {
    try {
      if (roomCode != null && roomCode.isNotEmpty) {
        await unsubscribeFromRoom(roomCode);
      }
      await _localNotifications.cancelAll();
      // ignore: deprecated_member_use
      await _fcm.deleteToken();
      LoggerService.info(
          'FCM token deleted and notifications cleared on logout',
          tag: _tag);
    } catch (e, stackTrace) {
      LoggerService.warn('Error clearing FCM on logout: $e',
          tag: _tag, error: e, stackTrace: stackTrace);
    }
  }
}
