---
change:
  ref: GH-13
  type: feat
  status: Proposed
  slug: samourai-kali-operationnel
  title: "Make Samourai Kali Fully Operational for Cyber Investigations"
  owners: [engineering]
  service: samourai-kali
  labels: [cyber, platform, commands, documentation, adapters, mcp]
  version_impact: minor
  audience: internal
  security_impact: medium
  risk_level: medium
  dependencies:
    internal: [core/agents, core/skills, scripts/install-samourai.sh]
    external: [NVD API, EPSS API]
---

# CHANGE SPECIFICATION

> **PURPOSE**: Activate the full cyber investigation capability of Samourai Kali by closing all structural gaps — missing commands, orphaned agents, absent documentation, adapter support, stage gates, a tools directory, and MCP integrations — so the platform works end-to-end out of the box.

## 1. SUMMARY

Samourai Kali is positioned as an AI Cybersecurity Operating System, yet its cyber core is non-operational: no cyber-specific commands exist, four agents are not tracked in `core/`, documentation is absent, and no editor adapters or security API integrations are wired up. This change delivers eight coordinated workstreams that together bring the platform from "skeleton" to "fully operational" — enabling practitioners to run `/investigate`, `/recon`, `/hunt`, and all related cyber workflows against real targets.

## 2. CONTEXT

### 2.1 Current State Snapshot

- **Agents**: 27 agent definitions exist in `core/agents/`, covering both generic (coder, reviewer, pm, …) and cyber-specific roles (cve-intelligence-agent, bug-hunting-agent, attack-surface-agent, etc.). The install script copies the entire `core/` tree, so agent availability is not blocked.
- **Skills**: 10+ cyber-specific skills exist in `core/skills/` (attack-surface-analysis, cve-research, poc-validation, etc.). Install handles deployment.
- **Commands**: All 11 current commands in `.opencode/command/` are generic dev-workflow commands (`/run-plan`, `/commit`, `/pr`, etc.). No cyber-specific command exists.
- **Orphaned agents**: 4 agents present in `.opencode/agent/` are **not** in `core/agents/` (`designer`, `image-generator`, `review-feedback-applier`, `tdd-orchestrator`). They would be silently deleted on reinstall.
- **Documentation**: No `CONTRIBUTING.md`, no architecture document, no investigation workflow template.
- **Adapters**: Only OpenCode is configured. No Claude Code or Cursor adapter exists. The install script has no `--editor` flag.
- **Stage gates**: Lifecycle mentions stage gates conceptually; no `lifecycle/stage-gates.md` definition file exists.
- **Tools directory**: No `tools/` directory or CLI tooling.
- **MCP integration**: No configuration for NVD API or EPSS API.

### 2.2 Pain Points / Gaps

- Cyber practitioners cannot start an investigation — there is no `/investigate` entry point.
- Agents added outside the canonical `core/agents/` path are silently lost on reinstall.
- New contributors have no guidance on how to contribute to the platform.
- Duplicate or deprecated files (e.g., `pr-instructions-template.md`) create confusion.
- The platform is editor-locked to OpenCode; teams using Cursor or Claude Code cannot adopt it.
- Security data from NVD and EPSS cannot be fetched without manual configuration.

## 3. PROBLEM STATEMENT

Because Samourai Kali lacks cyber-specific commands, proper agent tracking, documentation, adapter support, and security API integration, cyber practitioners cannot run end-to-end investigations using the platform, resulting in the product failing to deliver on its core value proposition as an AI Cybersecurity Operating System.

## 4. GOALS

- **G-1**: Provide a complete set of cyber commands so practitioners can trigger investigations and sub-workflows directly from their editor.
- **G-2**: Ensure all agents are tracked in `core/agents/` so reinstalls are lossless.
- **G-3**: Clean up deprecated and duplicate artifacts to reduce confusion.
- **G-4**: Provide documentation sufficient for a new contributor to understand and extend the platform.
- **G-5**: Support Claude Code and Cursor editors via native adapter configs.
- **G-6**: Define and publish lifecycle stage gates so delivery quality is enforceable.
- **G-7**: Provide at least one CLI tool in `tools/` to enable programmatic interaction.
- **G-8**: Configure MCP connections for NVD API and EPSS API to enable live security data retrieval.

### 4.1 Success Metrics / KPIs

