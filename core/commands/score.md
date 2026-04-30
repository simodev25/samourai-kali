---
#
description: Score exploitability using CVSS and EPSS context.
agent: exploitability-agent
subtask: true
---

<purpose>
Estimate exploitability risk by combining available scoring signals.
</purpose>

<command>
User invocation:
  /score <cve-id-or-finding>
</command>

<inputs>
  <item>cve-id-or-finding: target vulnerability reference.</item>
</inputs>

<process>
1. Resolve vulnerability reference.
2. Retrieve CVSS context and EPSS data where available.
3. Produce an exploitability summary with confidence and rationale.
</process>

<output_contract>
  <item>Exploitability summary including EPSS probability when available.</item>
</output_contract>
