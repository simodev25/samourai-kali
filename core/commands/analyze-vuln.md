---
#
description: Perform deep analysis of a specific vulnerability finding.
agent: vulnerability-analysis-agent
subtask: true
---

<purpose>
Deepen understanding of a vulnerability: root cause, impact, exploit path, and constraints.
</purpose>

<command>
User invocation:
  /analyze-vuln <finding-or-cve> [context]
</command>

<inputs>
  <item>finding-or-cve: finding identifier, CVE, or vulnerable component reference.</item>
  <item>context: optional environment and reproduction details.</item>
</inputs>

<process>
1. Validate finding context and assumptions.
2. Analyze root cause and affected versions/components.
3. Assess impact and exploitation prerequisites.
4. Produce a concise technical analysis report.
</process>

<output_contract>
  <item>Root-cause analysis with impact and reproducibility guidance.</item>
</output_contract>
