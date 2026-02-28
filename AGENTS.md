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
