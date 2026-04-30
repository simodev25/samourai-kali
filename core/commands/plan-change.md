---
#
description: Interactive investigation planning session to prepare context for /write-spec.
---

<purpose>
Guide the user through a structured, interactive planning conversation that transforms an initial target or finding into a complete, investigation-agnostic planning context for a single tracked investigation.

This command:

- Discovers or confirms the workItemRef (e.g., `PDEV-123`, `GH-456`) by scanning existing change specs or querying the tracker.
- Orients itself in the repository and security-relevant documentation under `.samourai/docai/spec/` and related docs.
- Systematically elicits and refines all information needed by `/write-spec` (target, attack surface, authorization, risks, evidence requirements, reporting needs).
- Concludes with a compact `<investigation_planning_summary>` plus a clear recommendation to invoke `/write-spec <workItemRef>`.

This command never writes files or modifies Git state; it operates purely via conversational planning and read-only repository inspection.
</purpose>

<command>
User invocation:
  /plan-change [<workItemRef>] [free-text idea / context]
Examples:
  /plan-change
    → Query tracker or discover next workItemRef, then ask what target/finding to investigate.
  /plan-change PDEV-123
    → Use PDEV-123 as the intended workItemRef, then start refinement questions.
  /plan-change GH-456 Suspicious auth bypass in tenant admin APIs
    → Use GH-456 as workItemRef and seed initial understanding from the target/finding text.
</command>

<inputs>
  <item>rawArguments: content after the command name (available via $ARGUMENTS).</item>
  <item>workItemRefHint: first token matching `<PREFIX>-<digits>` pattern (e.g., `PDEV-123`, `GH-456`); OPTIONAL.</item>
  <item>ideaSeed: remainder of rawArguments after stripping workItemRefHint; may be empty.</item>
</inputs>

<workItemRef_resolution>
Primary goal: determine the canonical workItemRef for this planning session.

Resolution rules:

1. If workItemRefHint is provided:
   - Validate format: uppercase prefix + hyphen + digits (e.g., `PDEV-123`, `GH-456`).
   - Treat as proposed workItemRef; ask user to confirm or override.

2. If no workItemRefHint:
   - Discover existing specs by scanning: `.samourai/docai/changes/**/chg-*-spec.md`.
   - For each match, parse the workItemRef segment (e.g., `chg-PDEV-123-spec.md` → `PDEV-123`).
   - Propose creating a new ticket via `@pm` or ask user to provide an existing reference.
   - If user provides a new reference, validate format and confirm.

3. Once confirmed, use workItemRef consistently in all summaries and handoff commands.

This command MUST NOT create folders or files in `.samourai/docai/changes/`; it only proposes and confirms the identifier for downstream commands.
</workItemRef_resolution>

<context_sources>
The planning agent may read from the repository to ground questions, but must not modify files.

Primary sources:

- `.samourai/docai/spec/**`: system-level and feature-level specifications.
- `.samourai/docai/overview/**`: domain and product overview documents.
- `.samourai/docai/decisions/**`: architecture decision records.
- `.samourai/docai/domain/**`, `.samourai/docai/diagrams/**`: architecture, flows, constraints.
- Existing change specs under `.samourai/docai/changes/**/chg-*-spec.md` for related changes.

Usage rules:

- When user describes the change, infer domain keywords and search documentation.
- Summarize only relevant parts in concise bullets; do not paste large documents.
- Quote document titles and short excerpts; ask user to confirm context anchors.
- Treat existing specs and ADRs as authoritative constraints unless explicitly revisiting.
  </context_sources>

<session_flow>

1. **Initialization & orientation**
   - Confirm single repository scope and target service/app.
   - Resolve and confirm workItemRef using workItemRef_resolution.
   - Clarify the investigation target or initial finding in plain language.
   - If ideaSeed provided, restate for confirmation.

2. **Define scope authorization**
   - Confirm explicit authorization boundaries and legal/ethical scope.
   - Capture allowed targets, forbidden targets, allowed tooling, and time windows.
   - Document rules of engagement and escalation contacts.

3. **Identify attack surface priorities**
   - Enumerate entry points: external services, APIs, auth flows, dependencies, infrastructure edges.
   - Rank by risk, exploit likelihood, impact, and investigative value.
   - Mark priority tiers for sequencing.

4. **Select tools and methodology**
   - Choose reconnaissance, analysis, validation, and evidence tools.
   - Confirm safe execution constraints for each tool.
   - Define data handling and sensitive-data redaction requirements.

5. **Plan investigation phases**
   - reconnaissance → analysis → POC → evidence → report
   - For each phase: goals, outputs, checkpoints, stop conditions.

6. **Risk controls and safety guardrails**
   - Ensure environment isolation and non-production safety.
   - Define rollback/containment actions for accidental impact.
   - Define evidence integrity expectations (hashing, timestamps, custody).

