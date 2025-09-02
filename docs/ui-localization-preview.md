# UI Localization Preview

## English Version (Default)
```
╔══════════════════════════════════════════════════════════╗
║ TechLingual Quest                            🌐 [EN] ▼ ║
╠══════════════════════════════════════════════════════════╣
║                         🎓                              ║
║                                                          ║
║                Welcome to TechLingual Quest!            ║
║                                                          ║
║           Your gamified journey to master                ║
║                 technical English                        ║
║                                                          ║
║    ┌─────────────────────────────────────────────────┐  ║
║    │  XP: 0                                          │  ║
║    │  ████████████████████████░░░░░░░░░░░░░░░░░░░░░  │  ║
║    └─────────────────────────────────────────────────┘  ║
║                                                          ║
║     [📖 Vocabulary]  [🏴 Quests]  [👤 Profile]          ║
║                                                          ║
║                     Features:                            ║
║              • Daily quests and challenges               ║
║         • Vocabulary building with spaced repetition    ║
║              • Technical article summaries              ║
║           • Progress tracking and achievements          ║
║           • AI-powered conversation practice            ║
║                                                          ║
║                                               [+ Earn XP] ║
╚══════════════════════════════════════════════════════════╝
```

## Japanese Version (言語切り替え後)
```
╔══════════════════════════════════════════════════════════╗
║ テックリンガルクエスト                       🌐 [JA] ▼ ║
╠══════════════════════════════════════════════════════════╣
║                         🎓                              ║
║                                                          ║
║              テックリンガルクエストへようこそ！         ║
║                                                          ║
║         技術英語をマスターするための                     ║
║           ゲーミフィケーション学習の旅                   ║
║                                                          ║
║    ┌─────────────────────────────────────────────────┐  ║
║    │  経験値: 0                                      │  ║
║    │  ████████████████████████░░░░░░░░░░░░░░░░░░░░░  │  ║
║    └─────────────────────────────────────────────────┘  ║
║                                                          ║
║       [📖 語彙]      [🏴 クエスト]   [👤 プロフィール]    ║
║                                                          ║
║                      機能:                               ║
║                • 日々のクエストとチャレンジ              ║
║                • 間隔反復による語彙力強化                ║
║                    • 技術記事要約                        ║
║                   • 進捗追跡と実績                       ║
║                  • AI搭載会話練習                        ║
║                                                          ║
║                                           [+ 経験値を獲得] ║
╚══════════════════════════════════════════════════════════╝
```

## Language Selector Dropdown
```
When user taps 🌐 icon:

┌──────────────┐
│ ✓ English    │  ← Currently selected (shown with checkmark)
│   日本語      │
└──────────────┘

After selecting Japanese:

┌──────────────┐
│   English    │
│ ✓ 日本語      │  ← Now selected
└──────────────┘
```

## Sub-pages Examples

### Vocabulary Page - English
```
╔══════════════════════════════════════════════════════════╗
║ ← Vocabulary                                             ║
╠══════════════════════════════════════════════════════════╣
║                         📖                              ║
║                                                          ║
║                  Vocabulary Learning                     ║
║                                                          ║
║     Vocabulary cards and learning features will be      ║
║              implemented here                            ║
║                                                          ║
╚══════════════════════════════════════════════════════════╝
```

### Vocabulary Page - Japanese
```
╔══════════════════════════════════════════════════════════╗
║ ← 語彙                                                   ║
╠══════════════════════════════════════════════════════════╣
║                         📖                              ║
║                                                          ║
║                      語彙学習                            ║
║                                                          ║
║              語彙カードと学習機能が                      ║
║               ここに実装される予定です                   ║
║                                                          ║
╚══════════════════════════════════════════════════════════╝
```

## Key Localization Features

### ✅ Implemented Features:
- **Language Toggle**: Tap 🌐 icon in app bar to switch languages
- **Persistent Settings**: Language choice saved and remembered
- **Comprehensive Coverage**: All UI text localized across all pages
- **Immediate Updates**: UI changes instantly when language is switched
- **Cultural Adaptation**: Japanese text uses appropriate formal language

### 🌐 Supported Languages:
- **English (en)**: Default language, suitable for international users
- **Japanese (ja)**: Primary target for beginners who struggle with English UI

### 🔧 Technical Implementation:
- Flutter's native l10n system with ARB files
- Riverpod state management for reactive language switching
- SharedPreferences for persistence
- Type-safe localization with generated classes

### 📱 User Experience:
1. App starts in English by default
2. User can tap language icon at any time
3. Language selection shows current choice with checkmark
4. All text updates immediately across the entire app
5. Language choice persists between app sessions
