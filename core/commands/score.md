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

<kali_execution_context>
  <tools>searchsploit, nuclei, curl, msfconsole</tools>
  <preflight>Run `command -v searchsploit nuclei curl msfconsole || true` before relying on any Kali tool. Record missing tools instead of inventing results.</preflight>
  <input_expected>Authorized lab target, workItemRef/finding reference when applicable, explicit scope boundaries, allowed testing window, rate limits, and evidence destination.</input_expected>
  <safe_defaults>Use passive or low-impact checks first; use `-Pn`, bounded ports, `--rate-limit`, `--batch`, `--safe-url`, low `--level/--risk`, and no destructive payloads unless the approved lab plan explicitly permits it.</safe_defaults>
  <command_examples>
    searchsploit --cve CVE_ID
    curl -fsSL "https://api.first.org/data/v1/epss?cve=CVE_ID"
    msfconsole -q -x "search cve:CVE_ID; exit"
  </command_examples>
  <structured_output>Exploitability score: CVSS vector, EPSS percentile/probability, exploit maturity, prerequisites, safe validation recommendation. Include `tools_used`, `commands_run`, `evidence_paths`, `missing_tools`, `limitations`, and `next_step`.</structured_output>
</kali_execution_context>
