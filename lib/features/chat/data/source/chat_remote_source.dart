import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:rumour/features/chat/data/model/chat_message_model.dart';
import 'package:rumour/services/firebase/env_config.dart';
import 'package:rumour/services/firebase/firebase_service.dart';
import 'package:rumour/services/logger/logger_service.dart';

class ChatRemoteSource {
  static const String _tag = 'ChatRemoteSource';
  final FirebaseFirestore? _firestore;

  ChatRemoteSource({FirebaseFirestore? firestore}) : _firestore = firestore;

  FirebaseFirestore get firestore => _firestore ?? FirebaseService.firestore;

  CollectionReference<Map<String, dynamic>> _messagesRef(String roomCode) =>
      firestore
          .collection('rooms')
          .doc(roomCode.trim().toUpperCase())
          .collection('messages');

  DocumentReference<Map<String, dynamic>> _roomRef(String roomCode) =>
      firestore.collection('rooms').doc(roomCode.trim().toUpperCase());

  Stream<QuerySnapshot<Map<String, dynamic>>> streamMessagesSnapshot(
    String roomCode, {
    int limit = 30,
  }) {
    final code = roomCode.trim().toUpperCase();
    LoggerService.debug(
        'Opening messages stream for room $code (limit: $limit)',
        tag: _tag);
    return _messagesRef(code)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> fetchOlderMessagesSnapshot({
    required String roomCode,
    required DocumentSnapshot<Map<String, dynamic>> lastDocument,
    int limit = 25,
  }) async {
    final code = roomCode.trim().toUpperCase();
    try {
      LoggerService.info(
          'Fetching older messages for room $code (limit: $limit)',
          tag: _tag);
      final result = await _messagesRef(code)
          .orderBy('createdAt', descending: true)
          .startAfterDocument(lastDocument)
          .limit(limit)
          .get();
      LoggerService.info(
          'Fetched ${result.docs.length} older messages for room $code',
          tag: _tag);
      return result;
    } catch (e, stackTrace) {
      LoggerService.error(
        'Failed to fetch older messages for room $code',
        tag: _tag,
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<void> sendMessage(ChatMessageModel message) async {
    final code = message.roomId.trim().toUpperCase();
    final messageDoc = _messagesRef(code).doc(message.id);
    final roomDoc = _roomRef(code);

    try {
      LoggerService.info(
        'Sending message ${message.id} to room $code from ${message.senderName}',
        tag: _tag,
      );
      final batch = firestore.batch();
      batch.set(messageDoc, message.toFirestore());
      batch.update(roomDoc, {
        'lastMessageAt': FieldValue.serverTimestamp(),
        'lastMessageText': message.text,
        'lastMessageSender': message.senderName,
        'lastMessageSenderId': message.senderId,
      });

      await batch.commit();
      LoggerService.info('Message ${message.id} committed successfully',
          tag: _tag);

      _dispatchPushNotification(
        roomCode: code,
        senderName: message.senderName,
        senderId: message.senderId,
        text: message.text,
      );
    } catch (e, stackTrace) {
      LoggerService.error(
        'Failed to commit message ${message.id} to room $code',
        tag: _tag,
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  static String get _fcmWorkerUrl => EnvConfig.get('FCM_NOTIFY_ENDPOINT');

  void _dispatchPushNotification({
    required String roomCode,
    required String senderName,
    required String senderId,
    required String text,
  }) {
    unawaited(() async {
      try {
        final client = http.Client();
        final response = await client
            .post(
              Uri.parse(_fcmWorkerUrl),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({
                'roomCode': roomCode,
                'senderName': senderName,
                'senderId': senderId,
                'text': text,
              }),
            )
            .timeout(const Duration(seconds: 5));
        client.close();
        LoggerService.debug(
          'FCM Cloudflare Worker response: ${response.statusCode} ${response.body}',
          tag: _tag,
        );
      } catch (e) {
        LoggerService.warn(
          'Failed to trigger background FCM notification via Cloudflare: $e',
          tag: _tag,
        );
      }
    }());
  }
}
