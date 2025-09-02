#!/bin/bash

# CI/CD設定管理スクリプト
# TechLingual QuestプロジェクトのCI/CD環境を設定・管理するためのユーティリティ

set -e

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 設定ファイル
CONFIG_FILE=".github/ci-cd-config.json"

print_header() {
    echo -e "${BLUE}======================================${NC}"
    echo -e "${BLUE}  TechLingual Quest CI/CD 設定ツール${NC}"
    echo -e "${BLUE}======================================${NC}"
    echo ""
}

print_usage() {
    echo "使用法: $0 <command> [options]"
    echo ""
    echo "コマンド:"
    echo "  setup           CI/CD環境の初期設定"
    echo "  webhook         Webhook URLの設定・テスト"
    echo "  test            ローカルでCI/CDテストを実行"
    echo "  validate        ワークフロー設定の検証"
    echo "  status          現在の設定状況を表示"
    echo "  help            このヘルプを表示"
    echo ""
    echo "例:"
    echo "  $0 setup"
    echo "  $0 webhook discord https://discord.com/api/webhooks/..."
    echo "  $0 test build"
    echo "  $0 validate"
}

check_prerequisites() {
    echo -e "${YELLOW}📋 前提条件の確認...${NC}"
    
    # Flutter SDKの確認
    if command -v flutter &> /dev/null; then
        FLUTTER_VERSION=$(flutter --version | head -n 1)
        echo -e "${GREEN}✅ Flutter SDK: $FLUTTER_VERSION${NC}"
    else
        echo -e "${RED}❌ Flutter SDKが見つかりません${NC}"
        echo "   Flutter SDKをインストールしてください: https://flutter.dev/docs/get-started/install"
        return 1
    fi
    
    # Git の確認
    if command -v git &> /dev/null; then
        echo -e "${GREEN}✅ Git がインストールされています${NC}"
    else
        echo -e "${RED}❌ Git が見つかりません${NC}"
        return 1
    fi
    
    # jq の確認（オプション）
    if command -v jq &> /dev/null; then
        echo -e "${GREEN}✅ jq がインストールされています (JSON処理用)${NC}"
    else
        echo -e "${YELLOW}⚠️  jq がインストールされていません (オプション)${NC}"
        echo "   JSON処理を改善するために jq のインストールを推奨します"
    fi
    
    # curl の確認
    if command -v curl &> /dev/null; then
        echo -e "${GREEN}✅ curl がインストールされています${NC}"
    else
        echo -e "${RED}❌ curl が見つかりません${NC}"
        return 1
    fi
}

setup_environment() {
    echo -e "${YELLOW}🔧 CI/CD環境の初期設定...${NC}"
    
    # プロジェクト構造の確認
    if [ ! -f "pubspec.yaml" ]; then
        echo -e "${RED}❌ pubspec.yaml が見つかりません。Flutterプロジェクトのルートディレクトリで実行してください。${NC}"
        exit 1
    fi
    
    # ワークフローディレクトリの確認
    if [ ! -d ".github/workflows" ]; then
        echo -e "${YELLOW}📁 .github/workflows ディレクトリを作成します...${NC}"
        mkdir -p .github/workflows
    fi
    
    # 設定ファイルの初期化
    if [ ! -f "$CONFIG_FILE" ]; then
        echo -e "${YELLOW}📄 設定ファイルを作成します...${NC}"
        cat > "$CONFIG_FILE" << 'EOF'
{
  "version": "1.0",
  "flutter_version": "3.24.3",
  "notifications": {
    "discord": {
      "enabled": false,
      "webhook_url": ""
    },
    "slack": {
      "enabled": false,
      "webhook_url": ""
    }
  },
  "build_targets": ["android", "web"],
  "test_coverage": true,
  "security_scan": true
}
EOF
        echo -e "${GREEN}✅ 設定ファイルが作成されました: $CONFIG_FILE${NC}"
    fi
    
    # 依存関係の取得
    echo -e "${YELLOW}📦 依存関係を取得しています...${NC}"
    flutter pub get
    
    echo -e "${GREEN}✅ CI/CD環境の初期設定が完了しました${NC}"
}

setup_webhook() {
    local service="$1"
    local webhook_url="$2"
    
    if [ -z "$service" ] || [ -z "$webhook_url" ]; then
        echo -e "${RED}❌ 使用法: $0 webhook <service> <webhook_url>${NC}"
        echo "   service: discord または slack"
        exit 1
    fi
    
    case "$service" in
        discord)
            echo -e "${YELLOW}🔗 Discord Webhook の設定...${NC}"
            ;;
        slack)
            echo -e "${YELLOW}🔗 Slack Webhook の設定...${NC}"
            ;;
        *)
            echo -e "${RED}❌ サポートされていないサービス: $service${NC}"
            echo "   対応サービス: discord, slack"
            exit 1
            ;;
    esac
    
    # Webhook URLのテスト
    echo -e "${YELLOW}🧪 Webhook URLをテストしています...${NC}"
    
    if [ "$service" = "discord" ]; then
        response=$(curl -s -o /dev/null -w "%{http_code}" -X POST \
            -H "Content-Type: application/json" \
            -d '{"content": "TechLingual Quest CI/CD テストメッセージ"}' \
            "$webhook_url")
    else # slack
        response=$(curl -s -o /dev/null -w "%{http_code}" -X POST \
            -H "Content-Type: application/json" \
            -d '{"text": "TechLingual Quest CI/CD テストメッセージ"}' \
            "$webhook_url")
    fi
    
    if [ "$response" = "200" ] || [ "$response" = "204" ]; then
        echo -e "${GREEN}✅ Webhook URLのテストが成功しました${NC}"
        echo -e "${BLUE}📝 次のステップ:${NC}"
        echo "   1. GitHub リポジトリの Settings → Secrets and variables → Actions"
        echo "   2. Variables タブで新しい変数を追加:"
        if [ "$service" = "discord" ]; then
            echo "      名前: DISCORD_WEBHOOK_URL"
        else
            echo "      名前: SLACK_WEBHOOK_URL"
        fi
        echo "      値: $webhook_url"
    else
        echo -e "${RED}❌ Webhook URLのテストが失敗しました (HTTP: $response)${NC}"
        echo "   URLが正しいか確認してください"
    fi
}

