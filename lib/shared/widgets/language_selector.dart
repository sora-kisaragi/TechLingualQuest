import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/language_service.dart';
import '../../generated/l10n/app_localizations.dart';

/// Language selector widget for switching between supported languages
/// 
/// Displays a dropdown or popup menu to allow users to select their preferred language
class LanguageSelector extends ConsumerWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(languageProvider);
    final l10n = AppLocalizations.of(context)!;

    return PopupMenuButton<String>(
      icon: const Icon(Icons.language),
      tooltip: l10n.language,
      onSelected: (String languageCode) {
        ref.read(languageProvider.notifier).changeLanguage(languageCode);
      },
      itemBuilder: (BuildContext context) {
        return [
          PopupMenuItem<String>(
            value: 'en',
            child: Row(
              children: [
                if (currentLocale.languageCode == 'en')
                  const Icon(Icons.check, size: 16),
                if (currentLocale.languageCode == 'en')
                  const SizedBox(width: 8),
                Text(l10n.english),
              ],
            ),
          ),
          PopupMenuItem<String>(
            value: 'ja',
            child: Row(
              children: [
                if (currentLocale.languageCode == 'ja')
                  const Icon(Icons.check, size: 16),
                if (currentLocale.languageCode == 'ja')
                  const SizedBox(width: 8),
                Text(l10n.japanese),
              ],
            ),
          ),
        ];
      },
    );
  }
}