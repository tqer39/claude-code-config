# Worktree ブランチ命名規則

## ブランチ名フォーマット

```text
<prefix>/<description>-<YYMMDD>-<short-hash>
```

- `<prefix>`: 作業種別（下表参照）
- `<description>`: 作業内容を表す英語のケバブケース
- `<YYMMDD>`: worktree 作成日（例: `260405`）
- `<short-hash>`: base branch の HEAD コミットの先頭 7 文字

## プレフィックス

| プレフィックス | 用途 |
|---------------|------|
| `feat` | 新機能の追加 |
| `fix` | バグ修正 |
| `docs` | ドキュメントのみの変更 |
| `refactor` | リファクタリング |
| `chore` | ビルド・ツール・依存の変更 |

ユーザーが種別を明示しない場合はデフォルトで `feat` を使用する。

## 日本語 → 英語ケバブケース変換例

| 日本語入力 | 変換結果 |
|-----------|---------|
| ユーザー認証を追加 | `add-user-auth` |
| ログイン画面の修正 | `fix-login-page` |
| README 更新 | `update-readme` |
| テストの追加 | `add-tests` |
| CI パイプラインの改善 | `improve-ci-pipeline` |

## EnterWorktree の name パラメータ

`EnterWorktree` ツールの `name` パラメータには `<description>` 部分のみを渡す。

例: ブランチ名が `feat/add-user-auth-260405-abc1234` の場合、`name` は `add-user-auth`。

## ブランチ名の生成手順

```bash
# 1. 日付を取得
DATE=$(date +%y%m%d)

# 2. base branch の short hash を取得
SHORT_HASH=$(git rev-parse --short=7 origin/<base-branch>)

# 3. ブランチ名を組み立て
BRANCH="<prefix>/<description>-${DATE}-${SHORT_HASH}"
```

## 重複時の対処

生成したブランチ名が既に存在する場合:

```bash
git branch --list "<branch-name>"
```

存在する場合はユーザーに別の description を依頼する。
