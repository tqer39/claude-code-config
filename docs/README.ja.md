# tqer39-plugins

Claude Code 用の個人 SRE/DevOps プラグインマーケットプレイス。

## 概要

約20の個人リポジトリに共通スキル・コマンドを配布するための一元管理マーケットプレイス。[Claude Code Plugin Marketplace](https://code.claude.com/docs/en/plugin-marketplaces) システムを利用。

## インストール

```bash
# マーケットプレイスを追加
claude plugin marketplace add tqer39/claude-code-marketplace

# プラグインをインストール
claude plugin install common-ci@tqer39-plugins
claude plugin install terraform@tqer39-plugins
claude plugin install python-uv@tqer39-plugins
```

## プラグイン

### common-ci

全リポジトリ共通の CI/CD スキル。

| スキル | 説明 |
|--------|------|
| pull-request | GitHub PR ワークフローの自動化（rebase、コンフリクト解決、説明文生成） |
| pr-review | PR のクオリティ、セキュリティ、規約準拠レビュー |
| commit-convention | Conventional Commits 形式の強制とコミットメッセージ提案 |
| github-actions | GitHub Actions ワークフローのベストプラクティスとトラブルシューティング |
| gitignore | プロジェクト自動検出による .gitignore の生成・更新 |
| agent-config-init | 統一 LLM コーディングエージェント設定の初期化（AGENTS.md） |
| redesign | アーキテクチャ分析と再設計提案ワークフロー |

### terraform

Terraform のレビュー、セキュリティ、ベストプラクティス。

| スキル | 説明 |
|--------|------|
| tf-review | Terraform コードのベストプラクティスとよくある問題のレビュー |
| tf-security | IAM、ネットワーク、暗号化に焦点を当てた Terraform セキュリティレビュー |

### python-uv

Python + uv ワークフローとサプライチェーンセキュリティ。

| スキル | 説明 |
|--------|------|
| uv-workflow | uv パッケージマネージャを使用した Python プロジェクトワークフロー |
| supply-chain-security | Python/PyPI サプライチェーンセキュリティチェックと依存関係監査 |

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
