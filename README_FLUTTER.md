# Flutter 環境セットアップ

このドキュメントでは、TechLingual Quest のFlutter開発環境のセットアップ手順を説明します。

## 前提条件

始める前に、以下がインストールされていることを確認してください：

1. **Flutter SDK**（3.35.x以降）
   ```bash
   # Flutter SDK のダウンロード
   git clone https://github.com/flutter/flutter.git -b stable
   export PATH="$PATH:`pwd`/flutter/bin"

   # または snap を使用（Ubuntu/Linux）
   sudo snap install flutter --classic

   # または homebrew を使用（macOS）
   brew install --cask flutter
   ```

2. **IDE セットアップ**
   - VS Code と Flutter、Dart 拡張機能
   - Android Studio と Flutter プラグイン
   - IntelliJ IDEA と Flutter プラグイン

## プロジェクト構造

プロジェクトは以下の構造でセットアップされています：

```
TechLingualQuest/
├── lib/
│   └── main.dart           # メインアプリケーションエントリーポイント
├── test/
│   └── widget_test.dart    # ウィジェットテスト
├── android/                # Android プラットフォーム固有ファイル
├── ios/                    # iOS プラットフォーム固有ファイル
├── web/                    # Web プラットフォーム固有ファイル
├── pubspec.yaml           # プロジェクトの依存関係とメタデータ
├── analysis_options.yaml  # Dart アナライザー設定
└── README_FLUTTER.md      # このファイル
```

## はじめに

1. **Flutter インストールの確認**
   ```bash
   flutter doctor
   ```

2. **依存関係のインストール**
   ```bash
   flutter pub get
   ```

3. **アプリの実行**
   ```bash
   # Web
   flutter run -d chrome

   # Android（接続されたデバイス/エミュレーターで）
   flutter run -d android

   # iOS（macOS のみ、シミュレーター/デバイスで）
   flutter run -d ios
   ```

4. **テストの実行**
   ```bash
   flutter test
   ```

5. **プロダクション用ビルド**
   ```bash
   # Web
   flutter build web

   # Android APK
   flutter build apk

   # Android App Bundle
   flutter build appbundle

   # iOS（macOS のみ）
   flutter build ios
   ```

## 開発ガイドライン

### コードスタイル
- Dart スタイルガイドに従う
- `flutter format` を使用してコードをフォーマット
- `flutter analyze` を実行して問題をチェック
- すべてのコメントは英語で記述し、必要に応じて日本語で補足説明

### ウィジェットガイドライン
- 可能な限り StatelessWidget を使用
- build メソッドを簡潔に保つ
- 小さく再利用可能なウィジェットを使用
- UI とビジネスロジックを分離

### テスト
- UI コンポーネントにはウィジェットテストを記述
- ビジネスロジックにはユニットテストを記述
- 良好なテストカバレッジを維持

## 利用可能な機能

現在のアプリには以下が含まれています：
- ✅ 基本的な Flutter プロジェクト構造
- ✅ Material Design 3 テーマ
- ✅ XP トラッキングシステム（基本機能）
- ✅ 進捗バー可視化
- ✅ マルチプラットフォーム対応（Android、iOS、Web）
- ✅ ウィジェットテスト

### 予定されている機能
- [ ] ユーザー認証
- [ ] 語彙管理
- [ ] クエストシステム
- [ ] データベース連携（Firebase/Supabase）
- [ ] 要約とクイズのAI統合

## トラブルシューティング

### よくある問題

1. **Flutter が認識されない**
   - Flutter が PATH に含まれていることを確認
   - `flutter doctor` を実行してインストールを確認

2. **依存関係が見つからない**
   - `flutter pub get` を実行して依存関係をインストール
   - `pubspec.yaml` で正しい依存関係バージョンを確認

3. **ビルドエラー**
   - プロジェクトをクリーンアップ: `flutter clean`
   - 依存関係を再インストール: `flutter pub get`
   - プラットフォーム固有のセットアップ（Android SDK、Xcode等）を確認

## 次のステップ

1. 優先IDEにFlutter拡張機能をセットアップ
2. テスト用のデバイス/エミュレーターを設定
3. `flutter pub get` を実行して依存関係をインストール
4. `flutter run` でアプリを開始
5. 予定されている機能の実装を開始

詳細については、[公式Flutter ドキュメント](https://docs.flutter.dev/)を参照してください。
