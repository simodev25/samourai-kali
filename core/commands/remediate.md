---
#
description: Produce and validate a remediation plan for findings.
agent: remediation-agent
subtask: true
---

<purpose>
Generate prioritized remediation guidance and validation checkpoints.
</purpose>

<command>
User invocation:
  /remediate <finding-or-cve>
</command>

<inputs>
  <item>finding-or-cve: vulnerability reference to remediate.</item>
</inputs>

<process>
1. Analyze feasible remediation options.
2. Propose prioritized fixes with risk reduction estimates.
3. Define validation checks and regression safeguards.
</process>

<output_contract>
  <item>Actionable remediation plan with verification steps.</item>
</output_contract>

<kali_execution_context>
  <tools>nmap, nuclei, nikto, sqlmap, semgrep, sslscan, testssl.sh, curl</tools>
  <preflight>Run `command -v nmap nuclei nikto sqlmap semgrep sslscan testssl.sh curl || true` before relying on any Kali tool. Record missing tools instead of inventing results.</preflight>
  <input_expected>Authorized lab target, workItemRef/finding reference when applicable, explicit scope boundaries, allowed testing window, rate limits, and evidence destination.</input_expected>
  <safe_defaults>Use passive or low-impact checks first; use `-Pn`, bounded ports, `--rate-limit`, `--batch`, `--safe-url`, low `--level/--risk`, and no destructive payloads unless the approved lab plan explicitly permits it.</safe_defaults>
  <command_examples>
    nmap -sV -sC -Pn -p PORTS -oA .samourai/tmpai/remediation/nmap-after TARGET
    nuclei -u https://TARGET -id TEMPLATE_ID -jsonl -o .samourai/tmpai/remediation/nuclei-after.jsonl
    semgrep --config=p/owasp-top-ten --json -o .samourai/tmpai/remediation/semgrep-after.json SRC
  </command_examples>
  <structured_output>Remediation plan and validation: fix option, residual risk, before/after evidence, regression checks, acceptance status. Include `tools_used`, `commands_run`, `evidence_paths`, `missing_tools`, `limitations`, and `next_step`.</structured_output>
</kali_execution_context>
