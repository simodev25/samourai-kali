---
#
description: Show investigation status, completed phases, and next actions.
agent: pm
subtask: true
---

<purpose>
Provide a concise status view of the current investigation lifecycle.
</purpose>

<command>
User invocation:
  /status [workItemRef]
</command>

<inputs>
  <item>workItemRef: optional tracker reference; defaults to active investigation.</item>
</inputs>

<process>
1. Resolve target investigation.
2. Read current phase progress and blockers.
3. Summarize completed work, pending tasks, and recommended next step.
</process>

<output_contract>
  <item>Compact status summary with explicit next actions.</item>
</output_contract>
