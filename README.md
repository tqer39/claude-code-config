# tqer39-plugins

Personal SRE/DevOps plugin marketplace for Claude Code.

## Overview

A centralized marketplace that distributes shared skills and commands across ~20 personal repositories. Built on the [Claude Code Plugin Marketplace](https://code.claude.com/docs/en/plugin-marketplaces) system.

## Installation

```bash
# Add marketplace
claude plugin marketplace add tqer39/claude-code-marketplace

# Install plugins
claude plugin install common-ci@tqer39-plugins
claude plugin install terraform@tqer39-plugins
claude plugin install python-uv@tqer39-plugins
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

### terraform

Terraform review, security, and best practices.

| Skill | Description |
|-------|-------------|
| tf-review | Review Terraform code for best practices and common mistakes |
| tf-security | Terraform security review focusing on IAM, networking, and encryption |

### python-uv

Python + uv workflow and supply chain security.

| Skill | Description |
|-------|-------------|
| uv-workflow | Python project workflow using uv package manager |
| supply-chain-security | Python/PyPI supply chain security checks and dependency auditing |

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
