---
name: writing-plans
description: "Produce detailed investigation/attack plans from a vulnerability spec"
---

# Writing Attack/Investigation Plans

## Overview

Write comprehensive investigation plans assuming the security researcher has zero context for this environment and needs explicit, operational steps. Document exactly what to analyze: attack surfaces, recon/scanning steps, hypothesis tests, POC work, evidence capture, and reporting tasks. Keep steps bite-sized. DRY. YAGNI. Frequent commits.

Assume they are a skilled researcher, but know almost nothing about local tooling or system-specific threat context.

**Announce at start:** "I'm using the writing-plans skill to create the investigation plan."

**Context:** This should be run in a dedicated worktree (created by brainstorming skill).

**Save plans to:** `.samourai/docai/changes/YYYY-MM/YYYY-MM-DD--<workItemRef>--<slug>/chg-<workItemRef>-plan.md`
- (User preferences for plan location override this default)

## Scope Check

If the vulnerability spec covers multiple independent threat domains, suggest breaking into separate plans — one per domain. Each plan should produce actionable, verifiable evidence on its own.

## File Structure

Before defining tasks, map out which files/artifacts will be created or modified and what each one is responsible for.

- Design investigation units with clear boundaries and interfaces.
- Prefer focused artifacts over monolithic reports.
- Artifacts that evolve together should live together.
- In existing codebases, follow established patterns unless they block investigation clarity.

This structure informs task decomposition. Each task should produce self-contained evidence.

## Bite-Sized Task Granularity

**Each step is one action (2-5 minutes):**
- "Define exploitation hypothesis" - step
- "Run minimal test to validate/disprove" - step
- "Capture evidence (log/request/trace)" - step
- "Implement minimal POC code" - step
- "Document result" - step

## Plan Document Header

**Every plan MUST start with this header:**

```markdown
# [Investigation Name] Investigation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use `subagent-driven-development` (recommended) or `executing-plans` to execute this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** [One sentence describing what this investigation proves or disproves]

**Approach:** [2-3 sentences about attack/investigation approach]

**Tool Stack:** [Key tools/libraries/platforms]

---
```

## Task Structure

````markdown
### Phase N: [Recon / Analysis / POC / Evidence / Reporting]

### Task N.M: [Surface or Vector Name]

**Files/Artifacts:**
- Create: `exact/path/to/poc_or_notes`
- Modify: `exact/path/to/config_or_script`
- Evidence: `exact/path/to/evidence-file`

- [ ] **Step 1: Define reconnaissance/analysis hypothesis**

```text
Hypothesis: [Specific, falsifiable security claim]
Expected behavior: [What should happen if exploitable]
```

- [ ] **Step 2: Run minimal test**

Run: `exact command`
Expected: [clear expected output]

- [ ] **Step 3: Build minimal POC**

```python
# minimal reproducible POC snippet
```

- [ ] **Step 4: Capture evidence (hash + timestamp)**

Run: `exact evidence capture command`
Expected: [evidence artifact path + signal]

- [ ] **Step 5: Document finding status**

```markdown
Result: [confirmed / disproved / inconclusive]
Constraints: [...]
Risk/impact: [...]
```
````

## POC Cycle (replaces TDD cycle)

For every investigation task, enforce:

1. **Hypothesis** — explicit, falsifiable exploitation claim
2. **Test** — minimal, controlled execution to validate/disprove
3. **Proof** — reproducible evidence artifact
4. **Document** — clear outcome and constraints

Never skip from idea to claim without proof.

## No Placeholders

Every step must contain exact content needed by a security researcher. These are **plan failures** — never write them:
- "TBD", "TODO", "investigate later", "fill in details"
- "Run scanner" (without exact target/options)
- "Collect evidence" (without exact command/output path)
- "Similar to Task N" (repeat exact details)
- Steps without expected outputs

## Remember
- Exact file/artifact paths always
- Exact commands with expected output
- Plan phases should explicitly cover recon, analysis, POC, evidence, and reporting
- Frequent commits with traceable evidence progression

## Self-Review

After writing the complete plan, validate it against the vulnerability spec:

1. **Spec coverage:** every claim/scope item maps to at least one task.
2. **Placeholder scan:** remove vague or incomplete instructions.
3. **Consistency:** hypotheses, commands, artifacts, and expected outputs align.

Fix issues inline before handoff.

## Execution Handoff

After saving the plan, offer execution choice:

**"Plan complete and saved to `.samourai/docai/changes/<YYYY-MM>/<YYYY-MM-DD--workItemRef--slug>/chg-<workItemRef>-plan.md`. Two execution options:**

**1. Subagent-Driven (recommended)** - dispatch a fresh subagent per task, review between tasks

**2. Inline Execution** - execute tasks in this session using executing-plans with checkpoints

**Which approach?"**

**If Subagent-Driven chosen:**
- **REQUIRED SUB-SKILL:** Use `subagent-driven-development`

**If Inline Execution chosen:**
- **REQUIRED SUB-SKILL:** Use `executing-plans`

## Safety Guardrails
- **LAB-ONLY**: All testing and exploitation MUST occur in isolated lab environments
- **NO WEAPONIZATION**: POCs must be minimal and non-weaponizable
- **AUTHORIZATION**: Verify written scope authorization before any active testing
- **LOGGING**: All actions must be logged and timestamped
- **RESPONSIBLE DISCLOSURE**: Follow responsible disclosure for any findings
