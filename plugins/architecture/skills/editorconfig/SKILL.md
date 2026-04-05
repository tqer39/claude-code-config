---
name: editorconfig
description: Generate and update .editorconfig files by auto-detecting project file types and applying best-practice formatting rules. Use this skill when the user mentions .editorconfig, wants consistent code formatting, sets up a new project, or asks about editor configuration. Also trigger when the user says "editorconfig を更新", "editorconfig を作成", or "フォーマット設定".
---

# editorconfig

Generate or update `.editorconfig` files by scanning the project for file types and applying best-practice indentation, charset, and whitespace rules.

## Workflow

### Step 1: Detect Project File Types

Scan the project root (excluding `.git/`, `node_modules/`, `vendor/`, `dist/`, `build/`, `__pycache__/`) to identify file extensions and special filenames. Use the detection table in `references/filetype-rules.md` to map detected files to `.editorconfig` sections.

Run:

```bash
find . -type f \
  -not -path './.git/*' \
  -not -path './node_modules/*' \
  -not -path './vendor/*' \
  -not -path './dist/*' \
  -not -path './build/*' \
  -not -path './__pycache__/*' \
  | sed 's/.*\///' | sed 's/.*\./\./' | sort | uniq -c | sort -rn
```

Also check for special filenames: `Makefile`, `justfile`, `Brewfile`, `Dockerfile`, `Vagrantfile`, `Gemfile`, `Rakefile`.

### Step 2: Build Rule Set

Using the detection results and the reference table:

1. Always start with the `[*]` base section (charset, end_of_line, insert_final_newline, indent_size, indent_style, trim_trailing_whitespace).
2. Add sections only for file types actually found in the project.
3. Only add a section when it differs from the `[*]` defaults.

### Step 3: Confirm with User

Present the detected file types and proposed `.editorconfig` sections to the user. Ask them to:

- Add any missing rules
- Remove any rules that don't apply
- Adjust indent sizes or styles

Do not write any files until the user confirms.

### Step 4: Write or Update .editorconfig

Handle three cases:

**Case A — No existing `.editorconfig`:**

Create a new `.editorconfig` at the project root with:

```ini
# see http://editorconfig.org
root = true
```

followed by the confirmed sections.

**Case B — Existing `.editorconfig`:**

Read the existing file. For each section in the proposed rules:

- **Section already exists** → Show the diff to the user and ask whether to update or keep.
- **Section does not exist** → Append the new section.

Preserve all existing sections that are not in the proposed rules. Maintain the original ordering where possible.

**Case C — Existing `.editorconfig` without `root = true`:**

Add `root = true` at the top (after the comment header) and warn the user that it was missing.

#### Edge Cases

- **Line endings**: Always use LF (`\n`) in the `.editorconfig` file itself.
- **Monorepo / subdirectory `.editorconfig`**: Only modify the project root `.editorconfig` unless the user explicitly requests otherwise.
- **Conflicting rules**: If an existing rule contradicts the proposed rule, always ask the user which to keep.

### Step 5: Verify and Report

After writing the file:

1. Show the final `.editorconfig` content
2. State whether the file was created (Case A) or updated (Case B/C)
3. List the detected file types and applied rules
4. Show the diff with `git diff .editorconfig` (or note it's a new file)
