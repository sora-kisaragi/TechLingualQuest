import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Supported language configuration
/// 
/// Defines the languages supported by the app with metadata
class SupportedLanguage {
  final String code;
  final String nativeName;
  final String englishName;
  final Locale locale;

  const SupportedLanguage({
    required this.code,
    required this.nativeName,
    required this.englishName,
    required this.locale,
  });
}

/// Language service for managing app localization preferences
///
/// Handles language switching and persisting user language choice
/// Designed to be easily extensible for additional languages
class LanguageService {
  static const String _languageKey = 'selected_language';
  static const String _defaultLanguageCode = 'en';

  /// All supported languages in the app
  /// 
  /// To add a new language:
  /// 1. Add the language here
  /// 2. Create the corresponding ARB file (app_[code].arb)
  /// 3. Update l10n.yaml if needed
  /// 4. Add translations for language names in ARB files
  static const List<SupportedLanguage> _supportedLanguages = [
    SupportedLanguage(
      code: 'en',
      nativeName: 'English',
      englishName: 'English',
      locale: Locale('en'),
    ),
    SupportedLanguage(
      code: 'ja',
      nativeName: '日本語',
      englishName: 'Japanese',
      locale: Locale('ja'),
    ),
    // Future languages can be added here:
    // SupportedLanguage(
    //   code: 'ko',
    //   nativeName: '한국어',
    //   englishName: 'Korean',
    //   locale: Locale('ko'),
    // ),
    // SupportedLanguage(
    //   code: 'zh',
    //   nativeName: '中文',
    //   englishName: 'Chinese',
    //   locale: Locale('zh'),
    // ),
  ];

  /// Get all supported languages
  static List<SupportedLanguage> getSupportedLanguages() {
    return List.unmodifiable(_supportedLanguages);
  }

  /// Get supported language by code
  static SupportedLanguage? getLanguageByCode(String code) {
    try {
      return _supportedLanguages.firstWhere((lang) => lang.code == code);
    } catch (e) {
      return null;
    }
  }

  /// Check if a language code is supported
  static bool isLanguageSupported(String code) {
    return _supportedLanguages.any((lang) => lang.code == code);
  }

  /// Get the saved language code from shared preferences
  /// Returns default language if no language is saved or saved language is not supported
  static Future<String> getSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCode = prefs.getString(_languageKey) ?? _defaultLanguageCode;
    
    // Validate that the saved language is still supported
    return isLanguageSupported(savedCode) ? savedCode : _defaultLanguageCode;
  }

  /// Save the selected language code to shared preferences
  /// Only saves if the language code is supported
  static Future<bool> saveLanguage(String languageCode) async {
    if (!isLanguageSupported(languageCode)) {
      return false;
    }
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, languageCode);
    return true;
  }

  /// Get the Locale object from language code
  static Locale getLocaleFromCode(String languageCode) {
    final language = getLanguageByCode(languageCode);
    return language?.locale ?? const Locale(_defaultLanguageCode);
  }

  /// Get supported locales for the app
  static List<Locale> getSupportedLocales() {
    return _supportedLanguages.map((lang) => lang.locale).toList();
  }

  /// Get default language
  static SupportedLanguage getDefaultLanguage() {
    return _supportedLanguages.firstWhere(
      (lang) => lang.code == _defaultLanguageCode,
    );
  }
}

/// Language state notifier for managing current language
class LanguageNotifier extends StateNotifier<Locale> {
  LanguageNotifier() : super(LanguageService.getDefaultLanguage().locale) {
    _loadSavedLanguage();
  }

  /// Load saved language from preferences
  Future<void> _loadSavedLanguage() async {
    final languageCode = await LanguageService.getSavedLanguage();
    state = LanguageService.getLocaleFromCode(languageCode);
  }

  /// Change the app language
  /// Returns true if the language was successfully changed
  Future<bool> changeLanguage(String languageCode) async {
    final success = await LanguageService.saveLanguage(languageCode);
    if (success) {
      state = LanguageService.getLocaleFromCode(languageCode);
    }
    return success;
  }

  /// Get the current language configuration
  SupportedLanguage? getCurrentLanguage() {
    return LanguageService.getLanguageByCode(state.languageCode);
  }
}

/// Provider for the language notifier
final languageProvider = StateNotifierProvider<LanguageNotifier, Locale>((ref) {
  return LanguageNotifier();
});