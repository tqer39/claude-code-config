# Language & Tool Detection Rules

Scan the project root for the following files and directories to determine which gitignore.io templates to include.

## Languages & Runtimes

| Indicator File/Dir | Template Name |
| --- | --- |
| `package.json` | `node` |
| `requirements.txt`, `setup.py`, `setup.cfg`, `pyproject.toml`, `Pipfile`, `tox.ini` | `python` |
| `Cargo.toml` | `rust` |
| `go.mod`, `go.sum` | `go` |
| `Gemfile`, `*.gemspec` | `ruby` |
| `pom.xml`, `build.gradle`, `build.gradle.kts`, `*.java` | `java` |
| `build.sbt` | `scala` |
| `mix.exs` | `elixir` |
| `*.swift`, `Package.swift` | `swift` |
| `*.kt`, `*.kts` | `kotlin` |
| `composer.json` | `composer` |
| `*.cs`, `*.csproj`, `*.sln` | `csharp` |
| `*.fs`, `*.fsproj` | `fsharp` |
| `stack.yaml`, `*.cabal` | `haskell` |
| `deno.json`, `deno.jsonc` | `deno` |
| `*.dart`, `pubspec.yaml` | `dart` |
| `*.zig` | `zig` |
| `CMakeLists.txt`, `*.cpp`, `*.c`, `*.h` | `c++` |
| `*.r`, `*.R`, `*.Rproj` | `r` |
| `*.lua` | `lua` |
| `*.pl`, `*.pm` | `perl` |
| `Project.toml`, `*.jl` | `julia` |

## Frameworks

| Indicator File/Dir | Template Name |
| --- | --- |
| `next.config.*` | `nextjs` |
| `nuxt.config.*` | `nuxt` |
| `angular.json` | `angular` |
| `svelte.config.*` | `svelte` |
| `vue.config.*`, `vite.config.*` (with vue dependency) | `vue` |
| `Podfile`, `*.xcworkspace`, `*.xcodeproj` | `xcode` |
| `android/`, `*.gradle` (with android plugin) | `android` |
| `flutter/`, `.flutter-plugins` | `flutter` |
| `rails`, `Rakefile` (with Rails) | `rails` |
| `django`, `manage.py` | `django` |
| `laravel`, `artisan` | `laravel` |

## Build Tools & Package Managers

| Indicator File/Dir | Template Name |
| --- | --- |
| `yarn.lock` | `yarn` |
| `pnpm-lock.yaml` | `pnpm` |
| `Makefile` | `cmake` |
| `gradlew`, `gradle/` | `gradle` |
| `mvnw`, `.mvn/` | `maven` |
| `bazel`, `BUILD`, `WORKSPACE` | `bazel` |

## Infrastructure & DevOps

| Indicator File/Dir | Template Name |
| --- | --- |
| `*.tf`, `*.tfvars` | `terraform` |
| `Vagrantfile` | `vagrant` |
| `Dockerfile`, `docker-compose.yml`, `docker-compose.yaml` | `docker` |
| `serverless.yml`, `serverless.yaml` | `serverless` |
| `pulumi/`, `Pulumi.yaml` | `pulumi` |
| `ansible.cfg`, `playbook.yml` | `ansible` |

## Editors & IDEs

| Indicator File/Dir | Template Name |
| --- | --- |
| `.idea/` | `jetbrains` |
| `.vscode/` | `visualstudiocode` |
| `*.sublime-project`, `*.sublime-workspace` | `sublimetext` |
| `.vim/`, `.vimrc` (project-local) | `vim` |
| `.emacs`, `.dir-locals.el` | `emacs` |

## OS (Always Include All Three)

These are always added regardless of detection:

| Template Name |
| --- |
| `macos` |
| `linux` |
| `windows` |

## Detection Notes

- Only scan the **project root** directory (not subdirectories) for indicator files
- Use glob patterns for wildcard matches (e.g., `*.java`)
- For directory indicators (e.g., `.idea/`), check existence with `ls` or glob
- A single project may match multiple templates — collect all matches
- When in doubt about a match, include it — the user will confirm in the next step
