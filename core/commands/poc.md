---
#
description: Build or validate a safe, lab-only proof of concept.
agent: safe-poc-agent
subtask: true
---

<purpose>
Create a minimal and non-weaponizable proof of concept in authorized lab scope.
</purpose>

<command>
User invocation:
  /poc <finding-or-cve> [lab-context]
</command>

<inputs>
  <item>finding-or-cve: vulnerability reference.</item>
  <item>lab-context: optional environment details and safety constraints.</item>
</inputs>

<process>
1. Verify authorization and lab-only environment.
2. Define minimal demonstration objective.
3. Implement safe POC with clear warnings and cleanup steps.
4. Validate reproducibility without unsafe behaviors.
</process>

<output_contract>
  <item>Safe POC package with run and cleanup instructions.</item>
</output_contract>
