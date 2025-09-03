#!/bin/bash
# setup_precommit_hooks.sh - pre-commitフックのセットアップスクリプト
# 自動Dartフォーマッティングを有効にして、CI/CDエラーを防止

set -e

echo "🔧 TechLingualQuest: Pre-commitフック設定スクリプト"
echo "   自動Dartフォーマッティングを設定します"
echo ""

# プロジェクトルートに移動
cd "$(dirname "$0")/.."

# Python3とpipの確認
if ! command -v python3 >/dev/null 2>&1; then
    echo "❌ Python3が必要です。インストールしてください。"
    exit 1
fi

if ! command -v pip3 >/dev/null 2>&1; then
    echo "❌ pip3が必要です。インストールしてください。"
    exit 1
fi

echo "✅ Python3とpip3が見つかりました"

# pre-commitのインストール確認
if ! command -v pre-commit >/dev/null 2>&1; then
    echo "📦 pre-commitをインストール中..."
    pip3 install pre-commit --user

    # PATHに~/.local/binを追加（必要に応じて）
    if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
        echo "export PATH=\"\$HOME/.local/bin:\$PATH\"" >> ~/.bashrc
        export PATH="$HOME/.local/bin:$PATH"
        echo "   ~/.bashrcにPATHを追加しました"
    fi
else
    echo "✅ pre-commitは既にインストール済みです"
fi

# pre-commitフックをインストール
echo "🔨 pre-commitフックをインストール中..."
if pre-commit install; then
    echo "✅ pre-commitフックのインストールが完了しました"
else
    echo "❌ pre-commitフックのインストールに失敗しました"
    exit 1
fi

# オプション: コミット時のメッセージフックも有効化
pre-commit install --hook-type commit-msg 2>/dev/null || true

echo ""
echo "🎉 セットアップが完了しました！"
echo ""
echo "📋 設定された機能:"
echo "   ✅ Dartコードの自動フォーマット（コミット時）"
echo "   ✅ 行末空白の自動除去"
echo "   ✅ ファイル末端の改行統一"
echo "   ✅ YAML/JSON構文チェック"
echo "   ✅ マージコンフリクトマーカーの検出"
echo ""
echo "💡 使用方法:"
echo "   今後のgit commitでは、Dartコードが自動的にフォーマットされ、"
echo "   CI/CDでのフォーマットエラーを防げます。"
echo ""
echo "🔍 手動テスト:"
echo "   pre-commit run --all-files  # 全ファイルでフックをテスト"
echo "   pre-commit run dart-format  # Dartフォーマットのみテスト"
echo ""
echo "📖 詳細なドキュメント:"
echo "   docs/DEVELOPMENT.md を参照してください。"
