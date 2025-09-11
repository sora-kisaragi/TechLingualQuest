import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/dynamic_localization_service.dart';

/// Dynamic language selector widget that works with JSON-based translations
///
/// This widget automatically adapts to all languages defined in the JSON file
/// without requiring code changes for new language additions
class DynamicLanguageSelector extends ConsumerStatefulWidget {
  const DynamicLanguageSelector({super.key});

  @override
  ConsumerState<DynamicLanguageSelector> createState() =>
      _DynamicLanguageSelectorState();
}

class _DynamicLanguageSelectorState
    extends ConsumerState<DynamicLanguageSelector> {
  List<LanguageInfo>? _supportedLanguages;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSupportedLanguages();
  }

  Future<void> _loadSupportedLanguages() async {
    try {
      final languages = await DynamicLocalizationService.getSupportedLanguages();
      if (mounted) {
        setState(() {
          _supportedLanguages = languages;
          _isLoading = false;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _supportedLanguages = null;
          _isLoading = false;
          _error = e.toString();
        });
      }
    }
  }

  Future<void> _reloadLanguages() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    await _loadSupportedLanguages();
  }

  @override
  Widget build(BuildContext context) {
    final currentLocale = ref.watch(dynamicLanguageProvider);
    final translationsAsync = ref.watch(appTranslationsProvider);

    // If languages failed to load, show a reload button
    if (_error != null) {
      return IconButton(
        icon: const Icon(Icons.error),
        tooltip: 'Error loading languages. Tap to retry.',
        onPressed: _reloadLanguages,
      );
    }

    // If still loading, show loading icon
    if (_isLoading || _supportedLanguages == null) {
      return const Icon(Icons.language);
    }

    // Create PopupMenuButton regardless of translations state
    return PopupMenuButton<String>(
      icon: const Icon(Icons.language),
      tooltip: 'Language', // Will be replaced with dynamic translation when available
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
        } else {
          // Reload the supported languages after a successful change
          // This helps ensure consistency
          _reloadLanguages();
        }
      },
      itemBuilder: (BuildContext context) {
        if (_supportedLanguages == null || _supportedLanguages!.isEmpty) {
          return [];
        }

        return _supportedLanguages!.map((language) {
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
                // Use native name if translations aren't available
                Text(
                  translationsAsync.when(
                    data: (translations) => _getLanguageDisplayNameSync(language, translations),
                    loading: () => language.nativeName,
                    error: (error, stack) => language.nativeName,
                  ),
                ),
              ],
            ),
          );
        }).toList();
      },
    );
  }

  /// Get the display name for a language using dynamic translations (synchronous)
  String _getLanguageDisplayNameSync(
    LanguageInfo language,
    AppTranslations translations,
  ) {
    try {
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
    } catch (e) {
      // Fallback to native name if translation fails
      return language.nativeName;
    }
  }

  /// Get the display name for a language using dynamic translations (asynchronous)
  Future<String> _getLanguageDisplayName(
    LanguageInfo language,
    AppTranslations translations,
  ) async {
    try {
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
    } catch (e) {
      // Fallback to native name if translation fails
      return language.nativeName;
    }
  }
}
