import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:rumour/features/chat/data/model/chat_message_model.dart';
import 'package:rumour/features/room/data/model/random_user_response_model.dart';
import 'package:rumour/features/room/data/model/room_identity_model.dart';
import 'package:rumour/features/room/data/model/room_member_model.dart';
import 'package:rumour/features/room/data/model/room_model.dart';
import 'package:rumour/services/firebase/firebase_service.dart';
import 'package:rumour/services/logger/logger_service.dart';
import 'package:rumour/utilities/handle_generator.dart';
import 'package:uuid/uuid.dart';

class RoomRemoteSource {
  static const String _tag = 'RoomRemoteSource';
  final FirebaseFirestore? _firestore;
  final http.Client client;
  final Uuid uuid;

  RoomRemoteSource({
    FirebaseFirestore? firestore,
    http.Client? client,
    Uuid? uuid,
  })  : _firestore = firestore,
        client = client ?? http.Client(),
        uuid = uuid ?? const Uuid();

  FirebaseFirestore get firestore => _firestore ?? FirebaseService.firestore;

  CollectionReference<Map<String, dynamic>> get _roomsRef =>
      firestore.collection('rooms');

  DocumentReference<Map<String, dynamic>> _roomDoc(String roomCode) =>
      _roomsRef.doc(roomCode.trim().toUpperCase());

  Future<String> _resolveUserId() async {
    final authUser = await FirebaseService.ensureAnonymousAuth();
    if (authUser?.uid != null && authUser!.uid.isNotEmpty) {
      return authUser.uid;
    }
    return uuid.v4();
  }

  Future<String> generateUniqueRoomCode({int maxAttempts = 5}) async {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final random = Random.secure();

    for (int attempt = 0; attempt < maxAttempts; attempt++) {
      final code =
          List.generate(6, (_) => chars[random.nextInt(chars.length)]).join();
      try {
        final snap = await _roomDoc(code).get();
        if (!snap.exists) {
          LoggerService.info('Server verified unique room code: $code',
              tag: _tag);
          return code;
        }
        LoggerService.debug(
            'Room code $code already taken on server, retrying...',
            tag: _tag);
      } catch (e) {
        LoggerService.warn(
            'Could not verify room code uniqueness on server ($e), using $code',
            tag: _tag);
        return code;
      }
    }
    return List.generate(6, (_) => chars[random.nextInt(chars.length)]).join();
  }

