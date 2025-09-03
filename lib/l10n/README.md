# Localization (l10n) Guide

This guide explains how to manage and extend the localization system in TechLingual Quest.

## Current Supported Languages

- **English (en)** - Default language
- **Japanese (ja)** - Complete translation with app title kept in English

## Adding a New Language

To add support for a new language, follow these steps:

### 1. Create ARB File

Create a new ARB file in this directory following the naming pattern `app_[language_code].arb`:

```bash
# Example for Korean
cp app_en.arb app_ko.arb
```

Edit the new file to include:
- Correct `@@locale` value
- Translated strings for all keys
- Keep `appTitle` as "TechLingual Quest" (app's unique name)

### 2. Update Language Service

In `lib/shared/services/language_service.dart`, add the new language to the `_supportedLanguages` list:

```dart
static const List<SupportedLanguage> _supportedLanguages = [
  // ... existing languages
  SupportedLanguage(
    code: 'ko',
    nativeName: '한국어',
    englishName: 'Korean',
    locale: Locale('ko'),
  ),
];
```

### 3. Add Localized Language Names

In both `app_en.arb` and `app_ja.arb` (and other existing language files), add entries for the new language:

```json
{
  "korean": "Korean",
  "@korean": {
    "description": "Korean language option"
  }
}
```

### 4. Update Language Selector

In `lib/shared/widgets/language_selector.dart`, add a case for the new language in the `_getLanguageDisplayName` method:

```dart
String _getLanguageDisplayName(SupportedLanguage language, AppLocalizations l10n) {
  switch (language.code) {
    case 'en':
      return l10n.english;
    case 'ja':
      return l10n.japanese;
    case 'ko':
      return l10n.korean;  // Add this
    default:
      return language.nativeName;
  }
}
```

### 5. Generate Localization Files

Run the Flutter localization generation command:

```bash
flutter gen-l10n
```

This will create `app_localizations_[language_code].dart` files in `lib/generated/l10n/`.

### 6. Test the Implementation

Add test cases in `test/localization_test.dart` to verify the new language works correctly.

## Key Principles

1. **App Name Consistency**: Always keep "TechLingual Quest" in English across all languages as it's the app's unique identifier.

2. **Extensible Design**: The language system is designed to easily accommodate new languages without breaking existing functionality.

3. **Fallback Behavior**: The system gracefully falls back to English if an unsupported or corrupted language preference is encountered.

4. **Native Names**: Use native script/characters for language names in the language selector when possible (e.g., 日本語 for Japanese, 한국어 for Korean).

## File Structure

```
lib/l10n/
├── README.md              # This file
├── app_en.arb            # English translations (template)
├── app_ja.arb            # Japanese translations
└── app_[code].arb        # Additional language files

lib/generated/l10n/
├── app_localizations.dart              # Main localization class
├── app_localizations_en.dart           # English implementation
├── app_localizations_ja.dart           # Japanese implementation
└── app_localizations_[code].dart       # Generated language implementations

lib/shared/services/
└── language_service.dart               # Language management service

lib/shared/widgets/
└── language_selector.dart              # Language selection UI widget
```

## Configuration Files

- `l10n.yaml` - Flutter localization configuration
- `pubspec.yaml` - Dependencies for `flutter_localizations`

## Best Practices

1. Always test language switching functionality after adding new languages
2. Ensure proper text direction (LTR/RTL) support if adding RTL languages
3. Consider cultural and regional differences in translations
4. Use appropriate formal/informal language levels for the target audience
5. Test UI layout with different text lengths as some languages may be more verbose
