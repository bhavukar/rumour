import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:rumour/services/analytics/analytics_service.dart';
import 'package:rumour/services/crashlytics/crashlytics_service.dart';
import 'package:rumour/services/dependency_injection/app_config.dart';
import 'package:rumour/services/firebase/env_config.dart';
import 'package:rumour/services/firebase/firebase_service.dart';
import 'package:rumour/services/notifications/notification_service.dart';
import 'package:rumour/services/routes/app_router.dart';
import 'package:rumour/services/storage/local_storage_service.dart';

void main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await EnvConfig.initialize();
  await FirebaseService.initialize();
  await CrashlyticsService.initialize();
  await AnalyticsService.initialize();
  await NotificationService.initialize();
  AppRouter.initializeNotificationRouting();

  final localStorageService = await LocalStorageService.init();

  runApp(
    AppConfiguration(
      localStorageService: localStorageService,
    ),
  );
}
