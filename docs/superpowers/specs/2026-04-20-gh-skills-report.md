# gh skills 代替可能性の検証レポート

- 作成日: 2026-04-20
- 対象: tqer39/claude-code-marketplace
- 検証者: Claude Code (Opus 4.7)
- gh バージョン: 2.90.0 (2026-04-16)

## 背景

`tqer39/claude-code-marketplace` は個人用 Claude Code プラグインマーケットプレイスとして、約 20 リポジトリで共通利用する skill / command / hook を一元配布している。

2026-04-16 に GitHub CLI 2.90.0 で `gh skill` が一般公開され、Open Agent Skills (OAS, `agentskills.io`) 準拠の skill をホスト横断で配布する仕組みが整った。Claude Code は公式サポート対象で、Copilot / Cursor / Codex / Gemini / Antigravity にもインストール先が用意されている。

本レポートは、本マーケットプレイスの「共通 skill 配布」役割の一部または全部が `gh skill` により代替可能かを、git:gitignore の PoC と残り 9 個の机上棚卸しで検証し、推奨方針を示す。

## 調査対象

- `gh skill` (GitHub CLI 2.90.0 組み込み、2026-04-16 GA)
  - 主要サブコマンド: `search` / `preview` / `install` / `update` / `publish`
  - `--agent` フラグで対象ホストを指定 (`claude-code` / `github-copilot` / `cursor` / `codex` / `gemini` / `antigravity`)
  - `--scope` で `project` / `user` を指定、`--dir` で任意ディレクトリ指定
  - `--pin` で git tag / SHA にバージョン固定、`--from-local` でローカルパスから install
- `gh-stack` (Stacked PR 管理拡張): Open Agent Skill 同梱の参考事例。本リポジトリとは領域が異なるため参考扱い。

## PoC: git:gitignore の OAS 移行検証

### 現行 SKILL.md の構造

```text
plugins/git/skills/gitignore/
├── SKILL.md
└── references/
    └── language-detection.md
```

frontmatter:

```yaml
---
name: gitignore
description: Generate and update .gitignore files using the gitignore.io API with automatic project detection. ...
---
```

### OAS 仕様とのギャップ

`gh skill install --help` および `gh skill publish --help` で確認した限り、OAS 必須 frontmatter は `name` と `description` のみ。`version` は任意（git tag で解決される）。ディレクトリ規約は `skills/{skill}/SKILL.md` で、`references/` `scripts/` `assets/` は任意のサブディレクトリとして認識される。

したがって現 SKILL.md は、frontmatter の追加・削除なしで OAS 互換。唯一の差分は配置規約にある。

本マーケットプレイスは `plugins/{scope}/skills/{skill}/SKILL.md` の 2 階層を採用しているのに対し、OAS は `skills/{skill}/SKILL.md` を既定とする。ただし `gh skill install` は `--dir` や明示パス指定で任意階層に対応できる。

### 変換後の SKILL.md（抜粋）

PoC では `/tmp/gh-skills-poc/skill-repo/skills/gitignore/SKILL.md` に現 SKILL.md をそのままコピー（frontmatter 変更なし）。install 実行時には `metadata.local-path` が `gh skill` によって自動注入される:

```yaml
---
description: Generate and update .gitignore files using the gitignore.io API with automatic project detection. ...
metadata:
    local-path: /tmp/gh-skills-poc/skill-repo/skills/gitignore
name: gitignore
---
```

### gh skill install 実行ログ

```text
$ gh skill install /tmp/gh-skills-poc/skill-repo gitignore \
    --from-local --agent claude-code --scope user \
    --dir /tmp/gh-skills-poc/install-target

! Skills are not verified by GitHub and may contain prompt injections, hidden instructions, or malicious scripts. Always review skill contents before use.

Installed gitignore (from /tmp/gh-skills-poc/skill-repo) in /tmp/gh-skills-poc/install-target

  gitignore/
  ├── SKILL.md
  └── references/
      └── language-detection.md
```

検証した `--pin` との併用:

```text
$ gh skill install /tmp/gh-skills-poc/skill-repo gitignore \
    --from-local --pin v0.1.0 ...

--from-local and --pin cannot be used together
```

`gh skill preview` のローカルパス試行:

```text
$ gh skill preview . gitignore
expected the "[HOST/]OWNER/REPO" format, got "."
```

### 検証結果

- **Install**: 成功。`--from-local` で任意ディレクトリから install 可能。`metadata.local-path` が SKILL.md に自動注入され、以後 `gh skill update` の追跡対象になる。
- **Preview**: 失敗。`gh skill preview` は GitHub の `OWNER/REPO` 形式のみ受け付け、ローカルパス非対応。
- **Pin**: ローカル install では `--pin` が使えない。バージョン固定は GitHub 上に push された repo + git tag が前提。
- **PoC 結論**: 現構造のままでも `gh skill install --from-local` は機能する。ただし `gh skill` のメリット（preview / pin / update の自動追跡）を享受するには、GitHub 上に独立 repo として公開する必要がある。

