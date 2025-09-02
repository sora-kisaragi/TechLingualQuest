import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Language information structure
class LanguageInfo {
  final String code;
  final String nativeName;
  final String englishName;
  final Locale locale;

  const LanguageInfo({
    required this.code,
    required this.nativeName,
    required this.englishName,
    required this.locale,
  });

  factory LanguageInfo.fromJson(String code, Map<String, dynamic> json) {
    return LanguageInfo(
      code: code,
      nativeName: json['nativeName'] ?? code,
      englishName: json['englishName'] ?? code,
      locale: Locale(code),
    );
  }
}

/// Dynamic localization system that uses JSON-based translations
/// 
/// This system allows for easy addition of new languages without code changes
/// by simply adding translations to the JSON file
class DynamicLocalizationService {
  static const String _languageKey = 'selected_language';
  static const String _defaultLanguageCode = 'en';
  static const String _translationsPath = 'assets/translations/translations.json';

  // Cache for loaded translations
  static Map<String, dynamic>? _translationsData;
  static Map<String, LanguageInfo>? _supportedLanguages;

  /// Load translations from JSON file
  static Future<void> _loadTranslations() async {
    if (_translationsData != null) return; // Already loaded

    try {
      final String jsonString = await rootBundle.loadString(_translationsPath);
      final Map<String, dynamic> data = json.decode(jsonString);
      
      _translationsData = data['translations'] ?? {};
      
      // Parse supported languages
      final Map<String, dynamic> languagesData = data['supportedLanguages'] ?? {};
      _supportedLanguages = {};
      
      for (final entry in languagesData.entries) {
        _supportedLanguages![entry.key] = LanguageInfo.fromJson(
          entry.key,
          entry.value,
        );
      }
    } catch (e) {
      // Fallback to minimal setup if loading fails
      _translationsData = {};
      _supportedLanguages = {
        'en': const LanguageInfo(
          code: 'en',
          nativeName: 'English',
          englishName: 'English',
          locale: Locale('en'),
        ),
      };
    }
  }

  /// Get all supported languages
  static Future<List<LanguageInfo>> getSupportedLanguages() async {
    await _loadTranslations();
    return _supportedLanguages!.values.toList();
  }

  /// Get language info by code
  static Future<LanguageInfo?> getLanguageByCode(String code) async {
    await _loadTranslations();
    return _supportedLanguages![code];
  }

  /// Check if a language is supported
  static Future<bool> isLanguageSupported(String code) async {
    await _loadTranslations();
    return _supportedLanguages!.containsKey(code);
  }

  /// Get translated text for a given key and language
  static Future<String> translate(String key, String languageCode) async {
    await _loadTranslations();
    
    final translationMap = _translationsData![key];
    if (translationMap == null) {
      return key; // Return key if no translation found
    }
    
    // Try to get translation for the specified language
    final translation = translationMap[languageCode];
    if (translation != null) {
      return translation;
    }
    
    // Fallback to English if available
    final englishTranslation = translationMap[_defaultLanguageCode];
    if (englishTranslation != null) {
      return englishTranslation;
    }
    
    // Return the key as last resort
    return key;
  }

  /// Get saved language from preferences
  static Future<String> getSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCode = prefs.getString(_languageKey) ?? _defaultLanguageCode;
    
    // Validate that the saved language is still supported
    final isSupported = await isLanguageSupported(savedCode);
    return isSupported ? savedCode : _defaultLanguageCode;
  }

  /// Save language preference
  static Future<bool> saveLanguage(String languageCode) async {
    final isSupported = await isLanguageSupported(languageCode);
    if (!isSupported) {
      return false;
    }
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, languageCode);
    return true;
  }

  /// Get locale from language code
  static Future<Locale> getLocaleFromCode(String languageCode) async {
    final language = await getLanguageByCode(languageCode);
    return language?.locale ?? const Locale(_defaultLanguageCode);
  }

  /// Get all supported locales
  static Future<List<Locale>> getSupportedLocales() async {
    final languages = await getSupportedLanguages();
    return languages.map((lang) => lang.locale).toList();
  }

  /// Get default language
  static Future<LanguageInfo> getDefaultLanguage() async {
    await _loadTranslations();
    return _supportedLanguages![_defaultLanguageCode] ?? 
           const LanguageInfo(
             code: _defaultLanguageCode,
             nativeName: 'English',
             englishName: 'English',
             locale: Locale(_defaultLanguageCode),
           );
  }

  /// Reload translations (useful for hot reload or dynamic updates)
  static Future<void> reloadTranslations() async {
    _translationsData = null;
    _supportedLanguages = null;
    await _loadTranslations();
  }
}

