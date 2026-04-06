# File Type Detection and EditorConfig Rules

## Base Defaults (always applied)

```ini
[*]
charset = utf-8
end_of_line = lf
insert_final_newline = true
indent_size = 2
indent_style = space
trim_trailing_whitespace = true
```

## Detection Table

Only add a section when the rule differs from `[*]` defaults.

| Indicator Files / Extensions | EditorConfig Section | Rules | Notes |
|------------------------------|---------------------|-------|-------|
| `Makefile`, `*.mk`, `GNUmakefile` | `[{Makefile,*.mk,GNUmakefile}]` | `indent_style = tab` | Make requires tabs |
| `*.py`, `*.pyi` | `[*.{py,pyi}]` | `indent_size = 4` | PEP 8 standard |
| `*.rs` | `[*.rs]` | `indent_size = 4` | Rust standard (rustfmt) |
| `*.go` | `[*.go]` | `indent_style = tab` | gofmt requires tabs |
| `*.java`, `*.kt`, `*.kts` | `[*.{java,kt,kts}]` | `indent_size = 4` | Java/Kotlin convention |
| `*.cs` | `[*.cs]` | `indent_size = 4` | C# convention |
| `*.rb`, `Gemfile`, `Rakefile` | `[*.rb]` | `indent_size = 2` | Ruby convention (same as default, skip if default is 2) |
| `*.md`, `*.mdx` | `[*.{md,mdx}]` | `trim_trailing_whitespace = false` | Trailing spaces = line break in Markdown |
| `*.yml`, `*.yaml` | `[*.{yml,yaml}]` | `indent_size = 2` | YAML standard |
| `*.json`, `*.json5`, `*.jsonc` | `[*.{json,json5,jsonc}]` | `indent_size = 2` | JSON standard (same as default, add for explicitness) |
| `*.toml` | `[*.toml]` | `indent_size = 2` | TOML convention |
| `*.xml`, `*.svg`, `*.html` | `[*.{xml,svg,html}]` | `indent_size = 2` | Web standard |
| `*.css`, `*.scss`, `*.less` | `[*.{css,scss,less}]` | `indent_size = 2` | CSS convention |
| `*.sh`, `*.bash`, `*.zsh` | `[*.{sh,bash,zsh}]` | `indent_size = 2` | Shell convention |
| `*.tf`, `*.tfvars` | `[*.{tf,tfvars}]` | `indent_size = 2` | Terraform standard |
| `justfile` | `[justfile]` | `indent_size = 4` | just recipe indentation |
| `Dockerfile`, `Dockerfile.*` | `[Dockerfile*]` | `indent_size = 4` | Docker convention |
| `*.gradle`, `*.gradle.kts` | `[*.{gradle,gradle.kts}]` | `indent_size = 4` | Gradle convention |
| `*.lua` | `[*.lua]` | `indent_size = 2` | Lua convention |
| `*.swift` | `[*.swift]` | `indent_size = 4` | Swift convention |
| `*.php` | `[*.php]` | `indent_size = 4` | PSR-12 standard |
| `*.ex`, `*.exs` | `[*.{ex,exs}]` | `indent_size = 2` | Elixir convention |

## Section Ordering

Sections should appear in this order:

1. `[*]` — base defaults
2. Language-specific sections — alphabetical by primary extension
3. Config file sections — `Makefile`, `justfile`, `Dockerfile` etc.

## Comments

Each section should have a short comment explaining why the rule differs from the default:

```ini
# Python (PEP 8)
[*.{py,pyi}]
indent_size = 4
```
