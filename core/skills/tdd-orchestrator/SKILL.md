---
name: tdd-orchestrator
description: "Enforce hypothesis-driven security testing — hypothesize-prove-document cycle for every finding"
---

# Red Team Orchestrator

Enforce disciplined, hypothesis-driven security investigation in the Samourai pipeline. Guarantees the HYPOTHESIZE-PROVE-DOCUMENT cycle for every finding.

<HARD-GATE>
Never publish or escalate a vulnerability finding before a reproducible proof exists.
</HARD-GATE>

## Activation in Samourai

Activated automatically during:
- `/run-plan <workItemRef>` when tasks include security investigation
- `/check-fix` when a finding is disputed or evidence fails validation
- Any `@coder` task that produces or updates a security finding

## Mandatory Cycle

```
For each investigation task:

  1. HYPOTHESIZE -> define exploitation hypothesis and expected behavior
  2. PROVE      -> execute minimal test to prove/disprove hypothesis
  3. DOCUMENT   -> collect evidence, record constraints, improve POC clarity

Never merge steps. Never skip HYPOTHESIZE.
```

## Integration with Samourai Plan

Read `chg-<workItemRef>-test-plan.md` (or investigation test-plan) before execution:

```markdown
For each task in plan:
  1. Identify validation steps covering this finding
  2. Write explicit exploitation hypothesis (HYPOTHESIZE)
  3. Run minimal proof test (PROVE)
  4. Document evidence and constraints (DOCUMENT)
  5. Commit: evidence + POC + notes together
```

If test-plan is missing/incomplete → signal to `@pm` before continuing.

## Investigation Levels

### Recommended evidence pyramid

```
        /\
       /Real-world impact\
      /-------------------\
     / Reproducible POC    \
    /-----------------------\
   / Hypothesis + control    \
  /___________________________\
```

Target balance:
- Many hypothesis/control checks
- Fewer full POCs
- Rare full-impact demonstrations

## Anti-Patterns to Detect and Correct

| Anti-pattern | Detection | Correction |
|---|---|---|
| Finding without POC | Claim exists, no reproducible proof | Return to PROVE step |
| POC without hypothesis | Payload/script exists, no falsifiable hypothesis | Write hypothesis first |
| Untested assumptions | Severity or impact stated without controls | Add control tests and evidence |
| Over-broad POC | POC modifies too many variables at once | Reduce to minimal proof |
| Evidence gaps | Missing logs/requests/trace artifacts | Capture and link artifacts |

## Completion Signals

A cycle is complete when:
- [ ] Hypothesis is explicit and falsifiable
- [ ] Minimal proof test executed
- [ ] Result clearly supports or rejects hypothesis
- [ ] Evidence artifacts are captured and linked
- [ ] POC safety constraints are documented
- [ ] Commit includes proof and documentation

## Coordination with Samourai Agents

| Agent | Role in security cycle |
|---|---|
| `@test-plan-writer` | Defines validation matrix for findings |
| `@coder` | Applies HYPOTHESIZE-PROVE-DOCUMENT per task |
| `@reviewer` | Verifies claim quality and proof integrity |
| `@runner` | Executes heavy verification commands |
| `@fixer` | Repairs broken proof chains via root-cause analysis |

## Safety Guardrails
- **LAB-ONLY**: All testing and exploitation MUST occur in isolated lab environments
- **NO WEAPONIZATION**: POCs must be minimal and non-weaponizable
- **AUTHORIZATION**: Verify written scope authorization before any active testing
- **LOGGING**: All actions must be logged and timestamped
- **RESPONSIBLE DISCLOSURE**: Follow responsible disclosure for any findings
