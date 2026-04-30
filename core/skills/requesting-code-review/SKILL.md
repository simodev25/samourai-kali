---
name: requesting-code-review
description: "Submit a security finding for peer review — accuracy, POC safety, evidence quality"
---

# Requesting Finding Review

Dispatch a security reviewer to catch inaccuracies before findings are shared broadly. The reviewer gets precise context focused on evidence quality, exploitability validity, and POC safety.

**Core principle:** Review early, review often.

## When to Request Review

**Mandatory:**
- After completing each major investigation task
- After confirming a significant finding
- Before final reporting/disclosure

**Optional but valuable:**
- When stuck on exploitability interpretation
- Before severity assignment changes
- After complex multi-step POC work

**Severity triage:**
- **Critical findings need immediate review** before any external disclosure.

## How to Request

**1. Get git SHAs (or evidence range):**
```bash
BASE_SHA=$(git rev-parse HEAD~1)  # or previous checkpoint
HEAD_SHA=$(git rev-parse HEAD)
```

**2. Dispatch security reviewer:**

Use the Task tool with `subagent_type: code-reviewer` and include a concise security review brief directly in the prompt.

**Placeholders:**
- `{WHAT_WAS_FOUND_OR_ANALYZED}` - What was investigated/found
- `{VULNERABILITY_SPEC_OR_INVESTIGATION_PLAN}` - Required behavior/scope
- `{BASE_SHA}` - Starting commit
- `{HEAD_SHA}` - Ending commit
- `{DESCRIPTION}` - Brief summary

**3. Act on feedback:**
- Fix Critical accuracy/safety issues immediately
- Fix Important evidence-quality issues before proceeding
- Note Minor improvements for next pass
- Push back if reviewer is wrong (with technical evidence)

## Example

```
[Just completed Task 2: Authorization bypass analysis]

You: Let me request finding review before proceeding.

BASE_SHA=$(git log --oneline | grep "Task 1" | head -1 | awk '{print $1}')
HEAD_SHA=$(git rev-parse HEAD)

[Dispatch security reviewer]
  WHAT_WAS_FOUND_OR_ANALYZED: Potential horizontal privilege escalation in account API
  VULNERABILITY_SPEC_OR_INVESTIGATION_PLAN: Task 2 from docs/investigations/plans/api-authz-plan.md
  BASE_SHA: a7981ec
  HEAD_SHA: 3df7661
  DESCRIPTION: Added POC request sequence and authorization boundary traces

[Reviewer returns]:
  Strengths: Reproducible POC, clear boundary mapping
  Issues:
    Important: Missing negative control case
    Minor: Evidence filenames inconsistent
  Assessment: Ready after control case added

You: [Add negative control case]
[Continue to next task]
```

## Integration with Workflows

**Subagent-Driven Development:**
- Review after EACH task
- Catch finding-quality issues before they compound

**Executing Plans:**
- Review after each batch
- Apply feedback, then continue

**Ad-Hoc Investigations:**
- Review before disclosure/report submission

## Red Flags

**Never:**
- Skip review because "finding is obvious"
- Ignore Critical safety concerns
- Proceed with unresolved Important evidence gaps
- Accept weak evidence for high-severity claims

**If reviewer wrong:**
- Push back with technical reasoning
- Show reproducible proof and controls
- Request clarification

When requesting review, prioritize exploitability validity, evidence quality, and POC safety constraints in the prompt.