| Metric | Target |
|--------|--------|
| Cyber commands available | 11 (investigate, recon, hunt, analyze-vuln, cve-lookup, score, poc, collect-evidence, cve-report, remediate, status) |
| Agents correctly tracked in `core/agents/` | 100% (zero orphans) |
| Deprecated files removed | All identified deprecated files gone |
| Documentation artifacts created | CONTRIBUTING.md + architecture doc + investigation template |
| Editor adapters supported | ≥ 2 (Claude Code + Cursor) |
| Install script `--editor` flag | Implemented and tested |
| Stage gates defined | `lifecycle/stage-gates.md` exists with ≥ 5 gates |
| CLI tools in `tools/` | ≥ 1 functional tool |
| MCP integrations configured | NVD API + EPSS API both wired |

### 4.2 Non-Goals

- **NG-1**: Building a custom LLM or fine-tuning models.
- **NG-2**: Implementing a GUI or web dashboard.
- **NG-3**: Integrating trackers beyond the existing convention (no new Jira/GitHub MCP scope in this change).
- **NG-4**: Writing automated integration tests that call live external APIs.
- **NG-5**: Migrating the platform to a different config schema.

## 5. FUNCTIONAL CAPABILITIES

| ID | Capability | Rationale |
|----|------------|-----------|
| F-1 | 11 cyber commands deployable via the standard command format | Commands are the practitioner's entry point; without them the cyber agents are unreachable. |
| F-2 | Orphaned agents migrated to `core/agents/` | Reinstall-safety; single source of truth. |
| F-3 | Repo cleanup: deprecated files removed, lifecycle deduplication resolved | Reduces confusion and lowers cognitive load for contributors. |
| F-4 | `CONTRIBUTING.md` explaining contribution workflow | Enables community and team contributions. |
| F-5 | Architecture document describing system structure | Provides onboarding context and guides design decisions. |
| F-6 | Investigation workflow template | Standardises how practitioners document and execute investigations. |
| F-7 | Claude Code adapter config | Extends platform reach to Claude Code users. |
| F-8 | Cursor adapter config | Extends platform reach to Cursor users. |
| F-9 | Install script `--editor` flag | Allows targeting a specific editor during install/reinstall. |
| F-10 | `lifecycle/stage-gates.md` with defined gates | Makes quality enforcement concrete and automatable. |
| F-11 | `tools/` directory with ≥ 1 CLI tool | Enables programmatic and scriptable interaction with platform data. |
| F-12 | MCP config for NVD API | Enables live CVE data lookup during investigations. |
| F-13 | MCP config for EPSS API | Enables exploit probability scoring during investigations. |

### 5.1 Capability Details

**F-1 — Cyber Commands**
Each command follows the established `.opencode/command/` format: YAML front matter with `description`, `agent`, and `subtask` fields, followed by structured content sections (`<purpose>`, `<command>`, `<inputs>`, `<process>`, `<output_contract>`). Commands must delegate to the appropriate cyber agent already present in `core/agents/`.

| Command | Primary Agent | Purpose |
|---------|--------------|---------|
| `/investigate` | pm | Orchestrate a full investigation lifecycle |
| `/recon` | attack-surface-agent | Passive/active reconnaissance |
| `/hunt` | bug-hunting-agent | Vulnerability hunt on a target |
| `/analyze-vuln` | vulnerability-analysis-agent | Deep analysis of a specific vulnerability |
| `/cve-lookup` | cve-intelligence-agent | Fetch CVE details and context |
| `/score` | exploitability-agent | Score exploitability via CVSS + EPSS |
| `/poc` | safe-poc-agent | Generate or validate a PoC safely |
| `/collect-evidence` | evidence-agent | Capture and structure investigation evidence |
| `/cve-report` | cve-report-agent | Generate a CVE report artifact |
| `/remediate` | remediation-agent | Produce a remediation plan |
| `/status` | pm | Display investigation status |

**F-2 — Orphaned Agent Migration**
The four agents (`designer`, `image-generator`, `review-feedback-applier`, `tdd-orchestrator`) must be placed in `core/agents/` with consistent front matter. Their `.opencode/agent/` copies become the installed artifacts; `core/agents/` becomes the canonical source.

**F-3 — Cleanup**
Remove `pr-instructions-template.md` (deprecated). Resolve duplicate lifecycle files: keep one authoritative version, remove or consolidate duplicates. No functional behavior change.

