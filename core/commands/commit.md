---
#
description: Delegate a single Conventional Commit.
agent: committer
subtask: true
---

<purpose>Trigger the @committer agent to create exactly one Conventional Commit.</purpose>

<inputs>
  <optional>
    <intent>$ARGUMENTS</intent>
  </optional>
</inputs>

<instructions>
  <rule>Invoke `@committer` now.</rule>
  <rule>Do not restate its workflow; do not add extra commentary.</rule>
  <rule>If blocked, surface the agent's message without alteration.</rule>
  <rule>If successful, return exactly the agent's output.</rule>
</instructions>

<intent>
$ARGUMENTS
</intent>

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
