# tqer39-plugins

Claude Code 用の個人 SRE/DevOps プラグインマーケットプレイス。

## 概要

約20の個人リポジトリに共通スキル・コマンドを配布するための一元管理マーケットプレイス。[Claude Code Plugin Marketplace](https://code.claude.com/docs/en/plugin-marketplaces) システムを利用。

## インストール

```bash
# マーケットプレイスを追加
/plugin marketplace add tqer39/claude-code-marketplace

# プラグインをインストール
/plugin install git@tqer39-plugins
/plugin install architecture@tqer39-plugins
/plugin install marketplace@tqer39-plugins
/plugin install security@tqer39-plugins
/plugin install agent-config@tqer39-plugins
/plugin install grill-me@tqer39-plugins
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
/plugin install git@tqer39-plugins

# project スコープ（チーム共有、.claude/settings.json に記録）
/plugin install git@tqer39-plugins --scope project

# local スコープ（自分、このプロジェクトのみ）
/plugin install git@tqer39-plugins --scope local
```

### プラグインの管理

```bash
# 利用可能なプラグインを一覧表示
/plugin

# アンインストールせずに有効/無効を切り替え
/plugin enable git@tqer39-plugins
/plugin disable git@tqer39-plugins

# アンインストール
/plugin uninstall git@tqer39-plugins

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
    "git@tqer39-plugins": true,
  }
}
```

## プラグイン

### git

Git ワークフローコマンド・スキル。

| 種類 | 名前 | 説明 |
|------|------|------|
| コマンド | auto-commit | 絵文字プレフィックス + 日本語要約で自動ステージング・コミット |
| コマンド | create-branch | 命名規則に基づくフィーチャーブランチの作成 |
| コマンド | create-pr | 現在のブランチから自動 push + `claude-auto` ラベル付きで PR を作成 |
| コマンド | push | 安全チェック付きでリモートに push |
| スキル | gitignore | プロジェクト自動検出による .gitignore の生成・更新 |
| スキル | pull-request | GitHub PR ワークフローの自動化（rebase、コンフリクト解決、説明文生成） |
| スキル | auto-merge | `claude-auto` ラベル付き PR の自動承認・自動マージワークフロー生成 |

### architecture

アーキテクチャ分析・再設計提案スキル。

| スキル | 説明 |
|--------|------|
| redesign | アーキテクチャ分析と再設計提案ワークフロー |
| editorconfig | ファイルタイプ自動検出による .editorconfig の生成・更新 |

### marketplace

マーケットプレイス検証・管理スキル。

| スキル | 説明 |
|--------|------|
| marketplace-lint | マーケットプレイスの設定不備・ドキュメント齟齬・構造の整合性を検証 |

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

### grill-me

計画や設計を stress-test する Socratic 型インタビュースキル。決定木の各分岐について 1 問ずつ質問し、共通理解に到達させる。

| スキル | 説明 |
|--------|------|
| grill-me | ユーザーに計画や設計について徹底インタビューし、決定木の各分岐を辿って共通理解に至らせる |

Upstream: [mattpocock/skills](https://github.com/mattpocock/skills) (MIT License)。

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
