# tqer39-plugins

Claude Code 用の個人 SRE/DevOps プラグインマーケットプレイス。

## 概要

約20の個人リポジトリに共通スキル・コマンドを配布するための一元管理マーケットプレイス。[Claude Code Plugin Marketplace](https://code.claude.com/docs/en/plugin-marketplaces) システムを利用。

## インストール

```bash
# マーケットプレイスを追加
/plugin marketplace add tqer39/claude-code-marketplace

# プラグインをインストール
/plugin install common-ci@tqer39-plugins
/plugin install git@tqer39-plugins
/plugin install security@tqer39-plugins
/plugin install terraform@tqer39-plugins
/plugin install agent-config@tqer39-plugins
```

## 使い方

### マーケットプレイスの追加

Claude Code セッション内で実行:

```bash
/plugin marketplace add tqer39/claude-code-marketplace
```

または、プロジェクトの `.claude/settings.json` に設定:

```json
{
  "extraKnownMarketplaces": {
    "tqer39-plugins": {
      "source": {
        "source": "github",
        "repo": "tqer39/claude-code-marketplace"
      }
    }
  }
}
```

### プラグインのインストール

スコープを指定してインストール:

```bash
# user スコープ（自分、全プロジェクト）— デフォルト
/plugin install common-ci@tqer39-plugins

# project スコープ（チーム共有、.claude/settings.json に記録）
/plugin install common-ci@tqer39-plugins --scope project

# local スコープ（自分、このプロジェクトのみ）
/plugin install common-ci@tqer39-plugins --scope local
```

### プラグインの管理

```bash
# 利用可能なプラグインを一覧表示
/plugin

# アンインストールせずに有効/無効を切り替え
/plugin enable common-ci@tqer39-plugins
/plugin disable common-ci@tqer39-plugins

# アンインストール
/plugin uninstall common-ci@tqer39-plugins

# 変更後にリロード
/reload-plugins
```

### 更新

```bash
# 全マーケットプレイスを更新
/plugin marketplace update

# 特定のマーケットプレイスを更新
/plugin marketplace update tqer39-plugins
```

### マーケットプレイスの削除

```bash
/plugin marketplace remove tqer39-plugins
```

> **注意:** マーケットプレイスを削除すると、そこからインストールした全プラグインもアンインストールされます。

### プロジェクトごとのプラグイン事前設定

プロジェクトの `.claude/settings.json` に追加:

```json
{
  "extraKnownMarketplaces": {
    "tqer39-plugins": {
      "source": {
        "source": "github",
        "repo": "tqer39/claude-code-marketplace"
      }
    }
  },
  "enabledPlugins": {
    "common-ci@tqer39-plugins": true,
    "terraform@tqer39-plugins": true
  }
}
```

## プラグイン

### common-ci

全リポジトリ共通の CI/CD スキル。

| スキル | 説明 |
|--------|------|
| pull-request | GitHub PR ワークフローの自動化（rebase、コンフリクト解決、説明文生成） |
| gitignore | プロジェクト自動検出による .gitignore の生成・更新 |
| redesign | アーキテクチャ分析と再設計提案ワークフロー |
| auto-merge | `claude-auto` ラベル付き PR の自動承認・自動マージワークフロー生成 |

### git

Git ワークフローコマンド。

| コマンド | 説明 |
|----------|------|
| auto-commit | 絵文字プレフィックス + 日本語要約で自動ステージング・コミット |
| create-pr | 現在のブランチから自動 push + `claude-auto` ラベル付きで PR を作成 |

### security

セキュリティレビュースキル: サプライチェーン、依存関係監査、脆弱性検出。

| スキル | 説明 |
|--------|------|
| supply-chain | サプライチェーンセキュリティ監査: lockfile 整合性、依存ピン留め、タイポスクワット検出、GitHub Actions SHA ピン留め、脆弱性スキャン設定 |

### agent-config

LLM コーディングエージェント設定: AGENTS.md の作成とツール固有の symlink 管理。

| スキル | 説明 |
|--------|------|
| agent-config-init | 統一 LLM コーディングエージェント設定の初期化（AGENTS.md）と Claude Code, Cursor, Copilot, Gemini CLI への symlink 作成 |

### terraform

Terraform のレビュー、セキュリティ、ベストプラクティス。

| スキル | 説明 |
|--------|------|
| tf-review | Terraform コードのベストプラクティスとよくある問題のレビュー |
| tf-security | IAM、ネットワーク、暗号化に焦点を当てた Terraform セキュリティレビュー |

## 開発

```bash
make bootstrap    # 依存関係のインストール
just lint         # リント実行
```

## バリデーション

```bash
claude plugin validate .
```

## ライセンス

個人利用のみ。
