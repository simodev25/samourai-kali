---
#
description: Build or validate a safe, lab-only proof of concept.
agent: safe-poc-agent
subtask: true
---

<purpose>
Create a minimal and non-weaponizable proof of concept in authorized lab scope.
</purpose>

<command>
User invocation:
  /poc <finding-or-cve> [lab-context]
</command>

<inputs>
  <item>finding-or-cve: vulnerability reference.</item>
  <item>lab-context: optional environment details and safety constraints.</item>
</inputs>

<process>
1. Verify authorization and lab-only environment.
2. Define minimal demonstration objective.
3. Implement safe POC with clear warnings and cleanup steps.
4. Validate reproducibility without unsafe behaviors.
</process>

<output_contract>
  <item>Safe POC package with run and cleanup instructions.</item>
</output_contract>

<kali_execution_context>
  <tools>curl, python3, nc, nmap, msfconsole</tools>
  <preflight>Run `command -v curl python3 nc nmap msfconsole || true` before relying on any Kali tool. Record missing tools instead of inventing results.</preflight>
  <input_expected>Authorized lab target, workItemRef/finding reference when applicable, explicit scope boundaries, allowed testing window, rate limits, and evidence destination.</input_expected>
  <safe_defaults>Use passive or low-impact checks first; use `-Pn`, bounded ports, `--rate-limit`, `--batch`, `--safe-url`, low `--level/--risk`, and no destructive payloads unless the approved lab plan explicitly permits it.</safe_defaults>
  <command_examples>
    curl -k -i --max-time 10 --path-as-is "https://LAB_TARGET/MINIMAL_TEST"
    python3 poc.py --target https://LAB_TARGET --safe-mode --dry-run
    nmap --script SAFE_NSE_SCRIPT -p PORT LAB_TARGET -oN .samourai/tmpai/poc/nse.txt
  </command_examples>
  <structured_output>Safe POC package: hypothesis, lab markers, minimal command/script, expected signal, cleanup, logs,notes. Include `tools_used`, `commands_run`, `evidence_paths`, `missing_tools`, `limitations`, and `next_step`.</structured_output>
</kali_execution_context>
