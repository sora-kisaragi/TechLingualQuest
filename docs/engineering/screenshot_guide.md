# スクリーンショット撮影ガイド / Screenshot Guide

## 概要 / Overview

このドキュメントでは、CI環境でのスクリーンショット撮影時によく発生する問題と、その解決策について説明します。

This document explains common issues when taking screenshots in CI environments and their solutions.

## よく発生する問題 / Common Issues

### 1. フォント読み込み失敗 / Font Loading Failures

**問題**: CI環境では外部フォント（Google Fonts等）がブロックされ、グレー画面のみ表示される
**Problem**: External fonts (like Google Fonts) are blocked in CI, resulting in gray screen only

**解決策 / Solutions**:
- Flutter Webアプリケーションをローカルフォントで構築する
- Build Flutter web applications with local fonts
- `flutter build web --dart-define=FLUTTER_WEB_USE_SKIA=false` を使用してHTMLレンダラーを強制する
- Use HTML renderer with `flutter build web --dart-define=FLUTTER_WEB_USE_SKIA=false`

### 2. CanvasKit読み込み失敗 / CanvasKit Loading Failures

**問題**: 外部CDNからのCanvasKit読み込みが失敗する
**Problem**: CanvasKit loading from external CDN fails

**解決策 / Solutions**:
- HTMLレンダラーを使用する
- Use HTML renderer instead
- ローカルCanvasKitを使用する設定を行う
- Configure to use local CanvasKit

## スクリーンショット撮影のベストプラクティス / Screenshot Best Practices

### 1. 複数の状態を撮影 / Capture Multiple States

認証機能の場合、以下の状態を撮影する:
For authentication features, capture these states:

- **未認証状態**: ログインボタンが表示されている状態
- **Unauthenticated state**: Shows login button
- **認証済み状態**: プロファイルボタンとログアウトボタンが表示されている状態
- **Authenticated state**: Shows profile button and logout button
- **プロファイルページ**: ユーザー情報とアカウント管理機能が表示されている状態
- **Profile page**: Shows user information and account management

### 2. 機能デモンストレーション / Feature Demonstration

- 実装した機能が明確に見えるようにする
- Make implemented features clearly visible
- UIの変化を強調する（ボタンの変化、新しい画面等）
- Highlight UI changes (button changes, new screens, etc.)
- 適切なテストデータを使用する
- Use appropriate test data

### 3. モックアップの活用 / Using Mockups

CI環境で実際のアプリが動作しない場合は、HTMLモックアップを作成して機能を説明する:
When the actual app doesn't work in CI, create HTML mockups to explain functionality:

```html
<!DOCTYPE html>
<html>
<head>
    <style>
        .phone-frame { 
            width: 375px; 
            height: 667px; 
            background: white;
            margin: 20px auto;
            border-radius: 20px;
            box-shadow: 0 8px 24px rgba(0,0,0,0.15);
            overflow: hidden;
        }
        /* Add styles that match your app's design */
    </style>
</head>
<body>
    <!-- Create mockup that demonstrates the functionality -->
</body>
</html>
```

### 4. 文書化 / Documentation

スクリーンショットには以下を含める:
Include the following with screenshots:

- **説明キャプション**: 何が表示されているかの説明
- **Descriptive captions**: Explain what is shown
- **実装詳細**: 関連するコード変更の説明
- **Implementation details**: Explain related code changes
- **使用方法**: ユーザーがどのように機能を使用するかの説明
- **Usage instructions**: How users interact with the feature

## CI環境での対処法 / CI Environment Workarounds

### Flutter Webビルド設定 / Flutter Web Build Configuration

```bash
# HTMLレンダラーを使用（フォント問題を回避）
# Use HTML renderer (avoids font issues)
flutter build web --dart-define=FLUTTER_WEB_USE_SKIA=false

# 外部リソースをローカルに含める設定
# Configure to include external resources locally
flutter build web --dart-define=FLUTTER_WEB_CANVASKIT_URL=https://unpkg.com/canvaskit-wasm@0.37.2/bin/
```

### Playwright設定 / Playwright Configuration

```javascript
// ブラウザ設定で外部リソースブロックを回避
// Configure browser to avoid external resource blocking
const browser = await chromium.launch({
  args: ['--disable-web-security', '--allow-running-insecure-content']
});
```

## トラブルシューティング / Troubleshooting

### グレー画面のみ表示される場合 / When Only Gray Screen is Displayed

1. ブラウザのデベロッパーコンソールでエラーを確認
   Check browser developer console for errors

2. フォント読み込みエラーがないか確認
   Check for font loading errors

3. CanvasKit読み込みエラーがないか確認
   Check for CanvasKit loading errors

4. HTMLモックアップを作成して機能を説明
   Create HTML mockups to explain functionality

### 対応例 / Example Solution

このプロジェクトでは、認証機能のスクリーンショットでグレー画面問題が発生した際に:
In this project, when gray screen issue occurred with authentication screenshots:

1. 問題を特定：外部フォントとCanvasKitの読み込み失敗
   Identified issue: External font and CanvasKit loading failures

2. HTMLモックアップを作成：実際のUIデザインを再現
   Created HTML mockups: Reproduced actual UI design

3. 複数状態のスクリーンショットを撮影：未認証、認証済み、プロファイルページ
   Captured multiple state screenshots: unauthenticated, authenticated, profile page

4. 詳細な説明を追加：各スクリーンショットの機能説明
   Added detailed explanations: Feature descriptions for each screenshot

## 結論 / Conclusion

CI環境でのスクリーンショット撮影は技術的制約があるため、複数のアプローチを組み合わせることが重要です。実際のアプリが動作しない場合も、モックアップと詳細な説明により機能を効果的に伝えることができます。

Screenshot capturing in CI environments has technical constraints, so it's important to combine multiple approaches. Even when the actual app doesn't work, functionality can be effectively communicated through mockups and detailed explanations.