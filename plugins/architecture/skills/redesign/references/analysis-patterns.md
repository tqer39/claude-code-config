# Architecture Analysis Patterns

A compact catalog of patterns for evaluating and proposing architectures. Each entry describes when a pattern fits, when it doesn't, and what you trade away by choosing it. Use this as a reference during Phase 2 (Analysis) — don't force patterns onto a codebase that has its own working conventions.

## Structural Patterns

### Monolith

Single deployable unit containing all functionality.
**Fits**: Small teams, early-stage products, low operational complexity, fast iteration needed.
**Doesn't fit**: Multiple teams needing independent deployment, vastly different scaling needs across components.
**Tradeoff**: Simple to deploy and reason about, but changes in one area risk breaking another. Scaling is all-or-nothing.

### Modular Monolith

Monolith with enforced module boundaries (separate packages/namespaces with explicit interfaces).
**Fits**: Growing teams that need clearer ownership without the operational cost of distributed systems.
**Doesn't fit**: Teams that need independent deployment cycles or polyglot tech stacks.
**Tradeoff**: Most of the simplicity of a monolith with better isolation. Requires discipline to maintain boundaries — without it, degrades into a regular monolith.

### Microservices

Independently deployable services communicating over network boundaries.
**Fits**: Large organizations, components with fundamentally different scaling/deployment needs, polyglot requirements.
**Doesn't fit**: Small teams, early-stage products, tightly coupled domains. Almost always premature for teams under ~20 engineers.
**Tradeoff**: Independent deployment and scaling, but massive increase in operational complexity (networking, observability, data consistency).

### Serverless / FaaS

Event-driven functions deployed individually, managed by the platform.
**Fits**: Event-driven workloads, sporadic traffic, glue code, quick prototypes, cost-sensitive low-traffic apps.
**Doesn't fit**: Long-running processes, low-latency requirements, complex stateful workflows.
**Tradeoff**: Near-zero operational overhead and cost-efficient at low scale, but cold starts, vendor lock-in, and debugging difficulty.

### Event-Driven Architecture

Components communicate through events (messages/streams) rather than direct calls.
**Fits**: Workflows with multiple independent reactions to the same trigger, audit requirements, eventual consistency is acceptable.
**Doesn't fit**: Workflows requiring immediate consistency, simple CRUD apps, teams unfamiliar with async patterns.
**Tradeoff**: Excellent decoupling and extensibility, but harder to trace, debug, and reason about ordering.

## Code Organization Patterns

### Layer-Based (MVC / Clean / Hexagonal)

Code organized by technical responsibility (controllers, services, repositories, domain).
**Fits**: Teams familiar with the pattern, projects where technical concerns are the primary axis of change.
**Doesn't fit**: Projects where features span many layers — leads to shotgun surgery across directories.
**Tradeoff**: Clear separation of concerns, but a single feature change often touches many directories.

### Feature-Based (Vertical Slices)

Code organized by feature or use case, each slice containing its own controller/service/data access.
**Fits**: Teams organized around features, projects where each feature is relatively independent.
**Doesn't fit**: Heavy cross-cutting concerns, features with deep shared state.
**Tradeoff**: Feature changes are localized, but shared logic needs careful handling to avoid duplication.

### Domain-Based (DDD)

Code organized around business domains with explicit bounded contexts, aggregates, and ubiquitous language.
**Fits**: Complex business logic, multiple subdomains with different models, large teams needing clear boundaries.
**Doesn't fit**: Simple CRUD apps, small projects, teams without domain expertise to guide boundaries.
**Tradeoff**: Excellent alignment between code and business, but high upfront investment in domain modeling. Overkill for simple problems.

## Data Patterns

### Repository Pattern

Abstract data access behind an interface. Application code talks to repositories, not directly to the database.
**Fits**: Projects that need testability, potential to swap data sources, or complex query logic worth encapsulating.
**Doesn't fit**: Simple apps where the ORM already provides sufficient abstraction.
**Tradeoff**: Clean separation and testability, but adds indirection. Can become a thin wrapper that doesn't earn its keep.

### Active Record

Domain objects contain both data and persistence logic (e.g., `user.save()`).
**Fits**: Simple CRUD applications, rapid prototyping, frameworks that make it the default (Rails, Laravel).
**Doesn't fit**: Complex business logic where persistence and domain rules should be separate.
**Tradeoff**: Fast to develop, minimal boilerplate. Blurs the line between domain and infrastructure as complexity grows.

### CQRS (Command Query Responsibility Segregation)

Separate models for reading and writing data.
**Fits**: Asymmetric read/write loads, complex read projections, systems where read and write models naturally differ.
**Doesn't fit**: Simple CRUD, symmetric read/write patterns, small teams.
**Tradeoff**: Optimized read and write paths independently, but increased system complexity and eventual consistency challenges.

### Event Sourcing

Store state as a sequence of events rather than current state snapshots.
**Fits**: Audit-critical systems, complex temporal queries, undo/replay requirements.
**Doesn't fit**: Simple state management, systems needing fast arbitrary queries, teams without event sourcing experience.
**Tradeoff**: Complete audit trail and time-travel debugging, but complex to implement, query, and evolve schemas.

## Common Antipatterns

### God Class / God Module

A single class or module that knows too much and does too much. Symptom: one file that appears in most diffs.
**Detection**: File >500 lines with unrelated responsibilities, high import count, high git churn.
**Resolution**: Extract cohesive groups of functionality into focused modules.

### Circular Dependencies

Module A depends on B, which depends on A (directly or transitively).
**Detection**: Import analysis, build tool warnings, or runtime errors during refactoring.
**Resolution**: Extract shared logic into a third module, use dependency inversion, or merge if the modules are not actually separate concerns.

### Leaky Abstraction

An abstraction that forces callers to understand internal implementation details.
**Detection**: Callers frequently reach into internals, workaround code near abstraction boundaries, error handling that exposes implementation details.
**Resolution**: Redesign the abstraction's interface to match how it's actually used, not how it's implemented.

### Over-Engineering

More abstraction, configurability, or generality than the problem requires.
**Detection**: Interfaces with single implementations, factory-of-factory patterns, config for behavior that never changes, deep inheritance hierarchies.
**Resolution**: Inline the unnecessary abstraction. Prefer concrete code that can be generalized later if needed (YAGNI).

### Config Sprawl

Configuration spread across many files, formats, and locations with unclear precedence.
**Detection**: Multiple config file formats, environment variable overrides of overrides, "where does this setting come from?" is hard to answer.
**Resolution**: Consolidate into fewer config sources with documented precedence. Prefer convention over configuration.

## Decision Heuristics

When evaluating which pattern to recommend, consider these questions:

1. **How big is the team?** Small teams (<5) benefit from simplicity. Patterns that require coordination overhead (microservices, CQRS) often cost more than they save.

2. **What changes most often?** Organize code along the axis of most frequent change. If features change independently, use feature-based organization. If the data model changes, invest in good data abstractions.

3. **What's the operational maturity?** Distributed architectures require monitoring, tracing, and deployment infrastructure. If the team doesn't have these, a monolith is more honest.

4. **Is this essential or accidental complexity?** Only invest in patterns that address real problems. If the current approach works and the team understands it, the best redesign might be no redesign.

5. **Can the team maintain it?** The best architecture is one the team can understand, evolve, and debug. A theoretically superior architecture that nobody on the team groks is worse than a simple one they can reason about.
