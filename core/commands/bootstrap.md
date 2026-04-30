---
description: Set up isolated security testing lab
agent: bootstrapper
subtask: false
---

<purpose>
Entry point for the security lab bootstrap workflow. Delegates to `@bootstrapper` agent for multi-session security onboarding.

User invocation:
  /bootstrap [<project-name>]

Examples:
  /bootstrap
    → Start or resume lab setup workflow; auto-detect project name from repo.

  /bootstrap my-billing-service
    → Start or resume lab setup with "my-billing-service" as the project name hint.
</purpose>

<inputs>
- projectName='$1': string — OPTIONAL. Project name hint passed to `@bootstrapper`.
- allArguments='$ARGUMENTS': string — full argument string for additional context.
</inputs>

<process>
1. Pass project-name hint (if provided) to `@bootstrapper` agent.
2. Tell `@bootstrapper` to use `.samourai/blueprints/project-bootstrap/` as
   the structural reference for generated setup instructions when available.
3. `@bootstrapper` checks for existing state at `.samourai/ai/local/bootstrapper-context.yaml`.
4. If state exists: resume from last phase.
5. If no state: start fresh with repo scan.
6. During interview, ask language selection first (French or English), lock it in state, then continue.
7. Follow the multi-session workflow:
   scan → assess → interview → lab-setup → draft → review → write.
8. Lab setup phase: configure isolated security testing lab with:
   - environment provisioning
   - tool installation (scanner and analysis tooling)
   - network isolation controls
   - explicit safety markers and authorization boundaries
9. MCP setup phase: detect available tools, ask targeted questions,
   activate relevant MCP entries in `.opencode/opencode.jsonc` when required by the workflow.
</process>

<notes>
- This command uses `subtask: false` because the lab setup workflow is multi-session and needs the main conversation context.
- The `@bootstrapper` agent manages its own persistent state across sessions.
- For the manual (non-automated) adoption path, see `.samourai/core/governance/conventions/onboarding-existing-project.md`.
- Blueprints are references, not additional write permissions. The bootstrapper
  must still obey its own write allowlist.
</notes>