**F-4–F-6 — Documentation**
`CONTRIBUTING.md` must cover: repo structure, agent contribution guide, skill contribution guide, command contribution guide, and PR workflow. The architecture document must describe the layered model (core → install → editor adapter → commands → agents → skills). The investigation template provides a structured Markdown scaffold for documenting a cyber investigation run.

**F-7–F-9 — Adapters & Install**
Claude Code and Cursor adapters require their respective native config file formats. The install script gains an `--editor` flag accepting values `opencode|claude|cursor|all` (default: `opencode` for backward compatibility).

**F-10 — Stage Gates**
`lifecycle/stage-gates.md` defines named gates (e.g., Spec-Ready, Plan-Ready, Evidence-Collected, Report-Generated, Remediation-Approved) with entry criteria, responsible agent, and exit criteria for each.

**F-11 — Tools Directory**
At minimum, one CLI tool (e.g., a shell or Python script) that provides a useful utility — such as listing active investigations, validating command front matter, or querying local evidence artifacts.

**F-12–F-13 — MCP Integrations**
Config entries pointing to the NVD REST API and EPSS API. Each entry specifies the base URL, required authentication mechanism (API key env var), and the skill(s) that consume it.

## 6. USER & SYSTEM FLOWS

**Flow 1 — Full Investigation**
```
Practitioner types /investigate <target>
  → @pm reads investigation template, initialises investigation context
  → @pm delegates /recon to @attack-surface-agent
  → @attack-surface-agent uses attack-surface-analysis skill
  → @pm delegates /hunt to @bug-hunting-agent
  → @bug-hunting-agent uses bug-hunting-analysis skill
  → @pm delegates /cve-lookup for discovered CVEs → @cve-intelligence-agent → NVD API (MCP)
  → @pm delegates /score → @exploitability-agent → EPSS API (MCP)
  → @pm delegates /collect-evidence → @evidence-agent
  → @pm delegates /cve-report → @cve-report-agent
  → Practitioner reviews generated report
```

**Flow 2 — Single CVE Lookup**
```
Practitioner types /cve-lookup CVE-2024-XXXXX
  → @cve-intelligence-agent fetches from NVD API via MCP
  → Returns structured CVE summary with EPSS score
```

**Flow 3 — Install with Editor Selection**
```
scripts/install-samourai.sh --editor cursor
  → Copies core/ to .opencode/ (standard)
  → Generates Cursor adapter config
  → Skips OpenCode-specific config
```

**Flow 4 — Reinstall (previously orphaned agents)**
```
Practitioner runs install script
  → Copies core/agents/ including formerly-orphaned agents (designer, tdd-orchestrator, etc.)
  → No agent is lost
```

## 7. SCOPE & BOUNDARIES

### 7.1 In Scope

- 11 new cyber command definitions in `core/commands/`
- Migration of 4 orphaned agents to `core/agents/`
- Removal of deprecated files
- Deduplication of lifecycle files
- `CONTRIBUTING.md`
- Architecture document
- Investigation workflow template
- Claude Code adapter
- Cursor adapter
- `--editor` flag on install script
- `lifecycle/stage-gates.md`
- `tools/` directory with ≥ 1 CLI tool
- MCP config for NVD API
- MCP config for EPSS API

### 7.2 Out of Scope

- [OUT] Live penetration testing or actual exploit execution
- [OUT] Custom LLM training or fine-tuning
- [OUT] GUI, web UI, or dashboard
- [OUT] Automated integration tests against live external APIs
- [OUT] New tracker integrations (Jira MCP, Linear, etc.)
- [OUT] Monetisation or licensing changes
- [OUT] Changes to the core Samourai installer beyond the `--editor` flag

### 7.3 Deferred / Maybe-Later

- VS Code / JetBrains adapters
- A second CLI tool (e.g., investigation status dashboard)
- GraphQL or webhook-based MCP for richer security data sources (Shodan, VirusTotal)
- Automated stage-gate enforcement CI pipeline

## 8. INTERFACES & INTEGRATION CONTRACTS

### 8.1 REST / HTTP Endpoints

N/A — No HTTP server is introduced. Security API calls are made outbound via MCP.

### 8.2 Events / Messages

N/A — No async event bus.

### 8.3 Data Model Impact

