---
name: redesign
description: Design or redesign a project's architecture from scratch. Use this skill whenever the user asks about redesigning, rethinking, or re-architecting a project or part of a project. Also use when the user says things like "もしゼロから作り直すなら", "設計を見直したい", "アーキテクチャを再設計", "このプロジェクトの理想的な構成は", "if I were to start over", "what would you change about this architecture", "redesign this", "how should this project be structured", "設計レビューしたい", "技術的負債を解消したい", "リファクタリングの方針を立てたい". Use even when the user asks vaguely about improving project structure, cleaning up technical debt, or wanting a fresh perspective on their codebase.
---

# redesign

Analyze a project's architecture and produce a structured redesign proposal through a four-phase process: reconnaissance, analysis, dialogue, and proposal.

Unlike mechanical workflow skills, this skill is a thinking process. The goal is to deeply understand the codebase, have a genuine conversation about tradeoffs, and produce a proposal that's honest about what's working and what isn't. If the current design is sound, say so — don't invent problems to justify a redesign.

## Locale

Match the language the user is using in the conversation. Default to Japanese (`ja`) if ambiguous. All output — phase summaries, questions, the final proposal — should be in the detected locale.

## Phase 1: Reconnaissance

The goal is to build a mental model of the project before forming opinions.

### 1.1 Determine Scope

Ask the user what they want to redesign:

- The entire project?
- A specific subsystem or module?
- A particular concern (e.g., data layer, API surface, deployment)?

For monorepos, narrow down to specific packages before proceeding. Don't try to redesign everything at once.

### 1.2 Explore the Codebase

Use the Agent tool with `subagent_type=Explore` for thorough exploration. Work through this checklist systematically:

| Area | What to look at |
| ------ | ---------------- |
| Structure | Directory layout, module boundaries, entry points |
| Dependencies | `package.json`, `go.mod`, `requirements.txt`, `Cargo.toml`, etc. — both what's used and what's surprising |
| Configuration | Environment variables, config files, feature flags |
| Data | Database schemas, migrations, data flow patterns |
| Tests | Test structure, coverage patterns, what's tested vs. what isn't |
| CI/CD | Pipeline definitions, deployment targets, build steps |
| Git history | Recent churn (`git log --oneline -30`), hot files (sort by frequency from `git log` output) |
| Documentation | README, ADRs, inline docs — what's documented vs. what's tribal knowledge |

Not every area applies to every project. Skip what's irrelevant. For small projects (<5 files), a quick read-through replaces this checklist.

### 1.3 Assess Project Scale

Categorize the project to calibrate the depth of analysis:

| Scale | Heuristic | Approach |
| ------- | --------- | -------- |
| Small | <5 files, single concern | Lightweight analysis. Often the answer is "rewrite it" rather than "redesign it." |
| Medium | 5-50 files, a few modules | Standard four-phase process. |
| Large | 50+ files, multiple domains | Focus on the highest-impact subsystem first. Break the redesign into scoped proposals. |

### 1.4 Gather Constraints

Ask the user about constraints that shape the design space. Don't ask all at once — weave these into the conversation naturally:

- **Domain**: What does this project actually do? What's the core problem it solves?
- **Team**: How many people work on this? What's their experience level?
- **Deployment**: Where does this run? Cloud, on-prem, edge, CLI?
- **Technical constraints**: Must it stay in the current language/framework? Are there integration requirements?
- **Appetite for change**: Is the user looking for incremental improvements or willing to consider a significant rewrite?
- **Timeline**: Is there urgency, or is this exploratory?

If the user doesn't know or doesn't care about some of these, use reasonable defaults and move on.

## Phase 2: Analysis

The goal is to form an honest assessment of the current architecture.

### 2.1 Identify Strengths

Start with what's working. Every codebase has good decisions in it — find them and acknowledge them. This builds trust and ensures the proposal preserves what shouldn't change.

### 2.2 Classify Complexity

For each problem area you find, classify it:

- **Essential complexity**: Inherent to the problem domain. Can't be eliminated, only managed. (e.g., "payment processing has many edge cases" — that's the nature of payments)
- **Accidental complexity**: Introduced by implementation choices. Can be reduced or eliminated. (e.g., "three different HTTP clients because nobody knew the first one existed")

Focus redesign effort on accidental complexity. Essential complexity warrants better management strategies, not elimination attempts.

### 2.3 Pattern Recognition

Read `references/analysis-patterns.md` to inform your analysis. Look for:

- Which architectural patterns are currently in use (explicitly or implicitly)
- Whether the current patterns fit the project's actual needs
- Common antipatterns that are causing friction

