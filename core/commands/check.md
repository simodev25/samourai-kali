---
#
description: Run this repo's evidence quality gates script and summarize results via the run-logs-runner.
agent: runner
---

<purpose>
Run the repository's configured evidence quality gates command and return a concise, high-signal summary with log pointers.

This command is intended for humans to invoke directly.
Agents should preferentially call `@runner` directly for execution/log-heavy tasks.
</purpose>

<command>
User invocation:
  /check [fast|slow|all|<gate>...] [--skip-autofix] [--dry-run]

Examples:
/check # default (usually all)
/check fast
/check slow
/check custody hashing redaction
</command>

<resolution>
Determine which evidence quality gates command to run:

1. Read `.samourai/AGENTS.md` (or root `AGENTS.md` as compatibility entrypoint) and look for an explicit evidence quality gates runner instruction.
   - If `.samourai/AGENTS.md` or the root `AGENTS.md` entrypoint includes a command like `./scripts/evidence-quality-gates.sh` (preferred) or any referenced path/command for evidence quality gates, use that.
   - If multiple are present, prefer the most explicit "Run all evidence quality gates" instruction.

2. Default fallback if no instruction found:
   - `./scripts/quality-gates.sh`

3. Pass through user-provided arguments (fast/slow/all/<gate>...) as-is to the resolved command.

4. Always run from repository root.
   </resolution>

<project_skills_activation>
Before running evidence quality gates:

1. Discover generated project skills in `.opencode/skills/project/**/SKILL.md`.
2. Select up to 2 skills most relevant to evidence-gate context (forensics/validation/ci/debug).
3. Apply selected skills as local execution constraints (command choice, expected checks, known pitfalls).
4. If no relevant project skill is found, continue with default evidence-gate resolution.
</project_skills_activation>

<behavior>
- Delegate actual execution to `@runner` (this command uses it as its agent).
- Ensure logs are saved under `.samourai/tmpai/run-logs-runner/<YYYY-MM-DD>/` and that output includes:
  - exact command
  - exit code
  - duration
  - log path(s)
  - `project_skills_applied` (selected names or empty list)
  - top error snippets and tail excerpts
- Evidence quality checks should include when available:
  - evidence completeness
  - hashing integrity
  - timestamp integrity
  - chain of custody metadata
  - sensitive data redaction
- If gates fail, prominently surface:
  - which evidence gates failed
  - pointers mentioned by scripts (e.g., evidence artifacts and failure reports)
</behavior>

<notes>
- Do not attempt fixes; this command is run-only.
- For fixing failures, use `/check-fix` (@fixer) or invoke `@fixer` directly.
</notes>