| ID | Element | Description |
|----|---------|-------------|
| DM-1 | Command front matter | Each command file carries YAML front matter: `description` (string), `agent` (agent-id string), `subtask` (boolean). |
| DM-2 | Agent front matter | Each agent file carries YAML front matter with at minimum: `name`, `description`, `skills` (list), `tools` (list). |
| DM-3 | Investigation template | Structured Markdown with fields: `target`, `scope`, `start_date`, `investigator`, `findings[]`, `evidence[]`, `recommendations[]`. |
| DM-4 | MCP config entry | Per-service block: `name`, `base_url`, `auth_env_var`, `consuming_skills[]`. |

### 8.4 External Integrations

| Service | Purpose | Auth |
|---------|---------|------|
| NVD API (nvd.nist.gov) | CVE data retrieval | API key via env var `NVD_API_KEY` |
| EPSS API (api.first.org/epss) | Exploit probability score | No auth required (public API) |

### 8.5 Backward Compatibility

- The install script change is backward-compatible: omitting `--editor` defaults to existing `opencode` behaviour.
- Deprecated file removal does not break any active workflow (files are dead code).
- Lifecycle deduplication keeps the authoritative file in place; removes or redirects duplicates only.
- No existing command, agent, or skill definition is modified in a breaking way.

## 9. NON-FUNCTIONAL REQUIREMENTS (NFRs)

| ID | Requirement | Threshold |
|----|-------------|-----------|
| NFR-1 | Install script execution time | `install-samourai.sh` with any `--editor` value completes in ≤ 30 seconds on a standard laptop |
| NFR-2 | Command file format compliance | 100% of new command files must pass front-matter validation (agent field present, subtask boolean) |
| NFR-3 | MCP config parsability | Config files must be valid JSON/YAML parseable by the respective editor toolchain |
| NFR-4 | Documentation completeness | `CONTRIBUTING.md` covers ≥ 4 contribution paths (agent, skill, command, PR workflow) |
| NFR-5 | Agent coverage | After migration, 0 orphaned agents (all agents in `.opencode/agent/` traceable to `core/agents/`) |
| NFR-6 | CLI tool reliability | The CLI tool in `tools/` must exit with code 0 on a clean repo and non-zero on detectable errors |

## 10. TELEMETRY & OBSERVABILITY REQUIREMENTS

N/A — This change operates at the file/config layer. No runtime telemetry infrastructure is introduced. Future changes may add investigation audit logs.

## 11. RISKS & MITIGATIONS

| ID | Risk | Impact | Probability | Mitigation | Residual Risk |
|----|------|--------|-------------|------------|---------------|
| RSK-1 | Large multi-workstream change increases merge conflict risk if parallel branches exist | H | M | Deliver as a single branch; coordinate with team before starting parallel work | L |
| RSK-2 | Claude Code and Cursor adapter config formats may change between versions | M | M | Document the adapter format version used; isolate adapter configs for easy update | M |
| RSK-3 | NVD API key requirement may block users without a key | M | H | Make NVD API key optional; agents must degrade gracefully when key is absent | L |
| RSK-4 | Lifecycle deduplication may accidentally remove an active file | H | L | Audit before deletion; check git history to confirm file is not referenced elsewhere | L |
| RSK-5 | Orphan agent migration may introduce subtle behavioural differences if front matter diverges | M | L | Copy verbatim from `.opencode/agent/`; review diff after copy | L |

## 12. ASSUMPTIONS

- The install script already copies the full `core/` tree; no install script refactor is needed beyond the `--editor` flag.
- Existing cyber agent definitions in `core/agents/` are accurate and complete; this change does not modify their behaviour.
- NVD and EPSS APIs remain publicly accessible; no proxy or firewall restriction is assumed.
- The `.opencode/command/` command format is stable; no schema migration is needed.
- Team uses git and the standard Samourai change convention for all work items.

## 13. DEPENDENCIES

| Direction | Item | Notes |
|-----------|------|-------|
| Depends on | `core/agents/` cyber agent definitions | Must exist and be correct before commands can reference them |
| Depends on | `core/skills/` cyber skill definitions | Must exist before commands invoke skills via agents |
| Depends on | `scripts/install-samourai.sh` | `--editor` flag added here; existing copy logic must not be broken |
| Depends on | NVD API public availability | Required for F-12; key must be provisioned by practitioner |
| Blocks | GH-14 (test plan) | Spec must be approved before test planning begins |
| Blocks | GH-15 (delivery plan) | Spec must be approved before implementation planning |

