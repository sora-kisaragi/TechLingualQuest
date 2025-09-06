import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tech_lingual_quest/shared/services/language_service.dart';

void main() {
  group('SupportedLanguage Tests', () {
    test('should create supported language with all properties', () {
      const language = SupportedLanguage(
        code: 'en',
        nativeName: 'English',
        englishName: 'English',
        locale: Locale('en'),
      );
      
      expect(language.code, equals('en'));
      expect(language.nativeName, equals('English'));
      expect(language.englishName, equals('English'));
      expect(language.locale, equals(const Locale('en')));
    });
  });

  group('LanguageService Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('should get supported languages', () {
      final languages = LanguageService.getSupportedLanguages();
      
      expect(languages, isNotEmpty);
      expect(languages.length, greaterThanOrEqualTo(2));
      
      // Check that English and Japanese are supported
      expect(languages.any((lang) => lang.code == 'en'), isTrue);
      expect(languages.any((lang) => lang.code == 'ja'), isTrue);
    });

    test('should get language by valid code', () {
      final english = LanguageService.getLanguageByCode('en');
      final japanese = LanguageService.getLanguageByCode('ja');
      
      expect(english, isNotNull);
      expect(english!.code, equals('en'));
      expect(english.englishName, equals('English'));
      expect(english.nativeName, equals('English'));
      
      expect(japanese, isNotNull);
      expect(japanese!.code, equals('ja'));
      expect(japanese.englishName, equals('Japanese'));
      expect(japanese.nativeName, equals('日本語'));
    });

    test('should return null for invalid language code', () {
      final invalidLanguage = LanguageService.getLanguageByCode('xyz');
      
      expect(invalidLanguage, isNull);
    });

    test('should check if language is supported', () {
      expect(LanguageService.isLanguageSupported('en'), isTrue);
      expect(LanguageService.isLanguageSupported('ja'), isTrue);
      expect(LanguageService.isLanguageSupported('xyz'), isFalse);
      expect(LanguageService.isLanguageSupported(''), isFalse);
    });

    test('should get saved language from preferences', () async {
      // Test with no saved language (should return default)
      final defaultLanguage = await LanguageService.getSavedLanguage();
      expect(defaultLanguage, equals('en'));
      
      // Test with saved language
      SharedPreferences.setMockInitialValues({'selected_language': 'ja'});
      final savedLanguage = await LanguageService.getSavedLanguage();
      expect(savedLanguage, equals('ja'));
    });

    test('should return default language when saved language is not supported', () async {
      SharedPreferences.setMockInitialValues({'selected_language': 'unsupported'});
      
      final language = await LanguageService.getSavedLanguage();
      expect(language, equals('en'));
    });

    test('should save supported language', () async {
      final success = await LanguageService.saveLanguage('ja');
      expect(success, isTrue);
      
      final savedLanguage = await LanguageService.getSavedLanguage();
      expect(savedLanguage, equals('ja'));
    });

    test('should not save unsupported language', () async {
      final success = await LanguageService.saveLanguage('unsupported');
      expect(success, isFalse);
    });

    test('should get locale from valid language code', () {
      final englishLocale = LanguageService.getLocaleFromCode('en');
      final japaneseLocale = LanguageService.getLocaleFromCode('ja');
      
      expect(englishLocale, equals(const Locale('en')));
      expect(japaneseLocale, equals(const Locale('ja')));
    });

    test('should return default locale for invalid language code', () {
      final invalidLocale = LanguageService.getLocaleFromCode('xyz');
      expect(invalidLocale, equals(const Locale('en')));
    });

    test('should get supported locales', () {
      final locales = LanguageService.getSupportedLocales();
      
      expect(locales, isNotEmpty);
      expect(locales, contains(const Locale('en')));
      expect(locales, contains(const Locale('ja')));
    });

    test('should get default language', () {
      final defaultLanguage = LanguageService.getDefaultLanguage();
      
      expect(defaultLanguage.code, equals('en'));
      expect(defaultLanguage.locale, equals(const Locale('en')));
    });

    test('should have immutable supported languages list', () {
      final languages1 = LanguageService.getSupportedLanguages();
      final languages2 = LanguageService.getSupportedLanguages();
      
      expect(languages1, isNot(same(languages2)));
      expect(languages1, equals(languages2));
    });

    test('should validate supported language properties', () {
      final languages = LanguageService.getSupportedLanguages();
      
      for (final language in languages) {
        expect(language.code, isNotNull);
        expect(language.code, isNotEmpty);
        expect(language.nativeName, isNotNull);
        expect(language.nativeName, isNotEmpty);
        expect(language.englishName, isNotNull);
        expect(language.englishName, isNotEmpty);
        expect(language.locale, isNotNull);
        expect(language.locale.languageCode, equals(language.code));
      }
    });
  });

  group('LanguageNotifier Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('should initialize with default language', () {
      final notifier = LanguageNotifier();
      
      expect(notifier.state, equals(const Locale('en')));
    });

    test('should change language successfully for supported language', () async {
      final notifier = LanguageNotifier();
      
      final success = await notifier.changeLanguage('ja');
      
      expect(success, isTrue);
      expect(notifier.state, equals(const Locale('ja')));
    });

    test('should not change language for unsupported language', () async {
      final notifier = LanguageNotifier();
      final originalState = notifier.state;
      
      final success = await notifier.changeLanguage('unsupported');
      
      expect(success, isFalse);
      expect(notifier.state, equals(originalState));
    });

    test('should get current language configuration', () {
      final notifier = LanguageNotifier();
      
      final currentLanguage = notifier.getCurrentLanguage();
      
      expect(currentLanguage, isNotNull);
      expect(currentLanguage!.code, equals('en'));
    });

    test('should load saved language on initialization', () async {
      SharedPreferences.setMockInitialValues({'selected_language': 'ja'});
      
      final notifier = LanguageNotifier();
      // Wait for async initialization
      await Future.delayed(const Duration(milliseconds: 10));
      
      expect(notifier.state, equals(const Locale('ja')));
    });

    test('should return current language after changing language', () async {
      final notifier = LanguageNotifier();
      
      await notifier.changeLanguage('ja');
      final currentLanguage = notifier.getCurrentLanguage();
      
      expect(currentLanguage, isNotNull);
      expect(currentLanguage!.code, equals('ja'));
      expect(currentLanguage.nativeName, equals('日本語'));
    });

    test('should return null for invalid current language', () async {
      final notifier = LanguageNotifier();
      // Manually set state to invalid locale (this shouldn't happen in normal usage)
      notifier.state = const Locale('xyz');
      
      final currentLanguage = notifier.getCurrentLanguage();
      expect(currentLanguage, isNull);
    });

    test('should handle language persistence correctly', () async {
      final notifier = LanguageNotifier();
      
      // Change language
      await notifier.changeLanguage('ja');
      
      // Create a new notifier to simulate app restart
      final newNotifier = LanguageNotifier();
      await Future.delayed(const Duration(milliseconds: 10));
      
      expect(newNotifier.state, equals(const Locale('ja')));
    });

    test('should handle empty language code gracefully', () async {
      final notifier = LanguageNotifier();
      final originalState = notifier.state;
      
      final success = await notifier.changeLanguage('');
      
      expect(success, isFalse);
      expect(notifier.state, equals(originalState));
    });

    test('should handle null language code gracefully', () async {
      final notifier = LanguageNotifier();
      final originalState = notifier.state;
      
      final success = await notifier.changeLanguage('null');
      
      expect(success, isFalse);
      expect(notifier.state, equals(originalState));
    });
  });

  group('LanguageService Integration Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('should maintain consistency between saved and retrieved language', () async {
      // Save Japanese
      final saveSuccess = await LanguageService.saveLanguage('ja');
      expect(saveSuccess, isTrue);
      
      // Retrieve saved language
      final savedLanguage = await LanguageService.getSavedLanguage();
      expect(savedLanguage, equals('ja'));
      
      // Get locale from saved language
      final locale = LanguageService.getLocaleFromCode(savedLanguage);
      expect(locale, equals(const Locale('ja')));
    });

    test('should handle multiple language changes', () async {
      // Start with English
      expect(await LanguageService.getSavedLanguage(), equals('en'));
      
      // Change to Japanese
      await LanguageService.saveLanguage('ja');
      expect(await LanguageService.getSavedLanguage(), equals('ja'));
      
      // Change back to English
      await LanguageService.saveLanguage('en');
      expect(await LanguageService.getSavedLanguage(), equals('en'));
    });

    test('should validate language support chain', () {
      final supportedLanguages = LanguageService.getSupportedLanguages();
      
      for (final language in supportedLanguages) {
        // Each supported language should be recognized as supported
        expect(LanguageService.isLanguageSupported(language.code), isTrue);
        
        // Each supported language should be retrievable
        final retrieved = LanguageService.getLanguageByCode(language.code);
        expect(retrieved, isNotNull);
        expect(retrieved!.code, equals(language.code));
        
        // Each supported language should produce valid locale
        final locale = LanguageService.getLocaleFromCode(language.code);
        expect(locale.languageCode, equals(language.code));
      }
    });
  });
}