## 机上棚卸し

### 評価軸

- **OAS 適合度**: 高 = frontmatter / 構造が既に OAS 準拠、中 = 軽微な修正で準拠、低 = 本質的に非準拠
- **Command 依存**: SKILL.md 内で `/slash-command` 呼び出しを前提にしているか
- **Hook/MCP 依存**: plugin 配下の hook や MCP server を必要とするか
- **CC 固有ツール依存**: `EnterWorktree` / `Agent(subagent_type=...)` 等、Claude Code / Superpowers 固有ツールを要求するか
- **移行判定**: 移行可 / 併用推奨 / 移行不可

### 評価表

| skill | OAS 適合度 | Command 依存 | Hook/MCP 依存 | CC 固有ツール依存 | 外部リソース | 移行判定 | 根拠 |
|---|---|---|---|---|---|---|---|
| git:gitignore | 高 | なし | なし | なし | references 1 本 | 移行可 | PoC で `--from-local` install に成功 |
| git:pull-request | 高 | なし | なし | なし | references 1 本 | 移行可 | gh CLI 依存だが OAS 仕様の範囲内 |
| git:auto-merge | 高 | なし | なし | なし | references 1 本 | 移行可 | gh CLI とテンプレート yaml のみ |
| git:worktree | 中 | なし | なし | **あり** (`EnterWorktree` / `ExitWorktree`) | references 1 本 | 併用推奨 | Phase 1 Step 5 と Phase 2 Step 4 で CC 独自ツールを呼ぶ |
| architecture:editorconfig | 高 | なし | なし | なし | references 1 本 | 移行可 | `find` と対話のみ |
| architecture:redesign | 高 | なし | なし | **あり** (`Agent(subagent_type=Explore)`) | references 2 本 | 併用推奨 | Phase 1.2 で Claude Code の Agent tool を推奨 |
| marketplace:marketplace-lint | 高 | なし | なし | なし | references 1 本 | 移行可 | 汎用的なファイル走査 + glob |
| security:supply-chain | 高 | なし | なし | なし | なし | 移行可 | 完全にセルフコンテナ化 |
| agent-config:agent-config-init | 高 | なし | なし | なし | なし | 移行可 | テンプレートが SKILL.md 内に埋め込み |
| grill-me:grill-me | 高 | なし | なし | なし | なし | 移行可 | 13 行、純粋な対話ガイド |

### パターン分析

10 個中 8 個が OAS と dual-compatible だった。frontmatter を `name` + `description` のみに抑え、hook / MCP / command を skill 本文から呼ばず、外部リソースを `references/` に限定する設計が貢献している。例外は Claude Code 固有ツールに依存する 2 本で、これらはホスト固有の UX を活かすため本マーケットプレイス側に残すのが自然。

集計:

- 移行可: 8 / 10
- 併用推奨: 2 / 10
- 移行不可: 0 / 10

OAS のスコープ外の要素として以下がある:

- skill-matcher プラグイン（hook のみ、SKILL.md なし）
- git プラグインの 4 commands（auto-commit / create-branch / create-pr / push）

これらは本マーケットプレイスでしか配布できない。移行判定とは別建ての要素として整理する。

## 機能比較マトリクス

| 機能 | gh skill | 本マーケットプレイス | コメント |
|---|---|---|---|
| Skill 配布 | ○ | ○ | 両者とも可能。gh skill は OAS 準拠が前提 |
| Slash Command | ✕ | ○ | OAS スコープ外。Claude Code の `commands/*.md` は本マーケットプレイスでのみ配布可能 |
| Hook | ✕ | ○ | `UserPromptSubmit` 等の hook 登録は OAS 非対応 |
| MCP server 定義 | ✕ | ○ | MCP は OAS スコープ外 |
| プラグインバンドル | ✕ | ○ | plugin.json の概念は OAS にない |
| バージョン固定 | ○ (`--pin`) | △ | gh skill はタグ / SHA に pin 可能。本マーケットプレイスは git 参照の手動運用 |
| クロスエージェント配布 | ○ | ✕ | gh skill は Copilot / Cursor / Codex / Gemini / Antigravity にも install 可能 |
| 自動更新検出 | ○ (`gh skill update`) | ✕ | tree SHA 比較で remote 変更を検知 |
| Preview / ドライラン | ○ (`gh skill preview`) | ✕ | ただしローカルパス非対応、OWNER/REPO のみ |