run_tests() {
    local test_type="$1"
    
    echo -e "${YELLOW}🧪 CI/CDテストを実行しています...${NC}"
    
    case "$test_type" in
        build|"")
            echo -e "${YELLOW}🔨 ビルドテスト...${NC}"
            flutter clean
            flutter pub get
            flutter analyze
            flutter test
            flutter build apk --debug
            flutter build web
            echo -e "${GREEN}✅ ビルドテストが完了しました${NC}"
            ;;
        format)
            echo -e "${YELLOW}📐 フォーマットチェック...${NC}"
            dart format --output=none --set-exit-if-changed .
            echo -e "${GREEN}✅ フォーマットチェックが完了しました${NC}"
            ;;
        analyze)
            echo -e "${YELLOW}🔍 静的解析...${NC}"
            flutter analyze
            echo -e "${GREEN}✅ 静的解析が完了しました${NC}"
            ;;
        test)
            echo -e "${YELLOW}🧪 ユニットテスト...${NC}"
            flutter test --coverage
            echo -e "${GREEN}✅ ユニットテストが完了しました${NC}"
            ;;
        all)
            echo -e "${YELLOW}🔄 全テストを実行...${NC}"
            run_tests format
            run_tests analyze
            run_tests test
            run_tests build
            ;;
        *)
            echo -e "${RED}❌ 不明なテストタイプ: $test_type${NC}"
            echo "   対応テスト: build, format, analyze, test, all"
            exit 1
            ;;
    esac
}

validate_workflows() {
    echo -e "${YELLOW}✅ ワークフロー設定の検証...${NC}"
    
    local workflows=(".github/workflows/flutter.yml" ".github/workflows/security-scan.yml" ".github/workflows/release.yml")
    
    for workflow in "${workflows[@]}"; do
        if [ -f "$workflow" ]; then
            echo -e "${GREEN}✅ $workflow が存在します${NC}"
            
            # YAML構文の基本チェック
            if command -v yq &> /dev/null; then
                if yq eval '.' "$workflow" > /dev/null 2>&1; then
                    echo -e "${GREEN}   └─ YAML構文が正しいです${NC}"
                else
                    echo -e "${RED}   └─ YAML構文にエラーがあります${NC}"
                fi
            fi
        else
            echo -e "${RED}❌ $workflow が見つかりません${NC}"
        fi
    done
    
    # Repository Variables の確認指示
    echo -e "${BLUE}📝 Repository Variables の確認:${NC}"
    echo "   GitHub リポジトリの Settings → Secrets and variables → Actions で以下を確認:"
    echo "   - DISCORD_WEBHOOK_URL (オプション)"
    echo "   - SLACK_WEBHOOK_URL (オプション)"
}

show_status() {
    echo -e "${YELLOW}📊 現在の設定状況...${NC}"
    
    # プロジェクト情報
    if [ -f "pubspec.yaml" ]; then
        PROJECT_NAME=$(grep "^name:" pubspec.yaml | cut -d: -f2 | xargs)
        PROJECT_VERSION=$(grep "^version:" pubspec.yaml | cut -d: -f2 | xargs)
        echo -e "${GREEN}📱 プロジェクト: $PROJECT_NAME ($PROJECT_VERSION)${NC}"
    fi
    
    # Flutter バージョン
    if command -v flutter &> /dev/null; then
        FLUTTER_VERSION=$(flutter --version | head -n 1 | cut -d' ' -f2)
        echo -e "${GREEN}🔧 Flutter: $FLUTTER_VERSION${NC}"
    fi
    
    # ワークフロー状況
    echo -e "${BLUE}⚙️  ワークフロー:${NC}"
    local workflows=("flutter.yml" "security-scan.yml" "release.yml")
    for workflow in "${workflows[@]}"; do
        if [ -f ".github/workflows/$workflow" ]; then
            echo -e "${GREEN}   ✅ $workflow${NC}"
        else
            echo -e "${RED}   ❌ $workflow${NC}"
        fi
    done
    
    # 設定ファイル
    if [ -f "$CONFIG_FILE" ]; then
        echo -e "${GREEN}📄 設定ファイル: $CONFIG_FILE${NC}"
    else
        echo -e "${YELLOW}📄 設定ファイル: 未作成${NC}"
    fi
}

# メイン処理
main() {
    print_header
    
    case "${1:-help}" in
        setup)
            check_prerequisites
            setup_environment
            ;;
        webhook)
            setup_webhook "$2" "$3"
            ;;
        test)
            check_prerequisites
            run_tests "$2"
            ;;
        validate)
            validate_workflows
            ;;
        status)
            show_status
            ;;
        help|*)
            print_usage
            ;;
    esac
}

# スクリプト実行
main "$@"