  Future<RoomIdentityModel> fetchRandomIdentity(String roomCode) async {
    final code = roomCode.trim().toUpperCase();
    final userId = await _resolveUserId();

    try {
      final uri =
          Uri.parse('https://randomuser.me/api/?inc=name,login,picture&noinfo');
      LoggerService.info(
          'Fetching random user persona from $uri for room $code',
          tag: _tag);

      final response =
          await client.get(uri).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body) as Map<String, dynamic>;
        final responseModel = RandomUserResponseModel.fromJson(decoded);

        if (responseModel.results.isNotEmpty) {
          final result = responseModel.results.first;
          final displayName = HandleGenerator.generateFallbackHandle();
          final mentionTag = result.login.username.isNotEmpty
              ? '@${result.login.username}'
              : HandleGenerator.toMentionTag(displayName);

          final persona = RoomIdentityModel(
            id: userId,
            roomId: code,
            displayName: displayName,
            mentionTag: mentionTag,
            avatarUrl: result.picture?.medium ?? result.picture?.thumbnail,
            createdAt: DateTime.now(),
          );

          LoggerService.info(
            'Fetched persona "${persona.displayName}" (${persona.mentionTag}) for room $code',
            tag: _tag,
          );
          return persona;
        }
      } else {
        LoggerService.warn(
          'randomuser.me returned status ${response.statusCode}, falling back to generator',
          tag: _tag,
        );
      }
    } catch (e, stackTrace) {
      LoggerService.warn(
        'Failed to reach randomuser.me API ($e). Using high-quality offline generator.',
        tag: _tag,
        error: e,
        stackTrace: stackTrace,
      );
    }

    final fallbackName = HandleGenerator.generateFallbackHandle();
    final fallbackPersona = RoomIdentityModel(
      id: userId,
      roomId: code,
      displayName: fallbackName,
      mentionTag: HandleGenerator.toMentionTag(fallbackName),
      avatarUrl: null,
      createdAt: DateTime.now(),
    );

    LoggerService.info(
      'Generated fallback persona "${fallbackPersona.displayName}" for room $code',
      tag: _tag,
    );
    return fallbackPersona;
  }

  Future<RoomModel?> fetchRoom(String roomCode) async {
    final code = roomCode.trim().toUpperCase();
    try {
      LoggerService.debug('Fetching room doc $code from Firestore', tag: _tag);
      final snap = await _roomDoc(code).get();
      if (!snap.exists) {
        LoggerService.debug('Room $code does not exist yet', tag: _tag);
        return null;
      }
      return RoomModel.fromFirestore(snap);
    } catch (e, stackTrace) {
      LoggerService.error(
        'Error fetching room $code from Firestore',
        tag: _tag,
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<RoomModel> createRoomWithMember({
    required String roomCode,
    required RoomIdentityModel identity,
  }) async {
    final code = roomCode.trim().toUpperCase();
    final roomDoc = _roomDoc(code);
    final memberDoc = roomDoc.collection('members').doc(identity.id);

    final roomModel = RoomModel(
      code: code,
      memberCount: 1,
      createdAt: DateTime.now(),
      createdBy: identity.id,
    );

    final memberModel = RoomMemberModel(
      id: identity.id,
      displayName: identity.displayName,
      avatarUrl: identity.avatarUrl,
      joinedAt: DateTime.now(),
    );

    try {
      LoggerService.info(
          'Creating room $code in Firestore with member ${identity.id}',
          tag: _tag);
      final batch = firestore.batch();
      batch.set(roomDoc, roomModel.toFirestore());
      batch.set(memberDoc, memberModel.toFirestore());

      final systemMessageDoc = roomDoc.collection('messages').doc(uuid.v4());
      final systemMessage = ChatMessageModel(
        id: systemMessageDoc.id,
        roomId: code,
        senderId: identity.id,
        senderName: identity.displayName,
        senderMention: identity.mentionTag,
        senderAvatarUrl: identity.avatarUrl,
        text: '${identity.displayName} created the room',
        createdAt: DateTime.now(),
        type: 'system',
      );
      batch.set(systemMessageDoc, systemMessage.toFirestore());

      await batch.commit();
      LoggerService.info('Room $code successfully created', tag: _tag);
      return roomModel;
    } catch (e, stackTrace) {
      LoggerService.error(
        'Failed to create room $code in Firestore',
        tag: _tag,
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<void> registerMemberToRoom({
    required String roomCode,
    required RoomIdentityModel identity,
  }) async {
    final code = roomCode.trim().toUpperCase();
    final roomDoc = _roomDoc(code);
    final memberDoc = roomDoc.collection('members').doc(identity.id);

    try {
      LoggerService.debug('Checking membership of ${identity.id} in room $code',
          tag: _tag);
      final memberSnap = await memberDoc.get();
      if (!memberSnap.exists) {
        final memberModel = RoomMemberModel(
          id: identity.id,
          displayName: identity.displayName,
          avatarUrl: identity.avatarUrl,
          joinedAt: DateTime.now(),
        );

        LoggerService.info(
            'Registering new member ${identity.displayName} to room $code',
            tag: _tag);
        final batch = firestore.batch();
        batch.set(memberDoc, memberModel.toFirestore());
        batch.update(roomDoc, {'memberCount': FieldValue.increment(1)});

        final systemMessageDoc = roomDoc.collection('messages').doc(uuid.v4());
        final systemMessage = ChatMessageModel(
          id: systemMessageDoc.id,
          roomId: code,
          senderId: identity.id,
          senderName: identity.displayName,
          senderMention: identity.mentionTag,
          senderAvatarUrl: identity.avatarUrl,
          text: '${identity.displayName} joined the room',
          createdAt: DateTime.now(),
          type: 'system',
        );
        batch.set(systemMessageDoc, systemMessage.toFirestore());

        await batch.commit();
        LoggerService.info(
            'Member ${identity.displayName} registered to room $code',
            tag: _tag);
      } else {
        LoggerService.debug(
            'Member ${identity.id} already registered in room $code',
            tag: _tag);
      }
    } catch (e, stackTrace) {
      LoggerService.error(
        'Failed to register member to room $code',
        tag: _tag,
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Stream<RoomModel?> streamRoom(String roomCode) {
    final code = roomCode.trim().toUpperCase();
    return _roomDoc(code).snapshots().map((snapshot) {
      if (!snapshot.exists) return null;
      return RoomModel.fromFirestore(snapshot);
    }).handleError((error, stackTrace) {
      LoggerService.error(
        'Error streaming room $code updates',
        tag: _tag,
        error: error,
        stackTrace: stackTrace,
      );
    });
  }

  Stream<List<RoomMemberModel>> streamRoomMembers(String roomCode) {
    final code = roomCode.trim().toUpperCase();
    return _roomDoc(code)
        .collection('members')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => RoomMemberModel.fromFirestore(doc))
            .toList())
        .handleError((error, stackTrace) {
      LoggerService.error(
        'Error streaming members for room $code',
        tag: _tag,
        error: error,
        stackTrace: stackTrace,
      );
    });
  }
}
