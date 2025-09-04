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
