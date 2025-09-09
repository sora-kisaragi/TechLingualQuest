---
author: "GitHub Copilot Agent"
date: "2025-01-09"
version: "1.0"
related_issues: ["#186"]
related_docs: ["DEVELOPMENT.md", "../requirements/requirements.md", "../../.github/instructions/coding/dart.instructions.md"]
---

# コードカバレッジガイド - TechLingual Quest

このドキュメントでは、プロジェクトにおけるコードカバレッジの要件と管理手順を説明します。

## 1. カバレッジ要件

### 1.1 必要なカバレッジレベル
- **全体プロジェクト**: 80%以上のコードカバレッジを維持
- **新規追加コード（パッチ）**: 85%以上のカバレッジ必須
- **継続的向上**: カバレッジの低下を防ぎ、品質を向上させる

### 1.2 対象範囲
以下のファイルはカバレッジ計算から除外されます：
- `lib/generated/**` - 自動生成ファイル
- `lib/**/*.g.dart` - build_runnerで生成されるファイル
- `lib/l10n/**` - ローカライゼーション自動生成ファイル
- `lib/main.dart` - エントリーポイント（UIテストで検証）
- `lib/**/constants/**` - 定数ファイル

## 2. ローカルでのカバレッジ確認手順

### 2.1 基本コマンド
```bash
# テスト実行とカバレッジ生成
flutter test --coverage

# カバレッジレポートの生成（HTML形式）
genhtml coverage/lcov.info -o coverage/html

# レポートの確認（ブラウザで開く）
open coverage/html/index.html  # macOS
xdg-open coverage/html/index.html  # Linux
start coverage/html/index.html  # Windows
```

### 2.2 カバレッジレポートの見方
1. **全体カバレッジ**: トップページで全体の割合を確認
2. **ファイル別**: 各ファイルのカバレッジを詳細確認
3. **未カバー箇所**: 赤色でハイライトされた行を確認
4. **関数別**: 関数単位でのカバレッジ状況を把握

### 2.3 特定ファイルのカバレッジ確認
```bash
# 特定のテストファイルのみ実行
flutter test test/specific_test.dart --coverage

# カバレッジの数値のみ確認
lcov --summary coverage/lcov.info
```

## 3. commit前の確認チェックリスト

- [ ] `flutter test --coverage` でテスト実行
- [ ] 全体カバレッジが80%以上であることを確認
- [ ] 新規追加・変更箇所が85%以上であることを確認
- [ ] 未カバー箇所に対してテストを追加（必要に応じて）
- [ ] カバレッジレポートをブラウザで確認

## 4. xDD開発手法の実践

### 4.1 TDD（Test-Driven Development）
1. **赤**: 失敗するテストを書く
2. **緑**: テストを通すための最小コードを書く
3. **リファクタ**: コードを改善する

```dart
// 例: 計算機能のTDD
test('should calculate sum correctly', () {
  // Arrange
  final calculator = Calculator();
  
  // Act
  final result = calculator.add(2, 3);
  
  // Assert
  expect(result, 5);
});
```

### 4.2 FDD（Feature-Driven Development）
1. 機能リストの作成
2. 機能ごとの設計
3. 機能ごとのテスト作成
4. 機能の実装

### 4.3 品質優先の考え方
- **動作するコード** < **テストされた動作するコード**
- テストカバレッジは品質の指標の一つ
- カバレッジが高いだけでなく、意味のあるテストを作成

## 5. CI/CDでの自動チェック

### 5.1 CodecovによるPRチェック
- PRごとに自動でカバレッジをチェック
- 基準を下回る場合はPRのマージをブロック
- カバレッジの変化をPRコメントで報告

### 5.2 GitHub ActionsでのCI
```yaml
# .github/workflows/test.yml の例
- name: Run tests with coverage
  run: flutter test --coverage
  
- name: Upload coverage to Codecov
  uses: codecov/codecov-action@v3
  with:
    file: coverage/lcov.info
```

## 6. カバレッジ向上のベストプラクティス

### 6.1 効果的なテストの書き方
- **単体テスト**: 個々の関数・メソッドをテスト
- **ウィジェットテスト**: UIコンポーネントをテスト
- **統合テスト**: 機能全体の動作をテスト

### 6.2 カバレッジが低い場合の対策
1. **未テスト箇所の特定**: HTMLレポートで赤色箇所を確認
2. **エッジケースの追加**: 異常系・境界値テストを追加
3. **プライベートメソッド**: 間接的にテストできているか確認
4. **モックの活用**: 外部依存をモック化してテスト

### 6.3 避けるべきパターン
- カバレッジのための意味のないテスト
- テストコードのみでプロダクションコードが実行されない
- 複雑すぎるセットアップが必要なテスト

## 7. トラブルシューティング

### 7.1 よくある問題
- **lcov.infoが生成されない**: `flutter test --coverage` が正しく実行されているか確認
- **カバレッジが0%**: テスト対象のファイルが正しくインポートされているか確認
- **HTMLレポートが表示されない**: `genhtml` コマンドが正しく実行されているか確認

### 7.2 参考リンク
- [Flutter Testing Documentation](https://flutter.dev/docs/testing)
- [Codecov Documentation](https://docs.codecov.com/)
- [LCOV Documentation](http://ltp.sourceforge.net/coverage/lcov.php)

---

## 関連ドキュメント
- [開発ガイド](DEVELOPMENT.md) - 開発環境のセットアップ
- [要件定義書](../requirements/requirements.md) - 非機能要件
- [Dartコーディング規約](../../.github/instructions/coding/dart.instructions.md) - コーディング標準