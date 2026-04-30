# Contributing to Samourai Kali

Thanks for contributing to Samourai Kali.

## Repository structure

- `core/agents/`: canonical agent definitions.
- `core/commands/`: slash-command definitions and contracts.
- `core/skills/`: reusable skills and operational playbooks.
- `core/governance/`: conventions and policies.
- `adapters/`: editor-specific adapter templates.
- `scripts/`: installer, uninstaller, and test scripts.
- `.samourai/docai/changes/`: per-change spec/plan/test-plan artifacts.

## Contributing an agent

1. Add or update a file in `core/agents/<agent>.md`.
2. Keep front matter consistent (`description`, `mode`, optional tools).
3. Use clear role/mission/constraints and explicit output contracts.
4. Validate installation output with installer tests.

## Contributing a skill

1. Add/update `core/skills/<skill>/SKILL.md`.
2. Keep the workflow concrete and verifiable.
3. Define when to use the skill and explicit constraints.
4. Ensure related commands/agents reference the skill correctly.

## Contributing a command

1. Add/update `core/commands/<command>.md`.
2. Required front matter fields: `description`, `agent`, `subtask`.
3. Follow the standard structure:
   - `<purpose>`
   - `<command>`
   - `<inputs>`
   - `<process>`
   - `<output_contract>`
4. Run `tools/validate-command-frontmatter` before opening a PR.

## PR workflow

1. Create a branch with convention: `<type>/<workItemRef>/<slug>`.
2. Ensure change artifacts exist in `.samourai/docai/changes/YYYY-MM/YYYY-MM-DD--<workItemRef>--<slug>/`.
3. Keep commits conventional and scoped.
4. Run `bash scripts/.tests/test-install-samourai.sh` before requesting review.
5. Open/update PR with clear summary, tests, and risk notes.
