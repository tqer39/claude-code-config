# PR Description Template

This file defines the format for pull request titles and descriptions. The generating agent must follow this template exactly.

## Locale

The description language is determined by locale:

- `ja` — Japanese (default)
- `en` — English

Locale detection priority:

1. User explicitly requested a language → use that
2. Conversation language — match the language the user has been using
3. Default → `ja`

## Title Format

A single line. No markdown formatting in the title. Start with a type emoji:

| Emoji | Type |
| ----- | ---- |
| ✨ | New feature |
| 🐛 | Bug fix |
| ♻️ | Refactoring |
| 📝 | Documentation |
| 🎨 | Style / formatting |
| ⚡ | Performance |
| 🔧 | Configuration / tooling |
| 🧪 | Tests |
| 🔒 | Security |
| ⬆️ | Dependency update |
| 🗑️ | Removal / deprecation |

Example titles:

- `✨ ユーザー認証機能を追加`
- `🐛 Fix race condition in payment processing`

If multiple types apply, use the primary one.

## Description Format

### Japanese (`ja`)

```markdown
## 📒 変更概要

- 変更点を箇条書きで簡潔に記述
- 各項目の先頭に適切な絵文字を付ける
- 「何を」「なぜ」変更したかを明確にする

## ⚒ 技術的詳細

- 実装の技術的なポイントを記述
- ファイル名は `backticks` で囲む
- コードの構造変更やアーキテクチャ上の判断があれば記述

## ⚠ 注意事項

- レビュアーに特に確認してほしい箇所
- 破壊的変更やマイグレーション手順
- 既知の制限事項
```

### English (`en`)

```markdown
## 📒 Summary of Changes

- Describe changes concisely in bullet points
- Prefix each item with an appropriate emoji
- Clarify "what" changed and "why"

## ⚒ Technical Details

- Note technical implementation details
- Wrap file names in `backticks`
- Document architectural decisions or structural changes

## ⚠ Points of Caution

- Areas that need special attention from reviewers
- Breaking changes or migration steps
- Known limitations
```

## Writing Rules

1. **Only include sections that have content.** If there are no special cautions, omit the `⚠` section entirely. Do not include empty sections.

2. **Never fabricate information.** Every claim in the description must be verifiable from the actual `git diff` and `git log`. If you are uncertain about something, do not include it.

3. **Use GitHub callout syntax** where appropriate for important notes:

   ```markdown
   > [!NOTE]
   > Supplementary information the reader should know.

   > [!TIP]
   > Helpful advice for using or reviewing this change.

   > [!IMPORTANT]
   > Critical information necessary for understanding this PR.

   > [!WARNING]
   > Information that requires the reader's immediate attention.

   > [!CAUTION]
   > Potential risks or negative outcomes of this change.
   ```

4. **File names** must always be wrapped in backticks: `src/utils/auth.ts`.

5. **Mermaid diagrams** may be included when they genuinely help explain a flow or architecture change. Do not add diagrams just for decoration.

   ````markdown
   ```mermaid
   graph LR
     A[Input] --> B[Process] --> C[Output]
   ```
   ````

6. **Emoji usage in bullet points** — use sparingly and consistently:
   - ➕ Added
   - ✏️ Modified
   - 🗑️ Removed
   - 🔄 Renamed / moved
   - 🔧 Configuration change
