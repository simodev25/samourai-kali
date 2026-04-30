---
#
description: Generate canonical vulnerability specification
agent: spec-writer
subtask: true
---

<purpose>
Generate a COMPLETE, investigation-agnostic VULNERABILITY SPECIFICATION from investigation planning context.

User invocation: `/write-spec <workItemRef>`

Inputs other than `workItemRef` MUST be sourced from the active investigation planning context; NOTHING may be invented.
Resulting spec becomes authoritative input for `/write-plan`.
</purpose>

<inputs>
<arguments>$ARGUMENTS</arguments>
<parsing>
- `workItemRef` = first token matching pattern `<PREFIX>-<number>` (e.g., `PDEV-123`, `GH-456`)
- If no valid `workItemRef` found, output NEEDS_INPUT:
  ```
  NEEDS_INPUT: workItemRef required
  Usage: /write-spec <workItemRef>
  Example: /write-spec PDEV-123
  ```
</parsing>
</inputs>

<discovery_rules>
Given `workItemRef`:

1. Search for existing folder: `.samourai/docai/changes/**/*--<workItemRef>--*/`
2. If not found, create: `.samourai/docai/changes/<YYYY-MM>/<YYYY-MM-DD>--<workItemRef>--<slug>/`

Files:

- Spec: `chg-<workItemRef>-spec.md`
- Branch: `<change.type>/<workItemRef>/<slug>`
  </discovery_rules>

<process>
1. Parse `workItemRef` from $ARGUMENTS
2. Gather investigation planning context from conversation
3. Compute slug from title (lowercase kebab-case, ≤60 chars)
4. Locate or create change folder per <discovery_rules>
5. Determine `change.type` from context (typically `fix` or `feat` with security scope)
6. Checkout/create branch
7. Delegate to `@spec-writer` agent with cybersecurity context:
   - vulnerability details and reproduction conditions
   - CWE classification
   - CVSS vector and score rationale
   - affected versions and exposure scope
   - impact analysis and exploit preconditions
8. Ensure output file `chg-<workItemRef>-spec.md` contains vulnerability-focused sections
9. Report: path to created spec, next step: `/write-plan <workItemRef>`
</process>

<output>
After successful execution:
- Created file path
- Branch name
- Recommendation: "Run `/write-plan <workItemRef>` to generate the investigation plan"
</output>

<constraints>
- No remediation implementation details in the spec
- Only the spec file may be written
- Await human approval before `/write-plan`
- Spec must focus on vulnerability facts, severity, impact, and evidence requirements
</constraints>
