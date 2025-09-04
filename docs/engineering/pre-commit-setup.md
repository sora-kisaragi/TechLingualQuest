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

構成は `.pre-commit-config.yaml` と、リポジトリ同梱の `scripts/format_dart.sh` を使用します。

## セットアップ

推奨: 自動セットアップ

```bash
bash ./scripts/setup_precommit_hooks.sh
```

手動セットアップ

```bash
pip3 install --user pre-commit
pre-commit install
pre-commit install --hook-type commit-msg
pre-commit run --all-files
```

Windows + Git Bash の場合:

```bash
python -m pre_commit run --all-files
```

## 日常の使い方

- 通常は `git commit` で自動実行。
- 手動実行:

```bash
pre-commit run --all-files
pre-commit run dart-format
```

## 構成ファイル

- `.pre-commit-config.yaml`: Dart整形、空白/EOF、YAML/JSON、コンフリクト検出
- `scripts/format_dart.sh`: 各種dart検出後に `dart format .` を実行

## トラブルと対策

- pre-commit が見つからない: `python -m pre_commit run --all-files`、PATH調整
- Flutter/Dart が見つからない: Flutterをインストール、`which flutter`/`dart`
- スキップ: `git commit --no-verify -m "msg"`
- 更新: `pre-commit autoupdate` / `pre-commit clean`

## CI/CD との関係

CI でも整形・チェックを行い差分流入を防止。CI/CD手順は `docs/engineering/ci-cd-setup.md` を参照。

## リンク

- 設定スクリプト: `scripts/setup_precommit_hooks.sh`
- Dart フォーマッタースクリプト: `scripts/format_dart.sh`
- 設定ファイル: `.pre-commit-config.yaml`
- 参考: `docs/engineering/DEVELOPMENT.md`