Don't force-fit pattern names onto the codebase. If the project has its own implicit patterns that work, describe them on their own terms.

### 2.4 Find Hotspots

Identify specific areas of friction:

- **Coupling hotspots**: Changes in module A frequently require changes in module B
- **Abstraction mismatches**: An abstraction that doesn't match how it's actually used (over-abstracted or under-abstracted)
- **Knowledge silos**: Code that only one person understands (detectable from git blame patterns)
- **Churn**: Files that change in every PR (from git history)

### 2.5 Share Findings

Before proposing solutions, share your analysis with the user. Present it conversationally, not as a formal report. Ask for their reaction:

- "Does this match your experience?"
- "Are there pain points I missed?"
- "Is anything I flagged actually intentional?"

This step matters. Your analysis might be wrong, and the user has context you don't.

## Phase 3: Dialogue

The goal is to align on direction before writing a proposal.

### 3.1 Present Design Directions

Based on the analysis, present 2-3 possible directions. Typically:

1. **Incremental improvement**: Keep the current structure, fix the worst pain points. Low risk, fast payoff, but doesn't address structural issues.
2. **Structural reorganization**: Reshape module boundaries and abstractions while preserving the core. Medium risk, requires coordinated effort.
3. **Clean-slate design**: Design from scratch with current knowledge. High risk, high potential, but loses existing institutional knowledge embedded in the code.

For each direction, be concrete about what changes and what stays. Don't present vague platitudes — give specific examples of what the code would look like.

Not every project needs all three options. A small project might only warrant "keep it" vs. "rewrite it." A project with a fundamentally sound architecture might only need targeted improvements.

### 3.2 Discuss Tradeoffs

Help the user think through tensions:

- **Simplicity vs. flexibility**: A simpler design is easier to understand but harder to extend. Which matters more for this project?
- **Migration speed vs. quality**: Can the team afford a long migration, or do they need quick wins?
- **Consistency vs. pragmatism**: Is it worth rewriting working code just for consistency?

### 3.3 Reach Agreement

Get explicit agreement on a direction before writing the proposal. The proposal should hold no surprises — it's a formalization of what you've already discussed.

If the user is just looking for validation that their current architecture is fine, and it is, say so clearly. Don't manufacture a redesign proposal for a codebase that doesn't need one.

## Phase 4: Proposal

The goal is to produce a clear, actionable redesign document.

### 4.1 Generate the Proposal

Read `references/output-template.md` for the exact template. Fill it in based on the agreed-upon direction from Phase 3.

Key principles for the proposal:

- **Grounded in evidence**: Every claim references specific code, files, or patterns found during analysis. No hand-waving.
- **Honest about tradeoffs**: Every design decision has a cost. State it.
- **Phased migration**: Break the work into phases that each deliver standalone value. No "big bang" rewrites unless the project is small enough that it's actually safer.
- **Risk-aware**: Each phase should note what could go wrong and how to detect it.

### 4.2 Migration Path

The migration path is the most important part of the proposal. A beautiful target architecture is worthless without a realistic plan to get there.

For each phase:

- **What changes**: Specific modules, files, or boundaries that move
- **Size estimate**: T-shirt size (S/M/L/XL) — avoid false precision with hour estimates
- **Prerequisites**: What must be true before this phase can start
- **Risks**: What could go wrong and how to mitigate it
- **Validation**: How to confirm this phase succeeded before moving to the next

### 4.3 Present and Refine

Show the proposal to the user. Ask if anything needs adjustment. Iterate until they're satisfied.

## Edge Cases

### Project with No Clear Architecture

Some projects grow organically without deliberate architecture. In this case:

- Don't criticize the lack of architecture — it's a common and often reasonable outcome
- Focus on discovering the implicit patterns that do exist
- Propose a minimal structure that formalizes what's already working

### User Wants Validation, Not Change

If the user is really asking "is my architecture OK?", and it is:

- Clearly state that the current design is sound
- Point out specific strengths
- Suggest only minor improvements if any
- Don't manufacture problems to justify the skill's existence

### Overwhelming Technical Debt

If the codebase has severe, pervasive issues:

- Be honest but kind
- Focus on the 2-3 highest-leverage changes rather than cataloging every problem
- Propose a realistic first step, not a fantasy end state

### Legacy Codebase with Active Users

When the system is in production and can't be taken offline:

- Emphasize strangler fig pattern or similar incremental strategies
- Each migration phase must maintain backward compatibility
- Include rollback plans
