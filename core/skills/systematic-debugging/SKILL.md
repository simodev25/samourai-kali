---
name: systematic-debugging
description: "Use when investigating any vulnerability finding — enforce root-cause investigation before claiming a vulnerability"
---

# Systematic Vulnerability Investigation

## Overview

Random exploitation attempts waste time and create false positives. Quick claims mask underlying causes.

**Core principle:** ALWAYS find root cause before claiming a vulnerability. Symptom-only evidence is failure.

**Violating the letter of this process is violating the spirit of investigation.**

## The Iron Law

```
NO VULNERABILITY CLAIM WITHOUT ROOT CAUSE INVESTIGATION FIRST
```

If you haven't completed Phase 1, you cannot claim a vulnerability.

## When to Use

Use for ANY potential security issue:
- Scanner findings (SAST/DAST)
- Suspected vulnerability reports
- Unexpected security behavior
- Access-control anomalies
- Auth/session/token concerns
- Unsafe configuration findings

**Use this ESPECIALLY when:**
- Under time pressure (guessing is tempting)
- "Just report it now" feels obvious
- You've already tried multiple exploitation ideas
- Previous hypothesis failed
- You don't fully understand impact/preconditions

**Don't skip when:**
- Finding seems simple (simple findings still need proof)
- You're in a hurry (rushing guarantees rework)
- Someone wants immediate severity labeling

## The Four Phases

You MUST complete each phase before proceeding to the next.

### Phase 1: Root Cause Investigation

**BEFORE attempting ANY vulnerability claim:**

1. **Read Finding Details Carefully**
   - Don't skip scanner metadata, traces, request/response details
   - Read evidence completely
   - Note endpoints, parameters, code paths, trust boundaries

2. **Reproduce Consistently**
   - Can you trigger it reliably?
   - What are exact steps/inputs/environment?
   - Is impact consistent or conditional?
   - If not reproducible → gather data, don't guess

3. **Check Relevant Context**
   - What changed that could affect exposure?
   - Git diff, recent commits, config/deploy drift
   - Auth rules, dependency changes, permission model changes

4. **Gather Evidence Across Trust Boundaries**

   **WHEN system has multiple components (edge → API → service → datastore):**

   **BEFORE claiming vulnerability, add diagnostic instrumentation:**
   ```
   For EACH trust boundary:
     - Capture what enters boundary
     - Capture what exits boundary
     - Verify identity/authz propagation
     - Check policy state at each layer

   Run once to gather evidence showing WHERE control fails
   THEN analyze evidence to identify failing layer
   THEN investigate that specific layer
   ```

5. **Trace Attack/Data Flow**

   **WHEN behavior is deep in stack:**

   - Where does exploitable condition originate?
   - What called this with unsafe state?
   - Keep tracing until source is found
   - Focus on source condition, not terminal symptom

### Phase 2: Pattern Analysis

**Compare against known vulnerability patterns before claiming:**

1. **Map to Known Patterns**
   - Compare finding with CWE and OWASP categories
   - Identify likely class and required preconditions

2. **Compare Against References**
   - Read relevant CWE/OWASP guidance COMPLETELY
   - Verify assumptions, exploitability requirements, impacts

3. **Identify Differences**
   - What's different between this finding and canonical patterns?
   - List every difference, however small

4. **Understand Preconditions**
   - Required attacker capabilities?
   - Required environment/configuration?
   - Required privileges or prior foothold?

### Phase 3: Hypothesis and Testing

**Scientific method:**

1. **Form Single Exploitation Hypothesis**
   - State clearly: "I think X is exploitable because Y"
   - Be specific and falsifiable

2. **Test Minimally**
   - Execute smallest safe test to validate hypothesis
   - One variable at a time
   - Don't alter multiple conditions at once

3. **Verify Before Continuing**
   - Hypothesis supported? Yes → Phase 4
   - Not supported? Form NEW hypothesis
   - Don't stack assumptions

4. **When You Don't Know**
   - Say "I don't understand X"
   - Ask for help / investigate further
   - Don't infer severity without evidence

### Phase 4: Implementation

**Prove the root cause, not the symptom:**

1. **Create Minimal POC**
   - Simplest reproducible exploit path
   - Safe and controlled by default
   - Script/requests/log capture as needed
   - MUST exist before claiming vulnerability

2. **Implement One Change at a Time**
   - One payload/condition change per attempt
   - No bundled scenario changes

3. **Verify Proof**
   - Reproduces reliably?
   - Evidence captured (logs/request-response/traces)?
   - Impact and constraints documented?

4. **If Hypothesis Doesn't Work**
   - STOP
   - Count failed exploitation hypotheses
   - If < 3: Return to Phase 1 with new data
   - **If ≥ 3: STOP and question whether this is actually a vulnerability**
   - DON'T attempt hypothesis #4 blindly

5. **If 3+ Hypotheses Failed: Reassess Vulnerability Claim**

   **Pattern indicating possible false positive:**
   - Core exploit preconditions cannot be met
   - Impact cannot be demonstrated under realistic assumptions
   - Repro only works with unrealistic attacker capabilities

   **STOP and question fundamentals:**
   - Is this truly exploitable?
   - Are we forcing a claim through confirmation bias?
   - Should this be reframed/downgraded/closed?

## Red Flags - STOP and Follow Process

If you catch yourself thinking:
- "Quick claim now, investigate later"
- "Just try random payloads"
- "Let's change multiple variables"
- "One screenshot is enough proof"
- "It's probably critical, report now"
- "One more hypothesis" (after 2+ failures)

**ALL of these mean: STOP. Return to Phase 1.**

**If 3+ exploitation hypotheses failed:** question whether it's actually a vulnerability.

## Common Rationalizations

| Excuse | Reality |
|--------|---------|
| "It's obvious" | Obvious findings still need reproducible proof. |
| "No time for process" | Systematic investigation is faster than exploit thrashing. |
| "I'll document later" | Unstructured proof fails peer review. |
| "One more attempt" | 3+ failures often indicates non-vulnerability or wrong model. |

## Quick Reference

| Phase | Key Activities | Success Criteria |
|-------|---------------|------------------|
| **1. Root Cause** | Read finding, reproduce, gather boundary evidence | Understand WHAT and WHY |
| **2. Pattern** | Compare with CWE/OWASP patterns | Realistic exploit class identified |
| **3. Hypothesis** | Form and minimally test exploit hypothesis | Supported or rejected hypothesis |
| **4. Implementation** | Build/validate POC and evidence | Reproducible proof or claim rejected |

## Supporting Techniques

- `root-cause-tracing.md` — trace source condition through boundaries
- `defense-in-depth.md` — analyze control layering after root-cause discovery
- `condition-based-waiting.md` — avoid timing assumptions in investigations

**Related skills:**
- `test-driven-development` — reproducibility discipline for POC/test harness
- `verification-before-completion` — evidence check before final claims
