#!/bin/bash
# format_dart.sh - スマートDartフォーマッターfor pre-commit hooks
# このスクリプトはFlutter/Dartの様々なインストール方法に対応

# Dartコマンドを検出する関数
find_dart_command() {
    # 1. システムPATHでdartを検索
    if command -v dart >/dev/null 2>&1; then
        echo "dart"
        return 0
    fi

    # 2. Flutterのbinディレクトリ内のdartを検索
    if command -v flutter >/dev/null 2>&1; then
        flutter_path=$(which flutter)
        flutter_dir=$(dirname "${flutter_path}")
        if [ -f "${flutter_dir}/dart" ]; then
            echo "${flutter_dir}/dart"
            return 0
        fi

        # Flutterインストールディレクトリの上の階層も確認
        flutter_parent_dir=$(dirname "${flutter_dir}")
        if [ -f "${flutter_parent_dir}/bin/dart" ]; then
            echo "${flutter_parent_dir}/bin/dart"
            return 0
        fi
    fi

    # 3. 一般的なインストール場所を検索
    common_paths=(
        "/usr/local/flutter/bin/dart"
        "/opt/flutter/bin/dart"
        "$HOME/flutter/bin/dart"
        "$HOME/.flutter/bin/dart"
        "/snap/flutter/current/bin/dart"
    )

    for path in "${common_paths[@]}"; do
        if [ -f "$path" ]; then
            echo "$path"
            return 0
        fi
    done

    # 4. fvmやその他のバージョン管理ツールもチェック
    if command -v fvm >/dev/null 2>&1; then
        if fvm dart --version >/dev/null 2>&1; then
            echo "fvm dart"
            return 0
        fi
    fi

    return 1
}

# Dartコマンドを取得
DART_CMD=$(find_dart_command)
DART_FOUND=$?

if [ $DART_FOUND -ne 0 ]; then
    echo "⚠️  Warning: Dart executable not found."
    echo "   This is likely a CI/CD environment or Dart is not installed locally."
    echo "   In local development, please install Flutter/Dart:"
    echo "   Visit: https://flutter.dev/docs/get-started/install"
    echo ""
    echo "💡 For local development setup, run:"
    echo "   ./scripts/setup_precommit_hooks.sh"
    echo ""
    echo "🔄 Skipping Dart format (CI/CD will handle this)..."
    exit 0
fi

echo "📝 Dartフォーマッターを実行中..."
echo "   使用コマンド: ${DART_CMD}"

# プロジェクトのルートディレクトリに移動
cd "$(dirname "$0")/.."

# フォーマットを実行
if ${DART_CMD} format . >/dev/null 2>&1; then
    echo "✅ Dartコードのフォーマットが完了しました"
    exit 0
else
    echo "❌ Dartフォーマットでエラーが発生しました"
    echo "   手動で確認してください: ${DART_CMD} format ."
    exit 1
fi
