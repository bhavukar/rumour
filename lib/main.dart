import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:rumour/services/analytics/analytics_service.dart';
import 'package:rumour/services/crashlytics/crashlytics_service.dart';
import 'package:rumour/services/dependency_injection/app_config.dart';
import 'package:rumour/services/firebase/env_config.dart';
import 'package:rumour/services/firebase/firebase_service.dart';
import 'package:rumour/services/logger/logger_service.dart';
import 'package:rumour/services/notifications/notification_service.dart';
import 'package:rumour/services/routes/app_router.dart';
import 'package:rumour/services/storage/local_storage_service.dart';

void main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Fast parallel initialization of local dependencies
  await EnvConfig.initialize();
  final results = await Future.wait([
    LocalStorageService.init(),
    FirebaseService.initializeCore().catchError((e) {
      LoggerService.warn('Firebase core initialization warning: $e');
    }),
  ]);

  final localStorageService = results[0] as LocalStorageService;

  // Mount UI immediately for an instant opening experience
  runApp(
    AppConfiguration(
      localStorageService: localStorageService,
    ),
  );

  // Remove native splash as soon as the first frame is mounted
  FlutterNativeSplash.remove();

  // Background non-blocking network and notification initialization in parallel
  unawaited(_initializeBackgroundServices());
}

Future<void> _initializeBackgroundServices() async {
  await Future.wait([
    FirebaseService.ensureAnonymousAuth()
        .timeout(const Duration(seconds: 2))
        .catchError((_) => null),
    CrashlyticsService.initialize()
        .timeout(const Duration(seconds: 1))
        .catchError((_) => null),
    AnalyticsService.initialize()
        .timeout(const Duration(seconds: 1))
        .catchError((_) => null),
    NotificationService.initialize()
        .timeout(const Duration(seconds: 2))
        .catchError((_) => null),
  ]);
  AppRouter.initializeNotificationRouting();
}
