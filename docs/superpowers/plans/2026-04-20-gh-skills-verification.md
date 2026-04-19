# gh skills 代替可能性の検証 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** `gh skill` (GitHub CLI 2.90.0) が本マーケットプレイスの共通 skill 配布役割を代替できるかを検証する。`git:gitignore` の実機 PoC と残り 8 skill の机上棚卸しを 1 本のレポートにまとめる。

**Architecture:** 検証用の一時リポジトリは `/tmp/gh-skills-poc/` に作成する。ローカルパス install が不可なら private repo にフォールバック。最終成果物は `docs/superpowers/specs/2026-04-20-gh-skills-report.md` の 1 ファイルのみ。`plugins/` 配下は変更しない。

**Tech Stack:** GitHub CLI 2.90.0 (`gh skill`), Open Agent Skills (agentskills.io), bash, markdown.

**Spec:** `docs/superpowers/specs/2026-04-20-gh-skills-design.md`

---

## File Structure

### 作成

- `docs/superpowers/plans/2026-04-20-gh-skills-verification.md` — 本プラン（既に作成済み）
- `docs/superpowers/specs/2026-04-20-gh-skills-report.md` — 最終レポート
- `/tmp/gh-skills-poc/` — PoC 用作業ディレクトリ（コミット対象外）
  - `/tmp/gh-skills-poc/oas-spec.md` — OAS 仕様メモ
  - `/tmp/gh-skills-poc/gitignore-gap.md` — 現 SKILL.md と OAS のギャップ
  - `/tmp/gh-skills-poc/skill-repo/` — OAS 準拠版 skill の最小 Git リポジトリ
  - `/tmp/gh-skills-poc/logs/` — 実行ログ

### 変更しない

- `plugins/**` — 既存プラグインは一切変更しない
- `.claude-plugin/marketplace.json`
- 他プロジェクトファイル

---

## Task 1: 環境確認と作業ディレクトリ準備

**Files:**

- Create: `/tmp/gh-skills-poc/` (ディレクトリ)
- Create: `/tmp/gh-skills-poc/logs/environment.txt`

- [ ] **Step 1: `gh` バージョンと `gh skill` サブコマンドの存在を確認**

```bash
gh --version
gh skill --help
```

Expected:

- `gh version 2.90.0` 以降
- `AVAILABLE COMMANDS` に `install` / `publish` / `search` / `update` / `preview` が含まれる

- [ ] **Step 2: 作業ディレクトリを作成し環境情報を保存**

```bash
mkdir -p /tmp/gh-skills-poc/logs /tmp/gh-skills-poc/skill-repo
{
  echo "=== Date ==="
  date
  echo
  echo "=== gh version ==="
  gh --version
  echo
  echo "=== gh skill help ==="
  gh skill --help
  echo
  echo "=== gh auth status ==="
  gh auth status 2>&1
} > /tmp/gh-skills-poc/logs/environment.txt
cat /tmp/gh-skills-poc/logs/environment.txt
```

Expected: `environment.txt` に gh バージョン・サブコマンド一覧・認証状態が記録される。

- [ ] **Step 3: コミット不要（`/tmp` 配下のためバージョン管理対象外）**

このタスクはコミットしない。以降のタスクも `/tmp` 配下の操作はコミットしない。

---

## Task 2: Open Agent Skills 仕様の調査

**Files:**

- Create: `/tmp/gh-skills-poc/oas-spec.md`

- [ ] **Step 1: `gh skill publish --help` と `gh skill install --help` から仕様要件を抽出**

```bash
{
  echo "=== gh skill publish ==="
  gh skill publish --help
  echo
  echo "=== gh skill install ==="
  gh skill install --help
  echo
  echo "=== gh skill preview ==="
  gh skill preview --help
} > /tmp/gh-skills-poc/logs/subcommand-help.txt
cat /tmp/gh-skills-poc/logs/subcommand-help.txt
```

Expected: サブコマンドの flag 一覧と必須引数が得られる。

- [ ] **Step 2: agentskills.io 仕様を Web で取得**

WebFetch ツールで以下を取得し、`SKILL.md` frontmatter の必須項目と任意項目を抽出:

- `https://agentskills.io/`（トップ）
- `https://agentskills.io/spec` もしくは同等のパス（実在しない場合は `gh skill publish --help` の出力のみで代替）

要約を `/tmp/gh-skills-poc/oas-spec.md` に保存。最低限以下を明記:

