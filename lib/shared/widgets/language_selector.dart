import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/language_service.dart';
import '../../generated/l10n/app_localizations.dart';

/// Language selector widget for switching between supported languages
///
/// Displays a dropdown or popup menu to allow users to select their preferred language
/// Automatically adapts to support any number of languages defined in LanguageService
class LanguageSelector extends ConsumerWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(languageProvider);
    final l10n = AppLocalizations.of(context)!;
    final supportedLanguages = LanguageService.getSupportedLanguages();

    return PopupMenuButton<String>(
      icon: const Icon(Icons.language),
      tooltip: l10n.language,
      onSelected: (String languageCode) async {
        final success = await ref
            .read(languageProvider.notifier)
            .changeLanguage(languageCode);
        if (!success && context.mounted) {
          // Show error if language change failed (though this shouldn't happen with valid codes)
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to change language to $languageCode'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
      itemBuilder: (BuildContext context) {
        return supportedLanguages.map((language) {
          final isSelected = currentLocale.languageCode == language.code;

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
                Text(_getLanguageDisplayName(language, l10n)),
              ],
            ),
          );
        }).toList();
      },
    );
  }

  /// Get the display name for a language based on current localization
  ///
  /// Uses localized names when available, falls back to native names
  String _getLanguageDisplayName(
    SupportedLanguage language,
    AppLocalizations l10n,
  ) {
    switch (language.code) {
      case 'en':
        return l10n.english;
      case 'ja':
        return l10n.japanese;
      default:
        // For future languages without localized names yet, show native name
        return language.nativeName;
    }
  }
}
