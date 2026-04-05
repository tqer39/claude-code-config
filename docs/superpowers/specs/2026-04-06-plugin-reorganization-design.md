# プラグイン再編成 設計仕様書

## 概要

`common-ci` プラグインのスキルを適切なプラグインに再配置し、プラグインの境界を明確にする。

### 背景

- `common-ci` に `redesign`（アーキテクチャ分析）が含まれており、CI/CD と無関係
- `pull-request` / `auto-merge` は Git ワークフローであり `git` プラグインと重複領域
- `marketplace-lint` はマーケットプレイス固有のスキルで独立すべき
- プラグインの凝集性を高め、利用者が直感的にスキルを見つけられるようにする

## 変更内容

### 1. `common-ci` プラグインを廃止

`plugins/common-ci/` ディレクトリを削除する。

### 2. `architecture` プラグインを新規作成

`plugins/architecture/` を作成し、`redesign` スキルを移動する。

```
plugins/architecture/
├── .claude-plugin/
│   └── plugin.json
└── skills/
    └── redesign/
        ├── SKILL.md
        └── references/
            ├── analysis-patterns.md
            └── output-template.md
```

**plugin.json:**
- name: `architecture`
- description: アーキテクチャ分析・再設計スキル

### 3. `marketplace` プラグインを新規作成

`plugins/marketplace/` を作成し、`marketplace-lint` スキルを移動する。

```
plugins/marketplace/
├── .claude-plugin/
│   └── plugin.json
└── skills/
    └── marketplace-lint/
        └── SKILL.md
```

**plugin.json:**
- name: `marketplace`
- description: マーケットプレイスの検証・管理スキル

### 4. `git` プラグインにスキルを統合

`pull-request` と `auto-merge` スキルを `plugins/git/skills/` に移動する。

```
plugins/git/skills/
├── gitignore/          # 既存
├── pull-request/       # common-ci から移動
└── auto-merge/         # common-ci から移動
```

`git` プラグインの `plugin.json` の description を更新し、PR・マージ関連スキルを含むことを反映する。

### 5. `marketplace.json` を更新

`.claude-plugin/marketplace.json` から `common-ci` を削除し、`architecture` と `marketplace` を追加する。

### 6. ドキュメント更新

- `README.md` のプラグイン一覧テーブルを更新
- `docs/README.ja.md` のプラグイン一覧テーブルを更新

## 再編成後のプラグイン構成

| プラグイン | スキル/コマンド | 説明 |
|-----------|---------------|------|
| **git** | auto-commit, create-branch, create-pr, push, gitignore, pull-request, auto-merge | Git ワークフロー全般 |
| **architecture** | redesign | アーキテクチャ分析・再設計 |
| **marketplace** | marketplace-lint | マーケットプレイス検証 |
| **security** | supply-chain | セキュリティ監査 |
| **terraform** | tf-review, tf-security | Terraform レビュー |
| **agent-config** | agent-config-init | LLM エージェント設定 |

## 変更対象ファイル

- `plugins/common-ci/` — 削除
- `plugins/architecture/` — 新規作成
- `plugins/marketplace/` — 新規作成
- `plugins/git/skills/pull-request/` — common-ci から移動
- `plugins/git/skills/auto-merge/` — common-ci から移動
- `plugins/git/.claude-plugin/plugin.json` — description 更新
- `.claude-plugin/marketplace.json` — プラグイン登録の更新
- `README.md` — プラグイン一覧の更新
- `docs/README.ja.md` — プラグイン一覧の更新

## 検証方法

1. `claude plugin validate .` でマーケットプレイスのバリデーションが通ること
2. 各プラグインの `plugin.json` が正しいフォーマットであること
3. 移動したスキルのファイルが全て揃っていること
4. `README.md` / `README.ja.md` の記載が新構成と一致すること
