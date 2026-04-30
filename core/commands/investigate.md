---
#
description: Orchestrate a full cyber investigation lifecycle for a target.
agent: pm
subtask: true
---

<purpose>
Start and orchestrate a full cyber investigation for a target from recon to reporting.
</purpose>

<command>
User invocation:
  /investigate <target> [context]
</command>

<inputs>
  <item>target: hostname, domain, IP, service, or asset identifier.</item>
  <item>context: optional scope, authorization reference, and constraints.</item>
</inputs>

<process>
1. Validate scope and authorization.
2. Initialize investigation context in change artifacts.
3. Delegate recon to `@attack-surface-agent`.
4. Delegate hunt/analysis as needed.
5. Coordinate evidence, report, and remediation outputs.
</process>

<output_contract>
  <item>Investigation initialized with clear next actions.</item>
  <item>Delegation plan with prioritized workflow steps.</item>
</output_contract>