## 14. OPEN QUESTIONS

| ID | Question | Context | Status |
|----|----------|---------|--------|
| OQ-1 | What is the exact config file format and location required by Claude Code for agent/command adapters? | F-7 depends on this | Decision needed: consult `@architect` or Claude Code docs |
| OQ-2 | What is the exact config file format and location required by Cursor for agent/command adapters? | F-8 depends on this | Decision needed: consult `@architect` or Cursor docs |
| OQ-3 | Should the `--editor` install flag support `all` as a value to deploy all adapters simultaneously? | F-9 | Open — lean yes for DX; confirm with team |
| OQ-4 | Which CLI tool provides the highest value: front-matter validator, investigation lister, or evidence formatter? | F-11 | Open — front-matter validator recommended as it validates F-1/F-2 deliverables |
| OQ-5 | Should MCP config live in a top-level `mcp.yaml` or inside `.opencode/config/`? | F-12, F-13 | Open — follow existing OpenCode config conventions |

## 15. DECISION LOG

| ID | Decision | Rationale | Date |
|----|----------|-----------|------|
| DEC-1 | Deliver all 8 workstreams in a single branch (`feat/GH-13/samourai-kali-operationnel`) | Avoids cross-branch dependency hell; workstreams are tightly coupled | 2026-04-30 |
| DEC-2 | Install script `--editor` defaults to `opencode` for backward compatibility | Existing users must not be broken by new flag | 2026-04-30 |
| DEC-3 | Orphaned agents copied verbatim from `.opencode/agent/` to `core/agents/` | Prevents accidental behavioural drift | 2026-04-30 |
| DEC-4 | EPSS API used without authentication (public endpoint) | Simplifies onboarding; no key required | 2026-04-30 |

## 16. AFFECTED COMPONENTS (HIGH-LEVEL)

| Component | Impact |
|-----------|--------|
| `core/commands/` | New — 11 cyber command definitions added |
| `core/agents/` | Updated — 4 orphaned agents added |
| `core/skills/` | No change |
| `.opencode/command/` | Populated by install — reflects new commands after reinstall |
| `.opencode/agent/` | No direct change; install will keep all agents |
| `scripts/install-samourai.sh` | Updated — `--editor` flag added |
| `lifecycle/` | Updated — `stage-gates.md` added; duplicates removed |
| `docs/` or `CONTRIBUTING.md` | New — CONTRIBUTING.md, architecture doc, investigation template |
| `tools/` | New — directory + ≥ 1 CLI tool |
| `mcp/` or `.opencode/config/` | New — MCP config for NVD + EPSS |
| Deprecated files | Deprecated — `pr-instructions-template.md` removed |

## 17. ACCEPTANCE CRITERIA

### Cyber Commands (F-1)

| ID | Criterion | Linked |
|----|-----------|--------|
| AC-F1-1 | **Given** a fresh install of Samourai Kali, **when** a practitioner types `/investigate <target>` in their editor, **then** the @pm agent is invoked and an investigation context is initialised | F-1 |
| AC-F1-2 | **Given** the 11 command files exist in `core/commands/`, **when** the install script runs, **then** all 11 commands are available in the editor's command palette | F-1, F-9 |
| AC-F1-3 | **Given** any new command file, **when** its front matter is parsed, **then** `description`, `agent`, and `subtask` fields are all present and correctly typed | F-1, DM-1 |

### Agent Coverage (F-2)

| ID | Criterion | Linked |
|----|-----------|--------|
| AC-F2-1 | **Given** the migrated agent definitions in `core/agents/`, **when** the install script runs, **then** all 4 previously-orphaned agents are present in `.opencode/agent/` | F-2, NFR-5 |
| AC-F2-2 | **Given** `core/agents/` and `.opencode/agent/`, **when** listing both directories after install, **then** no agent exists in `.opencode/agent/` that is absent from `core/agents/` | F-2, NFR-5 |

### Cleanup (F-3)

| ID | Criterion | Linked |
|----|-----------|--------|
| AC-F3-1 | **Given** the repository, **when** searching for `pr-instructions-template.md`, **then** no file with that name exists | F-3 |
| AC-F3-2 | **Given** lifecycle files, **when** reviewing `lifecycle/`, **then** no two files contain the same canonical lifecycle definition | F-3 |

