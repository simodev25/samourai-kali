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

<kali_execution_context>
  <tools>nmap, masscan, amass, subfinder, theHarvester, whatweb, wafw00f, gobuster, ffuf, nikto, curl</tools>
  <preflight>Run `command -v nmap masscan amass subfinder theHarvester whatweb wafw00f gobuster || true` before relying on any Kali tool. Record missing tools instead of inventing results.</preflight>
  <input_expected>Authorized lab target, workItemRef/finding reference when applicable, explicit scope boundaries, allowed testing window, rate limits, and evidence destination.</input_expected>
  <safe_defaults>Use passive or low-impact checks first; use `-Pn`, bounded ports, `--rate-limit`, `--batch`, `--safe-url`, low `--level/--risk`, and no destructive payloads unless the approved lab plan explicitly permits it.</safe_defaults>
  <command_examples>
    nmap -sV -sC -Pn --top-ports 1000 -oA .samourai/tmpai/recon/nmap-safe TARGET
    amass enum -passive -d DOMAIN -o .samourai/tmpai/recon/amass.txt
    gobuster dir -u https://TARGET -w /usr/share/wordlists/dirb/common.txt -t 10 -o .samourai/tmpai/recon/gobuster.txt
  </command_examples>
  <structured_output>Attack surface map: assets, ports, services, technologies, endpoints, confidence, evidence path, and next recommended agent. Include `tools_used`, `commands_run`, `evidence_paths`, `missing_tools`, `limitations`, and `next_step`.</structured_output>
</kali_execution_context>
