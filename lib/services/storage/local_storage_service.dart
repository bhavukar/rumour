import 'package:rumour/services/logger/logger_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const String _tag = 'LocalStorageService';
  final SharedPreferences prefs;

  const LocalStorageService({required this.prefs});

  static Future<LocalStorageService> init() async {
    try {
      LoggerService.info('Initializing SharedPreferences...', tag: _tag);
      final prefs = await SharedPreferences.getInstance();
      LoggerService.info('SharedPreferences initialized successfully',
          tag: _tag);
      return LocalStorageService(prefs: prefs);
    } catch (e, stackTrace) {
      LoggerService.error(
        'Failed to initialize SharedPreferences',
        tag: _tag,
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  String _roomIdentityKey(String roomId) =>
      'room_identity_${roomId.trim().toUpperCase()}';

  static const String _activeRoomKey = 'active_room_code';
  static const String _joinedRoomsKey = 'joined_room_codes';

  List<String> getJoinedRooms() {
    final list = prefs.getStringList(_joinedRoomsKey) ?? [];
    LoggerService.debug('Read joined rooms (${list.length}): $list', tag: _tag);
    return List<String>.from(list);
  }

  Future<bool> addJoinedRoom(String roomCode) async {
    final clean = roomCode.trim().toUpperCase();
    if (clean.isEmpty) return false;
    final list = getJoinedRooms();
    if (!list.contains(clean)) {
      list.insert(0, clean);
      LoggerService.info(
        'Adding room "$clean" to joined rooms (total: ${list.length})',
        tag: _tag,
      );
      return prefs.setStringList(_joinedRoomsKey, list);
    }
    return true;
  }

  Future<bool> removeJoinedRoom(String roomCode) async {
    final clean = roomCode.trim().toUpperCase();
    final list = getJoinedRooms();
    final removed = list.remove(clean);
    if (getActiveRoom() == clean) {
      await clearActiveRoom();
    }
    if (removed) {
      LoggerService.info(
        'Removed room "$clean" from joined rooms (remaining: ${list.length})',
        tag: _tag,
      );
      return prefs.setStringList(_joinedRoomsKey, list);
    }
    return true;
  }

  String? getActiveRoom() {
    final val = prefs.getString(_activeRoomKey);
    LoggerService.debug('Read active room: "$val"', tag: _tag);
    return val;
  }

  Future<bool> saveActiveRoom(String roomCode) async {
    final clean = roomCode.trim().toUpperCase();
    LoggerService.debug('Saving active room "$clean"', tag: _tag);
    await addJoinedRoom(clean);
    return prefs.setString(_activeRoomKey, clean);
  }

  Future<bool> clearActiveRoom() {
    LoggerService.debug('Clearing active room', tag: _tag);
    return prefs.remove(_activeRoomKey);
  }

  String? getRoomIdentity(String roomId) {
    final key = _roomIdentityKey(roomId);
    final val = prefs.getString(key);
    LoggerService.debug(
        'Read key "$key": ${val != null ? "found" : "not found"}',
        tag: _tag);
    return val;
  }

  Future<bool> saveRoomIdentity(String roomId, String jsonString) {
    final key = _roomIdentityKey(roomId);
    LoggerService.debug('Saving key "$key"', tag: _tag);
    return prefs.setString(key, jsonString);
  }

  Future<bool> clearRoomIdentity(String roomId) async {
    final key = _roomIdentityKey(roomId);
    LoggerService.debug('Removing key "$key"', tag: _tag);
    await removeJoinedRoom(roomId);
    return prefs.remove(key);
  }

  String _roomMessagesKey(String roomCode) =>
      'cached_messages_${roomCode.trim().toUpperCase()}';

  List<String> getCachedMessagesJson(String roomCode) {
    final key = _roomMessagesKey(roomCode);
    final list = prefs.getStringList(key) ?? [];
    LoggerService.debug('Read cached messages (${list.length}) for key "$key"',
        tag: _tag);
    return list;
  }

  Future<bool> saveCachedMessagesJson(
      String roomCode, List<String> messagesJson) {
    final key = _roomMessagesKey(roomCode);
    LoggerService.debug(
        'Saving ${messagesJson.length} cached messages for key "$key"',
        tag: _tag);
    return prefs.setStringList(key, messagesJson);
  }

  Future<bool> clearCachedMessages(String roomCode) {
    final key = _roomMessagesKey(roomCode);
    LoggerService.debug('Clearing cached messages for key "$key"', tag: _tag);
    return prefs.remove(key);
  }

  Future<void> clearAllSessionData() async {
    final keys = List<String>.from(prefs.getKeys());
    for (final key in keys) {
      if (key == _activeRoomKey ||
          key == _joinedRoomsKey ||
          key.startsWith('room_identity_') ||
          key.startsWith('cached_messages_') ||
          key.startsWith('fcm_token_') ||
          key.startsWith('room_name_')) {
        await prefs.remove(key);
      }
    }
    LoggerService.info('Cleared all local session data and identities',
        tag: _tag);
  }
}
