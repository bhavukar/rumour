class RoomNameGenerator {
  static const List<String> _adjectives = [
    'Neon',
    'Shadow',
    'Cyber',
    'Velvet',
    'Midnight',
    'Ghost',
    'Echo',
    'Silent',
    'Cosmic',
    'Solar',
    'Lunar',
    'Astral',
    'Dark',
    'Hidden',
    'Phantom',
    'Prism',
    'Rogue',
    'Vivid',
    'Electric',
    'Abyssal',
    'Static',
    'Quantum',
    'Glitch',
    'Obsidian',
    'Mirage',
    'Savage',
    'Zenith',
    'Arcane',
  ];

  static const List<String> _nouns = [
    'Lounge',
    'Chamber',
    'Vault',
    'Haven',
    'Den',
    'Crypt',
    'Sanctum',
    'Corner',
    'Hub',
    'Domain',
    'Nexus',
    'Shire',
    'Shelter',
    'Arcade',
    'Spire',
    'Fortress',
    'Refuge',
    'Basement',
    'Matrix',
    'Outpost',
    'Studio',
    'Station',
    'Room',
  ];

  static const List<String> _unsplashImages = [
    'https://images.unsplash.com/photo-1550684848-fac1c5b4e853?auto=format&fit=crop&w=300&h=300&q=80',
    'https://images.unsplash.com/photo-1508739773434-c26b3d09e071?auto=format&fit=crop&w=300&h=300&q=80',
    'https://images.unsplash.com/photo-1518770660439-4636190af475?auto=format&fit=crop&w=300&h=300&q=80',
    'https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5?auto=format&fit=crop&w=300&h=300&q=80',
    'https://images.unsplash.com/photo-1542751371-adc38448a05e?auto=format&fit=crop&w=300&h=300&q=80',
    'https://images.unsplash.com/photo-1511512578047-dfb367046420?auto=format&fit=crop&w=300&h=300&q=80',
    'https://images.unsplash.com/photo-1534447677768-be436bb09401?auto=format&fit=crop&w=300&h=300&q=80',
    'https://images.unsplash.com/photo-1519501025264-65ba15a82390?auto=format&fit=crop&w=300&h=300&q=80',
    'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?auto=format&fit=crop&w=300&h=300&q=80',
    'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?auto=format&fit=crop&w=300&h=300&q=80',
    'https://images.unsplash.com/photo-1607604276583-eef5d076aa5f?auto=format&fit=crop&w=300&h=300&q=80',
    'https://images.unsplash.com/photo-1579783900882-c0d3dad7b119?auto=format&fit=crop&w=300&h=300&q=80',
  ];

  static int _seedFromCode(String roomCode) {
    int hash = 0;
    for (int i = 0; i < roomCode.length; i++) {
      hash = (31 * hash + roomCode.codeUnitAt(i)) & 0x7FFFFFFF;
    }
    return hash;
  }

  static String generateRoomName(String roomCode) {
    if (roomCode.isEmpty) return 'Shadow Lounge';
    final seed = _seedFromCode(roomCode);
    final adj = _adjectives[seed % _adjectives.length];
    final noun = _nouns[(seed ~/ _adjectives.length) % _nouns.length];
    return '$adj $noun';
  }

  static String getInitials(String roomCode) {
    final name = generateRoomName(roomCode);
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    if (roomCode.length >= 2) {
      return roomCode.substring(0, 2).toUpperCase();
    }
    return 'RM';
  }

  static String getUnsplashAvatarUrl(String roomCode) {
    if (roomCode.isEmpty) return _unsplashImages[0];
    final seed = _seedFromCode(roomCode);
    return _unsplashImages[seed % _unsplashImages.length];
  }
}