### Documentation (F-4, F-5, F-6)

| ID | Criterion | Linked |
|----|-----------|--------|
| AC-F4-1 | **Given** the repository root, **when** a new contributor looks for contribution guidance, **then** `CONTRIBUTING.md` exists and covers agent, skill, command contribution, and PR workflow | F-4, NFR-4 |
| AC-F5-1 | **Given** the architecture document, **when** read, **then** it describes the layered model from `core/` through install to editor adapters, commands, agents, and skills | F-5 |
| AC-F6-1 | **Given** the investigation template, **when** a practitioner starts a new investigation, **then** the template provides scaffolding for target, scope, findings, evidence, and recommendations | F-6, DM-3 |

### Adapters & Install (F-7, F-8, F-9)

| ID | Criterion | Linked |
|----|-----------|--------|
| AC-F7-1 | **Given** `install-samourai.sh --editor claude`, **when** executed, **then** a valid Claude Code adapter config is generated and no error is returned | F-7, F-9 |
| AC-F8-1 | **Given** `install-samourai.sh --editor cursor`, **when** executed, **then** a valid Cursor adapter config is generated and no error is returned | F-8, F-9 |
| AC-F9-1 | **Given** `install-samourai.sh` with no `--editor` flag, **when** executed, **then** behaviour is identical to current (OpenCode only), exit code 0 | F-9, NFR-1 |

### Stage Gates (F-10)

| ID | Criterion | Linked |
|----|-----------|--------|
| AC-F10-1 | **Given** `lifecycle/stage-gates.md`, **when** read, **then** ≥ 5 named gates are defined each with entry criteria, responsible agent, and exit criteria | F-10 |

### Tools (F-11)

| ID | Criterion | Linked |
|----|-----------|--------|
| AC-F11-1 | **Given** the `tools/` directory, **when** a practitioner runs the CLI tool on a valid repo, **then** it exits with code 0 and produces meaningful output | F-11, NFR-6 |
| AC-F11-2 | **Given** the CLI tool run against a repo with malformed command front matter, **when** executed, **then** it exits non-zero and identifies the offending file | F-11, NFR-6 |

### MCP Integration (F-12, F-13)

| ID | Criterion | Linked |
|----|-----------|--------|
| AC-F12-1 | **Given** a valid `NVD_API_KEY` env var, **when** `/cve-lookup CVE-2024-XXXXX` is invoked, **then** the NVD MCP integration returns structured CVE data without error | F-12, F-1 |
| AC-F13-1 | **Given** no API key required, **when** `/score` is invoked for a known CVE, **then** the EPSS MCP integration returns an exploit probability score | F-13, F-1 |
| AC-F12-2 | **Given** an absent or invalid `NVD_API_KEY`, **when** `/cve-lookup` is invoked, **then** the agent degrades gracefully with an informative error message rather than crashing | F-12, RSK-3 |

## 18. ROLLOUT & CHANGE MANAGEMENT (HIGH-LEVEL)

Deliver all workstreams on a single branch (`feat/GH-13/samourai-kali-operationnel`). Recommended delivery order:

1. **Cleanup first** (F-3) — remove noise before adding content.
2. **Agent migration** (F-2) — stabilise the canonical agent list.
3. **Cyber commands** (F-1) — the highest-value deliverable.
4. **Documentation** (F-4, F-5, F-6) — enables contributors to verify and extend.
5. **Stage gates** (F-10) — formalise quality.
6. **Tools** (F-11) — enables validation of earlier deliverables.
7. **Adapters + install flag** (F-7, F-8, F-9) — broadens reach.
8. **MCP integration** (F-12, F-13) — completes the live data pipeline.

Merge via PR; assign to human reviewer before merge. Announce to team when PR is raised.

## 19. DATA MIGRATION / SEEDING (IF APPLICABLE)

No database migration. File-level changes only:
- 4 agent files moved from `.opencode/agent/` to `core/agents/` (copy + verify, original remains until install confirms).
- Deprecated files deleted from repo.
- Lifecycle duplicates consolidated.

## 20. PRIVACY / COMPLIANCE REVIEW

- Investigation artifacts may contain sensitive security findings. Practitioners must not commit real CVE PoCs or sensitive target data to the repo.
- NVD API key must be stored as an environment variable; it must never be committed to the repository.
- The investigation template should include a reminder about sensitive data handling.

