# PR説明文（日本語版）

**タイトル:** 重複するドキュメント構造をクリーンアップし、docs/配下に統合

このPRは、重複するファイルと階層を削除し、すべてのドキュメントを`docs/`ディレクトリ配下に統合することで、リポジトリのドキュメント構造の問題に対処します。

## 実施した変更

**重複するドキュメントファイルを削除:**
- `/design/HLD.md`と`/design/LLD.md`（より包括的な版を`/docs/design/`に保持）
- `/requirements/system-requirements.md`と`/requirements/user-requirements.md`（`/docs/requirements/requirements.md`に統合）
- `/optional/api_spec.md`と`/optional/db_design.md`（`/docs/optional/`の版を保持）
- 空のディレクトリを削除: `/design/`、`/requirements/`、`/optional/`

**破損したクロスリファレンスを修正:**
- 統合された構造内で正しい相対パスを使用するようにすべてのドキュメントリンクを更新
- `development-tasks.md`、`issue-10-summary.md`、`issue-creation-plan.md`、および設計ドキュメント内の参照を修正
- 新しいドキュメント構造を反映するようにGitHub Copilotの指示を更新

**結果:**
リポジトリは現在、`/docs/`配下にクリーンな階層を持つすべてのドキュメントの単一情報源を持っています：

```
docs/
├── design/
│   ├── HLD.md
│   └── LLD.md
├── requirements/
│   └── requirements.md
├── optional/
│   └── db_design.md
├── development-tasks.md
├── issue-10-summary.md
└── issue-creation-plan.md
```

すべてのドキュメントリンクは現在機能しており、正しい場所を指しています。これにより、重複ファイルからのメンテナンスオーバーヘッドが排除され、よりクリーンで整理されたドキュメント構造が提供されます。

問題 #19 を修正します。