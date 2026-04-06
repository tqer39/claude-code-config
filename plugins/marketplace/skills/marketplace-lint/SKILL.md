---
description: |
  Lint the Claude Code plugin marketplace for configuration issues, documentation drift,
  and structural inconsistencies. Checks plugin.json validity, SKILL.md format, directory structure,
  README sync, and multi-language documentation alignment.
  Use when validating marketplace integrity, before releasing updates, or after adding new plugins/skills.
  Triggers: "marketplace lint", "lint plugins", "check marketplace", "validate marketplace",
  "マーケットプレイスの検証", "プラグインのリント", "整合性チェック"
---

# Marketplace Lint

マーケットプレイスの構成・ドキュメント・構造の整合性を検証し、問題を報告する。

## Locale

会話で使われている言語に合わせる。曖昧な場合は日本語をデフォルトとする。

## ワークフロー

### 1. マーケットプレイスルートの検出

マーケットプレイスのルートディレクトリを特定する:

- `plugins/` ディレクトリが存在するか確認
- `README.md` と `docs/README.ja.md` の存在を確認

検出できない場合はエラーを報告して終了する。

### 2. プラグイン・スキル・コマンドの実態収集

`plugins/` 配下を走査し、実際のファイル構成を収集する:

- 各 `plugins/{name}/` ディレクトリ
- 各 `plugins/{name}/.claude-plugin/plugin.json` の内容
- 各 `plugins/{name}/skills/{skill}/SKILL.md` の存在とフロントマター
- 各 `plugins/{name}/skills/{skill}/references/` 内のファイル一覧
- 各 `plugins/{name}/commands/{cmd}.md` の存在

### 3. plugin.json 構造バリデーション

各プラグインの `.claude-plugin/plugin.json` を検証する。
ルール詳細は `references/check-categories.md` の「plugin.json 構造」セクションを参照。

チェック項目:

- ファイルが存在するか
- 必須フィールド（`name`, `description`, `version`）があるか
- `version` が semver（`X.Y.Z`）形式か
- `name` がディレクトリ名と一致するか

### 4. SKILL.md フォーマットバリデーション

各スキルの `SKILL.md` を検証する。
ルール詳細は `references/check-categories.md` の「SKILL.md フォーマット」セクションを参照。

チェック項目:

- スキルディレクトリに `SKILL.md` が存在するか
- `---` で囲まれた YAML フロントマターがあるか
- フロントマターに `description` フィールドがあり、空でないか
- `references/` 内のファイルが SKILL.md 本文で言及されているか（孤立ファイル検出）
- SKILL.md 本文で参照しているファイルが `references/` に実在するか（壊れた参照検出）

### 5. ディレクトリ構造チェック

各プラグインディレクトリを検証する。
ルール詳細は `references/check-categories.md` の「ディレクトリ構造」セクションを参照。

チェック項目:

- `.claude-plugin/plugin.json` が存在するか
- `skills/` または `commands/` のどちらかが存在するか（空プラグイン検出）
- 各スキルディレクトリ内に `SKILL.md` があるか

### 6. ドキュメント ↔ 実装の乖離チェック

README.md と docs/README.ja.md のプラグイン・スキル・コマンド一覧を解析し、実ファイルと突合する。
README のテーブルはマークダウンテーブル形式（`| name | description |`）で解析する。

チェック項目:

- **ファイルに存在するが README に未記載**: 実在するスキルまたはコマンドのうち README のテーブルに記載されていないもの
- **README に記載があるがファイルが存在しない**: README に記載のスキルまたはコマンドの実ファイルがない
- **所属プラグインの不一致**: README ではプラグイン A に記載されているが、実際はプラグイン B に存在する

### 7. 多言語ドキュメント同期チェック

README.md と docs/README.ja.md を比較する。
内容の翻訳品質は対象外。構造的な一致のみ検証する。

チェック項目:

- プラグイン一覧の差異（片方にしかないプラグイン）
- スキル/コマンド一覧の差異（片方にしかないスキルやコマンド）
- プラグイン数の不一致

## 出力フォーマット

```markdown
# Marketplace Lint Report

## Summary
- Critical: N 件
- High: N 件
- Medium: N 件
- Low: N 件

全 N プラグイン、N スキル、N コマンドを検証。

## Findings

### plugin.json 構造バリデーション

#### [HIGH] plugin.json の name とディレクトリ名が不一致
- **プラグイン:** {plugin-name}
- **plugin.json name:** `{json-name}`
- **ディレクトリ名:** `{dir-name}`

### SKILL.md フォーマットバリデーション

#### [HIGH] 壊れた参照ファイル
- **スキル:** {plugin}/{skill}
- **参照:** `references/{file}`（SKILL.md で言及されているがファイルが存在しない）

### ディレクトリ構造

#### [CRITICAL] plugin.json が存在しない
- **プラグイン:** {plugin-name}
- **期待パス:** `plugins/{plugin-name}/.claude-plugin/plugin.json`

### ドキュメント ↔ 実装の乖離

#### [HIGH] ファイルに存在するが README に未記載
- **対象:** {plugin}/commands/{cmd}.md
- **未記載の README:** README.md, docs/README.ja.md

#### [HIGH] 所属プラグインの不一致
- **README 記載:** {plugin-A} プラグインの {skill} スキル
- **実際の所在:** {plugin-B} プラグインの {skill} スキル

### 多言語ドキュメント同期

#### [MEDIUM] スキル一覧の差異
- **README.md のみ:** {skill}
- **docs/README.ja.md のみ:** {skill}

---

問題が 0 件の場合は「問題は検出されませんでした」と報告する。
```

## 注意事項

- 自動修正は行わない。発見事項と改善提案のみ報告する
- 実際にファイルを読んで確認した事実のみ報告する。推測で問題を報告しない
- 各 Finding にはプラグイン名・ファイルパス等の具体的な情報を含める
