# 開発環境セットアップガイド

## ローカル開発環境の設定

### Gradleメモリ設定

プロジェクトは、ローカル開発環境とCI/CD環境の両方に適切なデフォルト設定が行われています：

- ローカル開発: 2GBヒープサイズ（`android/gradle.properties`のデフォルト）
- CI/CD環境: 4GBヒープサイズ（環境変数で設定）

### ローカルメモリ設定のカスタマイズ

方法1: 環境変数（推奨）

```bash
export GRADLE_OPTS="-Xmx1G -XX:MaxMetaspaceSize=256m -XX:ReservedCodeCacheSize=128m"
flutter build apk --debug

export GRADLE_OPTS="-Xmx3G -XX:MaxMetaspaceSize=768m -XX:ReservedCodeCacheSize=384m"
flutter build apk --release
```

方法2: ローカルgradle.propertiesの上書き

```properties
org.gradle.jvmargs=-Xmx1G -XX:MaxMetaspaceSize=256m -XX:ReservedCodeCacheSize=128m
```

適用手順:
```bash
cp android/gradle.properties.local android/gradle.properties
flutter build apk --debug
git checkout android/gradle.properties
```

### システム別メモリ推奨設定

- 8GB RAM以下: 1GBヒープ（-Xmx1G）
- 8-16GB RAM: 2GBヒープ（デフォルト）
- 16GB+ RAM: 3GB+ヒープを検討

### CI/CD vs ローカル開発

CI/CDパイプラインでは自動でより高いメモリ設定（4GBヒープ）を使用します。ローカルは2GBデフォルトを推奨。

## 自動コードフォーマッティング（pre-commit）

Pre-commit のセットアップと運用手順は専用ドキュメントに分割:

- 詳細: `docs/engineering/pre-commit-setup.md`

## コードカバレッジの確認と管理

**詳細なガイド**: `docs/engineering/code-coverage-guide.md`

### クイックスタート
```bash
# テスト実行とカバレッジ生成
flutter test --coverage

# カバレッジレポートの生成（HTML形式）
genhtml coverage/lcov.info -o coverage/html

# レポートの確認（ブラウザで開く）
open coverage/html/index.html
```

### カバレッジ要件
- **全体カバレッジ**: 80%以上を維持
- **新規コード**: 85%以上のカバレッジ必須
- **commit前確認**: 必ずローカルでカバレッジを確認してからcommit

### xDD開発の推進
- **TDD（Test-Driven Development）**: テストファースト開発を優先
- **FDD（Feature-Driven Development）**: 機能駆動開発の採用
- **品質重視**: 動作するコードではなく、テストされた動作するコードを目指す

## トラブルシューティング

1. ビルド中のOutOfMemoryError: ヒープを増やす
2. システムが重い: ヒープを減らす
3. ビルドが遅い: 余裕があればヒープを増やす

### Androidビルドコマンド

```bash
flutter build apk --debug
flutter build apk --release
flutter build apk --profile
```
