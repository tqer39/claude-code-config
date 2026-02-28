---
name: gitignore
description: Generate and update .gitignore files using the gitignore.io API with automatic project detection. Use this skill whenever the user mentions .gitignore, wants to ignore files in git, needs gitignore templates, asks about what to put in .gitignore, creates a new project and needs a .gitignore, or asks to clean up tracked files. Also use this skill when setting up a new repository, initializing a project, or when the user says things like "set up git" or "init project" — a good .gitignore is part of proper project setup.
---

# gitignore

Generate or update `.gitignore` files by auto-detecting project technologies and fetching best-practice templates from the gitignore.io API.

## Workflow

### Step 1: Detect Project Technologies

Read `references/language-detection.md` for the full detection mapping table.

Scan the project root for indicator files and directories to build a list of gitignore.io template names. Use glob patterns and `ls` to check for the indicators listed in the reference file.

**Always include all three OS templates**: `macos`, `linux`, `windows` — regardless of detection results.

Collect all matched template names into a deduplicated list.

### Step 2: Confirm Templates with User

Present the detected templates to the user in a clear list, grouped by category (Languages, Frameworks, Tools, Editors, OS). Ask the user to:

- Add any templates that were missed
- Remove any templates that don't apply

Do not proceed to the API call until the user confirms the template list.

### Step 3: Validate Templates Against API

Fetch the list of all available templates:

```bash
curl -sL "https://www.toptal.com/developers/gitignore/api/list"
```

The response is a comma-separated list (with newlines). Check each selected template against this list (case-insensitive). If any templates are not found:

- Remove them from the list
- Warn the user which templates were removed and why

If the API is unreachable or returns an error, stop and notify the user. Do not write or modify any files.

### Step 4: Fetch .gitignore Content from API

Call the API with the validated, comma-separated template list:

```bash
curl -sL "https://www.toptal.com/developers/gitignore/api/{comma-separated-templates}"
```

Example: `curl -sL "https://www.toptal.com/developers/gitignore/api/node,python,macos,linux,windows"`

The response is plain text ready to use as `.gitignore` content. It includes marker lines:
- Header: `# Created by https://www.toptal.com/developers/gitignore/api/{templates}`
- Footer: `# End of https://www.toptal.com/developers/gitignore/api/{templates}`

Verify the response contains these markers. If it doesn't (API error, empty response), stop and notify the user.

### Step 5: Write or Update .gitignore

Handle three cases:

**Case A — No existing `.gitignore`:**

Create a new `.gitignore` at the project root with the API content as-is.

**Case B — Existing `.gitignore` without API markers:**

The existing file contains project-specific custom rules that must be preserved. Construct the new file as:

```
{API content}

# Custom rules
{existing .gitignore content}
```

Add a blank line and `# Custom rules` header between the API section and the original content to clearly separate them.

**Case C — Existing `.gitignore` with API markers:**

Replace the section from `# Created by https://www.toptal.com/developers/gitignore/api/...` through `# End of https://www.toptal.com/developers/gitignore/api/...` (inclusive) with the new API content. Preserve everything before the header and everything after the footer exactly as-is.

#### Edge Cases

- **Header exists but no footer**: Replace from the header to the end of the file. Warn the user that no footer marker was found and the content after the header was treated as API-generated.
- **Multiple marker pairs**: Replace only the first occurrence. Warn the user about duplicate marker sections.
- **Line endings**: Always use LF (`\n`), not CRLF.
- **Subdirectory `.gitignore`**: Only modify the project root `.gitignore` unless the user explicitly requests otherwise.

### Step 6: Verify and Report

After writing the file:

1. List the templates that were applied
2. State whether the file was created (Case A), prepended (Case B), or updated (Case C)
3. Show the diff with `git diff .gitignore` (or `git diff --no-index /dev/null .gitignore` for new files)
