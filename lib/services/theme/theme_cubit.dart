import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rumour/services/analytics/analytics_service.dart';
import 'package:rumour/services/logger/logger_service.dart';
import 'package:rumour/services/storage/local_storage_service.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  static const String _tag = 'ThemeCubit';
  static const String _storageKey = 'app_theme_mode';

  final LocalStorageService localStorageService;

  ThemeCubit({required this.localStorageService})
      : super(_readSavedTheme(localStorageService));

  static ThemeMode _readSavedTheme(LocalStorageService storage) {
    final saved = storage.prefs.getString(_storageKey);
    if (saved == 'light') return ThemeMode.light;
    return ThemeMode.dark;
  }

  void toggleTheme() {
    final nextMode = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    setTheme(nextMode);
  }

  void setTheme(ThemeMode mode) {
    final modeStr = mode == ThemeMode.light ? 'light' : 'dark';
    localStorageService.prefs.setString(_storageKey, modeStr);
    LoggerService.info('App theme switched to $modeStr', tag: _tag);
    AnalyticsService.logThemeChanged(modeStr);
    emit(mode);
  }

  bool get isDarkMode => state == ThemeMode.dark;
}
