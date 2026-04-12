#!/usr/bin/env bash
set -u

command -v jq >/dev/null 2>&1 || exit 0

INPUT="$(cat)"
PROMPT="$(printf '%s' "$INPUT" | jq -r '.prompt // empty' 2>/dev/null || true)"
TRIMMED="$(printf '%s' "$PROMPT" | awk '{$1=$1; print}')"

[[ -z "$TRIMMED" ]] && exit 0
[[ ${#TRIMMED} -gt 80 ]] && exit 0

# 空白を含む (複数トークン) の入力は早期に抜ける
case "$TRIMMED" in
  *[[:space:]]*) exit 0 ;;
esac

KEY="${TRIMMED#/}"

# スキル ID を動的にスキャン
# 形式: "<alias> <full-id>" を 1 行ずつ標準出力
scan_skills() {
  local cache_root="$HOME/.claude/plugins/cache"
  if [[ -d "$cache_root" ]]; then
    # cache/<marketplace>/<plugin>/<version>/skills/<skill>/SKILL.md
    while IFS= read -r skill_md; do
      [[ -z "$skill_md" ]] && continue
      local skill_dir version_dir plugin_dir name plugin
      skill_dir="$(dirname "$skill_md")"
      name="$(basename "$skill_dir")"
      version_dir="$(dirname "$(dirname "$skill_dir")")"
      plugin_dir="$(dirname "$version_dir")"
      plugin="$(basename "$plugin_dir")"
      [[ -z "$name" || -z "$plugin" ]] && continue
      printf '%s %s:%s\n' "$name" "$plugin" "$name"
    done < <(find "$cache_root" -mindepth 6 -maxdepth 6 -name SKILL.md 2>/dev/null)
  fi

  # ユーザースキル: ~/.claude/skills/<name>/SKILL.md (プラグイン接頭辞なし)
  if [[ -d "$HOME/.claude/skills" ]]; then
    while IFS= read -r skill_md; do
      [[ -z "$skill_md" ]] && continue
      local name
      name="$(basename "$(dirname "$skill_md")")"
      [[ -z "$name" ]] && continue
      printf '%s %s\n' "$name" "$name"
    done < <(find "$HOME/.claude/skills" -mindepth 2 -maxdepth 2 -name SKILL.md 2>/dev/null)
  fi
}

FULL_ID=""
while read -r alias full; do
  [[ -z "$alias" ]] && continue
  if [[ "$KEY" == "$alias" || "$KEY" == "$full" ]]; then
    FULL_ID="$full"
    break
  fi
done < <(scan_skills)

[[ -z "$FULL_ID" ]] && exit 0

MSG="ユーザー入力「${TRIMMED}」は利用可能スキルと一致した。会話的解釈を試みず、直ちに Skill ツールで '${FULL_ID}' を呼び出せ。ユーザーがスキル起動を意図している。"

jq -nc --arg msg "$MSG" '{
  hookSpecificOutput: {
    hookEventName: "UserPromptSubmit",
    additionalContext: $msg
  }
}'
