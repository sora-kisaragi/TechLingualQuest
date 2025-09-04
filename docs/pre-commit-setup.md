---
author: "GitHub Copilot"
date: "2025-09-04"
version: "1.0"
related_issues: []
---

# Pre-commit セットアップと運用ガイド

コミット時にコード品質チェックと自動整形を行い、CI/CD の失敗を未然に防ぐための設定と使い方をまとめます。

## できること

- ✅ Dart コードの自動フォーマット（`dart format`）
- ✅ 行末空白の削除、EOF 統一
- ✅ YAML/JSON の構文チェック
- ✅ マージコンフリクトマーカーの検出

構成は `.pre-commit-config.yaml` と、リポジトリ同梱の `scripts/format_dart.sh`（Dart 検出と実行をクロスプラットフォーム対応）を使用します。

## セットアップ

### 推奨: 自動セットアップ

```bash
bash ./scripts/setup_precommit_hooks.sh
```

このスクリプトは以下を行います。
- pre-commit のインストール（ユーザー領域）
- PATH の調整（Windows/Git Bash も考慮）
- フックのインストール（`pre-commit`, `commit-msg`）

### 手動セットアップ

```bash
# 1) pre-commit をインストール（ユーザー領域）
pip3 install --user pre-commit

# 2) フックをインストール
pre-commit install
pre-commit install --hook-type commit-msg

# 3) 全ファイルでテスト実行
pre-commit run --all-files
```

Windows + Git Bash などで `pre-commit` が PATH に出ない場合は、下記のように実行できます。

```bash
python -m pre_commit run --all-files
```

## 日常の使い方

- 通常はそのまま `git commit` で OK（コミット前に自動で走ります）。
- 手動で確認したいとき:

```bash
pre-commit run --all-files
# Dart フォーマットのみ
pre-commit run dart-format
```

## 構成ファイル（概要）

- `.pre-commit-config.yaml`
  - `local` repo: `scripts/format_dart.sh` を呼び出して Dart を整形
  - `pre-commit-hooks` repo: 末尾空白、EOF、YAML/JSON チェック、コンフリクト検出
- `scripts/format_dart.sh`
  - `dart`/`dart.exe`/`dart.bat`/`flutter dart` を順に検出して `dart format .` を実行

## よくあるトラブルと対策

- pre-commit が見つからない
  - `python -m pre_commit run --all-files` で実行
  - もしくは `~/.local/bin`（Linux/mac）や `Python user-base/Scripts`（Windows）を PATH に追加
- Flutter/Dart が見つからない
  - Flutter をインストールし、`flutter` コマンドが動く状態にする
  - `which flutter` / `which dart` の結果を確認
- 一時的にフックをスキップしたい
  - `git commit --no-verify -m "message"`
- アップデートしたい
  - `pre-commit autoupdate`（hook のバージョン更新）
  - `pre-commit clean`（環境クリーン）

## CI/CD との関係

pre-commit はローカルでの品質担保が目的です。CI でも整形やチェックを行うことで、差分の持ち込みを防ぎます。詳細は「docs/ci-cd-setup.md」を参照してください。

## リンク

- 設定スクリプト: `scripts/setup_precommit_hooks.sh`
- Dart フォーマッタースクリプト: `scripts/format_dart.sh`
- 設定ファイル: `.pre-commit-config.yaml`
- 参考: `docs/DEVELOPMENT.md`（環境全般）
