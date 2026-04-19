# gh skills 代替可能性の検証レポート 設計書

- 作成日: 2026-04-20
- 対象: tqer39/claude-code-marketplace
- ステータス: 設計（未実装）

## 背景

`tqer39/claude-code-marketplace` は個人用 Claude Code プラグインマーケットプレイスとして、~20 リポジトリで共通利用する skill/command/hook/MCP 設定を一元配布している。

2026-04-16 に GitHub CLI から `gh skill` が一般公開され、Open Agent Skills (agentskills.io) 仕様準拠の skill をホスト横断で配布する仕組みが整った。Claude Code は公式サポート対象。同時期に `gh-stack` 拡張も Open Agent Skill を同梱して配布されている。

本プロジェクトの「共通 skill 配布」という役割の一部または全部が `gh skill` によって代替可能かを検証し、推奨方針を決定する。

## 調査対象

- `gh skill` (GitHub CLI 組み込みコマンド, 2026-04-16 GA)
  - 主要サブコマンド: `search` / `install` / `update` / `publish`
  - `--agent claude-code` で Claude Code 向けインストール
  - `--pin` でバージョン固定、content-addressed な変更検出
- `gh-stack` (Stacked PR 管理拡張)
  - Open Agent Skill を同梱し `npx skills add github/gh-stack` で導入可能
  - 本リポジトリとは領域が異なる（stacked PR 特化）ため参考扱い

## 調査スコープ

### PoC（ハンズオン）

- 対象 skill: `plugins/git/skills/gitignore/`
- 選定理由: ファイル生成系で自己完結、外部依存・対話性が低く仕様適合検証に最適
- 検証作業（本リポジトリには残さない）:
  1. 現 `SKILL.md` を読み、Open Agent Skills 仕様とのギャップを列挙
  2. 一時ディレクトリ（例: `/tmp/gh-skills-poc/`）に最小リポを作成し OAS 準拠版 `SKILL.md` を配置
  3. `gh skill install <tmp-repo> gitignore --agent claude-code` を実行して導入成否を確認
  4. Claude Code セッションから呼び出し可能か確認
  5. `--pin` と `gh skill update` の挙動を確認
- 記録項目: コマンド出力、発生エラー、差分、所要時間

### 机上棚卸し（残り 8 skill）

評価軸（5 軸）:

| 軸 | 判定内容 |
|---|---|
| OAS 仕様適合度 | frontmatter/構造の変換難度（低・中・高） |
| Command 依存 | slash command 呼び出しが必須か |
| Hook/MCP 依存 | plugin.json の機能に依存しているか |
| 外部リソース依存 | `scripts/` `assets/` 等の同梱が必要か |
| 移行判定 | 移行可 / 併用推奨 / 移行不可 |

対象 skill:

- `git:pull-request`
- `git:auto-merge`
- `architecture:editorconfig`
- `architecture:redesign`
- `marketplace:marketplace-lint`
- `security:supply-chain`
- `agent-config:agent-config-init`
- `grill-me`（外部由来 / mattpocock/skills）

## 成果物

レポートを以下のパスに 1 本追加する:

`docs/superpowers/specs/2026-04-20-gh-skills-report.md`

構成:

```text
# gh skills 代替可能性の検証レポート

## 背景
- 現マーケットプレイスの役割
- gh skill / gh-stack リリースの要点

## 調査対象
- gh skill
- gh-stack

## PoC: git:gitignore の OAS 移行検証
- 現行 SKILL.md の構造
- OAS 仕様とのギャップ
- 変換後の SKILL.md（抜粋）
- gh skill install 実行ログ
- 検証結果: ✓/✗

## 机上棚卸し
- 9 skill の評価表（上記 5 軸）

## 機能比較マトリクス
- Skill / Command / Hook / MCP / Plugin bundle の代替可否

## 推奨方針
- 3 シナリオ（完全移行 / 併用 / 現状維持）の trade-off
- 推奨: どれを採るか + 根拠
- 移行ロードマップ（採用する場合のみ）

## 付録
- 参考リンク
- PoC で残したファイル / 捨てたファイル
```

## 受け入れ基準

- PoC セクションに実行したコマンドの **実出力** が貼られている（fabrication 禁止）
- 9 skill すべてが棚卸し表に含まれる
- 推奨方針が 1 つに絞られ、根拠（blast radius / 移行コスト / 将来性）が明示されている
- レポートファイル追加の 1 コミットで完結し、`plugins/` 配下を変更しない

## 非スコープ

- 既存 skill の書き換え・置き換え
- 新規プラグインの追加
- `gh-stack` 自体の導入検討（参考情報のみ）
- 他エージェント（Copilot/Gemini）向け配布検証

## リスクと前提

- `gh` CLI のバージョン依存: 検証時にバージョンを明記する
- PoC 用の tmp リポジトリは GitHub に push する必要がある可能性 → 最小 private repo で対応、結果的に削除
- Open Agent Skills 仕様は新しいため、ドキュメント更新に追随する必要あり
