import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;
    try {
      await dotenv.load(fileName: '.env');
      _initialized = true;
    } catch (_) {
      // In case .env file is missing or in tests, dotenv stays empty
    }
  }

  static String get(String key, {String defaultValue = ''}) {
    return dotenv.maybeGet(key) ?? defaultValue;
  }
}
