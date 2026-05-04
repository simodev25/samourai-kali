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

<kali_execution_context>
  <tools>curl, burpsuite, zaproxy, tcpdump, tshark, strace, ltrace, semgrep, nmap</tools>
  <preflight>Run `command -v curl burpsuite zaproxy tcpdump tshark strace ltrace semgrep || true` before relying on any Kali tool. Record missing tools instead of inventing results.</preflight>
  <input_expected>Authorized lab target, workItemRef/finding reference when applicable, explicit scope boundaries, allowed testing window, rate limits, and evidence destination.</input_expected>
  <safe_defaults>Use passive or low-impact checks first; use `-Pn`, bounded ports, `--rate-limit`, `--batch`, `--safe-url`, low `--level/--risk`, and no destructive payloads unless the approved lab plan explicitly permits it.</safe_defaults>
  <command_examples>
    curl -k -i --max-time 10 https://TARGET/PATH
    tcpdump -i IFACE -w .samourai/tmpai/evidence/traffic.pcap host TARGET_IP
    semgrep --config=p/owasp-top-ten --json -o .samourai/tmpai/analysis/semgrep.json SRC
  </command_examples>
  <structured_output>Technical analysis: root cause, exploit path, affected component/version, CWE, CVSS vector draft, constraints, evidence references. Include `tools_used`, `commands_run`, `evidence_paths`, `missing_tools`, `limitations`, and `next_step`.</structured_output>
</kali_execution_context>
