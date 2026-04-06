---
name: create-branch
description: base branch から新しいフィーチャーブランチを作成する（gnf 相当）
allowed-tools: [Bash]
---

# Create Branch

base branch（デフォルト: `main`）から新しいフィーチャーブランチを作成する。

## ブランチ名のフォーマット

```text
feat/<description>-<YYMMDD>-<short-hash>
```

- `<description>`: 機能を表す英語のケバブケース（例: `add-user-auth`）
- `<YYMMDD>`: ブランチ作成日（例: `260405`）
- `<short-hash>`: base branch の HEAD コミットの先頭 7 文字

## 手順

### 1. ユーザーからの入力を確認

- ブランチの目的・機能名を確認する
- 日本語で指示された場合は、適切な英単語・英文に変換してケバブケースにする
  - 例:「ユーザー認証を追加」→ `add-user-auth`
  - 例:「ログイン画面の修正」→ `fix-login-page`
  - 例:「README 更新」→ `update-readme`

### 2. base branch の最新化

```bash
git fetch origin main
```

### 3. ブランチ名の生成

- 日付を取得: `date +%y%m%d`
- short hash を取得: `git rev-parse --short=7 origin/main`
- ブランチ名を組み立てる: `feat/<description>-<YYMMDD>-<short-hash>`

### 4. ブランチの作成

- base branch（`origin/main`）から新しいブランチを作成してチェックアウトする:

```bash
git checkout -b feat/<description>-<YYMMDD>-<short-hash> origin/main
```

### 5. 結果の表示

- 作成されたブランチ名を表示する

## 禁止事項

- 現在のブランチからの派生（必ず base branch から派生すること）
- `git push` の実行（ブランチ作成のみ）
- description に日本語を含めること
