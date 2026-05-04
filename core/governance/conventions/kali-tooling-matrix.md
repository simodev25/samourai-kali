# Kali Tooling Matrix

This convention defines the canonical Kali/tool mapping for Samourai agents, skills, and command prompts.

## Execution Rules

- Every tool-dependent task must run a `command -v ... || true` preflight before relying on a Kali tool.
- Missing tools must be reported as `missing_tools` or `NEEDS_TOOLING`; agents must not invent output.
- Active scanning, brute force, exploitation validation, packet capture, and Metasploit usage are lab-only and require written authorization, scope, time window, and rate limits.
- Scanner output is a lead until independently reproduced and tied to evidence.
- Evidence artifacts must be written under `.samourai/tmpai/` or the approved change folder.
- User-facing reports and summaries must be written in French.

## Local Detection Baseline

During the repassage on this workspace, the following tools were detected:

- Present: `nmap`, `gobuster`, `hashcat`, `curl`, `wget`, `tcpdump`, `nc`
- Missing from this non-Kali workspace: `masscan`, `amass`, `subfinder`, `theHarvester`, `whatweb`, `wafw00f`, `nikto`, `dirsearch`, `ffuf`, `wfuzz`, `nuclei`, `sqlmap`, `commix`, `dalfox`, `hydra`, `sslscan`, `testssl.sh`, `tshark`, `searchsploit`, `semgrep`, `bandit`, `trufflehog`, `msfconsole`

Samourai targets Kali Linux, so missing local tools do not remove the standard mapping. They must be handled through preflight and lab readiness checks.

## Direct Cyber Agents

| Agent | Primary tools | Purpose |
|---|---|---|
| `@attack-surface-agent` | `nmap`, `masscan`, `amass`, `subfinder`, `theHarvester`, `whatweb`, `wafw00f`, `gobuster`, `ffuf`, `nikto`, `curl` | Reconnaissance, service discovery, attack surface mapping |
| `@bug-hunting-agent` | `nuclei`, `nikto`, `sqlmap`, `ffuf`, `gobuster`, `hydra`, `sslscan`, `testssl.sh`, `semgrep`, `bandit`, `trufflehog`, `curl` | Vulnerability discovery and triage |
| `@vulnerability-analysis-agent` | `curl`, `burpsuite`, `zaproxy`, `tcpdump`, `tshark`, `strace`, `ltrace`, `semgrep`, `nmap` | Root-cause and impact analysis |
| `@cve-intelligence-agent` | `searchsploit`, `nuclei`, `curl` | CVE, advisory, EPSS, and exploit maturity lookup |
| `@exploitability-agent` | `searchsploit`, `nuclei`, `curl`, `msfconsole` | CVSS/EPSS/exploitability assessment |
| `@safe-poc-agent` | `curl`, `python3`, `nc`, `nmap`, `msfconsole` | Minimal lab-only proof validation |
| `@evidence-agent` | `script`, `sha256sum`, `tcpdump`, `tshark`, `curl`, `scrot` | Evidence capture, hashing, custody metadata |
| `@remediation-agent` | `nmap`, `nuclei`, `nikto`, `sqlmap`, `semgrep`, `sslscan`, `testssl.sh`, `curl` | Fix planning and before/after validation |
| `@runner` | Any approved Kali command delegated by another agent | Execution, log capture, metadata |
| `@bootstrapper` | `command -v`, package metadata, baseline tools | Lab readiness and missing-tool reporting |

## Support Agents

Support agents such as `@pm`, `@reviewer`, `@editor`, `@committer`, `@pr-manager`, `@spec-writer`, and `@plan-writer` do not run offensive tooling directly by default. They consume, review, route, or publish Kali-derived evidence and must delegate execution to `@runner` or the specialized cyber agent.

Support agents may run read-only checks such as:

```bash
command -v nmap nuclei nikto sqlmap ffuf gobuster tcpdump searchsploit semgrep || true
rg -n "nmap|nuclei|nikto|sqlmap|ffuf|gobuster|tcpdump|searchsploit|semgrep" .samourai/docai .samourai/tmpai core || true
sha256sum EVIDENCE_ARTIFACT
```

## Workflow Compatibility

The canonical workflow contract is:

```text
/recon        -> @attack-surface-agent         -> attack surface map
/hunt         -> @bug-hunting-agent            -> findings register
/analyze-vuln -> @vulnerability-analysis-agent -> root cause and impact analysis
/cve-lookup   -> @cve-intelligence-agent       -> CVE/advisory intelligence
/score        -> @exploitability-agent         -> exploitability score
/poc          -> @safe-poc-agent               -> safe lab-only proof package
/collect-evidence -> @evidence-agent           -> evidence index
/cve-report   -> @cve-report-agent             -> CVE-ready report
/remediate    -> @remediation-agent            -> remediation and validation plan
```

Each stage must preserve `tools_used`, `commands_run`, `evidence_paths`, `missing_tools`, `limitations`, and `next_step`.
