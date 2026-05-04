---
#
description: Show investigation status, completed phases, and next actions.
agent: pm
subtask: true
---

<purpose>
Provide a concise status view of the current investigation lifecycle.
</purpose>

<command>
User invocation:
  /status [workItemRef]
</command>

<inputs>
  <item>workItemRef: optional tracker reference; defaults to active investigation.</item>
</inputs>

<process>
1. Resolve target investigation.
2. Read current phase progress and blockers.
3. Summarize completed work, pending tasks, and recommended next step.
</process>

<output_contract>
  <item>Compact status summary with explicit next actions.</item>
</output_contract>

<kali_execution_context>
  <tools>nmap, nuclei, nikto, sqlmap, ffuf, gobuster, tcpdump, searchsploit, semgrep</tools>
  <preflight>When this prompt plans, reviews, publishes, or coordinates tool-dependent work, run or request `command -v nmap nuclei nikto sqlmap ffuf gobuster tcpdump searchsploit semgrep || true` and record missing tools.</preflight>
  <input_expected>workItemRef or task context, relevant evidence paths, authorized scope boundaries if security execution is involved, and expected downstream artifact.</input_expected>
  <safe_defaults>This prompt must not execute active scans by itself unless its assigned agent is a cyber execution agent. Delegate execution to `@runner` or the specialized cyber agent and preserve lab-only authorization gates.</safe_defaults>
  <command_examples>
    command -v nmap nuclei nikto sqlmap ffuf gobuster tcpdump searchsploit semgrep || true
    rg -n "nmap|nuclei|nikto|sqlmap|ffuf|gobuster|tcpdump|searchsploit|semgrep" .samourai/docai .samourai/tmpai core || true
  </command_examples>
  <structured_output>Structured prompt output with delegated agent/tool, input contract, expected evidence fields, missing tools, limitations, and next step.</structured_output>
</kali_execution_context>
