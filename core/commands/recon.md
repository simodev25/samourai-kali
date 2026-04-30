---
#
description: Perform attack-surface reconnaissance on a scoped target.
agent: attack-surface-agent
subtask: true
---

<purpose>
Map externally reachable assets and attack surface with safe reconnaissance.
</purpose>

<command>
User invocation:
  /recon <target> [options]
</command>

<inputs>
  <item>target: domain, IP range, URL, or service identifier.</item>
  <item>options: optional scope constraints and depth level.</item>
</inputs>

<process>
1. Confirm authorized scope.
2. Enumerate assets, endpoints, and exposed services.
3. Record findings with confidence levels.
4. Return prioritized attack-surface map.
</process>

<output_contract>
  <item>Structured reconnaissance findings and priority targets.</item>
</output_contract>
