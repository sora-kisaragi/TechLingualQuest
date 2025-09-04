---
applyTo: "**"
---

# Git Flow Instructions for Copilot (English body)

This document defines a concise Git Flow for this repository. The body is in English for prompt efficiency, while the policy mandates writing user-facing Git text in Japanese.

## 1. Branch Guidance

- Branch types: main, develop, feature, hotfix, release.
- Naming: use ASCII (romaji) and kebab-case for compatibility.
  - Examples: `docs/ja-localization-YYYYMMDD`, `feat/auth-ui-kaizen`, `fix/ci-windows-path`.
- Japanese branch names are allowed but must render correctly on GitHub/CI.

## 2. Commit Guidance

- Follow Conventional Commits.
- Write commit titles/bodies in Japanese (concise, with reason/scope/migration notes).
  - Example: `docs: 日本語ローカライズの不足分を追加`.
- Reference issues when relevant (e.g., `Refs #123`).

## 3. PR Guidance

- PR titles/descriptions/review comments must be in Japanese.
- Include a short checklist in the PR description:
  - What/Why (変更概要・理由)
  - Related Issue (e.g., `Closes #123`)
  - How to test (手順/期待結果)
  - Impact scope (影響範囲: 機能/CI/ドキュメント など)
  - Release notes (if needed)
- Ensure lint and unit tests pass before merge.

### 3.1 Creating PRs via GitHub CLI (gh)

- Prefer using `gh` to open PRs from local branches.
- Basic flow (replace values as needed):
  - Set base branch to `develop` and fill Japanese title/body interactively:
    - `gh pr create --base develop --title "<日本語タイトル>" --body "<日本語本文>"`
  - Or open editor to compose in Japanese:
    - `gh pr create --base develop --fill` then edit title/body in Japanese.
- Add labels/reviewers as needed, e.g.:
  - `gh pr edit --add-label "documentation"`
  - `gh pr edit --add-reviewer <github-username>`

### 3.2 Newlines on Git Bash (commit/PR messages)

Git Bash does not interpret "\n" inside regular quotes. Use one of the following to ensure proper newlines in Japanese texts:

- Prefer files (most robust):

  - PR body: write to a file and pass it.
    - `gh pr create --base develop --title "<日本語タイトル>" --body-file pr_body_ja.md`
    - Update existing PR: `gh pr edit --body-file pr_body_ja.md`
  - Commit message: write to a file and use `-F`.
    - `git commit -F commit_message_ja.txt`

- Use ANSI-C quoting $'...': `\n` is interpreted in Git Bash only inside $'...'.

  - PR body inline:
    - `gh pr create --base develop --title 'docs: 日本語化と方針更新' --body $'## 概要\n- 変更点\n\n## 影響範囲\n- ドキュメントのみ'`
  - Commit body inline (title + body):
    - `git commit -m "docs: 日本語化の修正" -m $'## 概要\n- ...\n\n## 理由\n- ...'`

- Use an editor interactively:
  - Set editor (example VS Code) and let `gh` open it.
    - `export GH_EDITOR="code -w"`
    - `gh pr create --base develop --fill` (edit Japanese title/body in the editor)
  - For `git commit`, simply run `git commit` to open the editor and write Japanese with newlines.

Notes:

- Multiple `-m` flags in `git commit` create separate paragraphs (blank line between each `-m`).
- Avoid relying on plain "\n" inside normal quotes on Git Bash; use $'...' or files instead.

## 4. Merge Guidance

- Prefer Squash into develop.
- main requires review.
- hotfix can be merged directly if urgent.
- Flag potential conflicts early.

## 5. Verification

- Verify locally before pushing.
- Ensure generated code adheres to repo standards.

## 6. Code Quality and Formatting

- Pre-commit: use hooks (run `pre-commit install`). Dart code is formatted via `dart format`.
- Manual: run `dart format .` before commit.
- Check: `dart format --set-exit-if-changed .` in CI.
- All code must pass formatting in CI.

## 7. Language Policy (Japanese-first for Git Text)

- Commit messages: write in Japanese (Conventional Commits).
- PR title/description/review: write in Japanese.
- Branch names: ASCII/romaji kebab-case recommended; Japanese allowed if safe.
- Auto-generated logs (CI, tools) remain in English.

### PR template snippet (in Japanese)

```
## 概要
- 変更の要点（何を/なぜ）

## 変更内容
- <モジュール/ファイル> の主な変更

## 動作確認
1. 手順
2. 期待結果

## 影響範囲
- 機能/CI/ドキュメント 等

## 関連
- Closes #<issue-number>
```
