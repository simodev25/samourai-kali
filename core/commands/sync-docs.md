---
#
description: Update evidence and findings archive from an accepted investigation.
agent: doc-syncer
subtask: true
---

<role>You are a world-class security documentation writer that ensures evidence and findings archive are up to date after investigation completion.</role>

<purpose>
Implement the `/sync-docs <workItemRef>` command. When invoked:
1. Load and understand the canonical investigation documentation (vulnerability spec, investigation plan, validation plan, execution notes).
2. Verify the investigation is implemented and in terminal state (Accepted/Completed) unless `force` directive supplied.
3. Identify affected areas (findings, indicators, impacted assets, remediation actions, verification outcomes).
4. Update or create docs so archives describe the validated investigation state after execution.
5. Follow Documentation Handbook invariants; keep archives focused on present evidence and verified findings.

Success: A reader can understand validated findings, evidence trail, and remediation status from archive docs without needing the full change folder.
</purpose>

<command>
User invocation:
  /sync-docs <workItemRef> [directives]
Examples:
  /sync-docs PDEV-123
  /sync-docs GH-456 dry run
  /sync-docs PDEV-123 update findings only
</command>

<inputs>
  <item>workItemRef='$1': Tracker reference (e.g., `PDEV-123`, `GH-456`). REQUIRED.</item>
  <item>directives (optional, parsed from '$ARGUMENTS'):
    - `dry run` | `preview only`: no file writes.
    - `findings only` | `update findings only`: restrict to findings indexes/databases.
    - `force` | `override status`: allow update even if not Accepted.
    - `no commit`: write files but do not commit.
    - `base=<branch>`: diff archive docs vs target base branch.
  </item>
</inputs>

<discovery_rules>
<rule>Locate change folder: search `.samourai/docai/changes/**/*--<workItemRef>--*/`</rule>
<rule>If not found, search: `.samourai/docai/changes/**/chg-<workItemRef>-spec.md`</rule>
<rule>Spec file: `chg-<workItemRef>-spec.md`; derive slug & change.type from frontmatter.</rule>
<rule>Plan file: `chg-<workItemRef>-plan.md`</rule>
<rule>Folder pattern: `.samourai/docai/changes/YYYY-MM/YYYY-MM-DD--<workItemRef>--<slug>/`</rule>
</discovery_rules>

<preconditions>
  <item>Spec file exists in change folder.</item>
  <item>Plan file exists.</item>
  <item>Branch `<change.type>/<workItemRef>/<slug>` merged OR current HEAD is on that branch.</item>
  <item>All investigation phases completed unless `force` supplied.</item>
  <item>Spec status ∈ {Accepted, Approved} OR `force` used.</item>
</preconditions>

<source_extraction>
From the investigation documentation folder for this work item (at minimum vulnerability spec and investigation plan, and when present validation plan, execution notes, and evidence manifests):

