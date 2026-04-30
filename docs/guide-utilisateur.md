# Samourai Kali User Guide

This guide covers the installation and use of Samourai Kali in a cybersecurity
environment. It is intended for pentesters, vulnerability researchers, and security
analysts who want to structure their work with specialized AI agents.

## Scope

Samourai Kali installs an AI-assisted work framework in a security environment:

- specialized cyber agents (recon, hunting, analysis, POC, evidence, reporting);
- investigation workflow commands;
- skills based on real Kali Linux tools;
- governance conventions and ethical guardrails;
- CVE-ready reporting templates;
- adapters for OpenCode and VS Code/GitHub Copilot.

The kit does not replace human security expertise. It structures work,
automates repetitive tasks, and ensures evidence traceability.

**Mandatory guardrails**: LAB-ONLY, NO WEAPONIZATION, RESPONSIBLE DISCLOSURE,
AUTHORIZATION required, SCOPE respected, DATA PROTECTION, LOGGING mandatory.

## Installation Model

Identical to the original model (core/, adapters, blueprints). See README.md
for installation details.

### Core

```text
core/agents/       → cyber agents (attack-surface, bug-hunting, etc.)
core/commands/     → investigation commands
core/skills/       → skills based on Kali tools
core/governance/   → policies, lifecycle, permissions
core/templates/    → reporting templates
core/decisions/    → security decisions (SDR)
```

### Investigation Artifacts

Documents produced during investigations go under `.samourai/docai/`:

```text
.samourai/docai/changes/    → investigation folders per vulnerability
.samourai/docai/spec/       → vulnerability knowledge base
.samourai/docai/decisions/  → security decisions
```

Temporary files (scan logs, raw evidence):

```text
.samourai/tmpai/run-logs-runner/  → scan execution logs
.samourai/tmpai/code-review/      → findings review results
.samourai/tmpai/pr/               → reports for publication
```

## Investigation Workflow

A vulnerability investigation follows this order:

```text
/plan-change <ref>          → scope the investigation
/write-spec <ref>           → vulnerability specification
/write-test-plan <ref>      → POC validation plan
/write-plan <ref>           → investigation plan
/run-plan <ref>             → execute phases (recon → analysis → POC → evidence)
/review <ref>               → peer review
/check                      → evidence quality verification
/sync-docs <ref>            → archive evidence and findings
/commit                     → commit artifacts
/pr                         → publish report
```

For a GitHub ticket:

```text
/plan-change GH-42
/write-spec GH-42
/write-test-plan GH-42
/write-plan GH-42
/run-plan GH-42
/review GH-42
/check
/sync-docs GH-42
/commit
/pr
```

Orchestration can be delegated to Mission Control:

```text
@pm investigate GH-42
```

## Agent Roles

### Cyber Agents (Investigation)

| Agent | Responsibility | Kali Tools |
|-------|----------------|------------|
| `@attack-surface-agent` | Attack surface mapping | nmap, masscan, amass, subfinder, whatweb, gobuster, nikto |
| `@bug-hunting-agent` | Active vulnerability hunting | sqlmap, nuclei, ffuf, nikto, hydra, semgrep, sslscan |
| `@vulnerability-analysis-agent` | In-depth technical analysis | burpsuite, zaproxy, tcpdump, strace, semgrep |
| `@cve-intelligence-agent` | CVE research and intelligence | searchsploit, NVD API, EPSS API |
| `@exploitability-agent` | CVSS/EPSS scoring | CVSS calculators, EPSS API |
| `@safe-poc-agent` | Minimal, safe POC (lab-only) | curl, netcat, msfconsole, python3, nmap NSE |
| `@evidence-agent` | Forensic-grade evidence collection | sha256sum, tcpdump, tshark, script, scrot |
| `@cve-report-agent` | Standards-compliant CVE report | Writing only |
| `@remediation-agent` | Fixes and verification | nmap, nikto, nuclei, sqlmap, semgrep |

### Infrastructure Agents

| Agent | Responsibility |
|-------|----------------|
| `@pm` | Mission Control — orchestrates the full investigation |
| `@architect` | Threat Modeling — STRIDE/DREAD, attack trees, trust boundaries |
| `@reviewer` | Peer review of findings, POCs, and reports |
| `@runner` | Command execution and log capture |
| `@committer` | Conventional Commit commits |
| `@pr-manager` | Report publication |
| `@external-researcher` | Security intelligence via MCP (NVD, exploit-db, advisories) |
| `@editor` | Security technical writing (CVE, advisories, disclosure) |
| `@fixer` | Debugging and problem resolution |
| `@toolsmith` | Creating/modifying agents, skills, commands |
| `@image-reviewer` | Screenshot analysis of vulnerabilities |
| `@code-reviewer` | Code review: security, vulnerabilities, reliability |

### Typical Investigation Chain

```text
pm → attack-surface-agent → bug-hunting-agent → vulnerability-analysis-agent
   → cve-intelligence-agent → exploitability-agent → safe-poc-agent
   → evidence-agent → cve-report-agent → reviewer → remediation-agent
```

### Usage Examples

