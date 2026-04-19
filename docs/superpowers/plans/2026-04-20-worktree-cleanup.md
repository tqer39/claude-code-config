# Worktree Cleanup Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** `claude-code-marketplace` リポジトリの 2 つの worktree を PR 経由で merge したあと削除する。

**Architecture:** `sorted-sprouting-haven`（.gitignore）を先に merge する。これにより main の `.claude/` ディレクトリが ignore される。その後 `ancient-giggling-quasar`（design + plan ドキュメント）を merge する。両 PR は `claude-auto` ラベルによる auto-merge を利用する。

**Tech Stack:** git, git worktree, GitHub CLI (`gh`)

**対象リポジトリ:** `/Users/takeruooyama/workspace/tqer39/claude-code-marketplace`

---

## 事前確認

### Task 0: 前提の確認

**Files:** なし（read-only）

- [ ] **Step 1: リポジトリの現状を確認**

```bash
cd /Users/takeruooyama/workspace/tqer39/claude-code-marketplace
git worktree list
git status --short
```

Expected:

- worktree: main / ancient-giggling-quasar / sorted-sprouting-haven の 3 つ
- main の status に `?? .claude/` が見える（未 ignore）

- [ ] **Step 2: 両 worktree に未想定の変更がないか確認**

```bash
git -C .claude/worktrees/ancient-giggling-quasar status --short
git -C .claude/worktrees/sorted-sprouting-haven status --short
```

Expected:

- ancient-giggling-quasar: `AM docs/superpowers/plans/2026-04-20-gh-skills-verification.md` のみ
- sorted-sprouting-haven: 変更なし

想定外の変更があれば停止してユーザーに確認する。

---

## Task 1: sorted-sprouting-haven を push → PR → merge

**Files:**

- Modify: なし（既存 commit をそのまま push）

- [ ] **Step 1: push**

```bash
cd /Users/takeruooyama/workspace/tqer39/claude-code-marketplace/.claude/worktrees/sorted-sprouting-haven
git push -u origin worktree-sorted-sprouting-haven
```

Expected: branch が origin に作られる。

- [ ] **Step 2: PR 作成**

```bash
gh pr create \
  --base main \
  --head worktree-sorted-sprouting-haven \
  --title "🙈 .gitignore に .claude/worktrees/ を追加" \
  --body "$(cat <<'EOF'
## Summary

- `.gitignore` に `.claude/worktrees/` を追加し、ローカル worktree が untracked として現れないようにする。

## Test plan

- [x] `git status` で `.claude/` が untracked に出なくなることを確認
EOF
)"
```

Expected: PR URL が出力される。URL をメモ。

- [ ] **Step 3: auto-merge ラベル付与**

```bash
gh pr edit <PR_NUMBER> --add-label claude-auto
```

Expected: ラベル付与成功。auto-merge ワークフローが起動する。

- [ ] **Step 4: merge 完了待ち**

```bash
gh pr view <PR_NUMBER> --json state,mergedAt
```

Expected: `state: MERGED` になるまで待つ。長引く場合は CI 状態を `gh pr checks <PR_NUMBER>` で確認。

- [ ] **Step 5: main を最新化**

```bash
cd /Users/takeruooyama/workspace/tqer39/claude-code-marketplace
git checkout main
git pull --ff-only origin main
```

Expected: `.gitignore` に `.claude/worktrees/` が含まれている状態で main が HEAD。

- [ ] **Step 6: worktree と branch を削除**

```bash
git worktree remove .claude/worktrees/sorted-sprouting-haven
git branch -d worktree-sorted-sprouting-haven
```

Expected: worktree ディレクトリとローカル branch が消える。

- [ ] **Step 7: 確認**

```bash
git worktree list
git status --short
```

Expected:

- worktree list から sorted-sprouting-haven が消えている
- main の status で `.claude/` が untracked として出ない（ignore 済み）

---

## Task 2: ancient-giggling-quasar の staged 変更を既存 commit に amend

**Files:**

- Amend: 既存 commit `1a9c86f 📝 gh skills 代替可能性の検証設計書を追加`
- Include: `docs/superpowers/plans/2026-04-20-gh-skills-verification.md`

- [ ] **Step 1: 現在の diff を確認**

