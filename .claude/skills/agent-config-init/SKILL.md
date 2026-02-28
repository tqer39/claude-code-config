---
name: agent-config-init
description: Initialize a unified LLM coding agent configuration. Creates AGENTS.md as the single source of truth and symlinks it to tool-specific config files. Use when the user wants to set up agent config, create AGENTS.md, unify AI tool settings, or bootstrap coding guidelines for a project.
---

# Agent Config Init

Create `AGENTS.md` as the single source of truth for LLM coding agent guidelines. Then symlink it to each tool's config file. This keeps all agents (Claude Code, Codex, Gemini CLI, Cursor, Copilot) aligned on the same rules with zero duplication.

Based on arxiv 2602.11988: concise context files (~32 lines) outperform verbose ones.

## AGENTS.md Template

Write the following to `AGENTS.md` in the project root:

```markdown
# Agent Guidelines

## Principles

- Always prefer simplicity over pathological correctness
- YAGNI: do not add functionality until it is necessary
- KISS: prefer the simplest solution that works
- DRY: avoid duplication of logic
- No backward-compatibility shims or fallback paths unless they come for free without increasing cyclomatic complexity

## Code Style

- Follow existing project conventions; do not introduce new patterns gratuitously
- Prefer standard library solutions over third-party dependencies
- Write small, focused functions with clear names
- Comments explain "why", not "what"

## Changes

- Make the minimal change that solves the problem
- Do not refactor unrelated code in the same change
- Do not add speculative features, abstractions, or error handling for impossible scenarios
- If a test fails, fix the test only if the new behavior is intentionally correct

## Process

- Read existing code before writing new code
- Run tests before and after changes
- Commit messages: imperative mood, concise subject line
```

## Symlink Map

| Tool        | Target File                       | Command                                                                   |
| ----------- | --------------------------------- | ------------------------------------------------------------------------- |
| Claude Code | `CLAUDE.md`                       | `ln -sf AGENTS.md CLAUDE.md`                                              |
| Gemini CLI  | `GEMINI.md`                       | `ln -sf AGENTS.md GEMINI.md`                                              |
| Cursor      | `.cursorrules`                    | `ln -sf AGENTS.md .cursorrules`                                           |
| Copilot     | `.github/copilot-instructions.md` | `mkdir -p .github && ln -sf ../AGENTS.md .github/copilot-instructions.md` |

Codex reads `AGENTS.md` natively, so no symlink is needed.

`.cursorrules` (legacy format) is used intentionally. The newer `.cursor/rules/*.mdc` format requires YAML frontmatter and is incompatible with plain symlinks.

## Execution Steps

Run these steps in the **project root** (the directory containing `.git`):

### Step 1: Check for existing AGENTS.md

If `AGENTS.md` already exists, show its content to the user and ask whether to overwrite or keep it.

### Step 2: Write AGENTS.md

Create `AGENTS.md` with the template above. If the user wants to customize the content, apply their changes before writing.

### Step 3: Create symlinks

For each symlink target in the map above:

1. **Already a symlink to AGENTS.md** → Skip (already correct).
2. **Regular file exists** → Ask the user whether to back it up (rename to `<file>.bak`) or overwrite.
3. **Does not exist** → Create the symlink.

For `.github/copilot-instructions.md`, run `mkdir -p .github` first. Use `../AGENTS.md` as the symlink source because the file is one directory deeper.

### Step 4: Verify

Run `ls -la AGENTS.md CLAUDE.md GEMINI.md .cursorrules .github/copilot-instructions.md` to show the results to the user.

## Notes

- All symlinks use **relative paths** so the repo stays portable across machines.
- This operation is **idempotent**: running it again on an already-configured repo will skip existing correct symlinks.
- On Windows (WSL excluded), symlinks may require elevated permissions. Warn the user if the platform is Windows.