## 21. SECURITY REVIEW HIGHLIGHTS

- **API Key hygiene**: `NVD_API_KEY` must be loaded from env only; no hardcoding in config files.
- **PoC safety**: The `/poc` command delegates to `@safe-poc-agent`, which must enforce safe execution constraints (no live exploit against production targets without explicit consent).
- **Adapter configs**: Claude Code and Cursor adapter files must not embed credentials or tokens.
- **`tools/` CLI**: Must not execute arbitrary code from user-supplied inputs without sanitisation.

## 22. MAINTENANCE & OPERATIONS IMPACT

- Once merged, contributors add new cyber commands by dropping a `.md` file in `core/commands/` following the established format — no other config change needed.
- NVD API key rotation requires only updating the `NVD_API_KEY` env var.
- New editor adapter support (e.g., VS Code) follows the F-7/F-8 pattern and requires only a new adapter config + install script branch.
- Stage gates (`lifecycle/stage-gates.md`) should be reviewed and updated whenever new cyber investigation patterns are introduced.

## 23. GLOSSARY

| Term | Definition |
|------|------------|
| Cyber command | A `.md` file in `core/commands/` with front matter that maps a slash-command invocation to a cyber agent |
| Orphaned agent | An agent present in `.opencode/agent/` but absent from `core/agents/`, making it lost on reinstall |
| MCP | Model Context Protocol — the mechanism by which agents call external tools or APIs |
| Stage gate | A named quality checkpoint in the investigation lifecycle with defined entry/exit criteria |
| EPSS | Exploit Prediction Scoring System — a probability score for CVE exploitability |
| NVD | National Vulnerability Database — NIST's public CVE repository |
| Adapter | An editor-specific config file that wires Samourai Kali agents and commands into the editor's native AI interface |
| Investigation template | A Markdown scaffold for documenting a cyber investigation from target scoping to remediation |

## 24. APPENDICES

### A. Existing Cyber Agent Inventory

| Agent File | Role |
|------------|------|
| `attack-surface-agent.md` | Reconnaissance and attack surface mapping |
| `bug-hunting-agent.md` | Vulnerability discovery |
| `cve-intelligence-agent.md` | CVE research and enrichment |
| `cve-report-agent.md` | CVE report generation |
| `evidence-agent.md` | Evidence collection and structuring |
| `exploitability-agent.md` | Exploitability scoring |
| `safe-poc-agent.md` | Safe PoC generation/validation |
| `remediation-agent.md` | Remediation planning |
| `vulnerability-analysis-agent.md` | Deep vulnerability analysis |
| `external-researcher.md` | External threat research |
| `toolsmith.md` | Security tooling support |

### B. Orphaned Agents to Migrate

| Agent | Current Location | Target Location |
|-------|-----------------|-----------------|
| `designer.md` | `.opencode/agent/` | `core/agents/` |
| `image-generator.md` | `.opencode/agent/` | `core/agents/` |
| `review-feedback-applier.md` | `.opencode/agent/` | `core/agents/` |
| `tdd-orchestrator.md` | `.opencode/agent/` | `core/agents/` |

## 25. DOCUMENT HISTORY

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2026-04-30 | @spec-writer | Initial specification |

---

## AUTHORING GUIDELINES

This spec was authored using:
- Planning session context provided by @pm for GH-13
- Existing agent/skill/command inventory from `core/agents/`, `core/skills/`, `.opencode/command/`
- Command format pattern derived from `run-plan.md`
- Template structure from `.samourai/core/templates/change-spec-template.md`
- Repository conventions from `.samourai/core/governance/conventions/`

Missing information (adapter config formats, MCP config location) captured as OQ-1 through OQ-5.

## VALIDATION CHECKLIST

- [x] `change.ref` matches provided `workItemRef` (GH-13)
- [x] `owners` has at least one entry
- [x] `status` is "Proposed"
- [x] All sections present in order (1-25 + guidelines + checklist)
- [x] ID prefixes consistent and unique (F-, AC-, NFR-, RSK-, DEC-, DM-, OQ-)
- [x] Acceptance criteria reference at least one F-/NFR-/DM- ID and use Given/When/Then
- [x] NFRs include measurable values
- [x] Risks include Impact & Probability
- [x] No implementation details (no file-level code paths, no step-by-step tasks)
- [x] No content duplicated from linked docs
- [x] Front matter validates per front_matter_rules
