---
author: "GitHub Copilot"
date: "2025-09-04"
version: "1.0"
---

# 日本語 UI ローカライズ実装

## 概要

本書は、TechLingual Quest の UI を日本語化する実装内容をまとめたものです。英語のみの UI に抵抗がある初学者でも使いやすくすることを目的とします。

## 実装詳細

### 1. ローカライズ基盤

- 依存関係の追加: `flutter_localizations`, `shared_preferences`, `intl`（`pubspec.yaml`）
- l10n 設定: Flutter の自動生成に対応する `l10n.yaml`
- 言語サービス: 言語選好を管理する `LanguageService`
- 状態管理: Riverpod によるリアクティブな言語切替

### 2. 対応言語

- 英語（en）: 既定
- 日本語（ja）: 本実装の主対象

### 3. ファイル構成

```
lib/
├── l10n/
│   ├── app_en.arb          # 英語の翻訳
│   └── app_ja.arb          # 日本語の翻訳
├── generated/l10n/
│   ├── app_localizations.dart      # 自動生成されたローカライズ delegate
│   ├── app_localizations_en.dart   # 英語実装
│   └── app_localizations_ja.dart   # 日本語実装
├── shared/
│   ├── services/
│   │   └── language_service.dart   # 言語設定の永続化
│   └── widgets/
│       └── language_selector.dart  # 言語選択 UI コンポーネント
```

### 4. 主な機能

- 言語切替: AppBar のセレクタから英語/日本語を切替
- 永続化: SharedPreferences に選好を保存
- リアクティブ更新: 言語変更時に UI 文言を即時更新
- 網羅性: ユーザー向け文言を全てローカライズ

### 5. ローカライズ対象

ホーム画面:
- アプリ名: "TechLingual Quest" / "テックリンガルクエスト"
- ウェルカム文: 例「TechLingual Quest へようこそ！」
- 機能一覧の説明、ナビゲーション（Vocabulary/Quests/Profile）

各機能ページ:
- Vocabulary/Quests/Auth などのタイトル・説明

UI コンポーネント:
- 言語セレクタ（表示名・ツールチップ）
- XP ラベルとツールチップ
- 各種ボタンとラベル

### 6. 技術実装

LanguageService（抜粋）:
```dart
class LanguageService {
  // 言語設定の永続化とロケール変換の管理
  static Future<String> getSavedLanguage();
  static Future<void> saveLanguage(String languageCode);
  static Locale getLocaleFromCode(String languageCode);
  static List<Locale> getSupportedLocales();
}
```

状態管理（抜粋）:
```dart
final languageProvider = StateNotifierProvider<LanguageNotifier, Locale>((ref) {
  return LanguageNotifier();
});
```

アプリ設定:
- `locale`: 言語プロバイダから取得
- `localizationsDelegates`: Flutter 提供の delegate を設定
- `supportedLocales`: 英語/日本語

### 7. 使い方

1. AppBar の地球アイコン（🌐）から言語メニューを開く
2. 言語を選択すると、UI が即時に切り替わる
3. 選択は次回起動時も維持される

### 8. 開発者向けメモ

- ARB: 翻訳は `.arb` ファイルで管理
- コード生成: `gen-l10n` により型安全なクラスを生成
- 拡張性: 新言語追加時は以下を実施
  1. 例: 韓国語なら `app_ko.arb` を作成
  2. `LanguageService.getSupportedLocales()` にロケールを追加
  3. `LanguageService.getLocaleFromCode()` に分岐を追加
  4. `LanguageSelector` にメニュー項目を追加

### 9. 品質保証

- 用語統一: 技術用語はプロダクト内で統一
- 文化適合: 日本語として自然で丁寧な表現
- 一貫性: 同種 UI で同一用語を使用
- テスト: 全画面での切替動作を確認

### 10. 今後の拡張

- 多言語（韓国語・中国語など）の追加
- 言語に応じた動的フォントサイズ
- 右から左（RTL）言語対応
- 地域別ロケール（ja-JP, en-US など）の検討

## 動作確認手順

1. 既定の英語で起動
2. AppBar の言語セレクタを開く
3. 「日本語」を選択
4. 全文言が日本語化されることを確認
5. 画面遷移して一貫性を確認
6. 再起動して選好が保持されることを確認
