import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/dynamic_localization_service.dart';

/// Dynamic language selector widget that works with JSON-based translations
/// JSON ベースの翻訳に対応する動的言語選択ウィジェット
///
/// This widget automatically adapts to all languages defined in the JSON file
/// without requiring code changes for new language additions
/// このウィジェットは JSON ファイルで定義されたすべての言語に自動的に適応し、
/// 新しい言語追加時にコード変更を必要としません
class DynamicLanguageSelector extends ConsumerWidget {
  const DynamicLanguageSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(dynamicLanguageProvider);

    return FutureBuilder<List<LanguageInfo>>(
      key: ValueKey(currentLocale.languageCode), // Force rebuild when language changes
      future: DynamicLocalizationService.getSupportedLanguages(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Icon(Icons.language);
        }

        final supportedLanguages = snapshot.data!;

        return PopupMenuButton<String>(
          icon: const Icon(Icons.language),
          tooltip: 'Language', // Will be replaced with dynamic translation
          onSelected: (String languageCode) async {
            final success = await ref
                .read(dynamicLanguageProvider.notifier)
                .changeLanguage(languageCode);

            if (!success && context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Failed to change language to $languageCode',
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          },
          itemBuilder: (BuildContext context) {
            return supportedLanguages.map((language) {
              final isSelected =
                  currentLocale.languageCode == language.code;

              return PopupMenuItem<String>(
                value: language.code,
                child: Row(
                  children: [
                    if (isSelected) ...[
                      const Icon(Icons.check, size: 16),
                      const SizedBox(width: 8),
                    ],
                    if (!isSelected)
                      const SizedBox(width: 24), // Space for alignment
                    Text(
                      _getLanguageDisplayNameSimple(language, currentLocale),
                    ),
                  ],
                ),
              );
            }).toList();
          },
        );
      },
    );
  }

  /// Get the display name for a language using dynamic translations
  Future<String> _getLanguageDisplayName(
    LanguageInfo language,
    AppTranslations translations,
  ) async {
    switch (language.code) {
      case 'en':
        return await translations.english;
      case 'ja':
        return await translations.japanese;
      case 'ko':
        return await translations.korean;
      case 'zh':
        return await translations.chinese;
      default:
        // For any future languages, show native name
        return language.nativeName;
    }
  }

  /// Get the display name for a language using synchronous translations
  String _getLanguageDisplayNameSync(
    LanguageInfo language,
    AppTranslations translations,
  ) {
    switch (language.code) {
      case 'en':
        return translations.getSync('English', fallback: language.nativeName);
      case 'ja':
        return translations.getSync('Japanese', fallback: language.nativeName);
      case 'ko':
        return translations.getSync('Korean', fallback: language.nativeName);
      case 'zh':
        return translations.getSync('Chinese', fallback: language.nativeName);
      default:
        // For any future languages, show native name
        return language.nativeName;
    }
  }

  /// Get the display name for a language without async translations
  /// This provides a more reliable approach that avoids the async provider issues
  String _getLanguageDisplayNameSimple(
    LanguageInfo language,
    Locale currentLocale,
  ) {
    // For now, always show language names in English to avoid the translation loading issues
    // This ensures the menu always works regardless of async state
    switch (language.code) {
      case 'en':
        return 'English';
      case 'ja':
        return 'Japanese';
      case 'ko':
        return 'Korean';
      case 'zh':
        return 'Chinese';
      default:
        return language.nativeName;
    }
  }
}