- 必須 frontmatter フィールド（name, description, version など）
- 任意 frontmatter フィールド
- ディレクトリ構造の規約（`SKILL.md` の位置、`references/`, `scripts/`, `assets/` の扱い）
- `--pin` / content-addressed の仕組み

- [ ] **Step 3: 仕様メモを確認（目視）**

`/tmp/gh-skills-poc/oas-spec.md` を読み返し、次タスクでギャップ分析に使える粒度であることを確認。

---

## Task 3: 現 git:gitignore SKILL.md とのギャップ分析

**Files:**

- Read: `plugins/git/skills/gitignore/SKILL.md`
- Read: `plugins/git/skills/gitignore/references/language-detection.md`
- Create: `/tmp/gh-skills-poc/gitignore-gap.md`

- [ ] **Step 1: 現 SKILL.md の frontmatter と構造を記録**

```bash
head -5 plugins/git/skills/gitignore/SKILL.md > /tmp/gh-skills-poc/logs/current-frontmatter.txt
ls -la plugins/git/skills/gitignore/ >> /tmp/gh-skills-poc/logs/current-frontmatter.txt
cat /tmp/gh-skills-poc/logs/current-frontmatter.txt
```

Expected: 現 frontmatter は `name` と `description` の 2 フィールドのみ。参照フォルダは `references/`。

- [ ] **Step 2: ギャップを markdown 表形式で記録**

`/tmp/gh-skills-poc/gitignore-gap.md` に以下の構造で書く:

```markdown
# git:gitignore → Open Agent Skills ギャップ分析

## frontmatter 差分

| フィールド | 現行 | OAS 仕様 | アクション |
|---|---|---|---|
| name | あり | 必須 | そのまま |
| description | あり | 必須 | そのまま |
| version | なし | （確認結果を記載） | 追加 or 不要 |
| ... | ... | ... | ... |

## ディレクトリ構造差分

（current vs OAS の差を列挙）

## 移行に必要な変更まとめ

（箇条書き）
```

- [ ] **Step 3: ギャップ分析ファイルを目視確認**

このファイルは次タスク（OAS 準拠版 skill の作成）の入力になるので、欠落なく埋まっていることを確認。

---

## Task 4: OAS 準拠版 SKILL.md を一時リポジトリに作成

**Files:**

- Create: `/tmp/gh-skills-poc/skill-repo/SKILL.md`
- Create: `/tmp/gh-skills-poc/skill-repo/references/language-detection.md`（現行からコピー）
- Create: `/tmp/gh-skills-poc/skill-repo/README.md`

- [ ] **Step 1: Git リポジトリを初期化**

```bash
cd /tmp/gh-skills-poc/skill-repo
git init -b main
```

Expected: `Initialized empty Git repository in /tmp/gh-skills-poc/skill-repo/.git/`

- [ ] **Step 2: OAS 準拠版 SKILL.md を作成**

Task 3 のギャップ分析結果を反映し、以下の要領で `/tmp/gh-skills-poc/skill-repo/SKILL.md` を書く。現行本文はそのまま流用、frontmatter のみ OAS 仕様に合わせる:

```markdown
---
name: gitignore
description: Generate and update .gitignore files using the gitignore.io API with automatic project detection.
version: 0.1.0
# (Task 2/3 で確認した OAS 必須フィールドをすべて埋める)
---

# gitignore

（現行 SKILL.md の本文をそのままコピー）
```

- [ ] **Step 3: references/ をコピー**

```bash
mkdir -p /tmp/gh-skills-poc/skill-repo/references
cp -v /Users/takeruooyama/workspace/tqer39/claude-code-marketplace/.claude/worktrees/ancient-giggling-quasar/plugins/git/skills/gitignore/references/*.md /tmp/gh-skills-poc/skill-repo/references/
ls -la /tmp/gh-skills-poc/skill-repo/references/
```

Expected: `language-detection.md` がコピーされる。

- [ ] **Step 4: 最小 README を追加して commit**

```bash
cd /tmp/gh-skills-poc/skill-repo
cat > README.md <<'EOF'
# gitignore skill (OAS PoC)

Open Agent Skills 形式への移行検証用。
EOF
git add -A
git commit -m "init: OAS-compliant gitignore skill for PoC"
```

Expected: 1 コミットで `SKILL.md`, `references/language-detection.md`, `README.md` が含まれる。