```text
@attack-surface-agent map target 192.168.1.0/24 scope authorized
@bug-hunting-agent hunt for SQL injection on https://lab-target
@safe-poc-agent create POC for CVE-2024-1234 in lab environment
@evidence-agent collect and hash all artifacts for GH-42
@cve-report-agent generate CVE report for GH-42
@remediation-agent verify fix for SQL injection on lab-target
```

## Available Commands

| Command | Usage |
|---------|-------|
| `/bootstrap` | Configure the test environment (lab setup) |
| `/plan-change [ref]` | Scope an investigation before analysis |
| `/write-spec <ref>` | Vulnerability specification |
| `/write-test-plan <ref>` | POC validation plan |
| `/write-plan <ref>` | Investigation plan |
| `/run-plan <ref> [directives]` | Execute investigation phases |
| `/tdd <ref> [scope]` | Red team cycle (hypothesis → proof → documentation) |
| `/review <ref>` | Review finding against spec and plan |
| `/check` | Evidence quality verification (hashing, timestamps, custody) |
| `/check-fix` | Remediation verification and correction |
| `/sync-docs <ref>` | Archive evidence and findings |
| `/commit` | Conventional Commit commit |
| `/pr` | Publish report |
| `/git-workflow <branch> [flags]` | Full Git flow with checkpoints |
| `/generate-project-skills` | Generate project-specific skills |
| `/test-api-e2e` | Run security scans (nmap, nikto, sqlmap) |

## Kali Skills

Each skill is based on real Kali tools with concrete commands:

| Skill | Primary Tool | Example Command |
|-------|-------------|-----------------|
| `attack-surface-analysis` | nmap | `nmap -sV -sC -O -Pn -oA results <target>` |
| `bug-hunting-analysis` | sqlmap, nuclei | `sqlmap -u "url?id=1" --batch --dbs` |
| `vulnerability-analysis` | burpsuite, tcpdump | `tcpdump -i eth0 -w capture.pcap host target` |
| `cve-research` | searchsploit | `searchsploit apache 2.4` |
| `exploitability-assessment` | CVSS calculator | CVSS v3.1/v4.0 score + EPSS |
| `safe-poc-generation` | curl, msfconsole | `curl -s "target/page?id=1' OR '1'='1"` |
| `poc-validation` | tcpdump, sha256sum | `sha256sum poc_output.txt` |
| `evidence-collection` | sha256sum, tshark | `find evidence/ -exec sha256sum {} \;` |
| `cve-reporting` | — | CVE JSON 5.0 writing |
| `remediation-plan` | nmap, nuclei | `nuclei -u target -t template.yaml` |

## Investigation Example

Ticket:

```text
GH-42: Potential SQL Injection vulnerability on /api/search
```

### Scoping

```text
/plan-change GH-42
```

Specify: target, scope, authorization, priority tools, confirmation criteria.

### Specification

```text
/write-spec GH-42
```

Deliverable:
```text
.samourai/docai/changes/YYYY-MM/YYYY-MM-DD--GH-42--sqli-api-search/chg-GH-42-spec.md
```

### POC Validation Plan

```text
/write-test-plan GH-42
```

Criteria: reproducibility, lab isolation, POC safety, evidence hashing.

### Investigation Plan

```text
/write-plan GH-42
```

Phases:
1. Reconnaissance of the /api/search endpoint
2. SQL injection testing (sqlmap)
3. Root cause analysis
4. CVE correlation (searchsploit)
5. CVSS/EPSS scoring
6. Safe POC creation (lab-only)
7. Evidence collection (hash + timestamp)
8. CVE report writing

### Execution

```text
/run-plan GH-42
```

Or phase by phase:
```text
@attack-surface-agent scan /api/search endpoint on lab-target
@bug-hunting-agent test SQL injection on https://lab-target/api/search
@safe-poc-agent create minimal POC for SQL injection
@evidence-agent collect and hash all findings for GH-42
@cve-report-agent generate report for GH-42
```

### Review and Verification

```text
/review GH-42
/check
```

### Publication

```text
/commit
/pr
```

## Best Practices

- Always verify authorization before any investigation.
- Work exclusively in an isolated lab environment.
- Never create a weaponizable POC.
- Hash and timestamp all evidence.
- Review generated reports before publication.
- Follow the responsible disclosure process.
- Document limitations and unverified assumptions.
- Use `@pm` to orchestrate complex investigations.
- Use `@external-researcher` for CVE monitoring and advisories.

## Troubleshooting

### Invalid OpenCode Configuration

```bash
cat .opencode/opencode.jsonc
./scripts/install-samourai.sh --target /chemin/vers/lab --editor opencode --force
```

### Missing Kali Tool

If an agent reports a missing tool:

```bash
sudo apt install nmap nikto sqlmap hydra gobuster
pip install semgrep
```

### Uninstall

```bash
./scripts/uninstall-samourai.sh --target /chemin/vers/lab
```

## Summary

For full orchestration:

```text
OpenCode + /bootstrap + @pm investigate GH-42
```

For targeted use:

```text
@attack-surface-agent scan target
@bug-hunting-agent hunt for OWASP Top 10
@safe-poc-agent create POC for finding
```
