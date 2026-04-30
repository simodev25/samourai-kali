---
#
description: Generate or update POC validation plan
agent: test-plan-writer
subtask: true
---

<purpose>
Create or update a COMPLETE, requirements-driven POC VALIDATION PLAN for a vulnerability investigation.

User invocation: `/write-test-plan <workItemRef> [options]`

Options: `focus=backend`, `nfr-only`, `no-manual`, etc.

The POC VALIDATION PLAN:

- Ensures safe validation of exploit hypotheses and constraints
- Aligns with investigation plan phases
- Uses `.samourai/ai/rules/testing-strategy.md` for enrichment when available; if missing, proceed with spec/plan defaults
  </purpose>

<inputs>
<arguments>$ARGUMENTS</arguments>
<parsing>
- `workItemRef` = first token matching pattern `<PREFIX>-<number>` (e.g., `PDEV-123`, `GH-456`)
- Remaining args = options (e.g., `focus=backend`)
- If no valid `workItemRef` found, output NEEDS_INPUT:
  ```
  NEEDS_INPUT: workItemRef required
  Usage: /write-test-plan <workItemRef> [options]
  Example: /write-test-plan PDEV-123 focus=backend
  ```
</parsing>
</inputs>

<discovery_rules>
Given `workItemRef`:

1. Search for folder: `.samourai/docai/changes/**/*--<workItemRef>--*/`
2. Locate spec: `chg-<workItemRef>-spec.md` (required)
3. Locate plan: `chg-<workItemRef>-plan.md` (optional)
4. Read: `.samourai/ai/rules/testing-strategy.md` (optional enrichment)

Files:

- Spec: `chg-<workItemRef>-spec.md`
- Plan: `chg-<workItemRef>-plan.md`
- Test Plan: `chg-<workItemRef>-test-plan.md`
- Branch: `<change.type>/<workItemRef>/<slug>`
  </discovery_rules>

<process>
1. Parse `workItemRef` and options from $ARGUMENTS
2. Locate change folder, spec, plan per <discovery_rules>
3. If `.samourai/ai/rules/testing-strategy.md` is available, read it for enrichment; if missing, proceed with spec-based test strategy (and plan defaults when present)
4. Read `.samourai/blueprints/testing/` when available and pass it to
   `@test-plan-writer` as structural guidance only.
5. Extract vulnerability requirements, AC-#, API-#, NFR-#, and evidence requirements from spec
6. Checkout/create branch
7. Delegate to `@test-plan-writer` agent (it has full template and rules)
8. Ensure resulting validation plan covers:
   - POC safety validation
   - reproducibility testing
   - environment isolation verification
   - evidence completeness checks
9. Report: path to created POC validation plan, next step: `/run-plan <workItemRef>`
</process>

<output>
After successful execution:
- Created/updated file path
- Branch name
- Coverage summary (how many AC-# covered, any TODOs)
- Recommendation: "Run `/run-plan <workItemRef>` to begin investigation execution"
</output>

<constraints>
- Spec must exist; fail if not found
- Testing strategy file is optional: if available, use for enrichment; if missing, proceed with spec-based test strategy (and plan defaults when present)
- Only the test plan file may be written
- Derive all context from vulnerability spec/plan; do not invent requirements
- Mark uncovered AC-# as TODO with open questions
</constraints>
