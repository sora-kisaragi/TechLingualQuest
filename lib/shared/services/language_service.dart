import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Language service for managing app localization preferences
///
/// Handles language switching and persisting user language choice
class LanguageService {
  static const String _languageKey = 'selected_language';

  /// Get the saved language code from shared preferences
  /// Returns 'en' as default if no language is saved
  static Future<String> getSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_languageKey) ?? 'en';
  }

  /// Save the selected language code to shared preferences
  static Future<void> saveLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, languageCode);
  }

  /// Get the Locale object from language code
  static Locale getLocaleFromCode(String languageCode) {
    switch (languageCode) {
      case 'ja':
        return const Locale('ja');
      case 'en':
      default:
        return const Locale('en');
    }
  }

  /// Get supported locales for the app
  static List<Locale> getSupportedLocales() {
    return const [
      Locale('en'), // English
      Locale('ja'), // Japanese
    ];
  }
}

/// Language state notifier for managing current language
class LanguageNotifier extends StateNotifier<Locale> {
  LanguageNotifier() : super(const Locale('en')) {
    _loadSavedLanguage();
  }

  /// Load saved language from preferences
  Future<void> _loadSavedLanguage() async {
    final languageCode = await LanguageService.getSavedLanguage();
    state = LanguageService.getLocaleFromCode(languageCode);
  }

  /// Change the app language
  Future<void> changeLanguage(String languageCode) async {
    await LanguageService.saveLanguage(languageCode);
    state = LanguageService.getLocaleFromCode(languageCode);
  }
}

/// Provider for the language notifier
final languageProvider = StateNotifierProvider<LanguageNotifier, Locale>((ref) {
  return LanguageNotifier();
});