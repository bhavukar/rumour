import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:rumour/services/crashlytics/crashlytics_service.dart';

class LoggerService {
  LoggerService._();

  static const String _defaultTag = 'Rumour';

  static const String _reset = '\x1B[0m';
  static const String _gray = '\x1B[90m';
  static const String _blue = '\x1B[34m';
  static const String _green = '\x1B[32m';
  static const String _yellow = '\x1B[33m';
  static const String _red = '\x1B[31m';

  static void debug(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(
      level: 'DEBUG',
      color: _blue,
      message: message,
      tag: tag ?? _defaultTag,
      error: error,
      stackTrace: stackTrace,
      logLevelValue: 500,
    );
  }

  static void info(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(
      level: 'INFO',
      color: _green,
      message: message,
      tag: tag ?? _defaultTag,
      error: error,
      stackTrace: stackTrace,
      logLevelValue: 800,
    );
  }

  static void warn(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(
      level: 'WARN',
      color: _yellow,
      message: message,
      tag: tag ?? _defaultTag,
      error: error,
      stackTrace: stackTrace,
      logLevelValue: 900,
    );
  }

  static void error(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(
      level: 'ERROR',
      color: _red,
      message: message,
      tag: tag ?? _defaultTag,
      error: error,
      stackTrace: stackTrace,
      logLevelValue: 1000,
    );
  }

  static void _log({
    required String level,
    required String color,
    required String message,
    required String tag,
    Object? error,
    StackTrace? stackTrace,
    required int logLevelValue,
  }) {
    final now = DateTime.now().toIso8601String().substring(11, 23);
    final formattedMessage = '[$now] [$level] [$tag] $message';

    if (kDebugMode) {
      developer.log(
        '$color$formattedMessage$_reset'
        '${error != null ? '\n$_red[Error]: $error$_reset' : ''}'
        '${stackTrace != null ? '\n$_gray$stackTrace$_reset' : ''}',
        name: tag,
        level: logLevelValue,
        error: error,
        stackTrace: stackTrace,
      );
    } else {
      developer.log(
        formattedMessage,
        name: tag,
        level: logLevelValue,
        error: error,
        stackTrace: stackTrace,
      );
    }

    try {
      if (level == 'ERROR') {
        CrashlyticsService.recordError(
          error ?? message,
          stackTrace,
          reason: message,
          fatal: false,
        );
      } else {
        CrashlyticsService.log('[$level] [$tag] $message');
      }
    } catch (_) {}
  }
}
