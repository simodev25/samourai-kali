# Document Templates

Authoring templates for all document types used in this repository.

## Purpose

Templates define the **structure** (sections, front-matter, ordering) for each document type. They are:

- **Read by agents at runtime** — `@spec-writer`, `@plan-writer`, `@test-plan-writer`, and `@doc-syncer` use these as structural guides.
- **Used by humans** — Copy a template when authoring a new document manually.

Agent prompts define quality rules and domain-specific logic; templates define only structure. If a template is absent, agents fall back to their embedded default structure.

## Templates

| Template | Purpose |
|----------|---------|
| `change-spec-template.md` | Change specification (`chg-<workItemRef>-spec.md`) |
| `decision-record-template.md` | Decision records of all types (ADR/PDR/TDR/BDR/ODR) |
| `feature-spec-template.md` | Feature specifications for `.samourai/docai/spec/features/` |
| `test-spec-template.md` | Test specifications for `.samourai/docai/quality/test-specs/` |
| `test-plan-template.md` | Per-change test plans (`chg-<workItemRef>-test-plan.md`) |
| `implementation-plan-template.md` | Per-change implementation plans (`chg-<workItemRef>-plan.md`) |
| `north-star-template.md` | Product north star document (`.samourai/docai/overview/01-north-star.md`) |
| `pr-instructions-template.md` | PR/MR platform instructions (`.samourai/ai/agent/pr-instructions.md`) |

## Conventions

- Templates are **shared** and versioned; link to canonical sources.
- Each template includes YAML front-matter skeleton and inline HTML comment guidance.
- See `.samourai/docai/documentation-handbook.md` §17 for the full template index.
