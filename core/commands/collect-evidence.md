---
#
description: Collect, structure, and preserve investigation evidence.
agent: evidence-agent
subtask: true
---

<purpose>
Capture reproducible evidence artifacts with integrity and traceability metadata.
</purpose>

<command>
User invocation:
  /collect-evidence <context>
</command>

<inputs>
  <item>context: finding, target, and artifact pointers to collect.</item>
</inputs>

<process>
1. Gather relevant logs, outputs, and artifacts.
2. Record timestamps, hashes, and custody metadata.
3. Redact sensitive information where required.
4. Produce evidence package summary.
</process>

<output_contract>
  <item>Structured evidence index with integrity metadata.</item>
</output_contract>

<kali_execution_context>
  <tools>script, sha256sum, tcpdump, tshark, curl, scrot</tools>
  <preflight>Run `command -v script sha256sum tcpdump tshark curl scrot || true` before relying on any Kali tool. Record missing tools instead of inventing results.</preflight>
  <input_expected>Authorized lab target, workItemRef/finding reference when applicable, explicit scope boundaries, allowed testing window, rate limits, and evidence destination.</input_expected>
  <safe_defaults>Use passive or low-impact checks first; use `-Pn`, bounded ports, `--rate-limit`, `--batch`, `--safe-url`, low `--level/--risk`, and no destructive payloads unless the approved lab plan explicitly permits it.</safe_defaults>
  <command_examples>
    script -q .samourai/tmpai/evidence/session.typescript -c "APPROVED_COMMAND"
    sha256sum .samourai/tmpai/evidence/* > .samourai/tmpai/evidence/SHA256SUMS
    tcpdump -i IFACE -w .samourai/tmpai/evidence/capture.pcap host TARGET_IP
  </command_examples>
  <structured_output>Evidence index: artifact path, command, timestamp, SHA256, scope note, redaction status, custody metadata. Include `tools_used`, `commands_run`, `evidence_paths`, `missing_tools`, `limitations`, and `next_step`.</structured_output>
</kali_execution_context>