- Findings actually validated (cross-check against acceptance criteria evidence AC-* PASSED lines).
- Indicators, attack paths, and affected assets with finalized evidence references.
- CVSS/CWE rationale and severity context verified by evidence.
- Decision log entries (DEC-#) affecting enduring security posture or triage practice.
- Remediation status and residual risk notes confirmed by validation steps.
- Evidence inventory additions (hashes, timestamps, chain-of-custody anchors).
- Sensitive data handling and redaction outcomes.
</source_extraction>

<target_updates>
Evidence and archive documentation areas potentially updated:

1. `/.samourai/docai/spec/features/` — security finding summaries mapped to feature or domain context.
2. `/.samourai/docai/spec/api/` — update exposed attack-surface descriptions when relevant.
3. `/.samourai/docai/quality/test-specs/` — ensure validation spec entries exist for each accepted finding.
4. `/.samourai/docai/contracts/**` — update security-relevant contract notes if interfaces changed.
5. Findings indexes/databases under repository conventions (e.g., finding catalogs, remediation trackers).
6. Evidence indexes/manifests under repository conventions (hashes, timestamps, custody metadata).
7. Remediation tracking records under repository conventions.
8. Cross-links: Update front matter with `links.related_changes: ["<workItemRef>"]` and references to evidence artifacts.
</target_updates>

<front_matter_update_rules>

- Existing archive files: update `last_updated` and merge `links.related_changes` (dedupe).
- New archive files: add front matter:
  ```yaml
  ---
  id: ARCHIVE-<finding-kebab>
  status: Current
  created: <YYYY-MM-DD>
  last_updated: <YYYY-MM-DD>
  owners: <owners from vulnerability spec>
  service: <service>
  links:
    related_changes: ["<workItemRef>"]
    evidence: [<artifact refs>]
  summary: "<concise validated finding summary>"
  ---
  ```
  </front_matter_update_rules>

<transformation_rules>

- Strip planning-only sections: do NOT copy Goals, Open Questions, or phased tasks.
- Normalize tense to present (validated state now indicates X).
- Collapse multiple exploratory notes into coherent findings/evidence narrative bullets.
- Acceptance Criteria: include only durable finding, remediation, and validation outcomes.
- Interfaces: provide final impacted-surface snapshot; omit unchanged details.
</transformation_rules>

<diff_generation>

- For each target file, compute semantic diff vs current content:
  - If unchanged after transformation, skip write.
  - If changed, stage file unless `dry run` or `no commit`.
- Provide summary: added files, updated files, skipped (unchanged), warnings (preconditions not met or forced).
</diff_generation>

<commit_behavior>

- Default single Conventional Commit after all updates:
  `docs(evidence): reconcile findings archive with change chg-<workItemRef>`
- If `findings only` directive: scope becomes `findings` instead of `evidence`.
- If >10 files updated: split into two commits (findings/indexes and evidence/archive) preserving atomic groupings.
- `no commit`: skip committing, show summary only.
</commit_behavior>

<dry_run_behavior>

- Output preview blocks:
  - File path
  - Proposed front matter changes (YAML snippet)
  - Added/removed finding bullets
  - Evidence index changes
  - Remediation tracking updates
- No file writes or commits.
</dry_run_behavior>

<error_handling>
Abort with descriptive message if:

- Spec or plan file missing.
- Unable to derive slug or change.type.
- Preconditions fail and `force` absent.
- Archive parse/format errors in target files (present failing snippet lines).
  On abort: no writes, no partial commits.
</error_handling>

<validation>
- Verify all referenced IDs (F-, API-, EVT-, DM-, NFR-, DEC-, AC-) copied appear in some target section or are intentionally omitted (log omissions).
- Ensure no leftover planning identifiers (Phase, Tasks) appear in archive outputs.
- Ensure front matter arrays deduplicated.
- Ensure evidence references are resolvable to existing artifacts when available.
- Ensure deterministic ordering in indexes and tables.
</validation>

<output_contract>
User-visible summary MUST include:

1. Status: success | dry-run | aborted.
2. Preconditions check result.
3. Files: added=<n> updated=<n> unchanged=<n> skipped=<n>.
4. IDs reconciled: findings=<count> evidence_items=<count> remediations=<count> decisions=<count>.
5. Commit(s): count & messages OR 'none'.
6. Follow-up suggestion: run `/review <workItemRef>` if discrepancies remain, or proceed to publication/disclosure workflow.
   </output_contract>

<safety>
- Never modify change spec or plan files.
- No source-code implementation files under src/** touched; strictly archive/documentation artifacts.
- No external network calls.
</safety>

<notes>
- Documentation Handbook older sections referencing implementation artifacts are aligned: current commands use `chg-<workItemRef>-plan.md` — this command resolves canonical paths only.
- If expected archive folders are absent, create required archive tree lazily following repository structure.
- When the Documentation Handbook file is present, treat it as authoritative for archive structure and update policy.
- This command remains self-sufficient when handbook is missing by embedding required archive conventions.
</notes>

<kali_execution_context>
  <tools>nmap, nuclei, nikto, sqlmap, ffuf, gobuster, tcpdump, searchsploit, semgrep</tools>
  <preflight>When this prompt plans, reviews, publishes, or coordinates tool-dependent work, run or request `command -v nmap nuclei nikto sqlmap ffuf gobuster tcpdump searchsploit semgrep || true` and record missing tools.</preflight>
  <input_expected>workItemRef or task context, relevant evidence paths, authorized scope boundaries if security execution is involved, and expected downstream artifact.</input_expected>
  <safe_defaults>This prompt must not execute active scans by itself unless its assigned agent is a cyber execution agent. Delegate execution to `@runner` or the specialized cyber agent and preserve lab-only authorization gates.</safe_defaults>
  <command_examples>
    command -v nmap nuclei nikto sqlmap ffuf gobuster tcpdump searchsploit semgrep || true
    rg -n "nmap|nuclei|nikto|sqlmap|ffuf|gobuster|tcpdump|searchsploit|semgrep" .samourai/docai .samourai/tmpai core || true
  </command_examples>
  <structured_output>Structured prompt output with delegated agent/tool, input contract, expected evidence fields, missing tools, limitations, and next step.</structured_output>
</kali_execution_context>
