---
#
description: Hunt for vulnerabilities in a scoped target.
agent: bug-hunting-agent
subtask: true
---

<purpose>
Systematically identify potential vulnerabilities within authorized scope.
</purpose>

<command>
User invocation:
  /hunt <target> [focus]
</command>

<inputs>
  <item>target: asset under investigation.</item>
  <item>focus: optional vulnerability classes or components.</item>
</inputs>

<process>
1. Build hunt hypotheses from target context.
2. Execute safe checks and analysis routines.
3. Capture candidate findings with reproducible evidence.
</process>

<output_contract>
  <item>Candidate findings with severity hints and evidence links.</item>
</output_contract>
