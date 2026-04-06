# Check Categories

marketplace-lint で検証するルールカタログ。

## plugin.json 構造

| Rule ID | Severity | チェック内容 | 検出方法 |
|---------|----------|-------------|----------|
| PJ-001 | CRITICAL | plugin.json が存在しない | `plugins/{name}/.claude-plugin/plugin.json` の存在確認 |
| PJ-002 | HIGH | 必須フィールドの欠落 | `name`, `description`, `version` の存在確認 |
| PJ-003 | MEDIUM | version が semver 非準拠 | `X.Y.Z` 形式（数字.数字.数字）にマッチするか |
| PJ-004 | HIGH | name とディレクトリ名の不一致 | `plugin.json` の `name` と親ディレクトリ名を比較 |

## SKILL.md フォーマット

| Rule ID | Severity | チェック内容 | 検出方法 |
|---------|----------|-------------|----------|
| SK-001 | CRITICAL | SKILL.md が存在しない | `plugins/{plugin}/skills/{skill}/SKILL.md` の存在確認 |
| SK-002 | HIGH | フロントマターがない | ファイル先頭が `---` で始まり、2つ目の `---` で閉じられているか |
| SK-003 | HIGH | description フィールドがない | フロントマター YAML に `description` キーが存在するか |
| SK-004 | MEDIUM | description が空 | `description` の値が空文字列またはホワイトスペースのみ |
| SK-005 | LOW | 孤立した参照ファイル | `references/` 内のファイル名が SKILL.md 本文に出現しない |
| SK-006 | HIGH | 壊れた参照 | SKILL.md 本文で `references/` のファイルを参照しているが実ファイルがない |

## ディレクトリ構造

| Rule ID | Severity | チェック内容 | 検出方法 |
|---------|----------|-------------|----------|
| DS-001 | CRITICAL | plugin.json が存在しない | PJ-001 と同一（構造観点で再確認） |
| DS-002 | HIGH | 空プラグイン | `skills/` も `commands/` も存在しないプラグインディレクトリ |
| DS-003 | CRITICAL | スキルディレクトリに SKILL.md がない | SK-001 と同一（構造観点で再確認） |

## ドキュメント ↔ 実装の乖離

| Rule ID | Severity | チェック内容 | 検出方法 |
|---------|----------|-------------|----------|
| DD-001 | HIGH | ファイルに存在するが README に未記載 | 実ファイル一覧と README テーブルの差分（スキル） |
| DD-002 | HIGH | ファイルに存在するが README に未記載 | 実ファイル一覧と README テーブルの差分（コマンド） |
| DD-003 | HIGH | README に記載があるがファイルが存在しない | README テーブルと実ファイル一覧の差分（スキル） |
| DD-004 | HIGH | README に記載があるがファイルが存在しない | README テーブルと実ファイル一覧の差分（コマンド） |
| DD-005 | HIGH | 所属プラグインの不一致 | README での記載プラグインと実際のディレクトリの比較 |

## 多言語ドキュメント同期

| Rule ID | Severity | チェック内容 | 検出方法 |
|---------|----------|-------------|----------|
| ML-001 | MEDIUM | プラグイン一覧の差異 | README.md と docs/README.ja.md のプラグインセクション見出しを比較 |
| ML-002 | MEDIUM | スキル/コマンド一覧の差異 | 両 README のテーブル行を名前で突合 |
| ML-003 | MEDIUM | プラグイン数の不一致 | 両 README のプラグインセクション数を比較 |
