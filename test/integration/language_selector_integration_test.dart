import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tech_lingual_quest/shared/widgets/dynamic_language_selector.dart';
import 'package:tech_lingual_quest/shared/services/dynamic_localization_service.dart';

void main() {
  group('Language Selector Integration Tests', () {
    testWidgets(
        'should be able to change language and still show menu items',
        (WidgetTester tester) async {
      // Build the widget
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: DynamicLanguageSelector(),
            ),
          ),
        ),
      );

      // Wait for initial loading
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Find and tap the language icon to open the dropdown
      final languageIcon = find.byIcon(Icons.language);
      expect(languageIcon, findsOneWidget);

      await tester.tap(languageIcon);
      await tester.pumpAndSettle();

      // Check if we can find language text options (native names)
      final englishText = find.text('English');
      final japaneseText = find.text('日本語');
      final koreanText = find.text('한국어');
      
      // At least one language option should be visible
      final hasLanguageOptions = englishText.evaluate().isNotEmpty || 
                                japaneseText.evaluate().isNotEmpty ||
                                koreanText.evaluate().isNotEmpty;
      
      expect(hasLanguageOptions, true, 
           reason: 'At least one language option should be visible');

      // If Japanese option is available, test language change
      if (japaneseText.evaluate().isNotEmpty) {
        await tester.tap(japaneseText);
        await tester.pumpAndSettle();

        // Wait a bit for the language change to complete
        await tester.pump(const Duration(milliseconds: 500));

        // Now try to open the language selector again
        await tester.tap(languageIcon);
        await tester.pumpAndSettle();

        // Check if the menu items are still displayed after language change
        // This is where the bug should occur - check for any language text
        final hasOptionsAfterChange = find.text('English').evaluate().isNotEmpty || 
                                    find.text('日本語').evaluate().isNotEmpty ||
                                    find.text('한국어').evaluate().isNotEmpty ||
                                    find.text('中文').evaluate().isNotEmpty;
                                    
        expect(hasOptionsAfterChange, true,
            reason: 'Language menu items should still be available after changing language');
      }
    });

    testWidgets('should handle multiple language changes gracefully',
        (WidgetTester tester) async {
      // Build the widget
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: DynamicLanguageSelector(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle(const Duration(seconds: 2));

      final languageIcon = find.byIcon(Icons.language);

      // Perform multiple language changes
      for (int i = 0; i < 3; i++) {
        await tester.tap(languageIcon);
        await tester.pumpAndSettle();

        // Look for any available language option and tap it
        final allLanguageTexts = [
          find.text('English'),
          find.text('日本語'),
          find.text('한국어'),
          find.text('中文'),
        ];
        
        for (final textFinder in allLanguageTexts) {
          if (textFinder.evaluate().isNotEmpty) {
            await tester.tap(textFinder, warnIfMissed: false);
            await tester.pumpAndSettle();
            break;
          }
        }

        // Small delay between changes
        await tester.pump(const Duration(milliseconds: 200));
      }

      // After rapid changes, verify the menu still works
      await tester.tap(languageIcon);
      await tester.pumpAndSettle();

      // Check if any language options are still available
      final hasOptionsAfterRapidChanges = find.text('English').evaluate().isNotEmpty || 
                                        find.text('日本語').evaluate().isNotEmpty ||
                                        find.text('한국어').evaluate().isNotEmpty ||
                                        find.text('中文').evaluate().isNotEmpty;
                                        
      expect(hasOptionsAfterRapidChanges, true,
          reason: 'Language menu should still work after multiple rapid changes');
    });

    testWidgets('should maintain language cache consistency',
        (WidgetTester tester) async {
      // Test that the supported languages cache doesn't get corrupted
      final languages1 = await DynamicLocalizationService.getSupportedLanguages();
      expect(languages1.isNotEmpty, true);

      // Simulate a language change
      await DynamicLocalizationService.saveLanguage('ja');

      final languages2 = await DynamicLocalizationService.getSupportedLanguages();
      expect(languages2.length, equals(languages1.length),
          reason: 'Supported languages should remain consistent after language change');
      
      // Change to another language
      await DynamicLocalizationService.saveLanguage('ko');

      final languages3 = await DynamicLocalizationService.getSupportedLanguages();
      expect(languages3.length, equals(languages1.length),
          reason: 'Supported languages should remain consistent after multiple language changes');
    });
  });
}