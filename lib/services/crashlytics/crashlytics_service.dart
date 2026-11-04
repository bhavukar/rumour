import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:rumour/services/logger/logger_service.dart';

class CrashlyticsService {
  static const String _tag = 'CrashlyticsService';
  static bool _initialized = false;

  /// Initializes Crashlytics exception hooks for both Flutter framework errors
  /// and uncaught platform/async errors.
  static Future<void> initialize() async {
    try {
      if (kIsWeb) return;

      // Enable collection (can be disabled in debug mode if desired)
      await FirebaseCrashlytics.instance
          .setCrashlyticsCollectionEnabled(!kDebugMode);

      // 1. Pass all uncaught "fatal" errors from the framework to Crashlytics
      FlutterError.onError = (errorDetails) {
        LoggerService.error(
          'FlutterError caught by Crashlytics: ${errorDetails.exceptionAsString()}',
          tag: _tag,
          error: errorDetails.exception,
          stackTrace: errorDetails.stack,
        );
        try {
          FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
        } catch (_) {}
      };

      // 2. Pass all uncaught asynchronous errors that aren't handled by Flutter
      PlatformDispatcher.instance.onError = (error, stack) {
        LoggerService.error(
          'PlatformDispatcher error caught by Crashlytics: $error',
          tag: _tag,
          error: error,
          stackTrace: stack,
        );
        try {
          FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        } catch (_) {}
        return true;
      };

      _initialized = true;
      LoggerService.info('Firebase Crashlytics initialized successfully',
          tag: _tag);
    } catch (e, stackTrace) {
      LoggerService.warn(
        'Crashlytics initialization skipped or failed (expected in offline test mode): $e',
        tag: _tag,
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Sets the user identifier for crash reports
  static void setUserIdentifier(String userId) {
    try {
      if (kIsWeb || !_initialized) return;
      FirebaseCrashlytics.instance.setUserIdentifier(userId);
    } catch (_) {}
  }

  /// Sets custom key-value metadata on Crashlytics reports
  static void setCustomKey(String key, Object value) {
    try {
      if (kIsWeb || !_initialized) return;
      FirebaseCrashlytics.instance.setCustomKey(key, value);
    } catch (_) {}
  }

  /// Logs breadcrumbs visible in the Crashlytics session timeline
  static void log(String message) {
    try {
      if (kIsWeb || !_initialized) return;
      FirebaseCrashlytics.instance.log(message);
    } catch (_) {}
  }

  /// Explicitly records a handled non-fatal or fatal error
  static void recordError(
    dynamic error,
    StackTrace? stackTrace, {
    dynamic reason,
    bool fatal = false,
  }) {
    try {
      if (kIsWeb || !_initialized) return;
      FirebaseCrashlytics.instance.recordError(
        error,
        stackTrace,
        reason: reason,
        fatal: fatal,
      );
    } catch (_) {}
  }
}
