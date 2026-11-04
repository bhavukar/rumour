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

  // Fast local configuration loading
  await EnvConfig.initialize();
  final localStorageService = await LocalStorageService.init();

  // Initialize Firebase core locally (registers options in memory without blocking)
  try {
    await FirebaseService.initializeCore().timeout(const Duration(seconds: 2));
  } catch (e) {
    LoggerService.warn('Firebase core initialization timeout: $e');
  }

  // Mount UI immediately so app launches instantly even completely offline
  runApp(
    AppConfiguration(
      localStorageService: localStorageService,
    ),
  );

  // Guaranteed splash removal once app is mounted
  FlutterNativeSplash.remove();

  // Background non-blocking network and notification initialization
  unawaited(_initializeBackgroundServices());
}

Future<void> _initializeBackgroundServices() async {
  try {
    await FirebaseService.ensureAnonymousAuth()
        .timeout(const Duration(seconds: 3));
  } catch (_) {}

  try {
    await CrashlyticsService.initialize().timeout(const Duration(seconds: 2));
  } catch (_) {}

  try {
    await AnalyticsService.initialize().timeout(const Duration(seconds: 2));
  } catch (_) {}

  try {
    await NotificationService.initialize().timeout(const Duration(seconds: 3));
    AppRouter.initializeNotificationRouting();
  } catch (_) {}
}
