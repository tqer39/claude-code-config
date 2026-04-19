# Worktree Cleanup Design: claude-code-marketplace

作成日: 2026-04-20。

## 目的

`claude-code-marketplace` リポジトリに残っている 2 つの worktree を整理し、作業内容は PR 経由で `main` に反映してから worktree と branch を削除する。

## 対象

| worktree | branch | 状態 |
|---|---|---|
| `.claude/worktrees/ancient-giggling-quasar` | `design/gh-skills-verification` | staged 変更 1 件 + commit 1 件（未 push） |
| `.claude/worktrees/sorted-sprouting-haven` | `worktree-sorted-sprouting-haven` | commit 1 件（未 push） |

## 変更内容

### sorted-sprouting-haven

- 変更: `.gitignore` に `.claude/worktrees/` を追加（commit 1 件）
- 掃除手順:
  1. `git push -u origin worktree-sorted-sprouting-haven`
  2. `gh pr create` で PR 作成
  3. `claude-auto` ラベル付与で auto-merge
  4. merge 後、main で `git worktree remove` + `git branch -d`

### ancient-giggling-quasar

- 変更（既存 commit）: `docs/superpowers/specs/2026-04-20-gh-skills-verification-design.md`
- 変更（staged / 未 commit）: `docs/superpowers/plans/2026-04-20-gh-skills-verification.md`
- 掃除手順:
  1. staged の plan ファイルを既存 commit に amend（message を更新: design + plan）
  2. `git push -u origin design/gh-skills-verification`
  3. `gh pr create` で PR 作成
  4. `claude-auto` ラベル付与で auto-merge
  5. merge 後、main で `git worktree remove` + `git branch -d`

## 順序

1. `sorted-sprouting-haven`（.gitignore）を先に merge → main で `.claude/worktrees/` が ignore される
2. その後 `ancient-giggling-quasar` を merge

## 対象外

- main worktree の untracked `.claude/` ディレクトリは触らない（.gitignore merge 後に自動解消）
- 他リポジトリの worktree（dotfiles 側など）には手を付けない

## 成功条件

- `git worktree list` で claude-code-marketplace 配下に main しか残っていない
- 該当 branch がローカルから削除されている
- 2 つの PR が merge 済みで `main` に反映されている
