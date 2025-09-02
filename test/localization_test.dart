import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:tech_lingual_quest/generated/l10n/app_localizations.dart';
import 'package:tech_lingual_quest/shared/services/language_service.dart';
import 'package:tech_lingual_quest/shared/widgets/language_selector.dart';

void main() {
  group('Localization Tests', () {
    testWidgets('Should display English text by default', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            locale: const Locale('en'),
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: LanguageService.getSupportedLocales(),
            home: Builder(
              builder: (context) {
                final l10n = AppLocalizations.of(context)!;
                return Scaffold(
                  body: Column(
                    children: [
                      Text(l10n.appTitle),
                      Text(l10n.welcomeMessage),
                      Text(l10n.vocabulary),
                      Text(l10n.quests),
                      Text(l10n.profile),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      );

      // Verify English text is displayed
      expect(find.text('TechLingual Quest'), findsOneWidget);
      expect(find.text('Welcome to TechLingual Quest!'), findsOneWidget);
      expect(find.text('Vocabulary'), findsOneWidget);
      expect(find.text('Quests'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);
    });

    testWidgets('Should display Japanese text when locale is Japanese', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            locale: const Locale('ja'),
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: LanguageService.getSupportedLocales(),
            home: Builder(
              builder: (context) {
                final l10n = AppLocalizations.of(context)!;
                return Scaffold(
                  body: Column(
                    children: [
                      Text(l10n.appTitle),
                      Text(l10n.welcomeMessage),
                      Text(l10n.vocabulary),
                      Text(l10n.quests),
                      Text(l10n.profile),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      );

      // Verify Japanese text is displayed (app title stays in English)
      expect(find.text('TechLingual Quest'), findsOneWidget);
      expect(find.text('テックリンガルクエストへようこそ！'), findsOneWidget);
      expect(find.text('語彙'), findsOneWidget);
      expect(find.text('クエスト'), findsOneWidget);
      expect(find.text('プロフィール'), findsOneWidget);
    });

    testWidgets('Language selector should show language options', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            locale: const Locale('en'),
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: LanguageService.getSupportedLocales(),
            home: const Scaffold(
              body: LanguageSelector(),
            ),
          ),
        ),
      );

      // Find and tap the language selector
      final languageButton = find.byIcon(Icons.language);
      expect(languageButton, findsOneWidget);
      
      await tester.tap(languageButton);
      await tester.pumpAndSettle();

      // Verify language options are shown
      expect(find.text('English'), findsOneWidget);
      expect(find.text('Japanese'), findsOneWidget);
    });

    test('LanguageService should return correct locales', () {
      final supportedLocales = LanguageService.getSupportedLocales();
      expect(supportedLocales.length, 2);
      expect(supportedLocales.contains(const Locale('en')), true);
      expect(supportedLocales.contains(const Locale('ja')), true);
    });

    test('LanguageService should convert language codes to locales correctly', () {
      expect(LanguageService.getLocaleFromCode('en'), const Locale('en'));
      expect(LanguageService.getLocaleFromCode('ja'), const Locale('ja'));
      expect(LanguageService.getLocaleFromCode('unknown'), const Locale('en')); // Default fallback
    });

    test('LanguageService should handle supported languages correctly', () {
      final supportedLanguages = LanguageService.getSupportedLanguages();
      expect(supportedLanguages.length, 2);
      
      // Test English language
      final english = LanguageService.getLanguageByCode('en');
      expect(english, isNotNull);
      expect(english!.code, 'en');
      expect(english.englishName, 'English');
      expect(english.locale, const Locale('en'));
      
      // Test Japanese language
      final japanese = LanguageService.getLanguageByCode('ja');
      expect(japanese, isNotNull);
      expect(japanese!.code, 'ja');
      expect(japanese.englishName, 'Japanese');
      expect(japanese.nativeName, '日本語');
      expect(japanese.locale, const Locale('ja'));
      
      // Test unsupported language
      final unsupported = LanguageService.getLanguageByCode('fr');
      expect(unsupported, isNull);
    });

    test('LanguageService should validate language support correctly', () {
      expect(LanguageService.isLanguageSupported('en'), true);
      expect(LanguageService.isLanguageSupported('ja'), true);
      expect(LanguageService.isLanguageSupported('fr'), false);
      expect(LanguageService.isLanguageSupported(''), false);
    });

    test('LanguageService should return default language', () {
      final defaultLang = LanguageService.getDefaultLanguage();
      expect(defaultLang.code, 'en');
      expect(defaultLang.englishName, 'English');
    });
  });
}