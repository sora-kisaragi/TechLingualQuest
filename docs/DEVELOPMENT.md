# 開発環境セットアップガイド

## ローカル開発環境の設定

### Gradleメモリ設定

プロジェクトは、ローカル開発環境とCI/CD環境の両方に適切なデフォルト設定が行われています：

- **ローカル開発**: 2GBヒープサイズ（`android/gradle.properties`のデフォルト）
- **CI/CD環境**: 4GBヒープサイズ（環境変数で設定）

### ローカルメモリ設定のカスタマイズ

ローカル開発中にメモリ問題やクラッシュが発生する場合、Gradleヒープサイズをカスタマイズできます：

#### 方法1: 環境変数（推奨）
Flutterコマンドを実行する前に`GRADLE_OPTS`環境変数を設定します：

```bash
# ヒープサイズを小さくする場合（クラッシュが発生する場合）
export GRADLE_OPTS="-Xmx1G -XX:MaxMetaspaceSize=256m -XX:ReservedCodeCacheSize=128m"
flutter build apk --debug

# ヒープサイズを大きくする場合（OutOfMemoryErrorでビルドが失敗する場合）
export GRADLE_OPTS="-Xmx3G -XX:MaxMetaspaceSize=768m -XX:ReservedCodeCacheSize=384m"
flutter build apk --release
```

#### 方法2: ローカルgradle.propertiesの上書き
希望する設定でローカルの`android/gradle.properties.local`ファイル（git無視対象）を作成します：

```properties
org.gradle.jvmargs=-Xmx1G -XX:MaxMetaspaceSize=256m -XX:ReservedCodeCacheSize=128m
```

その後、一時的にメインファイルにコピーします：
```bash
cp android/gradle.properties.local android/gradle.properties
# ビルドを実行
flutter build apk --debug
# 元に戻す
git checkout android/gradle.properties
```

### システム別メモリ推奨設定

- **8GB RAM以下**: 1GBヒープを使用（`-Xmx1G`）
- **8-16GB RAM**: 2GBヒープを使用（デフォルト）
- **16GB+ RAM**: 必要に応じて3GB+ヒープを使用可能

### CI/CD vs ローカル開発

CI/CDパイプラインでは、クラウド環境での安定したビルドを保証するため、自動的により高いメモリ設定（4GBヒープ）を使用します。ローカル開発者は、システムクラッシュを避けるためより保守的な2GBデフォルトを維持します。

## 自動コードフォーマッティング設定

### CI/CDフォーマットエラーの予防

プロジェクトでは、コミット時に自動的にDartコードをフォーマットするpre-commitフックを設定できます。これにより、CI/CDでのフォーマットエラーを事前に防げます。

#### 自動セットアップ（推奨）

```bash
# プロジェクトルートで実行
./scripts/setup_precommit_hooks.sh
```

このスクリプトは以下を自動実行します：
- pre-commitフレームワークのインストール
- pre-commitフックの設定
- Dartフォーマッターの設定

#### 手動セットアップ

```bash
# 1. pre-commitをインストール
pip3 install pre-commit --user

# 2. フックをインストール
pre-commit install

# 3. テスト実行
pre-commit run --all-files
```

#### 設定される機能

- ✅ **Dartコードの自動フォーマット**: `dart format`がコミット時に自動実行
- ✅ **行末空白の除去**: 不要な空白を自動削除
- ✅ **ファイル末端の改行統一**: ファイル末端の改行を統一
- ✅ **YAML/JSON構文チェック**: 設定ファイルの構文を検証
- ✅ **マージコンフリクトの検出**: コンフリクトマーカーを検出

#### 使用方法

セットアップ後は、通常通り`git commit`を実行するだけで、自動的にコードがフォーマットされます：

```bash
git add .
git commit -m "feat: add new feature"
# → Dartコードが自動的にフォーマットされ、コミットされます
```

#### トラブルシューティング

**Flutter/Dartが見つからない場合:**
```bash
# Flutter/DartへのPATHを確認
which flutter
which dart

# PATHに追加（必要に応じて）
export PATH="$PATH:/path/to/flutter/bin"
```

**pre-commitを無効にする場合:**
```bash
# 一時的に無効化
git commit --no-verify -m "commit message"

# 完全に無効化
pre-commit uninstall
```

## トラブルシューティング

### 一般的なメモリ問題

1. **ビルド中のOutOfMemoryError**: ヒープサイズを増やす
2. **システムが応答しなくなる**: ヒープサイズを減らす
3. **ビルドに時間がかかりすぎる**: システムが許可する場合、ヒープサイズを増やしてみる

### Androidビルドコマンド

```bash
# デバッグビルド（高速、メモリ使用量少）
flutter build apk --debug

# リリースビルド（低速、メモリ使用量多）
flutter build apk --release

# プロファイルビルド（中間的な選択肢）
flutter build apk --profile
```
