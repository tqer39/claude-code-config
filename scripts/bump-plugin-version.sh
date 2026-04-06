#!/usr/bin/env bash
set -euo pipefail

# プラグインの plugin.json バージョンを自動更新する commit-msg フック
# コミットメッセージのプレフィックスから semver の種別を判定し、
# ステージされたファイルから対象プラグインを特定してバージョンを更新する。

COMMIT_MSG_FILE="${1:?コミットメッセージファイルが指定されていません}"

if ! command -v jq &>/dev/null; then
  echo "エラー: jq がインストールされていません。brew install jq を実行してください。" >&2
  exit 1
fi

first_line=$(head -n 1 "$COMMIT_MSG_FILE")

# マージコミットはスキップ
if [[ "$first_line" =~ ^Merge ]]; then
  exit 0
fi

# プレフィックスを抽出（例: "feat(scope): msg" → "feat", "fix!: msg" → "fix!"）
prefix=$(echo "$first_line" | sed -n 's/^\([a-zA-Z]*!*\)\(([^)]*)\)\{0,1\}:.*/\1/p')

if [[ -z "$prefix" ]]; then
  exit 0
fi

# バージョン種別を判定
bump_type="minor"
case "$prefix" in
  fix | bugfix)
    bump_type="patch"
    ;;
  *!)
    bump_type="major"
    ;;
esac

# BREAKING CHANGE がコミット本文にある場合は major
if grep -q "^BREAKING CHANGE" "$COMMIT_MSG_FILE" 2>/dev/null; then
  bump_type="major"
fi

# ステージされたファイルから対象プラグインを特定
staged_files=$(git diff --cached --name-only)

if [[ -z "$staged_files" ]]; then
  exit 0
fi

# plugins/ 配下のファイルからプラグイン名を抽出（重複排除）
plugin_names=$(echo "$staged_files" | sed -n 's|^plugins/\([^/]*\)/.*|\1|p' | sort -u)

if [[ -z "$plugin_names" ]]; then
  exit 0
fi

# plugin.json のみの変更かチェック（無限ループ防止）
non_plugin_json_files=$(echo "$staged_files" | grep '^plugins/' | grep -v '\.claude-plugin/plugin\.json$' || true)
if [[ -z "$non_plugin_json_files" ]]; then
  exit 0
fi

# semver をバンプする関数
bump_version() {
  local version="$1"
  local type="$2"
  local major minor patch
  IFS='.' read -r major minor patch <<< "$version"

  case "$type" in
    major)
      echo "$((major + 1)).0.0"
      ;;
    minor)
      echo "${major}.$((minor + 1)).0"
      ;;
    patch)
      echo "${major}.${minor}.$((patch + 1))"
      ;;
  esac
}

updated=false

for plugin_name in $plugin_names; do
  plugin_json="plugins/${plugin_name}/.claude-plugin/plugin.json"

  if [[ ! -f "$plugin_json" ]]; then
    continue
  fi

  current_version=$(jq -r '.version' "$plugin_json")
  new_version=$(bump_version "$current_version" "$bump_type")

  jq --arg v "$new_version" '.version = $v' "$plugin_json" > "${plugin_json}.tmp"
  mv "${plugin_json}.tmp" "$plugin_json"
  git add "$plugin_json"

  echo "バージョン更新: ${plugin_name} ${current_version} → ${new_version} (${bump_type})"
  updated=true
done

if [[ "$updated" = true ]]; then
  echo "plugin.json のバージョンを更新しました。"
fi