- [ ] **Step 5: Git tag を付与（`--pin` 検証のため）**

```bash
cd /tmp/gh-skills-poc/skill-repo
git tag v0.1.0
git log --oneline --decorate
```

Expected: タグ `v0.1.0` が HEAD に付く。

---

## Task 5: `gh skill preview` でローカル検証

**Files:**

- Create: `/tmp/gh-skills-poc/logs/preview.txt`

- [ ] **Step 1: ローカルリポジトリを対象に preview を実行**

```bash
cd /tmp/gh-skills-poc/skill-repo
gh skill preview . gitignore 2>&1 | tee /tmp/gh-skills-poc/logs/preview.txt
```

Expected: 成功なら skill メタデータが表示される。失敗ならエラー内容をログに残す。

備考: `gh skill preview` がローカルパスを受け付けない場合、Step 2 にスキップして GitHub 上の private repo で検証する方針に切り替える。判断はログ内容を見て行う。

- [ ] **Step 2: エラー解析とフォールバック判断**

`preview.txt` の内容に応じて以下のいずれかに進む:

- **成功**: Task 6 (install 検証) へ進む
- **ローカルパス不可のエラー**: Task 5.1 (GitHub push フォールバック) を実施
- **frontmatter 不足エラー**: Task 4 Step 2 に戻って修正し、Task 5 Step 1 を再実行

判断結果を `/tmp/gh-skills-poc/logs/preview-decision.txt` にメモ。

---

## Task 5.1: （フォールバック）GitHub private repo 経由で検証

Task 5 でローカルパス不可と判断された場合のみ実施。それ以外はスキップ。

**Files:**

- Create: `/tmp/gh-skills-poc/logs/github-push.txt`

- [ ] **Step 1: 検証用 private repo を作成**

```bash
cd /tmp/gh-skills-poc/skill-repo
gh repo create tqer39/gh-skills-poc-gitignore --private --source=. --push 2>&1 | tee /tmp/gh-skills-poc/logs/github-push.txt
```

Expected: private repo が作成され、`main` ブランチが push される。

- [ ] **Step 2: タグを push**

```bash
git push origin v0.1.0 2>&1 | tee -a /tmp/gh-skills-poc/logs/github-push.txt
```

Expected: タグ `v0.1.0` が origin に push される。

- [ ] **Step 3: 後始末メモ**

レポート提出後に repo を削除する旨を `/tmp/gh-skills-poc/logs/cleanup-todo.txt` に記録:

```bash
echo "DELETE AFTER REPORT: gh repo delete tqer39/gh-skills-poc-gitignore --yes" > /tmp/gh-skills-poc/logs/cleanup-todo.txt
```

---

## Task 6: `gh skill install` 実機検証

**Files:**

- Create: `/tmp/gh-skills-poc/logs/install.txt`

- [ ] **Step 1: Claude Code 向けインストールを実行**

ソース指定は Task 5 / 5.1 の結果に応じて以下のいずれか:

- ローカルパス版: `gh skill install /tmp/gh-skills-poc/skill-repo gitignore --agent claude-code`
- GitHub 版: `gh skill install tqer39/gh-skills-poc-gitignore gitignore --agent claude-code`

```bash
gh skill install <SOURCE> gitignore --agent claude-code 2>&1 | tee /tmp/gh-skills-poc/logs/install.txt
```

Expected: 成功なら Claude Code の skill ディレクトリ（`~/.claude/skills/` 等）に配置される。失敗ならエラー理由をログに残す。

- [ ] **Step 2: インストール先を特定**

```bash
{
  echo "=== find potential install locations ==="
  ls -la ~/.claude/skills/ 2>&1
  ls -la ~/.claude/plugins/ 2>&1 | head -20
  find ~/.claude -name 'SKILL.md' -path '*gitignore*' 2>/dev/null
} | tee -a /tmp/gh-skills-poc/logs/install.txt
```

Expected: OAS 版 SKILL.md のパスが特定できる。

- [ ] **Step 3: `--pin` の動作確認**

```bash
gh skill install <SOURCE> gitignore --agent claude-code --pin v0.1.0 2>&1 | tee /tmp/gh-skills-poc/logs/install-pin.txt
```

Expected: タグでバージョン固定される or 既にインストール済みとの警告。

- [ ] **Step 4: `gh skill update` の動作確認**

まず skill-repo に変更とタグ v0.1.1 を追加:

