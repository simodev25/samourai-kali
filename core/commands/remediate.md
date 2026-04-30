---
#
description: Produce and validate a remediation plan for findings.
agent: remediation-agent
subtask: true
---

<purpose>
Generate prioritized remediation guidance and validation checkpoints.
</purpose>

<command>
User invocation:
  /remediate <finding-or-cve>
</command>

<inputs>
  <item>finding-or-cve: vulnerability reference to remediate.</item>
</inputs>

<process>
1. Analyze feasible remediation options.
2. Propose prioritized fixes with risk reduction estimates.
3. Define validation checks and regression safeguards.
</process>

<output_contract>
  <item>Actionable remediation plan with verification steps.</item>
</output_contract>
