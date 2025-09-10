import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/services/ai_service.dart';
import '../../core/services/voice_service.dart';
import '../../core/services/database_service.dart';

class AppState {
  final Locale locale;
  final ThemeMode themeMode;
  final bool isInitialized;
  final String? error;

  const AppState({
    required this.locale,
    required this.themeMode,
    required this.isInitialized,
    this.error,
  });

  bool get isArabic => locale.languageCode == 'ar';

  AppState copyWith({
    Locale? locale,
    ThemeMode? themeMode,
    bool? isInitialized,
    String? error,
  }) {
    return AppState(
      locale: locale ?? this.locale,
      themeMode: themeMode ?? this.themeMode,
      isInitialized: isInitialized ?? this.isInitialized,
      error: error,
    );
  }
}

class AppStateNotifier extends StateNotifier<AppState> {
  AppStateNotifier() : super(const AppState(
    locale: Locale('ar', 'SA'),
    themeMode: ThemeMode.system,
    isInitialized: false,
  ));

  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load saved locale
      final languageCode = prefs.getString('language_code') ?? 'ar';
      final countryCode = prefs.getString('country_code') ?? 'SA';
      
      // Load saved theme
      final themeIndex = prefs.getInt('theme_mode') ?? 0;
      final themeMode = ThemeMode.values[themeIndex];
      
      state = state.copyWith(
        locale: Locale(languageCode, countryCode),
        themeMode: themeMode,
        isInitialized: true,
      );
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to initialize app: $e',
        isInitialized: true,
      );
    }
  }

  Future<void> setLocale(Locale locale) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('language_code', locale.languageCode);
      await prefs.setString('country_code', locale.countryCode ?? '');
      
      state = state.copyWith(locale: locale);
    } catch (e) {
      state = state.copyWith(error: 'Failed to save locale: $e');
    }
  }

  Future<void> setThemeMode(ThemeMode themeMode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('theme_mode', themeMode.index);
      
      state = state.copyWith(themeMode: themeMode);
    } catch (e) {
      state = state.copyWith(error: 'Failed to save theme: $e');
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final appStateProvider = StateNotifierProvider<AppStateNotifier, AppState>((ref) {
  return AppStateNotifier();
});