```bash
cd /tmp/gh-skills-poc/skill-repo
echo "# v0.1.1 test change" >> SKILL.md
git add SKILL.md
git commit -m "test: bump for update check"
git tag v0.1.1
# GitHub 版の場合は push も必要
git push origin main v0.1.1 2>&1 || true
```

その後:

```bash
gh skill update 2>&1 | tee /tmp/gh-skills-poc/logs/update.txt
```

Expected: v0.1.0 pin されたものは据え置き、pin なしのものは更新を検出。

---

## Task 7: Claude Code からの呼び出し確認

**Files:**

- Create: `/tmp/gh-skills-poc/logs/claude-invocation.txt`

- [ ] **Step 1: インストールされた SKILL.md の内容を確認**

Task 6 Step 2 で特定したパスを対象に:

```bash
cat <INSTALLED_PATH>/SKILL.md | head -20 > /tmp/gh-skills-poc/logs/claude-invocation.txt
```

Expected: frontmatter と skill 本文の冒頭が確認できる。

- [ ] **Step 2: Claude Code セッション内の skill 一覧に出現するかを観測**

本タスクは別セッション or 別ターミナルでの Claude Code 起動が必要。実施不可の場合は「未検証」として `/tmp/gh-skills-poc/logs/claude-invocation.txt` に明記し、レポートでも正直にそう記載する。

実施できる場合:

- 新規 Claude Code セッションで `/skills` もしくは Skill tool 一覧に `gitignore` が現れるか確認
- 確認結果を `/tmp/gh-skills-poc/logs/claude-invocation.txt` に追記

- [ ] **Step 3: PoC 結論を 1 行でまとめる**

`/tmp/gh-skills-poc/logs/poc-verdict.txt` に以下のフォーマットで書く:

```text
Verdict: <成功 | 部分成功 | 失敗>
Blocker: <成功の場合は "なし", それ以外はブロッカーの 1 行要約>
Notes: <補足 1-2 行>
```

---

## Task 8: 残り 8 skill の机上棚卸し

**Files:**

- Read: `plugins/git/skills/pull-request/SKILL.md`
- Read: `plugins/git/skills/auto-merge/SKILL.md`
- Read: `plugins/architecture/skills/editorconfig/SKILL.md`
- Read: `plugins/architecture/skills/redesign/SKILL.md`
- Read: `plugins/marketplace/skills/marketplace-lint/SKILL.md`
- Read: `plugins/security/skills/supply-chain/SKILL.md`
- Read: `plugins/agent-config/skills/agent-config-init/SKILL.md`
- Read: `plugins/grill-me/skills/*/SKILL.md`（実際のパスは `ls` で確認）
- Create: `/tmp/gh-skills-poc/assessment.md`

- [ ] **Step 1: 全 skill の SKILL.md を列挙**

```bash
cd /Users/takeruooyama/workspace/tqer39/claude-code-marketplace/.claude/worktrees/ancient-giggling-quasar
find plugins -name 'SKILL.md' | tee /tmp/gh-skills-poc/logs/all-skills.txt
```

Expected: 9 個の `SKILL.md` パスが列挙される（git:gitignore 含む）。

- [ ] **Step 2: 評価表のテンプレートを作成**

`/tmp/gh-skills-poc/assessment.md` を以下の構造で初期化:

```markdown
# 机上棚卸し結果

## 評価軸

- OAS 仕様適合度: 低/中/高 （変換難度）
- Command 依存: あり/なし
- Hook/MCP 依存: あり/なし
- 外部リソース: あり/なし（scripts/ assets/ 等）
- 移行判定: 移行可 / 併用推奨 / 移行不可

## 評価表

| skill | OAS 適合度 | Command 依存 | Hook/MCP 依存 | 外部リソース | 移行判定 | 根拠 |
|---|---|---|---|---|---|---|
| git:gitignore | （PoC 結果） | なし | なし | references のみ | （PoC 結果） | PoC で検証 |
| git:pull-request | | | | | | |
| git:auto-merge | | | | | | |
| architecture:editorconfig | | | | | | |
| architecture:redesign | | | | | | |
| marketplace:marketplace-lint | | | | | | |
| security:supply-chain | | | | | | |
| agent-config:agent-config-init | | | | | | |
| grill-me | | | | | | |
```

- [ ] **Step 3: 8 skill の SKILL.md を読んで表を埋める**

