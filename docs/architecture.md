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
