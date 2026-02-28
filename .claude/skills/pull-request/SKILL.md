---
name: pull-request
description: Create and update GitHub pull requests with automatic rebase, conflict resolution, and description generation. Use this skill whenever the user wants to create a PR, open a pull request, push and create a PR, submit changes for review, update a PR description, or says things like "PRを作って", "プルリクエスト作成", "レビューに出したい", "PRお願い", "create a PR", "open a pull request", "submit for review", "push and create PR". Also use when the user has finished working on a feature branch and wants to merge it.
---

# pull-request

Automate the full pull request workflow: rebase onto the base branch, resolve conflicts, push, and create or update a GitHub PR with a well-structured description.

## Prerequisites

Before starting, verify all of the following. If any check fails, stop and tell the user what needs to be fixed.

1. **Git repository**: Confirm the current directory is inside a git repository (`git rev-parse --is-inside-work-tree`).
2. **`gh` CLI authenticated**: Run `gh auth status`. If not authenticated, tell the user to run `gh auth login`.
3. **Not on the base branch**: The current branch must not be `main` or `master` (or whatever the base branch is). Creating a PR from the base branch to itself is not allowed.
4. **Working tree status**: Run `git status --porcelain`. If there are uncommitted changes, ask the user how to handle them before proceeding:
   - Commit them first
   - Stash them
   - Abort the PR workflow

## Workflow

### Step 1: Detect Base Branch

Determine the base branch using this priority order:

1. If the user explicitly specified a base branch, use that.
2. Check if `main` exists as a remote branch: `git ls-remote --heads origin main`
3. Check if `master` exists as a remote branch: `git ls-remote --heads origin master`
4. Use the remote HEAD: `git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@'`

If none of these resolve, ask the user to specify the base branch.

### Step 2: Fetch Latest

```bash
git fetch origin
```

This ensures the local tracking refs are up to date before rebasing.

### Step 3: Rebase onto Base Branch

```bash
git rebase origin/{base-branch}
```

**If the rebase succeeds** (exit code 0): proceed to Step 4.

**If the rebase hits conflicts:**

1. Identify conflicting files from `git diff --name-only --diff-filter=U`.
2. For each conflicting file, read the file and examine the conflict markers (`<<<<<<<`, `=======`, `>>>>>>>`).
3. **Trivial conflicts** (e.g., import ordering, adjacent non-overlapping edits): resolve automatically by choosing the correct combination, then `git add {file}`.
4. **Non-trivial conflicts** (semantic differences, logic changes): show the conflict to the user with context and ask which resolution to apply.
5. After resolving all conflicts in a step: `git rebase --continue`.
6. Repeat until rebase finishes.

**If the conflicts are too complex** (more than 5 files with non-trivial conflicts, or the user asks to abort):

```bash
git rebase --abort
```

Report the situation and suggest alternatives (merge instead, or manually resolve).

### Step 4: Push

Determine whether the branch already exists on the remote:

```bash
git ls-remote --heads origin $(git branch --show-current)
```

**Branch exists on remote:**

Before force-pushing, always confirm with the user. Explain that force-push rewrites remote history and could affect collaborators.

Never force-push to `main` or `master`. This is an absolute rule — refuse even if the user asks.

After user confirmation:

```bash
git push --force-with-lease
```

Always use `--force-with-lease` (never `--force`) to protect against overwriting others' work.

**Branch is new (not on remote):**

```bash
git push -u origin $(git branch --show-current)
```

No confirmation needed for first push.

### Step 5: Check for Existing PR

```bash
gh pr view --json number,title,body,url 2>/dev/null
```

**If a PR already exists:**

Ask the user:
- **Update**: Update the existing PR's title and description (go to Step 6, then use `gh pr edit`).
- **Skip**: Keep the existing PR as-is and just report the URL.

**If no PR exists:** proceed to Step 6 to create one.

### Step 6: Generate PR Title and Description

Gather context for writing the PR description:

```bash
git log origin/{base-branch}..HEAD --oneline
git diff origin/{base-branch}...HEAD --stat
git diff origin/{base-branch}...HEAD
```

Read `references/pr-description-template.md` for the exact format to follow.

**Locale detection** (for description language):
1. If the user explicitly requested a language, use that.
2. Otherwise, look at the conversation language — if the user has been writing in Japanese, use Japanese (`ja`). If in English, use English (`en`).
3. Default: `ja` (Japanese).

Generate the PR title and description following the template. The content must be:
- Based only on actual changes (never fabricate or assume changes that don't exist in the diff)
- Concise but informative
- Using the correct locale

### Step 7: Create or Update the PR

**Creating a new PR:**

```bash
gh pr create --base {base-branch} --title "{title}" --body "$(cat <<'EOF'
{generated description}
EOF
)"
```

**Updating an existing PR:**

```bash
gh pr edit --title "{title}" --body "$(cat <<'EOF'
{generated description}
EOF
)"
```

Before executing, show the user a preview of the title and description. Ask for confirmation or edits.

### Step 8: Report Result

After the PR is created or updated:

1. Display the PR URL.
2. Summarize what was done:
   - Whether a rebase was performed (and if conflicts were resolved)
   - Whether it was a new PR or an update
   - The base branch used