各 SKILL.md を `Read` で読み、frontmatter・依存している command/hook/MCP・`references/` `scripts/` の有無を確認して表を埋める。Command 依存の判定基準は「SKILL.md 内で `/command-name` の呼び出しを前提にしているか」。Hook/MCP 依存は「plugin.json や `.claude/settings.json` に登録された hook/MCP を必要とするか」。

各判定の「根拠」列に 1 文の理由を記載。

- [ ] **Step 4: 集計して統計を追記**

`assessment.md` 末尾に以下を追記:

```markdown
## 集計

- 移行可: X / 9
- 併用推奨: Y / 9
- 移行不可: Z / 9

## パターン分析

（移行不可が多い理由、併用が妥当な理由、等を 2-3 文で）
```

---

## Task 9: レポート骨格の作成

**Files:**

- Create: `docs/superpowers/specs/2026-04-20-gh-skills-report.md`

- [ ] **Step 1: レポートの骨格を書き出す**

`docs/superpowers/specs/2026-04-20-gh-skills-report.md` を以下の章立てで作成（本文は次タスク以降で埋める）:

```markdown
# gh skills 代替可能性の検証レポート

- 作成日: 2026-04-20
- 対象: tqer39/claude-code-marketplace
- 検証者: （実行者名）
- gh バージョン: （Task 1 の結果）

## 背景

（spec の背景を要約）

## 調査対象

- gh skill (2026-04-16 GA, preview)
- gh-stack（参考扱い）

## PoC: git:gitignore の OAS 移行検証

### 現行 SKILL.md の構造

### OAS 仕様とのギャップ

### 変換後の SKILL.md（抜粋）

### gh skill install 実行ログ

### 検証結果

## 机上棚卸し

### 評価軸

### 評価表

### パターン分析

## 機能比較マトリクス

| 機能 | gh skill | 本マーケットプレイス |
|---|---|---|
| Skill 配布 | | |
| Slash Command | | |
| Hook | | |
| MCP server 定義 | | |
| プラグインバンドル | | |
| バージョン固定 | | |

## 推奨方針

### シナリオ比較

- A. 完全移行
- B. 併用
- C. 現状維持

### 推奨

### 根拠

### 移行ロードマップ（推奨採用時のみ）

## 付録

### 参考リンク

### PoC 作業ログ（/tmp 配下の要約）
```

Expected: ファイルが作成され、章立てだけ埋まっている状態。

- [ ] **Step 2: 内容なしで commit しない**

このタスク単独ではコミットしない。Task 11 の最終 commit でまとめて入れる。

---

## Task 10: レポート本文を埋める

**Files:**

- Modify: `docs/superpowers/specs/2026-04-20-gh-skills-report.md`

- [ ] **Step 1: 背景・調査対象セクションを埋める**

spec (`2026-04-20-gh-skills-design.md`) の該当箇所を引用・要約して本文を書く。参考リンクは本文中ではなく「付録 > 参考リンク」に集約。

- [ ] **Step 2: PoC セクションを埋める**

`/tmp/gh-skills-poc/` の各ログから以下を引用:

- 現行 SKILL.md frontmatter: `logs/current-frontmatter.txt`
- ギャップ: `gitignore-gap.md`
- 変換後 SKILL.md 冒頭 30 行: `skill-repo/SKILL.md`
- install 実行ログ: `logs/install.txt`（fabrication 禁止、実際の出力をそのまま貼る）
- 検証結果: `logs/poc-verdict.txt`

コードブロックは ```` ```text ```` で囲み、長大なログは関連 20 行に絞る（省略箇所は `... (中略) ...` と明記）。

- [ ] **Step 3: 机上棚卸しセクションを埋める**

`/tmp/gh-skills-poc/assessment.md` の表をそのまま貼り、集計とパターン分析を転記。

- [ ] **Step 4: 機能比較マトリクスを埋める**

以下のマトリクス（spec のマトリクスを拡張）で評価:

| 機能 | gh skill | 本マーケットプレイス | コメント |
|---|---|---|---|
| Skill 配布 | ○ | ○ | |
| Slash Command | ✕ | ○ | |
| Hook | ✕ | ○ | |
| MCP server 定義 | ✕ | ○ | |
| プラグインバンドル | ✕ | ○ | |
| バージョン固定 | ○（`--pin`） | △（git tag 手動参照） | |
| クロスエージェント（Copilot/Gemini） | ○ | ✕ | |

各 ✕/○ の判断根拠を「コメント」列に 1 文で添える。

- [ ] **Step 5: 推奨方針セクションを埋める**

3 シナリオそれぞれについて以下を書く:

- 概要（1-2 文）
- メリット（箇条書き 2-3 項目）
- デメリット（箇条書き 2-3 項目）
- 移行コスト（低/中/高）
- blast radius（影響範囲）

最後に「推奨」サブセクションで 1 つを選び、選定根拠を 3-5 行で明記。推奨採用時のみ、簡易ロードマップ（Phase 1 / 2 / 3 など箇条書き 5 項目以内）を追加。

- [ ] **Step 6: 付録を埋める**

参考リンク:

- `https://github.blog/changelog/2026-04-16-manage-agent-skills-with-github-cli/`
- `https://github.com/github/gh-stack`
- `https://agentskills.io/`（Task 2 で確認したページのみ）

