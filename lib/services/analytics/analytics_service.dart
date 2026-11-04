import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:rumour/services/logger/logger_service.dart';

class AnalyticsService {
  static const String _tag = 'AnalyticsService';
  static FirebaseAnalytics? _analyticsInstance;
  static bool _initialized = false;

  static FirebaseAnalytics? get _analytics {
    if (_analyticsInstance != null) return _analyticsInstance;
    try {
      _analyticsInstance = FirebaseAnalytics.instance;
      return _analyticsInstance;
    } catch (_) {
      return null;
    }
  }

  /// GoRouter navigation observer that automatically tracks page views
  static NavigatorObserver? get observer {
    try {
      final a = _analytics;
      if (a != null) {
        return FirebaseAnalyticsObserver(analytics: a);
      }
    } catch (_) {}
    return null;
  }

  /// Initializes Firebase Analytics and sets collection mode
  static Future<void> initialize() async {
    try {
      final a = _analytics;
      if (a == null) return;

      await a.setAnalyticsCollectionEnabled(!kDebugMode);
      _initialized = true;
      LoggerService.info('Firebase Analytics initialized successfully',
          tag: _tag);
    } catch (e, stackTrace) {
      LoggerService.warn(
        'Analytics initialization skipped or failed (expected in test mode): $e',
        tag: _tag,
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Sets the unique anonymous user identifier in Analytics
  static Future<void> setUserId(String userId) async {
    try {
      if (!_initialized) return;
      await _analytics?.setUserId(id: userId);
      await _analytics?.setUserProperty(name: 'is_anonymous', value: 'true');
    } catch (_) {}
  }

  /// Logs when a new anonymous room is generated
  static Future<void> logRoomCreated(String roomCode) async {
    try {
      if (!_initialized) return;
      await _analytics?.logEvent(
        name: 'room_created',
        parameters: {
          'room_code': roomCode,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } catch (_) {}
  }

  /// Logs when a user successfully enters or joins a room
  static Future<void> logRoomJoined(String roomCode) async {
    try {
      if (!_initialized) return;
      await _analytics?.logEvent(
        name: 'room_joined',
        parameters: {
          'room_code': roomCode,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } catch (_) {}
  }

  /// Logs when a user leaves a room
  static Future<void> logRoomLeft(String roomCode) async {
    try {
      if (!_initialized) return;
      await _analytics?.logEvent(
        name: 'room_left',
        parameters: {
          'room_code': roomCode,
        },
      );
    } catch (_) {}
  }

  /// Logs when a chat message is successfully dispatched
  static Future<void> logMessageSent({
    required String roomCode,
    required int messageLength,
    bool isReply = false,
  }) async {
    try {
      if (!_initialized) return;
      await _analytics?.logEvent(
        name: 'message_sent',
        parameters: {
          'room_code': roomCode,
          'length': messageLength,
          'is_reply': isReply ? 1 : 0,
        },
      );
    } catch (_) {}
  }

  /// Logs screen views explicitly if needed
  static Future<void> logScreenView(String screenName) async {
    try {
      if (!_initialized) return;
      await _analytics?.logScreenView(screenName: screenName);
    } catch (_) {}
  }

  /// Logs when the user changes theme mode
  static Future<void> logThemeChanged(String themeMode) async {
    try {
      if (!_initialized) return;
      await _analytics?.logEvent(
        name: 'theme_changed',
        parameters: {
          'mode': themeMode,
        },
      );
    } catch (_) {}
  }

  /// Logs when the user clears local app data from Settings
  static Future<void> logAppDataCleared() async {
    try {
      if (!_initialized) return;
      await _analytics?.logEvent(name: 'app_data_cleared');
    } catch (_) {}
  }
}
