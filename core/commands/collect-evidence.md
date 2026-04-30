---
#
description: Collect, structure, and preserve investigation evidence.
agent: evidence-agent
subtask: true
---

<purpose>
Capture reproducible evidence artifacts with integrity and traceability metadata.
</purpose>

<command>
User invocation:
  /collect-evidence <context>
</command>

<inputs>
  <item>context: finding, target, and artifact pointers to collect.</item>
</inputs>

<process>
1. Gather relevant logs, outputs, and artifacts.
2. Record timestamps, hashes, and custody metadata.
3. Redact sensitive information where required.
4. Produce evidence package summary.
</process>

<output_contract>
  <item>Structured evidence index with integrity metadata.</item>
</output_contract>
