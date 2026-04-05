# Redesign Proposal Template

This file defines the format for the redesign proposal document. The generating agent must follow this template, adapting section content to the locale.

## Locale

The proposal language is determined by locale:

- `ja` — Japanese (default)
- `en` — English

Locale detection priority:

1. User explicitly requested a language → use that
2. Conversation language — match the language the user has been using
3. Default → `ja`

## Template

### Japanese (`ja`)

```markdown
# [プロジェクト名] 再設計提案

## エグゼクティブサマリー

対象スコープ、提案する方向性、期待される効果を3-5文で要約。

## 現状分析

### 強み

- 現在の設計で上手く機能している点
- 維持すべきパターンや設計判断

### 課題

- 偶発的複雑性とその影響
- 結合ホットスポットや抽象度のミスマッチ
- 具体的なファイルやモジュールを参照すること

## 提案アーキテクチャ

### 概要

提案する設計の全体像。Mermaid図があると効果的な場合は含める。

### ディレクトリ構成

提案するディレクトリレイアウト（変更がある場合のみ）。

### 主要設計判断

- 判断内容とその理由
- 検討した代替案と却下理由
- トレードオフの明示

### 技術スタック変更

変更がある場合のみ記載。変更なしなら省略。

## 移行パス

### フェーズ 1: [名前]

- **変更内容**: 具体的に何を変えるか
- **規模**: S / M / L / XL
- **前提条件**: このフェーズを始める前に必要なこと
- **リスク**: 何が起きうるか、どう対処するか
- **検証方法**: 成功をどう確認するか

### フェーズ 2: [名前]

（同様の構成で続ける）

## リスクと考慮事項

- 全体を通じたリスク
- 組織的・技術的な制約
- 注意すべき依存関係

## 補足

その他の参考情報、関連するADR、推奨リソースなど。
```

### English (`en`)

```markdown
# [Project Name] Redesign Proposal

## Executive Summary

Summarize the scope, proposed direction, and expected impact in 3-5 sentences.

## Current State Analysis

### Strengths

- What's working well in the current design
- Patterns and decisions worth preserving

### Issues

- Accidental complexity and its impact
- Coupling hotspots and abstraction mismatches
- Reference specific files and modules

## Proposed Architecture

### Overview

High-level view of the proposed design. Include a Mermaid diagram if it genuinely helps.

### Directory Structure

Proposed directory layout (only if it changes).

### Key Design Decisions

- What was decided and why
- Alternatives considered and why they were rejected
- Explicit tradeoffs

### Technology Stack Changes

Only if applicable. Omit if no changes.

## Migration Path

### Phase 1: [Name]

- **Changes**: What specifically changes
- **Size**: S / M / L / XL
- **Prerequisites**: What must be true before starting
- **Risks**: What could go wrong and how to mitigate
- **Validation**: How to confirm success

### Phase 2: [Name]

(Continue with the same structure)

## Risks and Considerations

- Cross-cutting risks
- Organizational and technical constraints
- Dependencies to watch

## Appendix

Additional references, related ADRs, recommended resources.
```

## Writing Rules

1. **Only include sections that have content.** If there are no technology stack changes, omit that section entirely. Do not include empty sections.

2. **Never fabricate information.** Every claim must be grounded in code or patterns actually found during the reconnaissance phase. If uncertain, say so explicitly.

3. **Use GitHub callout syntax** where appropriate:

   ```markdown
   > [!NOTE]
   > Supplementary information.

   > [!WARNING]
   > Information requiring immediate attention.

   > [!IMPORTANT]
   > Critical context for understanding the proposal.
   ```

4. **File names** must always be wrapped in backticks: `src/utils/auth.ts`.

5. **Mermaid diagrams** may be included when they genuinely help explain architecture or data flow. Do not add diagrams for decoration.

   ````markdown
   ```mermaid
   graph LR
     A[Input] --> B[Process] --> C[Output]
   ```
   ````

6. **Size estimates** use T-shirt sizes (S/M/L/XL), not hours or days. Avoid false precision.

7. **Migration phases** must each deliver standalone value. No phase should leave the system in a broken intermediate state.
