# tqer39-plugins

Personal SRE/DevOps plugin marketplace for Claude Code.

## Overview

A centralized marketplace that distributes shared skills and commands across ~20 personal repositories. Built on the [Claude Code Plugin Marketplace](https://code.claude.com/docs/en/plugin-marketplaces) system.

## Installation

```bash
# Add marketplace
/plugin marketplace add tqer39/claude-code-marketplace

# Install plugins
/plugin install common-ci@tqer39-plugins
/plugin install git@tqer39-plugins
/plugin install security@tqer39-plugins
/plugin install terraform@tqer39-plugins
/plugin install python-uv@tqer39-plugins
```

## Usage

### Adding the marketplace

From within a Claude Code session:

```bash
/plugin marketplace add tqer39/claude-code-marketplace
```

Or configure it in `.claude/settings.json` for your project:

```json
{
  "extraKnownMarketplaces": {
    "tqer39-plugins": {
      "source": {
        "source": "github",
        "repo": "tqer39/claude-code-marketplace"
      }
    }
  }
}
```

### Installing plugins

Install individual plugins by scope:

```bash
# User scope (you, all projects) — default
/plugin install common-ci@tqer39-plugins

# Project scope (shared with team via .claude/settings.json)
/plugin install common-ci@tqer39-plugins --scope project

# Local scope (you, this project only)
/plugin install common-ci@tqer39-plugins --scope local
```

### Managing plugins

```bash
# Browse all available plugins
/plugin

# Enable/disable without uninstalling
/plugin enable common-ci@tqer39-plugins
/plugin disable common-ci@tqer39-plugins

# Uninstall
/plugin uninstall common-ci@tqer39-plugins

# Reload after changes
/reload-plugins
```

### Updating

```bash
# Update all marketplaces
/plugin marketplace update

# Update a specific marketplace
/plugin marketplace update tqer39-plugins
```

### Removing the marketplace

```bash
/plugin marketplace remove tqer39-plugins
```

> **Note:** Removing a marketplace also uninstalls all plugins from it.

### Pre-configuring plugins per project

Add to your project's `.claude/settings.json`:

```json
{
  "extraKnownMarketplaces": {
    "tqer39-plugins": {
      "source": {
        "source": "github",
        "repo": "tqer39/claude-code-marketplace"
      }
    }
  },
  "enabledPlugins": {
    "common-ci@tqer39-plugins": true,
    "terraform@tqer39-plugins": true
  }
}
```

## Plugins

### common-ci

Common CI/CD skills shared across all repositories.

| Skill | Description |
|-------|-------------|
| pull-request | Automate GitHub PR workflow with rebase, conflict resolution, and description generation |
| pr-review | Review pull requests for quality, security, and convention compliance |
| commit-convention | Enforce Conventional Commits format and provide commit message suggestions |
| github-actions | GitHub Actions workflow best practices and troubleshooting |
| gitignore | Generate and update .gitignore files with automatic project detection |
| agent-config-init | Initialize unified LLM coding agent configuration (AGENTS.md) |
| redesign | Architectural analysis and redesign proposal workflow |
| auto-merge | Generate auto-approve and auto-merge workflow for PRs with `claude-auto` label |

### git

Git workflow commands.

| Command | Description |
|---------|-------------|
| auto-commit | Auto stage and commit with emoji prefix + Japanese summary |
| create-pr | Create a PR from the current branch with auto push and `claude-auto` label |

### security

Security review skills: supply chain, dependency auditing, and vulnerability detection.

| Skill | Description |
|-------|-------------|
| supply-chain | Audit supply chain security: lockfile integrity, dependency pinning, typosquatting detection, GitHub Actions SHA pinning, vulnerability scanning config |

### terraform

Terraform review, security, and best practices.

| Skill | Description |
|-------|-------------|
| tf-review | Review Terraform code for best practices and common mistakes |
| tf-security | Terraform security review focusing on IAM, networking, and encryption |

### python-uv

Python project workflow using uv package manager.

| Skill | Description |
|-------|-------------|
| uv-workflow | Python project workflow using uv package manager |

## Development

```bash
make bootstrap    # Install dependencies
just lint         # Run linting
```

## Validation

```bash
claude plugin validate .
```

## License

Private use only.
