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

<kali_execution_context>
  <tools>nuclei, nikto, sqlmap, ffuf, gobuster, hydra, sslscan, testssl.sh, semgrep, bandit, trufflehog, curl</tools>
  <preflight>Run `command -v nuclei nikto sqlmap ffuf gobuster hydra sslscan testssl.sh || true` before relying on any Kali tool. Record missing tools instead of inventing results.</preflight>
  <input_expected>Authorized lab target, workItemRef/finding reference when applicable, explicit scope boundaries, allowed testing window, rate limits, and evidence destination.</input_expected>
  <safe_defaults>Use passive or low-impact checks first; use `-Pn`, bounded ports, `--rate-limit`, `--batch`, `--safe-url`, low `--level/--risk`, and no destructive payloads unless the approved lab plan explicitly permits it.</safe_defaults>
  <command_examples>
    nuclei -u https://TARGET -severity critical,high,medium -rate-limit 5 -jsonl -o .samourai/tmpai/hunt/nuclei.jsonl
    nikto -h https://TARGET -nointeractive -Format json -output .samourai/tmpai/hunt/nikto.json
    sqlmap -u "https://TARGET/item?id=1" --batch --safe-url=https://TARGET/health --level=1 --risk=1 --output-dir=.samourai/tmpai/hunt/sqlmap
  </command_examples>
  <structured_output>Findings register: finding ID, class/CWE, target, reproduction signal, severity hint, confidence, false-positive notes, evidence path. Include `tools_used`, `commands_run`, `evidence_paths`, `missing_tools`, `limitations`, and `next_step`.</structured_output>
</kali_execution_context>
