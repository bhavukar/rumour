import 'package:rumour/features/room/data/model/room_identity_model.dart';
import 'package:rumour/features/room/data/model/room_member_model.dart';
import 'package:rumour/features/room/data/model/room_model.dart';
import 'package:rumour/features/room/data/source/room_local_source.dart';
import 'package:rumour/features/room/data/source/room_remote_source.dart';
import 'package:rumour/services/analytics/analytics_service.dart';
import 'package:rumour/services/crashlytics/crashlytics_service.dart';
import 'package:rumour/services/logger/logger_service.dart';

class RoomRepository {
  static const String _tag = 'RoomRepository';
  final RoomLocalSource localSource;
  final RoomRemoteSource remoteSource;

  const RoomRepository({
    required this.localSource,
    required this.remoteSource,
  });

  Future<({RoomIdentityModel identity, bool isNew})> getOrCreateIdentity(
      String roomCode) async {
    final code = roomCode.trim().toUpperCase();

    final cached = localSource.getPersistedIdentity(code);
    if (cached != null) {
      CrashlyticsService.setCustomKey('active_room', code);
      AnalyticsService.logRoomJoined(code);
      return (identity: cached, isNew: false);
    }

    final remote = await remoteSource.fetchRandomIdentity(code);
    await localSource.persistIdentity(code, remote);
    CrashlyticsService.setCustomKey('active_room', code);
    AnalyticsService.logRoomJoined(code);

    return (identity: remote, isNew: true);
  }

  RoomIdentityModel? getCachedIdentity(String roomCode) {
    final code = roomCode.trim().toUpperCase();
    return localSource.getPersistedIdentity(code);
  }

  Future<bool> clearCachedIdentity(String roomCode) {
    final code = roomCode.trim().toUpperCase();
    return localSource.clearIdentity(code);
  }

  Future<RoomModel> joinOrCreateRoom({
    required String roomCode,
    required RoomIdentityModel identity,
  }) async {
    final code = roomCode.trim().toUpperCase();

    try {
      final existing = await remoteSource.fetchRoom(code);

      if (existing == null) {
        final created = await remoteSource.createRoomWithMember(
          roomCode: code,
          identity: identity,
        );
        return created;
      } else {
        await remoteSource.registerMemberToRoom(
          roomCode: code,
          identity: identity,
        );
        return existing;
      }
    } catch (e, stackTrace) {
      LoggerService.warn(
        'Network error joining room $code: $e',
        tag: _tag,
        error: e,
        stackTrace: stackTrace,
      );
      return RoomModel(
        code: code,
        memberCount: 1,
        createdAt: DateTime.now(),
        createdBy: identity.id,
      );
    }
  }

  Future<({RoomModel room, RoomIdentityModel identity})> createRoom() async {
    final roomCode = await remoteSource.generateUniqueRoomCode();
    final identityResult = await getOrCreateIdentity(roomCode);
    final room = await remoteSource.createRoomWithMember(
      roomCode: roomCode,
      identity: identityResult.identity,
    );
    CrashlyticsService.setCustomKey('active_room', roomCode);
    AnalyticsService.logRoomCreated(roomCode);

    return (room: room, identity: identityResult.identity);
  }

  Stream<RoomModel?> streamRoom(String roomCode) {
    return remoteSource.streamRoom(roomCode);
  }

  Stream<List<RoomMemberModel>> streamRoomMembers(String roomCode) {
    return remoteSource.streamRoomMembers(roomCode);
  }

  Future<List<String>> syncAndPruneJoinedRooms(List<String> roomCodes) async {
    final validRooms = <String>[];
    for (final code in roomCodes) {
      try {
        final snap = await remoteSource
            .getRoomSnapshot(code)
            .timeout(const Duration(seconds: 2));

        // Only prune if the remote server explicitly confirmed non-existence.
        // Never prune if offline or if snapshot is from local cache!
        if (snap != null && !snap.metadata.isFromCache && !snap.exists) {
          LoggerService.info(
            'Room $code does not exist on remote server. Pruning locally.',
            tag: _tag,
          );
          await localSource.clearIdentity(code);
          await localSource.storageService.clearCachedMessages(code);
        } else {
          validRooms.add(code);
        }
      } catch (e) {
        // Keep room in case of network interruption or timeout
        validRooms.add(code);
      }
    }
    return validRooms;
  }
}
