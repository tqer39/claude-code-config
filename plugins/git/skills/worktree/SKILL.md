---
name: worktree
description: Create, manage, and clean up git worktrees for isolated parallel work. Trigger phrases include "worktreeで作業したい", "worktreeを作って", "worktreeを片付けて", "worktree終了", "worktree一覧", "start a worktree", "clean up worktree", "list worktrees".
---

# worktree

git worktree を使って隔離された作業環境を管理する。3 つのフェーズ（Start / Finish / List）をサポートする。

## フェーズ判定

ユーザーのリクエストから実行するフェーズを判定する:

| フェーズ | トリガー |
|---------|---------|
| **Start** | "worktreeで作業したい", "worktreeを作って", "start a worktree", 新しい作業を始めたい |
| **Finish** | "worktreeを片付けて", "worktree終了", "clean up worktree", 作業が終わった |
| **List** | "worktree一覧", "list worktrees", worktree の状態を確認したい |

判定できない場合はユーザーに確認する。

## 前提条件

すべてのフェーズ共通:

1. **git リポジトリ**: `git rev-parse --is-inside-work-tree` で確認する。
2. **`gh` CLI**: PR 関連の操作に必要。`gh auth status` で確認する。

---

## Phase 1: Start

### Step 1: 現在の状態を確認

worktree 内で作業中でないことを確認する:

```bash
git rev-parse --show-toplevel
```

現在のパスが `.claude/worktrees/` 配下の場合は、先に Finish フェーズを実行するよう案内して中断する。

### Step 2: base branch の検出

以下の優先順位で base branch を決定する:

1. ユーザーが明示的に指定した場合はそれを使用
2. `git ls-remote --heads origin main` → `main`
3. `git ls-remote --heads origin master` → `master`
4. `git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@'`

いずれも解決できない場合はユーザーに確認する。

### Step 3: 最新を取得

```bash
git fetch origin
```

fetch が失敗した場合（ネットワーク不通など）:

- ローカルコピーが古い可能性をユーザーに警告する
- 続行か中断かをユーザーに確認する

### Step 4: ブランチ名の生成

ユーザーに作業内容を確認する。`references/worktree-naming.md` の命名規則に従ってブランチ名を生成する。

1. 作業種別からプレフィックスを決定（デフォルト: `feat`）
2. 作業内容を英語ケバブケースの description に変換
3. 日付と short hash を取得してブランチ名を組み立てる

```bash
DATE=$(date +%y%m%d)
SHORT_HASH=$(git rev-parse --short=7 origin/<base-branch>)
BRANCH="<prefix>/<description>-${DATE}-${SHORT_HASH}"
```

ブランチ名が既に存在する場合は別の description を依頼する:

```bash
git branch --list "${BRANCH}" --remotes --format='%(refname:short)'
```

### Step 5: Worktree の作成

`EnterWorktree` ツールを使用して worktree を作成し、セッションの作業ディレクトリを切り替える:

- `name`: description 部分（例: `add-user-auth`）

### Step 6: ブランチのセットアップ

worktree 内で base branch の最新から新しいブランチを作成する:

```bash
git checkout -b <branch-name> origin/<base-branch>
```

### Step 7: 結果の表示

以下を表示する:

- 作成された worktree のパス
- ブランチ名
- base branch
- 「作業が終わったら "worktreeを片付けて" と指示してください」という案内

---

## Phase 2: Finish

### Step 1: 未コミット変更の確認

```bash
git status --porcelain
```

変更がある場合、ユーザーに対処方法を確認する:

- **コミットする**: auto-commit コマンドのパターンに従ってコミットを実行する
- **Stash する**: `git stash push -m "worktree cleanup stash"`
- **破棄する**: ユーザーの明示的な確認を得てから `git checkout -- .` と `git clean -fd`

### Step 2: 未 push コミットの確認

```bash
git log --oneline @{upstream}..HEAD 2>/dev/null
```

未 push のコミットがある場合:

- リモートにブランチが存在するか確認:

```bash
git ls-remote --heads origin $(git branch --show-current)
```

- **新規ブランチ**: `git push -u origin $(git branch --show-current)`
- **既存ブランチ**: `--force-with-lease` の使用をユーザーに確認してから push

### Step 3: PR 作成の確認

ユーザーに PR を作成するか確認する:

- **作成する**: pull-request スキルのワークフローを実行する
- **スキップ**: 次のステップに進む
- **後で作成**: worktree を残して後で対応する

### Step 4: Worktree の削除

`ExitWorktree` ツールを使用して worktree を削除し、元のディレクトリに戻る。

- 未コミット変更が残っている場合は `ExitWorktree` が拒否する。Step 1 に戻って対処する。
- ユーザーが worktree を残したい場合は、`ExitWorktree` の `action: "keep"` オプションを使用する。

### Step 5: 結果の表示

以下を表示する:

- worktree が削除されたか、保持されたか
- 元のディレクトリに戻ったこと
- PR を作成した場合はその URL

---

## Phase 3: List

### Step 1: Worktree 一覧の取得

```bash
git worktree list
```

### Step 2: 各 worktree の状態を確認

各 worktree に対して:

```bash
git -C <worktree-path> status --porcelain
git -C <worktree-path> log --oneline -3
```

### Step 3: 結果の表示

以下の情報をテーブル形式で表示する:

| パス | ブランチ | 状態 | 最新コミット |
|------|---------|------|-------------|

### Step 4: 孤立 worktree の検出

worktree のパスが存在しない場合、prune を提案する:

```bash
git worktree prune --dry-run
```

ユーザーが承認したら実行:

```bash
git worktree prune
```

---

## 禁止事項

- 生の `git worktree add` / `git worktree remove` は使わない（`EnterWorktree` / `ExitWorktree` を使用する）
- 未コミット変更がある worktree をユーザーの確認なしに強制削除しない
- base branch 以外からの worktree 作成（必ず `origin/<base-branch>` から派生する）
- `--no-verify` フラグの使用
- `.env`、`credentials.json`、`*.secret`、`*.key` などのシークレットファイルのステージング
- `git push --force` の使用（`--force-with-lease` のみ許可）
