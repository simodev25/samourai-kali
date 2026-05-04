---
description: Execute a red team cycle for a specific task or phase — hypothesize first, then prove, then document.
agent: fixer
subtask: true
---

<purpose>
Invoke @fixer using the tdd-orchestrator SKILL as a red team cycle to implement a task or phase by following strictly the cycle hypothesize → prove → document. Guarantees that hypotheses and validation checks are defined BEFORE final conclusions.

Used by investigation execution in /run-plan when the red team orchestrator skill is active, or invoked directly for a specific task.
</purpose>

<command>
User invocation:
  /tdd <workItemRef> [task description or phase number]
Examples:
  /tdd GH-42
  /tdd GH-42 phase 3
  /tdd GH-42 "validate authentication bypass hypothesis"
  /tdd PDEV-123 next task
</command>

<inputs>
  <item>workItemRef='$1' — Tracker reference (e.g., `GH-456`, `PDEV-123`). REQUIRED.</item>
  <item>scope='$ARGUMENTS' — Phase number, task description, or "next task". OPTIONAL (default: next incomplete task in plan).</item>
</inputs>

<discovery_rules>
<rule>Locate change folder: search `.samourai/docai/changes/**/*--<workItemRef>--*/`</rule>
<rule>Plan file: `chg-<workItemRef>-plan.md` — source of truth for investigation tasks</rule>
<rule>Test-plan file: `chg-<workItemRef>-test-plan.md` — POC validation steps</rule>
<rule>Spec file: `chg-<workItemRef>-spec.md` — finding acceptance criteria</rule>
</discovery_rules>

<scope_resolution>
Resolve target task from $ARGUMENTS:
- "phase N" → all incomplete tasks in phase N
- "next task" or absent → first incomplete task in plan
- free description → match against plan tasks (fuzzy match)
- If ambiguity → list candidates and ask for confirmation
</scope_resolution>

<process>
1. Resolve change folder and locate plan + test-plan + spec
2. Read `.samourai/ai/agent/project-profile.md` when present and pass it to @fixer running the tdd-orchestrator SKILL (`core/skills/tdd-orchestrator/SKILL.md`)
3. Identify target task(s) per scope_resolution
4. For each task:
   a. Read validation plan to identify corresponding checks
   b. Invoke @fixer with: task, test_plan_path, spec_path, and instruction to follow tdd-orchestrator SKILL (`core/skills/tdd-orchestrator/SKILL.md`)
   c. @fixer executes cycle HYPOTHESIZE → PROVE → DOCUMENT using the tdd-orchestrator SKILL guidance
   d. Update plan: mark [x] + evidence
   e. Commit via /commit (one commit per complete red-team cycle task)
5. Final report: completed tasks, hypotheses validated, evidence quality, project profile applied
</process>

<integration>
This command integrates into the Samourai pipeline:
- Called during /run-plan when red-team-orchestrator behavior is active
- Can replace /run-plan for a specific task requiring strict hypothesis/proof discipline
- Produced commits follow Conventional Commits format via /commit
</integration>

<output>
Structured report:
- Tasks processed + status (COMPLETE / PARTIAL / BLOCKED)
- Hypotheses tested (N) and proven/disproven counts
- Evidence artifacts produced
- Safety anti-patterns detected
- Project profile applied (`TMA`, `Build`, `Guide`, `Mix` or `none`)
- Suggested next action
</output>

<errors>
- Plan or validation plan missing → STOP with clear message
- Target task not found → list available tasks
- Proof step impossible after 3 attempts → BLOCKED, document in plan
</errors>

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