7. **Dependencies, risks, assumptions**
   - Internal dependencies: platforms, teams, credentials, staging access.
   - External dependencies: third-party intel, CVE databases, tooling feeds.
   - Risks (RSK-# style) with impact/probability and mitigations.
   - Classification and severity assumptions for unresolved unknowns.

8. **Affected assets and scope boundaries**
   - List targeted assets with `[PRIORITY]`, `[DEFERRED]`, `[OUT]`.
   - Clarify in-scope attack paths vs prohibited pathways.

9. **Investigation acceptance criteria and reporting strategy**
   - Draft measurable criteria for a completed investigation.
   - Define report audience, required sections, and disclosure path.

10. **Consolidation and readiness check**
   - Maintain explicit list of Open Questions (BLOCKING / NON-BLOCKING with owner).
   - Resolve as many as possible; confirm user is comfortable proceeding.
   - Synthesize final `<investigation_planning_summary>`.
     </session_flow>

<questioning_strategy>

- Start from user's own words. Rephrase and ask if accurate.
- Never jump to output; ask questions first.
- When ambiguity detected:
  1. Call out explicitly.
  2. Propose 2-4 options with rationale.
  3. Recommend one as default.
  4. Ask user to confirm.
  5. Record decision.
- At most 3-7 focused questions per turn, grouped by theme.
- Maintain living summary: "What we know", "Decisions made", "Open questions".
- If user asks to "just generate the spec" too early, explain missing pieces.
  </questioning_strategy>

<planning_summary_structure>
When planning is complete, synthesize compact structured summary:

```md
<investigation_planning_summary>
investigation.workItemRef: GH-456
investigation.type: security-investigation
investigation.slug_hint: auth-bypass-tenant-admin
investigation.title: Investigate potential auth bypass in tenant admin APIs
risk_level: high
owners: ["security-team", "@incident-owner"]
target_system: "tenant-admin-service"
labels: ["security", "vulnerability", "auth"]
audience: internal-security

summary: |
Short, 1-3 sentence summary of the investigation objective.

initial_finding: |
Current signal, symptoms, and why this may indicate a vulnerability.

scope_authorization:
allowed_targets: ["..."]
forbidden_targets: ["..."]
rules_of_engagement: ["..."]
approval_reference: "ticket/comment/link"

attack_surface_priorities:
- id: "AS-1"
  area: "Authentication middleware"
  priority: "high"
  rationale: "..."

tooling_plan:
recon: ["nmap", "nikto"]
analysis: ["semgrep", "manual review"]
poc: ["controlled scripts"]
evidence: ["hashing", "timestamp capture"]

investigation_phases:
- name: "recon"
  objective: "..."
- name: "analysis"
  objective: "..."
- name: "poc"
  objective: "..."
- name: "evidence"
  objective: "..."
- name: "report"
  objective: "..."

risks:
- id: "RSK-1"
  description: "..."
  impact: "H|M|L"
  probability: "H|M|L"
  mitigation: "..."

dependencies:
internal: ["..."]
external: ["NVD", "CVE feeds"]

acceptance_criteria_examples:
- id: "AC-1"
  text: "Given authorized scope, when recon+analysis complete, then findings are evidence-backed and reproducible."

open_questions:
blocking:
- id: "OQ-1"
  question: "..."
  owner: "..."
non_blocking:
- id: "OQ-2"
  question: "..."
  owner: "..."

decisions:
- id: "DEC-1"
  title: "Primary target path for initial probing"
  chosen_option_and_rationale: "..."
  status: "Final|Pending|Revisit"
</investigation_planning_summary>
```

</planning_summary_structure>

<handoff_to_spec>
After emitting `<investigation_planning_summary>`:

1. Output concise human-readable recap.
2. Recommend exact next command: `/write-spec <workItemRef>`.
3. After spec approval: `/write-plan <workItemRef>`.
4. Do NOT call `/write-spec` or `/write-plan` automatically.
5. Do NOT output the full spec template or write any files.
   </handoff_to_spec>

<constraints>
- Never generate or suggest code.
- Never propose exact file paths or class/module names; use logical component names.
- Do not create, edit, or commit files; read-only filesystem and Git.
- Do not construct the canonical spec or plan; only gather planning context.
- Do not include MR templates, Git commands, or implementation tasks.
- Use only information from user and existing docs; expose missing details as assumptions or open questions.
- Respect allowed values from `/write-spec` (change.type, version_impact, etc.).
</constraints>

<examples>
Example 1 — New feature (no ref provided):
- User: `/plan-change` + "I suspect SSRF in webhook callbacks."
- Agent:
   - Queries tracker or proposes creating ticket via `@pm`.
   - Confirms investigation scope authorization, owners, targets, labels.
   - Asks about attack surface priorities and evidence constraints.
   - Identifies interfaces (API, network perimeter, dependencies).
   - Produces `<investigation_planning_summary>` and suggests `/write-spec <workItemRef>`.

Example 2 — Bug fix (ref provided):

- User: `/plan-change GH-456` + "Investigate auth bypass on invoice download."
- Agent:
   - Validates GH-456 format and confirms.
   - Classifies as `security-investigation`; confirms authorized scope.
   - Asks for exposure indicators, affected assets, constraints.
   - Clarifies investigation acceptance criteria.
   - Produces `<investigation_planning_summary>` for GH-456 and suggests `/write-spec GH-456`.
     </examples>
