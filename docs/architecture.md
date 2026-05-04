# Samourai Kali Architecture

This document describes the delivery architecture and layering used by Samourai Kali.

## Layered model

1. **Core (`core/`)**
   - Canonical source for agents, commands, skills, governance conventions, and templates.
2. **Installer (`scripts/install-samourai.sh`)**
   - Copies core artifacts into target projects under `.samourai/` and selected editor adapters.
3. **Editor adapters (`adapters/`)**
   - Editor-specific integration points (OpenCode, VS Code, and additional adapters).
4. **Commands (`core/commands/`)**
   - Entry points that route user intent to specialized agents via structured contracts.
5. **Agents (`core/agents/`)**
   - Role-focused executors for planning, coding, review, quality, security investigation, and reporting.
6. **Skills (`core/skills/`)**
   - Reusable operational workflows injected into agent execution when relevant.

## Kali tooling contract

Samourai maps cyber agents and command prompts to real Kali tooling through the
canonical matrix in `core/governance/conventions/kali-tooling-matrix.md`.

Every tool-dependent workflow must:

- preflight tool availability with `command -v ... || true`;
- record missing tools instead of inventing results;
- keep active testing lab-only and inside written authorization;
- preserve `tools_used`, `commands_run`, `evidence_paths`, `missing_tools`,
  `limitations`, and `next_step` across handoffs.

Support agents do not run offensive tools directly by default. They consume or
review evidence and delegate execution to `@runner` or the relevant cyber agent.

## Change artifacts

Per-work-item delivery artifacts live under:

- `.samourai/docai/changes/YYYY-MM/YYYY-MM-DD--<workItemRef>--<slug>/`

Canonical files per change include:

- `chg-<workItemRef>-spec.md`
- `chg-<workItemRef>-plan.md`
- `chg-<workItemRef>-test-plan.md`
- `chg-<workItemRef>-pm-notes.yaml`

## Data flow (high level)

- User invokes a command.
- Command delegates to one or more agents.
- Agents apply governance + skills + project profile constraints.
- Output and evidence are captured in change artifacts.
- Installer tests and quality checks validate portability and consistency.
