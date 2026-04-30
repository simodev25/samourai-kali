---
name: receiving-code-review
description: "Handle peer review feedback on security findings with technical rigor"
---

# Receiving Finding Feedback

## Overview

Security finding review requires technical evaluation, not performative agreement.

**Core principle:** Verify before implementing. Ask before assuming. Technical correctness over social comfort.

## The Response Pattern

```
WHEN receiving security finding feedback:

1. READ: Complete feedback without reacting
2. UNDERSTAND: Restate requirement in own words (or ask)
3. VERIFY: Check against evidence and environment reality
4. EVALUATE: Technically sound for THIS target/context?
5. RESPOND: Technical acknowledgment or reasoned pushback
6. IMPLEMENT: One item at a time, re-validate evidence
```

## Forbidden Responses

**NEVER:**
- Blind agreement without validation
- "Let me apply all of that now" before verification
- Severity changes without evidence

**INSTEAD:**
- Restate technical requirement
- Ask clarifying questions
- Push back with technical evidence when wrong
- Take concrete actions and show results

## Handling Unclear Feedback

```
IF any item is unclear:
  STOP - do not implement partial changes yet
  ASK for clarification on unclear items first
```

Why: review items are often interdependent; partial understanding leads to invalid findings.

## Source-Specific Handling

### From your human partner
- Trusted direction after understanding
- Ask if scope/impact unclear
- Move quickly to verifiable action

### From External Reviewers
Before implementing:
1. Check technical correctness for THIS stack/environment
2. Check whether suggestion breaks reproducibility or safety
3. Check whether reviewer has full context
4. Check for conflicts with prior constraints

If suggestion seems wrong: push back with technical reasoning.

If cannot verify quickly: state limitation and ask for direction.

## Security-Specific Verification

Always validate:
- **CVSS scoring feedback** (vector, exploitability, impact assumptions)
- **POC safety comments** (non-destructive behavior, controlled scope, data handling)
- **Evidence quality feedback** (reproducibility, controls, artifact integrity)

## Implementation Order

```
FOR multi-item feedback:
  1. Clarify unclear items FIRST
  2. Then implement in order:
     - Safety/blocking issues
     - Evidence/correctness issues
     - Editorial/reporting polish
  3. Re-test each change individually
  4. Verify no regressions in proof chain
```

## When To Push Back

Push back when:
- Feedback conflicts with reproducible evidence
- Suggested change weakens POC safety
- CVSS suggestion uses invalid assumptions
- Reviewer lacks target-specific context
- Suggestion introduces unsupported claims

**How to push back:**
- Use technical reasoning, not defensiveness
- Show evidence artifacts and control tests
- Ask specific technical questions

## Acknowledging Correct Feedback

When feedback IS correct:
- "Fixed. [Brief technical change + evidence updated]"
- "Good catch — corrected [specific issue] in [location]."
- Or just implement and show validated result

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Blind implementation | Verify against evidence first |
| Partial implementation of unclear set | Clarify all unclear items first |
| CVSS updates by intuition | Recompute vector with explicit assumptions |
| Unsafe POC modifications | Re-check safety constraints and controls |
| Avoiding pushback | Technical correctness > comfort |

## The Bottom Line

Peer feedback is input to evaluate, not instructions to apply blindly.

Verify. Question. Then implement.
