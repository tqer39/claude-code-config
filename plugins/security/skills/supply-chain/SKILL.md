---
description: |
  Audit supply chain security posture of a project. Checks lockfile integrity, dependency pinning,
  typosquatting risks, GitHub Actions SHA pinning, and vulnerability scanning configuration.
  Use when reviewing dependencies, onboarding a new project, or after adding new packages.
  Triggers: "supply chain check", "dependency audit", "security review", "サプライチェーンチェック", "依存関係の監査"
---

# Supply Chain Security Audit

プロジェクトのサプライチェーンセキュリティを監査し、改善提案を行う。

## 背景: 最近の攻撃事例

| 事例 | 攻撃手法 | 教訓 |
|------|----------|------|
| axios (npm) | `axio`, `axois` 等のタイポスクワットで env 変数を窃取 | 依存の追加時に名前検証が必須 |
| trivy (GitHub Actions) | `trivy-action@master` のタグ書き換えによる改竄 | Actions は full SHA でピン留めすべき |
| LiteLLM (PyPI) | `litelm` タイポスクワットで post-install リバースシェル | pip-audit + hash pinning が有効 |

## ワークフロー

### 1. プロジェクト検出

プロジェクトルートをスキャンし、使用技術を特定する:

- `package.json` / `pnpm-lock.yaml` / `package-lock.json` / `yarn.lock` → Node.js
- `pyproject.toml` / `uv.lock` / `requirements.txt` / `Pipfile.lock` → Python
- `go.mod` / `go.sum` → Go
- `.github/workflows/*.yml` → GitHub Actions
- `renovate.json` / `renovate.json5` / `.renovaterc` → Renovate

### 2. Lockfile 整合性チェック

**確認項目:**

- lockfile がリポジトリにコミットされているか（`git ls-files` で確認）
- CI で frozen install が使われているか:
  - npm: `npm ci` または `--frozen-lockfile`
  - pnpm: `pnpm install --frozen-lockfile`
  - uv: `uv sync --frozen`
  - pip: `--require-hashes`

**判定:**

- lockfile 未コミット → **CRITICAL**
- frozen install 未設定 → **HIGH**

### 3. 依存ピン留めチェック

**Node.js:**

- `package.json` の dependencies で `^` / `~` を使用しているものを列挙
- `devDependencies` は `^` を許容（ただし警告は出す）

**Python:**

- `pyproject.toml` / `requirements.txt` でバージョン未固定のものを列挙
- hash pinning の有無を確認（`--require-hashes` または `uv.lock`）

**判定:**

- 本番依存でバージョン範囲指定 → **MEDIUM**
- hash pinning なし → **LOW**（lockfile があれば許容）

### 4. タイポスクワット検出

新規追加された依存パッケージについて、以下をチェック:

- 有名パッケージとの類似名（Levenshtein distance 1-2）
- 既知のタイポスクワットパターン:
  - `axios` → `axio`, `axois`, `axios-https`
  - `litellm` → `litelm`, `lite-llm`
  - `requests` → `request`, `requestes`
  - `lodash` → `lodas`, `lodashs`
  - `express` → `expres`, `expresss`
- npm/PyPI のダウンロード数が極端に少ないパッケージ

**手順:**

1. `git diff` で lockfile の差分から新規追加パッケージを抽出
2. パッケージ名を上記パターンと照合
3. 疑わしいものがあれば **WARNING** として報告

### 5. GitHub Actions SHA ピン留めチェック

`.github/workflows/*.yml` を走査し:

- `uses:` でタグ参照しているものを全て列挙（例: `actions/checkout@v4`）
- SHA ピン留め済みのものは OK（例: `actions/checkout@<40-char-sha>`）
- タグ + SHA コメントパターンも OK（例: `actions/checkout@abc123 # v4`）

**判定:**

- サードパーティ action がタグ参照 → **HIGH**
- 公式 actions（`actions/*`）がタグ参照 → **MEDIUM**

**改善提案:**

- Renovate 設定に `helpers:pinGitHubActionDigests` の追加を提案
- 各 action の SHA を調べて書き換え例を提示

### 6. 脆弱性スキャン設定チェック

CI 設定ファイル（`.github/workflows/*.yml`）で以下の存在を確認:

- `npm audit` / `pnpm audit` / `yarn audit`
- `pip-audit` / `uv pip audit`
- `trivy` / `grype` / `snyk`
- Dependabot / Renovate の脆弱性アラート設定

**判定:**

- CI に脆弱性スキャンなし → **HIGH**
- Dependabot/Renovate 未設定 → **MEDIUM**

### 7. Provenance / SLSA チェック

- npm: `npm audit signatures` の CI 組み込み有無
- GitHub Actions: SLSA provenance generator の使用有無
- コンテナイメージ: Cosign/Sigstore 署名の有無

**判定:**

- プロベナンス検証なし → **LOW**（推奨レベル）

## 出力フォーマット

````markdown
# Supply Chain Security Audit Report

## Summary
- Critical: N件
- High: N件
- Medium: N件
- Low: N件

## Findings

### [CRITICAL] Lockfile が未コミット
- **対象:** package-lock.json
- **リスク:** CI と開発環境で異なるバージョンがインストールされる可能性
- **対策:** `git add package-lock.json` でコミットする

### [HIGH] GitHub Actions がタグ参照
- **対象:** .github/workflows/ci.yml
- **行:** `uses: aquasecurity/trivy-action@master`
- **リスク:** タグ書き換えによるコード注入（trivy 事例参照）
- **対策:**
  ```yaml
  uses: aquasecurity/trivy-action@<SHA> # master
  ```

...（以下同様）
````

## 注意事項

- 自動修正は行わない。発見事項と改善提案のみ報告する
- `--fix` オプション付きで呼ばれた場合も、変更内容をユーザーに提示して確認を取る
- 社内パッケージや private registry のパッケージはタイポスクワット検出の対象外とする
