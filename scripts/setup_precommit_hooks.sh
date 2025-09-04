#!/bin/bash
# setup_precommit_hooks.sh - pre-commitフックのセットアップスクリプト
# 自動Dartフォーマッティングを有効にして、CI/CDエラーを防止

set -e

echo "🔧 TechLingualQuest: Pre-commitフック設定スクリプト"
echo "   自動Dartフォーマッティングを設定します"
echo ""

# プロジェクトルートに移動
cd "$(dirname "$0")/.."

# Python / Pip の確認（Windows/Git Bash互換）
PY_BIN=""
if command -v python3 >/dev/null 2>&1; then
    PY_BIN="python3"
elif command -v python >/dev/null 2>&1; then
    PY_BIN="python"
elif command -v py >/dev/null 2>&1; then
    PY_BIN="py"
else
    echo "❌ Pythonが必要です。インストールしてください。"
    exit 1
fi

PIP_BIN=""
if command -v pip3 >/dev/null 2>&1; then
    PIP_BIN="pip3"
elif command -v pip >/dev/null 2>&1; then
    PIP_BIN="pip"
else
    # 最後の手段: python -m pip
    if "$PY_BIN" -m pip --version >/dev/null 2>&1; then
        PIP_BIN="$PY_BIN -m pip"
    else
        echo "❌ pip が見つかりません。Pythonのpipをインストールしてください。"
        exit 1
    fi
fi

echo "✅ Python: $PY_BIN / Pip: $PIP_BIN を使用します"

# pre-commitのインストール確認
if ! command -v pre-commit >/dev/null 2>&1; then
    echo "📦 pre-commitをインストール中..."
    eval "$PIP_BIN install --user pre-commit"

    # PATHに~/.local/binを追加（必要に応じて）
    if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
        # Python user-base の Scripts/bin をPATHに追加（Windows/Unix 両対応）
        USER_BASE=$($PY_BIN -m site --user-base 2>/dev/null || echo "")
        if [ -n "$USER_BASE" ]; then
            if [ "$OS" = "Windows_NT" ]; then
                BIN_DIR="$USER_BASE/Scripts"
            else
                BIN_DIR="$USER_BASE/bin"
            fi
            export PATH="$BIN_DIR:$HOME/.local/bin:$PATH"
            # bash 環境でのみ .bashrc に追記
            if [ -n "$BASH_VERSION" ]; then
                {
                    echo "# Added by setup_precommit_hooks.sh"
                    echo "export PATH=\"$BIN_DIR:\$HOME/.local/bin:\$PATH\""
                } >> ~/.bashrc
                echo "   PATH を $BIN_DIR と ~/.local/bin に拡張（~/.bashrc へ追記）"
            fi
        else
            # フォールバック
            export PATH="$HOME/.local/bin:$PATH"
        fi
    fi
else
    echo "✅ pre-commitは既にインストール済みです"
fi

# pre-commitフックをインストール
echo "🔨 pre-commitフックをインストール中..."
if pre-commit install 2>/dev/null || "$PY_BIN" -m pre_commit install; then
    echo "✅ pre-commitフックのインストールが完了しました"
else
    echo "❌ pre-commitフックのインストールに失敗しました"
    exit 1
fi

# オプション: コミット時のメッセージフックも有効化
pre-commit install --hook-type commit-msg 2>/dev/null || "$PY_BIN" -m pre_commit install --hook-type commit-msg 2>/dev/null || true

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
echo "   docs/engineering/DEVELOPMENT.md を参照してください。"
