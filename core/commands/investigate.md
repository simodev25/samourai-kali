---
#
description: Orchestrate a full cyber investigation lifecycle for a target.
agent: pm
subtask: true
---

<purpose>
Start and orchestrate a full cyber investigation for a target from recon to reporting.
</purpose>

<command>
User invocation:
  /investigate <target> [context]
</command>

<inputs>
  <item>target: hostname, domain, IP, service, or asset identifier.</item>
  <item>context: optional scope, authorization reference, and constraints.</item>
</inputs>

<process>
1. Validate scope and authorization.
2. Initialize investigation context in change artifacts.
3. Delegate recon to `@attack-surface-agent`.
4. Delegate hunt/analysis as needed.
5. Coordinate evidence, report, and remediation outputs.
</process>

<output_contract>
  <item>Investigation initialized with clear next actions.</item>
  <item>Delegation plan with prioritized workflow steps.</item>
</output_contract>

<kali_execution_context>
  <tools>nmap, masscan, amass, subfinder, theHarvester, whatweb, wafw00f, nikto, gobuster, dirsearch, ffuf, wfuzz, nuclei, sqlmap, commix, dalfox, hydra, sslscan, testssl.sh, tcpdump, tshark, searchsploit, semgrep, bandit, trufflehog, msfconsole</tools>
  <preflight>Run `command -v nmap masscan amass subfinder theHarvester whatweb wafw00f nikto || true` before relying on any Kali tool. Record missing tools instead of inventing results.</preflight>
  <input_expected>Authorized lab target, workItemRef/finding reference when applicable, explicit scope boundaries, allowed testing window, rate limits, and evidence destination.</input_expected>
  <safe_defaults>Use passive or low-impact checks first; use `-Pn`, bounded ports, `--rate-limit`, `--batch`, `--safe-url`, low `--level/--risk`, and no destructive payloads unless the approved lab plan explicitly permits it.</safe_defaults>
  <command_examples>
    /recon TARGET
    /hunt TARGET
    /analyze-vuln FINDING_OR_CVE
  </command_examples>
  <structured_output>Investigation state, delegation plan, required artifacts, and next command. Include `tools_used`, `commands_run`, `evidence_paths`, `missing_tools`, `limitations`, and `next_step`.</structured_output>
</kali_execution_context>
