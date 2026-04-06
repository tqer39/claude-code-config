---
name: push
description: リモートへ push する（auto-merge 機構検出時は claude-auto ラベル付与、conflict 時は rebase で解消）
allowed-tools: [Bash, Read, Glob, Grep]
---

# Push

現在のブランチをリモートへ push する。conflict がある場合は rebase で解消し、auto-merge ワークフローが存在する場合は `claude-auto` ラベルを PR に付与する。

## 手順

### 1. ブランチの確認

- `git branch --show-current` で現在のブランチ名を取得する
- ブランチが `main` または `master` の場合は **エラーを表示して終了** する

### 2. 未コミット変更の確認

- `git status --porcelain` で未コミットの変更を確認する
- 変更がある場合は **警告を表示して終了** する（先にコミットするよう案内）

### 3. リモートの最新化

```bash
git fetch origin
```

### 4. Base Branch の検出

以下の優先順で base branch を決定する:

1. `main` がリモートに存在するか: `git ls-remote --heads origin main`
2. `master` がリモートに存在するか: `git ls-remote --heads origin master`
3. リモート HEAD: `git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@'`

### 5. Rebase の実行

```bash
git rebase origin/{base-branch}
```

**rebase が成功した場合**: ステップ 6 へ進む。

**conflict が発生した場合:**

1. `git diff --name-only --diff-filter=U` で conflict ファイルを特定する
2. 各 conflict ファイルを読み、conflict マーカー（`<<<<<<<`, `=======`, `>>>>>>>`）を確認する
3. **自明な conflict**（import の順序、隣接する非重複の編集など）: 正しい組み合わせを選択して自動解消し、`git add {file}` する
4. **非自明な conflict**（意味的な差異、ロジックの変更）: conflict の内容をユーザーに提示し、どの解決策を適用するか確認する
5. すべての conflict を解消後: `git rebase --continue`
6. rebase が完了するまで繰り返す

**conflict が複雑すぎる場合**（非自明な conflict が 5 ファイル超、またはユーザーが中止を要求）:

```bash
git rebase --abort
```

状況を報告し、代替案（merge の使用、手動解消）を提案する。

### 6. Push の実行

リモートにブランチが存在するか確認する:

```bash
git ls-remote --heads origin $(git branch --show-current)
```

**ブランチがリモートに存在する場合:**

```bash
git push --force-with-lease
```

`--force-with-lease` を使用する（rebase 後のため必要）。`--force` は **絶対に使わない**。

**ブランチが新規の場合:**

```bash
git push -u origin $(git branch --show-current)
```

### 7. Auto-Merge 機構の検出

`.github/workflows/` 配下のファイルに auto-merge の機構が存在するか確認する:

```bash
grep -rl "claude-auto" .github/workflows/ 2>/dev/null
```

該当ファイルが **存在しない場合**: ここで終了（通常の push 完了）。

### 8. PR への claude-auto ラベル付与

auto-merge 機構が検出された場合、現在のブランチに紐づく PR を確認する:

```bash
gh pr view --json number --jq '.number' 2>/dev/null
```

**PR が存在する場合:**

- `claude-auto` ラベルが既に付いているか確認する:

```bash
gh pr view --json labels --jq '[.labels[].name] | any(. == "claude-auto")'
```

- ラベルが付いていなければ付与する:

```bash
gh pr edit --add-label "claude-auto"
```

**PR が存在しない場合**: ラベル付与はスキップする（PR 作成は `create-pr` コマンドの責務）。

### 9. 結果の表示

以下を表示する:

- push 先のリモートブランチ名
- rebase が行われたか（conflict 解消があったか）
- `claude-auto` ラベルが付与されたか（auto-merge 機構がある場合のみ）

## 禁止事項

- `main` または `master` ブランチでの push
- `git push --force` の使用（`--force-with-lease` のみ許可）
- 未コミットの変更がある状態での push
- `--no-verify` フラグの使用
