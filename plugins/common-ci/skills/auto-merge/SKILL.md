---
name: auto-merge
description: Generate a GitHub Actions workflow that auto-approves and auto-merges PRs with the `claude-auto` label using a GitHub App token. Use this skill when the user wants to set up auto-merge for Claude-created PRs, add automatic PR merging, configure auto-merge workflows, or says things like "auto-mergeを設定して", "自動マージのワークフローを追加", "claude-autoラベルで自動マージしたい", "PRを自動でマージする仕組みがほしい".
---

# auto-merge

`claude-auto` ラベルが付いた PR を GitHub App トークンで自動承認・自動マージする GitHub Actions ワークフローを生成する。

## 前提条件

以下をユーザーに確認すること。満たしていない場合は設定方法を案内する。

1. **GitHub App の登録**: リポジトリに対する `contents: write` と `pull-requests: write` 権限を持つ GitHub App が必要。
2. **Secrets の設定**: リポジトリの Secrets に以下が登録されていること:
   - `GHA_APP_ID` — GitHub App の App ID
   - `GHA_APP_PRIVATE_KEY` — GitHub App の秘密鍵
3. **ブランチ保護ルール**: base ブランチに「Require approvals」が設定されている場合、GitHub App のレビューがカウントされるよう設定されていること。

## ワークフロー生成手順

### Step 1: 既存ワークフローの確認

```bash
ls .github/workflows/auto-merge.yml 2>/dev/null
```

ファイルが存在する場合はユーザーに上書きするか確認する。

### Step 2: ディレクトリの作成

```bash
mkdir -p .github/workflows
```

### Step 3: ワークフローファイルの生成

`references/workflow-template.yml` の内容を `.github/workflows/auto-merge.yml` として書き出す。

### Step 4: `claude-auto` ラベルの作成

リポジトリに `claude-auto` ラベルが存在するか確認し、なければ作成する。

```bash
gh label list --search "claude-auto" --json name --jq '.[].name' | grep -q "^claude-auto$" \
  || gh label create "claude-auto" --description "Claude による自動マージ対象" --color "6f42c1"
```

### Step 5: 結果の報告

以下を表示する:

1. 生成したファイルのパス
2. 必要な Secrets（`GHA_APP_ID`, `GHA_APP_PRIVATE_KEY`）が設定済みか確認するよう案内
3. 使い方の説明: PR に `claude-auto` ラベルを付けると自動で approve → squash merge される

## マージ戦略

デフォルトは `--squash` を使用する。ユーザーが別のマージ戦略（`--merge`, `--rebase`）を希望した場合はテンプレートを変更して対応する。

## 禁止事項

- Secrets の値をログに出力しない
- `GITHUB_TOKEN` を approve に使用しない（PR 作成者と同一のため approve できない）
- `--force` や `--admin` フラグでブランチ保護を迂回しない
