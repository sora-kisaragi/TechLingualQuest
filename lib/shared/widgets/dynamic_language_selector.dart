import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/dynamic_localization_service.dart';

/// Dynamic language selector widget that works with JSON-based translations
///
/// This widget automatically adapts to all languages defined in the JSON file
/// without requiring code changes for new language additions
class DynamicLanguageSelector extends ConsumerWidget {
  const DynamicLanguageSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(dynamicLanguageProvider);
    final translationsAsync = ref.watch(appTranslationsProvider);

    return translationsAsync.when(
      data: (translations) {
        return FutureBuilder<List<LanguageInfo>>(
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
                        FutureBuilder<String>(
                          future: _getLanguageDisplayName(
                            language,
                            translations,
                          ),
                          builder: (context, nameSnapshot) {
                            return Text(
                              nameSnapshot.data ?? language.nativeName,
                            );
                          },
                        ),
                      ],
                    ),
                  );
                }).toList();
              },
            );
          },
        );
      },
      loading: () => const Icon(Icons.language),
      error: (error, stack) => const Icon(Icons.language),
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
}