## 推奨方針

### シナリオ比較

#### A. 完全移行（本マーケットプレイスを廃止し gh skill へ集約）

- 概要: 全 skill を OAS repo として公開し、各プロジェクトで `gh skill install` を使う
- メリット:
  - クロスエージェント配布が可能
  - `--pin` / `gh skill update` による厳密なバージョン管理
  - GitHub 公式エコシステムへの追従
- デメリット:
  - commands / hooks / MCP を配布できない（4 commands + skill-matcher hook が孤児化）
  - worktree / redesign の CC 固有ツール依存部分を書き換える必要あり
  - プラグイン単位での bundle 配布が不可能
- 移行コスト: 高
- blast radius: 大（~20 リポジトリの導入手順を書き換え）

#### B. 併用（skill は両方、commands / hooks は marketplace のみ）

- 概要: OAS 適合 skill は GitHub に OAS repo として公開しつつ本マーケットプレイスにも残す。Claude Code 固有機能は本マーケットプレイス専用
- メリット:
  - クロスエージェント配布のオプションを得られる
  - Claude Code 固有の価値（commands / hooks / CC ツール連携）を維持
  - 段階的移行が可能
- デメリット:
  - 2 箇所メンテで DRY 違反（CI で同期検証が要る）
  - ユーザー目線で導入経路が 2 つになる
- 移行コスト: 中
- blast radius: 中（CI 同期ロジックの追加が必要）

#### C. 現状維持

- 概要: gh skill は採用せず、本マーケットプレイスのみで配布を継続
- メリット:
  - 追加コストゼロ、学習コスト不要
  - commands / hooks / MCP をフル活用できる
- デメリット:
  - Claude Code 以外のエージェントで共有したくなったとき詰む
  - `--pin` 相当の厳密なバージョン管理は自力実装になる
- 移行コスト: 低
- blast radius: 小

### 推奨

**C. 現状維持** を推奨する。

### 根拠

1. **本マーケットプレイスの主要価値は Claude Code 固有機能の配布**。10 skill のうち 2 個は CC 固有ツール依存、さらに 4 commands と 1 hook は OAS スコープ外。完全移行すると重要な 7 要素を失う。
2. **個人用・~20 リポジトリ限定の運用**では、クロスエージェント配布の需要が薄く、gh skill のメリット（`--pin` / クロスホスト）が活きにくい。
3. **PoC で preview / pin にローカル非対応という制約が判明**。gh skill 連携には GitHub 公開 repo + tag 運用のオーバーヘッドが追加でかかり、DRY 違反のコストに見合わない。
4. **Open Agent Skills 仕様は新しく、現時点では様子見が妥当**。将来的に Copilot / Gemini への展開要件が出たタイミングで B に切り替える判断は、現行構造のまま実行可能（棚卸しで 8 / 10 が dual-compatible と確認済み）。

### 移行ロードマップ（将来 B を採用する場合のみ）

現状では実施しない。将来クロスエージェント配布の要件が発生した時点で以下を検討する。

- Phase 1: 移行可判定の 8 skill を対象に、`plugins/{scope}/skills/*/` から `skills/*/` への mirror 生成スクリプトを作成
- Phase 2: GitHub に OAS repo を 1 本作成し、上記 mirror を push
- Phase 3: 各プロジェクトで `gh skill install` の導入手順をドキュメント化

## 付録

### 参考リンク

- <https://github.blog/changelog/2026-04-16-manage-agent-skills-with-github-cli/>
- <https://github.com/github/gh-stack>
- <https://agentskills.io/>
- <https://agentskills.io/specification>

### PoC 作業ログ（/tmp 配下の要約）

- `/tmp/gh-skills-poc/oas-spec.md` — OAS 仕様メモ
- `/tmp/gh-skills-poc/gitignore-gap.md` — ギャップ分析
- `/tmp/gh-skills-poc/assessment.md` — 机上棚卸し原本
- `/tmp/gh-skills-poc/logs/environment.txt` — gh バージョン・認証状態
- `/tmp/gh-skills-poc/logs/subcommand-help.txt` — `gh skill {install,preview,publish} --help`
- `/tmp/gh-skills-poc/logs/install.txt` — `gh skill install --from-local` 実行ログ
- `/tmp/gh-skills-poc/logs/install-pin.txt` — `--pin` 併用エラー
- `/tmp/gh-skills-poc/logs/preview.txt` — `gh skill preview .` エラー
- `/tmp/gh-skills-poc/logs/poc-verdict.txt` — PoC 所見
- `/tmp/gh-skills-poc/skill-repo/` — PoC 用最小リポジトリ（次回マシン再起動で消える）

PoC 用の GitHub private repo は作成していないため削除作業は不要。