PoC 作業ログサマリ:

```markdown
- /tmp/gh-skills-poc/oas-spec.md - OAS 仕様メモ
- /tmp/gh-skills-poc/gitignore-gap.md - ギャップ分析
- /tmp/gh-skills-poc/assessment.md - 机上棚卸し原本
- /tmp/gh-skills-poc/logs/*.txt - 実行ログ
- /tmp/gh-skills-poc/skill-repo/ - PoC 用最小リポジトリ（作業後削除）
```

---

## Task 11: Self-review、lint 通過、コミット

**Files:**

- Modify: `docs/superpowers/specs/2026-04-20-gh-skills-report.md`（必要に応じて）

- [ ] **Step 1: Self-review チェックリスト**

自分で以下を確認:

- 9 skill 全てが机上棚卸し表に含まれている
- PoC セクションに実行コマンドの出力が fabrication なしで貼られている
- 推奨方針が 1 つに絞られ、根拠が明示されている
- 「TBD」「TODO」「あとで埋める」等の placeholder が残っていない
- 漢字 7 文字連続の textlint ルールに抵触する見出しがない（過去事例: 代替可能性の検証、など）

問題があれば修正。

- [ ] **Step 2: pre-commit を先に通して lint エラーを潰す**

```bash
cd /Users/takeruooyama/workspace/tqer39/claude-code-marketplace/.claude/worktrees/ancient-giggling-quasar
git add docs/superpowers/plans/2026-04-20-gh-skills-verification.md docs/superpowers/specs/2026-04-20-gh-skills-report.md
pre-commit run --files docs/superpowers/plans/2026-04-20-gh-skills-verification.md docs/superpowers/specs/2026-04-20-gh-skills-report.md 2>&1 | tee /tmp/gh-skills-poc/logs/pre-commit.txt
```

Expected: すべての hook が Passed。失敗した場合は指摘内容に従って修正し再実行。

- [ ] **Step 3: コミット**

```bash
git commit -m "$(cat <<'EOF'
📝 gh skills 代替可能性の検証レポートとプランを追加

git:gitignore の PoC と残り 8 skill の机上棚卸しを実施し、
gh skill と本マーケットプレイスの機能比較マトリクスおよび
推奨方針（完全移行 / 併用 / 現状維持）をまとめた。

Co-Authored-By: Claude Opus 4.7 <noreply@anthropic.com>
EOF
)"
```

Expected: 2 ファイル（plan + report）が 1 コミットに含まれる。

- [ ] **Step 4: PoC 作業ディレクトリの後始末メモを確認**

```bash
cat /tmp/gh-skills-poc/logs/cleanup-todo.txt 2>/dev/null || echo "No cleanup tasks (no GitHub repo was created)"
```

GitHub 上に private repo を作った場合、レポート提出後に `gh repo delete` で削除する旨をユーザーに通知。`/tmp/gh-skills-poc/` 自体は次回マシン再起動で消えるので削除不要。

- [ ] **Step 5: 最終状態の確認**

```bash
git log --oneline -3
git status
```

Expected: 最新コミットが本タスクのもの、作業ツリーがクリーン。

---

## 成功条件（Definition of Done）

- `docs/superpowers/specs/2026-04-20-gh-skills-report.md` が存在する
- PoC セクションに実コマンド出力が貼られている（fabrication なし）
- 9 skill 全てが棚卸し表に含まれている
- 推奨方針が 1 つ、根拠付きで示されている
- `plugins/` 配下に変更なし（`git diff main -- plugins/` が空）
- pre-commit 全通過
