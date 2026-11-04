import 'package:rumour/features/room/data/model/room_identity_model.dart';
import 'package:rumour/services/logger/logger_service.dart';
import 'package:rumour/services/storage/local_storage_service.dart';

class RoomLocalSource {
  static const String _tag = 'RoomLocalSource';
  final LocalStorageService storageService;

  const RoomLocalSource({required this.storageService});

  RoomIdentityModel? getPersistedIdentity(String roomCode) {
    final code = roomCode.trim().toUpperCase();
    final rawJson = storageService.getRoomIdentity(code);
    if (rawJson == null || rawJson.isEmpty) {
      return null;
    }

    try {
      return RoomIdentityModel.fromJsonString(rawJson);
    } catch (e, stackTrace) {
      LoggerService.error(
        'Failed to parse cached identity for room $code',
        tag: _tag,
        error: e,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  Future<bool> persistIdentity(
      String roomCode, RoomIdentityModel identity) async {
    final code = roomCode.trim().toUpperCase();
    try {
      return await storageService.saveRoomIdentity(
          code, identity.toJsonString());
    } catch (e, stackTrace) {
      LoggerService.error(
        'Exception while persisting identity for room $code',
        tag: _tag,
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  Future<bool> clearIdentity(String roomCode) async {
    final code = roomCode.trim().toUpperCase();
    try {
      return await storageService.clearRoomIdentity(code);
    } catch (e, stackTrace) {
      LoggerService.error(
        'Exception while clearing identity for room $code',
        tag: _tag,
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }
}
