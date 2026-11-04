import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rumour/features/chat/data/model/chat_message_model.dart';
import 'package:rumour/features/chat/data/source/chat_remote_source.dart';
import 'package:rumour/features/room/data/model/room_identity_model.dart';
import 'package:rumour/services/analytics/analytics_service.dart';
import 'package:rumour/services/logger/logger_service.dart';
import 'package:rumour/services/storage/local_storage_service.dart';
import 'package:uuid/uuid.dart';

class PaginatedMessagesResult {
  final List<ChatMessageModel> messages;
  final DocumentSnapshot<Map<String, dynamic>>? lastVisible;
  final bool hasMore;

  const PaginatedMessagesResult({
    required this.messages,
    this.lastVisible,
    required this.hasMore,
  });
}

class ChatRepository {
  static const String _tag = 'ChatRepository';
  final ChatRemoteSource remoteSource;
  final LocalStorageService? localStorageService;
  final Uuid uuid;

  ChatRepository({
    required this.remoteSource,
    this.localStorageService,
    Uuid? uuid,
  }) : uuid = uuid ?? const Uuid();

  List<ChatMessageModel> getCachedMessages(String roomCode) {
    if (localStorageService == null) return const [];
    try {
      final jsonList = localStorageService!.getCachedMessagesJson(roomCode);
      final List<ChatMessageModel> messages = [];
      for (final str in jsonList) {
        try {
          final decoded = json.decode(str) as Map<String, dynamic>;
          messages.add(ChatMessageModel.fromJson(decoded));
        } catch (e) {
          LoggerService.warn(
            'Failed to parse individual cached message in room $roomCode: $e',
            tag: _tag,
          );
        }
      }
      return messages;
    } catch (e, stackTrace) {
      LoggerService.warn(
        'Failed to read cached messages for room $roomCode: $e',
        tag: _tag,
        error: e,
        stackTrace: stackTrace,
      );
      return const [];
    }
  }

  Future<void> cacheMessages(
      String roomCode, List<ChatMessageModel> messages) async {
    if (localStorageService == null) return;
    try {
      final topMessages = messages.take(50).toList();
      final jsonList = topMessages.map((m) => json.encode(m.toJson())).toList();
      await localStorageService!.saveCachedMessagesJson(roomCode, jsonList);
    } catch (e, stackTrace) {
      LoggerService.warn(
        'Failed to cache messages for room $roomCode: $e',
        tag: _tag,
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> streamMessagesSnapshot(
    String roomCode, {
    int limit = 30,
  }) {
    return remoteSource.streamMessagesSnapshot(roomCode, limit: limit);
  }

  Future<PaginatedMessagesResult> fetchOlderMessages({
    required String roomCode,
    required DocumentSnapshot<Map<String, dynamic>> lastDocument,
    int limit = 25,
  }) async {
    try {
      final snapshot = await remoteSource.fetchOlderMessagesSnapshot(
        roomCode: roomCode,
        lastDocument: lastDocument,
        limit: limit,
      );

      final messages = snapshot.docs
          .map((doc) => ChatMessageModel.fromFirestore(doc))
          .toList();

      final lastVisible = snapshot.docs.isNotEmpty ? snapshot.docs.last : null;
      final hasMore = snapshot.docs.length >= limit;

      LoggerService.info(
        'Fetched ${messages.length} older messages for room $roomCode (hasMore: $hasMore)',
        tag: _tag,
      );

      return PaginatedMessagesResult(
        messages: messages,
        lastVisible: lastVisible,
        hasMore: hasMore,
      );
    } catch (e, stackTrace) {
      LoggerService.error(
        'Failed to fetch older messages for room $roomCode',
        tag: _tag,
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<ChatMessageModel> sendMessage({
    required String roomCode,
    required RoomIdentityModel sender,
    required String text,
    String? messageId,
    String? replyToId,
    String? replyToSenderName,
    String? replyToText,
  }) async {
    final clean = text.trim();
    if (clean.isEmpty) {
      LoggerService.warn('Cannot send empty message', tag: _tag);
      throw ArgumentError('Message text cannot be empty');
    }

    final id = messageId ?? uuid.v4();

    final message = ChatMessageModel(
      id: id,
      roomId: roomCode,
      senderId: sender.id,
      senderName: sender.displayName,
      senderMention: sender.mentionTag,
      senderAvatarUrl: sender.avatarUrl,
      text: clean,
      createdAt: DateTime.now(),
      type: 'text',
      replyToId: replyToId,
      replyToSenderName: replyToSenderName,
      replyToText: replyToText,
    );

    try {
      LoggerService.info('Dispatching message $id to room $roomCode',
          tag: _tag);
      await remoteSource.sendMessage(message);
      AnalyticsService.logMessageSent(
        roomCode: roomCode,
        messageLength: clean.length,
        isReply: replyToId != null,
      );
      return message;
    } catch (e, stackTrace) {
      LoggerService.error(
        'Failed to dispatch message $messageId to room $roomCode',
        tag: _tag,
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}
