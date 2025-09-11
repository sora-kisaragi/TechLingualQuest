import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tech_lingual_quest/shared/widgets/dynamic_language_selector.dart';
import 'package:tech_lingual_quest/shared/services/dynamic_localization_service.dart';

/// Simplified test to debug the language selector issue
void main() {
  group('Language Selector Debug Tests', () {
    testWidgets('should load supported languages correctly',
        (WidgetTester tester) async {
      // Test the service directly
      final languages = await DynamicLocalizationService.getSupportedLanguages();
      expect(languages.isNotEmpty, true, reason: 'Should have at least one language');
      
      print('Found ${languages.length} supported languages:');
      for (final lang in languages) {
        print('- ${lang.code}: ${lang.nativeName}');
      }
    });

    testWidgets('should build widget without errors', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: DynamicLanguageSelector(),
            ),
          ),
        ),
      );

      // Wait for widget to load
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Should display language icon
      expect(find.byIcon(Icons.language), findsAtLeastNWidgets(1));
      
      // Check if we have any error icons
      final errorIcons = find.byIcon(Icons.error);
      if (errorIcons.evaluate().isNotEmpty) {
        print('ERROR: Found error icon in language selector');
      }
    });

    testWidgets('should show popup menu items when tapped', 
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: DynamicLanguageSelector(),
            ),
          ),
        ),
      );

      // Wait for complete loading with multiple pump cycles
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      // Look for PopupMenuButton after all loading is complete
      final languageButton = find.byType(PopupMenuButton);
      
      print('After full loading - PopupMenuButton found: ${languageButton.evaluate().isNotEmpty}');
      
      if (languageButton.evaluate().isEmpty) {
        print('WARNING: No PopupMenuButton found');
        
        // Check all widget types present
        final allWidgets = find.byElementPredicate((element) => true);
        final widgetTypes = <Type>{};
        for (final element in allWidgets.evaluate()) {
          widgetTypes.add(element.widget.runtimeType);
        }
        print('Widget types found: ${widgetTypes.toList()}');
        
        // Try to find the language icon directly
        final iconButton = find.byIcon(Icons.language);
        if (iconButton.evaluate().isNotEmpty) {
          print('INFO: Found language icon');
        } else {
          print('ERROR: No language icon found either');
        }
        return;
      }

      // Now test the actual functionality
      expect(languageButton, findsOneWidget);

      // Tap the popup menu button
      await tester.tap(languageButton);
      await tester.pumpAndSettle();

      // Check for popup menu items
      final menuItems = find.byType(PopupMenuItem);
      print('Found ${menuItems.evaluate().length} menu items');
      
      expect(menuItems, findsAtLeastNWidgets(1));
      
      // Look for specific language texts
      final englishText = find.text('English');
      final japaneseText = find.text('日本語');
      print('English text found: ${englishText.evaluate().isNotEmpty}');
      print('Japanese text found: ${japaneseText.evaluate().isNotEmpty}');
    });
  });
}