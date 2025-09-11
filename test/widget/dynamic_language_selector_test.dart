import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../lib/shared/widgets/dynamic_language_selector.dart';
import '../../lib/shared/services/dynamic_localization_service.dart';

/// Test to reproduce the language selector issue
/// 
/// Issue: After changing language from English to Japanese, 
/// tapping the language button shows animation but no list appears
void main() {
  group('DynamicLanguageSelector Issue Tests', () {
    setUp(() async {
      // Mock SharedPreferences for testing
      SharedPreferences.setMockInitialValues({});
      
      // Reset the static cache to ensure clean state
      await DynamicLocalizationService.reloadTranslations();
    });

    testWidgets('Language selector should show menu after language change', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              appBar: AppBar(
                actions: const [DynamicLanguageSelector()],
              ),
              body: const Center(child: Text('Test')),
            ),
          ),
        ),
      );

      // Wait for initial load
      await tester.pumpAndSettle();

      // Find the language button
      final languageButton = find.byIcon(Icons.language);
      expect(languageButton, findsOneWidget);

      // Tap the language button to open menu
      await tester.tap(languageButton);
      await tester.pumpAndSettle();

      // Verify menu appears with language options
      expect(find.text('English'), findsAny,
          reason: 'English should appear in language menu');
      expect(find.text('Japanese'), findsAny,
          reason: 'Japanese should appear in language menu');

      // Select Japanese
      await tester.tap(find.text('Japanese'));
      await tester.pumpAndSettle();

      // Now try to open the language selector again
      // This should reproduce the issue where menu doesn't appear
      await tester.tap(languageButton);
      await tester.pumpAndSettle();

      // This should still show language options but might fail due to the bug
      expect(
        find.text('English'), 
        findsWidgets,
        reason: 'Language menu should still appear after changing language',
      );
      expect(
        find.text('Japanese'), 
        findsWidgets,
        reason: 'Language menu should still appear after changing language',
      );
    });

    testWidgets('Multiple language changes should work consistently', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              appBar: AppBar(
                actions: const [DynamicLanguageSelector()],
              ),
              body: const Center(child: Text('Test')),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final languageButton = find.byIcon(Icons.language);

      // Test sequence: English -> Japanese -> Korean -> English
      final languageSequence = ['Japanese', 'Korean', 'English'];
      
      for (final language in languageSequence) {
        // Open language menu
        await tester.tap(languageButton);
        await tester.pumpAndSettle();

        // Should show all language options
        expect(
          find.text('English'),
          findsWidgets,
          reason: 'English should always be available in menu',
        );
        expect(
          find.text('Japanese'),
          findsWidgets, 
          reason: 'Japanese should always be available in menu',
        );

        // Select the target language
        await tester.tap(find.text(language));
        await tester.pumpAndSettle();
      }
    });

    test('DynamicLocalizationService cache invalidation test', () async {
      // Test that cache is properly managed during language changes
      
      // First load should populate cache
      final languages1 = await DynamicLocalizationService.getSupportedLanguages();
      expect(languages1.isNotEmpty, true);

      // Change language  
      await DynamicLocalizationService.saveLanguage('ja');
      
      // Get supported languages again - should still work
      final languages2 = await DynamicLocalizationService.getSupportedLanguages();
      expect(languages2.length, equals(languages1.length));
      
      // Translations should work for both languages
      final enText = await DynamicLocalizationService.translate('Language', 'en');
      final jaText = await DynamicLocalizationService.translate('Language', 'ja');
      
      expect(enText, equals('Language'));
      expect(jaText, equals('言語'));
    });
  });
}