```bash
cd /Users/takeruooyama/workspace/tqer39/claude-code-marketplace/.claude/worktrees/ancient-giggling-quasar
git diff --cached
git diff
```

Expected: plan.md が index / working tree の両方に変更あり（`AM`）。

- [ ] **Step 2: working tree 側の変更も stage する**

```bash
git add docs/superpowers/plans/2026-04-20-gh-skills-verification.md
git status --short
```

Expected: `A docs/superpowers/plans/2026-04-20-gh-skills-verification.md`（`M` が消えて `A` のみ）。

- [ ] **Step 3: 既存 commit に amend し、メッセージを更新**

```bash
git commit --amend -m "📝 gh skills 代替可能性の検証設計書と plan を追加"
```

Expected: HEAD が更新される（commit hash 変化）。

- [ ] **Step 4: amend 結果を確認**

```bash
git log --oneline main..HEAD
git show --stat HEAD
```

Expected:

- commit が 1 件のみ（先行 commit は 1 つ）
- 以下の両方が含まれている
  - `docs/superpowers/specs/2026-04-20-gh-skills-verification-design.md`
  - `docs/superpowers/plans/2026-04-20-gh-skills-verification.md`

---

## Task 3: ancient-giggling-quasar を push → PR → merge

**Files:** なし（既に amend 済み）

- [ ] **Step 1: push**

```bash
cd /Users/takeruooyama/workspace/tqer39/claude-code-marketplace/.claude/worktrees/ancient-giggling-quasar
git push -u origin design/gh-skills-verification
```

Expected: branch が origin に作られる。

- [ ] **Step 2: PR 作成**

```bash
gh pr create \
  --base main \
  --head design/gh-skills-verification \
  --title "📝 gh skills 代替可能性の検証設計書と plan を追加" \
  --body "$(cat <<'EOF'
## Summary

- `gh skills` を使った代替可能性の検証に関する design 文書と plan 文書を追加。

## Test plan

- [x] 文書のみの追加であり、コード変更なし
EOF
)"
```

Expected: PR URL が出力される。URL をメモ。

- [ ] **Step 3: auto-merge ラベル付与**

```bash
gh pr edit <PR_NUMBER> --add-label claude-auto
```

Expected: ラベル付与成功。

- [ ] **Step 4: merge 完了待ち**

```bash
gh pr view <PR_NUMBER> --json state,mergedAt
```

Expected: `state: MERGED`。

- [ ] **Step 5: main を最新化**

```bash
cd /Users/takeruooyama/workspace/tqer39/claude-code-marketplace
git checkout main
git pull --ff-only origin main
```

Expected: main に design + plan 文書が入っている。

- [ ] **Step 6: worktree と branch を削除**

```bash
git worktree remove .claude/worktrees/ancient-giggling-quasar
git branch -d design/gh-skills-verification
```

Expected: worktree ディレクトリとローカル branch が消える。

---

## Task 4: 最終確認

**Files:** なし（read-only）

- [ ] **Step 1: worktree 一覧**

```bash
cd /Users/takeruooyama/workspace/tqer39/claude-code-marketplace
git worktree list
```

Expected: main のみ。

- [ ] **Step 2: ローカル branch 一覧**

```bash
git branch
```

Expected: `* main` のみ（`design/gh-skills-verification` / `worktree-sorted-sprouting-haven` が消えている）。

- [ ] **Step 3: 作業ディレクトリの状態**

```bash
git status --short
```

Expected: clean（`.claude/` が ignore されているため何も出ない）。

- [ ] **Step 4: main に反映されたか**

```bash
git log --oneline -5
```

Expected: 直近に「🙈 .gitignore...」「📝 gh skills...」2 件の merge commit または squash commit が含まれている。

---

## ロールバック方針

- Task 1 の push 後に PR merge が失敗した場合: PR を close し、`git push origin --delete worktree-sorted-sprouting-haven` して元の状態に戻す。
- Task 2 の amend に失敗した場合: `git reflog` で元の HEAD に戻せる (`git reset --hard HEAD@{n}`)。
- worktree 削除後に復元が必要になった場合: branch が残っていれば `git worktree add <path> <branch>` で復元可能。
