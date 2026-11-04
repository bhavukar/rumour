class AppRoutes {
  static const String root = '/';
  static const String rooms = '/';
  static const String joinRoom = '/';
  static const String chatRoom = '/chat/:roomCode';
  static const String settings = '/settings';

  static String chatRoomPath(String roomCode) => '/chat/$roomCode';
  static const String settingsPath = '/settings';
}