/// Notifier for managing current language state
class DynamicLanguageNotifier extends StateNotifier<Locale> {
  DynamicLanguageNotifier() : super(const Locale('en')) {
    _loadSavedLanguage();
  }

  /// Load saved language from preferences
  Future<void> _loadSavedLanguage() async {
    final languageCode = await DynamicLocalizationService.getSavedLanguage();
    final locale = await DynamicLocalizationService.getLocaleFromCode(languageCode);
    state = locale;
  }

  /// Change the app language
  Future<bool> changeLanguage(String languageCode) async {
    final success = await DynamicLocalizationService.saveLanguage(languageCode);
    if (success) {
      final locale = await DynamicLocalizationService.getLocaleFromCode(languageCode);
      state = locale;
    }
    return success;
  }

  /// Get current language info
  Future<LanguageInfo?> getCurrentLanguage() async {
    return await DynamicLocalizationService.getLanguageByCode(state.languageCode);
  }
}

/// Provider for the dynamic language system
final dynamicLanguageProvider = StateNotifierProvider<DynamicLanguageNotifier, Locale>((ref) {
  return DynamicLanguageNotifier();
});

/// Translation helper class that provides easy access to translations
class AppTranslations {
  final String _languageCode;
  
  const AppTranslations._(this._languageCode);

  /// Create translations instance for a specific language
  static Future<AppTranslations> of(String languageCode) async {
    return AppTranslations._(languageCode);
  }

  /// Get translation for a key
  Future<String> get(String key) async {
    return await DynamicLocalizationService.translate(key, _languageCode);
  }

  /// Get translation synchronously if translations are already loaded
  /// Falls back to async loading if not cached
  String getSync(String key, {String fallback = ''}) {
    if (DynamicLocalizationService._translationsData == null) {
      return fallback;
    }
    
    final translationMap = DynamicLocalizationService._translationsData![key];
    if (translationMap == null) {
      return fallback.isNotEmpty ? fallback : key;
    }
    
    final translation = translationMap[_languageCode];
    if (translation != null) {
      return translation;
    }
    
    // Fallback to English
    final englishTranslation = translationMap['en'];
    if (englishTranslation != null) {
      return englishTranslation;
    }
    
    return fallback.isNotEmpty ? fallback : key;
  }

  // Convenience getters for common translations (async)
  Future<String> get appTitle => get('TechLingual Quest');
  Future<String> get welcomeMessage => get('Welcome to TechLingual Quest!');
  Future<String> get gamifiedJourney => get('Your gamified journey to master technical English');
  Future<String> get xpLabel => get('XP:');
  Future<String> get earnXpTooltip => get('Earn XP');
  Future<String> get featuresTitle => get('Features:');
  Future<String> get feature1 => get('• Daily quests and challenges');
  Future<String> get feature2 => get('• Vocabulary building with spaced repetition');
  Future<String> get feature3 => get('• Technical article summaries');
  Future<String> get feature4 => get('• Progress tracking and achievements');
  Future<String> get feature5 => get('• AI-powered conversation practice');
  Future<String> get vocabulary => get('Vocabulary');
  Future<String> get quests => get('Quests');
  Future<String> get profile => get('Profile');
  Future<String> get vocabularyLearning => get('Vocabulary Learning');
  Future<String> get vocabularyDescription => get('Vocabulary cards and learning features will be implemented here');
  Future<String> get dailyQuests => get('Daily Quests');
  Future<String> get questsDescription => get('Quest system and gamification features will be implemented here');
  Future<String> get authentication => get('Authentication');
  Future<String> get authDescription => get('User authentication will be implemented here');
  Future<String> get language => get('Language');
  Future<String> get english => get('English');
  Future<String> get japanese => get('Japanese');
  Future<String> get korean => get('Korean');
  Future<String> get chinese => get('Chinese');

  // Convenience getters for common translations (sync)
  String get appTitleSync => getSync('TechLingual Quest', fallback: 'TechLingual Quest');
  String get welcomeMessageSync => getSync('Welcome to TechLingual Quest!', fallback: 'Welcome to TechLingual Quest!');
  String get vocabularySync => getSync('Vocabulary', fallback: 'Vocabulary');
  String get questsSync => getSync('Quests', fallback: 'Quests');
  String get profileSync => getSync('Profile', fallback: 'Profile');
}

/// Provider for app translations based on current language
final appTranslationsProvider = FutureProvider<AppTranslations>((ref) async {
  final locale = ref.watch(dynamicLanguageProvider);
  return await AppTranslations.of(locale.languageCode);
});