---
id: chg-GH-13-test-plan
status: Proposed
created: 2026-04-30T20:14:55Z
last_updated: 2026-04-30T20:14:55Z
owners: [engineering]
service: samourai-kali
labels: [cyber, platform, commands, documentation, adapters, mcp]
links:
  change_spec: ./chg-GH-13-spec.md
  implementation_plan: ./chg-GH-13-plan.md
  testing_strategy: .samourai/ai/rules/testing-strategy.md
version_impact: minor
summary: "Activate the full cyber investigation capability of Samourai Kali by closing all structural gaps — missing commands, orphaned agents, absent documentation, adapter support, stage gates, a tools directory, and MCP integrations — so the platform works end-to-end out of the box."
---

# Test Plan - Make Samourai Kali Fully Operational for Cyber Investigations

## 1. Scope and Objectives

This change is a framework/config delivery with no application runtime. Testing focuses on verifying that installation produces the expected file structure (commands/agents/adapters/docs/tools), that file formats are valid and consistent (front matter, config parsability), and that uninstall/reinstall behaviors are regression-safe.

Primary risks to protect against are: silently missing commands/agents after install, adapter configs that are invalid or in the wrong location, accidental removal of active lifecycle docs during cleanup, and MCP configuration that is malformed or encourages secret leakage.

### 1.1 In Scope

- Install script behavior for default and editor-selected installs (per AC-F7-1, AC-F8-1, AC-F9-1).
- Verification that 11 cyber commands and 4 migrated agents are installed and non-orphaned (AC-F1-2, AC-F2-1, AC-F2-2).
- File-format/contract validation:
  - Command front matter fields and types (AC-F1-3, NFR-2, DM-1).
  - Agent front matter presence (DM-2).
  - Adapter/MCP config parsability (NFR-3, DM-4).
- Presence and minimum content expectations for documentation and templates (AC-F4-1, AC-F5-1, AC-F6-1).
- Presence and structure of stage gates (AC-F10-1).
- CLI tool exit codes and error reporting behavior (AC-F11-1, AC-F11-2, NFR-6).

### 1.2 Out of Scope & Known Gaps

- No unit/integration/E2E runtime tests (project has no runtime) per `.samourai/ai/rules/testing-strategy.md`.
- No automated tests that call live external APIs (NG-4). Validation of NVD/EPSS behavior is manual or via non-network contract checks.
- Editor-specific “command palette invocation” behavior cannot be fully automated in bash; we validate via installed file presence + manual smoke where needed.

## 2. References

- Change spec: `./chg-GH-13-spec.md`
- Implementation plan: `./chg-GH-13-plan.md`
- Repository testing strategy: `.samourai/ai/rules/testing-strategy.md`
- Existing test patterns (installer regression harness): `scripts/.tests/test-install-samourai.sh`

## 3. Coverage Overview

### 3.1 Functional Coverage (F-#, AC-#)

| AC ID | Description (from spec) | TC ID(s) | Status |
|------:|--------------------------|----------|--------|
| AC-F1-1 | `/investigate <target>` delegates to @pm and initializes investigation context | TC-KALI-003 | Planned |
| AC-F1-2 | Install makes all 11 commands available in editor command palette | TC-KALI-002 | Planned |
| AC-F1-3 | Command front matter has `description`, `agent`, `subtask` present + typed | TC-KALI-004, TC-KALI-003 | Planned |
| AC-F2-1 | Install includes 4 previously-orphaned agents under `.opencode/agent/` | TC-KALI-005 | Planned |
| AC-F2-2 | No agent exists in `.opencode/agent/` absent from `core/agents/` after install | TC-KALI-005 | Planned |
| AC-F3-1 | `pr-instructions-template.md` removed (no such file exists) | TC-KALI-006 | Planned |
| AC-F3-2 | No duplicated canonical lifecycle definition files | TC-KALI-006 | Planned (partial manual) |
| AC-F4-1 | `CONTRIBUTING.md` exists and covers agent/skill/command contribution + PR workflow | TC-KALI-007 | Planned |
| AC-F5-1 | Architecture doc describes layered model (`core/` → install → adapters → commands → agents → skills) | TC-KALI-007 | Planned |
| AC-F6-1 | Investigation template scaffolds target/scope/findings/evidence/recommendations | TC-KALI-007 | Planned |
| AC-F7-1 | `install-samourai.sh --editor claude` generates valid Claude config, exit 0 | TC-KALI-008 | TODO (blocked by OQ-1) |
| AC-F8-1 | `install-samourai.sh --editor cursor` generates valid Cursor config, exit 0 | TC-KALI-009 | TODO (blocked by OQ-2) |
| AC-F9-1 | Install without `--editor` matches current OpenCode-only behavior, exit 0 | TC-KALI-001 | Planned |
| AC-F10-1 | `lifecycle/stage-gates.md` defines ≥ 5 gates with criteria + ownership | TC-KALI-011 | Planned |
| AC-F11-1 | `tools/` CLI tool exits 0 on clean repo, meaningful output | TC-KALI-012 | TODO (tool choice from OQ-4) |
| AC-F11-2 | CLI tool exits non-zero on malformed command front matter and identifies file | TC-KALI-012 | TODO (tool choice from OQ-4) |
| AC-F12-1 | With `NVD_API_KEY`, `/cve-lookup` returns structured CVE data via MCP | TC-KALI-014 | Manual only |
| AC-F13-1 | `/score` returns EPSS exploit probability score | TC-KALI-014 | Manual only |
| AC-F12-2 | Missing/invalid `NVD_API_KEY` degrades gracefully with informative error | TC-KALI-015 | Manual only |

### 3.2 Interface Coverage (API-#, EVT-#, DM-#)

| Interface ID | Element | TC ID(s) | Notes |
|-------------:|---------|----------|-------|
| DM-1 | Command front matter (`description`, `agent`, `subtask`) | TC-KALI-003, TC-KALI-004, TC-KALI-012 | Validated via content checks and/or validator tool |
| DM-2 | Agent front matter (`name`, `description`, `skills`, `tools`) | TC-KALI-005 | Validated on migrated agents and install outputs |
| DM-3 | Investigation template structure fields | TC-KALI-007 | Validated via template content checklist |
| DM-4 | MCP config entry (`name`, `base_url`, `auth_env_var`, `consuming_skills[]`) | TC-KALI-013 | Validated via parse + required-field checks |

### 3.3 Non-Functional Coverage (NFR-#)

| NFR ID | Requirement | TC ID(s) | Status |
|-------:|-------------|----------|--------|
| NFR-1 | Install completes in ≤ 30 seconds (any `--editor` value) | TC-KALI-001, TC-KALI-008, TC-KALI-009 | Planned (timing assertion TODO for new editors) |
| NFR-2 | 100% new command files pass front matter validation | TC-KALI-004, TC-KALI-012 | Planned (validator tool may be required) |
| NFR-3 | Config files are valid JSON/YAML parseable by toolchain | TC-KALI-013, TC-KALI-008, TC-KALI-009 | Planned / TODO (depends on config formats) |
| NFR-4 | `CONTRIBUTING.md` covers ≥ 4 contribution paths | TC-KALI-007 | Planned |
| NFR-5 | 0 orphaned agents after migration | TC-KALI-005 | Planned |
| NFR-6 | CLI tool exits 0 on success and non-zero on detectable errors | TC-KALI-012 | TODO (tool choice from OQ-4) |

## 4. Test Types and Layers

Per `.samourai/ai/rules/testing-strategy.md`, this repo uses:

- **Bash Script Tests (Primary)**: installer/uninstaller regression harness.
  - Location: `scripts/.tests/test-install-samourai.sh`
  - Type mapping for this test plan: **Integration** (script-level install/uninstall + filesystem verification)
- **File Existence and Structure Verification**: file presence checks and directory inventories.
  - Implemented in the same bash harness and/or dedicated helper scripts.
  - Type mapping: **Contract** (format and schema compliance)
- **Content Validation**: minimum content expectations for docs/templates; front matter field checks.
  - Type mapping: **Contract** and **Manual** as appropriate

Not applicable:

- Unit / runtime integration / API E2E tests (no application runtime).
- Performance tests beyond simple timing checks for install duration.

## 5. Test Scenarios

### 5.1 Scenario Index

| TC ID | Title | Type | Level | Priority | AC Coverage |
|-------|-------|------|-------|----------|------------|
| TC-KALI-001 | Default install (no `--editor`) is backward compatible and fast | Regression | Critical | High | AC-F9-1 |
| TC-KALI-002 | `--editor opencode` installs the 11 cyber commands | Happy Path | Critical | High | AC-F1-2 |
| TC-KALI-003 | `/investigate` command definition delegates to @pm and meets contract | Happy Path | Important | High | AC-F1-1, AC-F1-3 |
| TC-KALI-004 | All cyber command files have valid front matter (schema + types) | Regression | Critical | High | AC-F1-3 |
| TC-KALI-005 | Orphaned agents are migrated and no orphan remains after install | Regression | Critical | High | AC-F2-1, AC-F2-2 |
| TC-KALI-006 | Deprecated file removed and lifecycle docs not duplicated | Regression | Important | Medium | AC-F3-1, AC-F3-2 |
| TC-KALI-007 | Docs and templates exist and satisfy minimum content requirements | Happy Path | Important | Medium | AC-F4-1, AC-F5-1, AC-F6-1 |
| TC-KALI-008 | `--editor claude` install generates valid adapter config | Happy Path | Important | Medium | AC-F7-1 |
| TC-KALI-009 | `--editor cursor` install generates valid adapter config | Happy Path | Important | Medium | AC-F8-1 |
| TC-KALI-011 | Stage gates file defines ≥ 5 gates with required fields | Happy Path | Important | Medium | AC-F10-1 |
| TC-KALI-012 | CLI tool exits 0 on clean repo and non-zero on malformed commands | Negative | Critical | High | AC-F11-1, AC-F11-2 |
| TC-KALI-013 | MCP config and adapter configs are parseable and contain required fields | Regression | Important | Medium | (supports AC-F12-1, AC-F13-1) |
| TC-KALI-014 | Manual: `/cve-lookup` and `/score` work with network and required env vars | Happy Path | Important | Low | AC-F12-1, AC-F13-1 |
| TC-KALI-015 | Manual: `/cve-lookup` degrades gracefully without NVD key | Negative | Important | Low | AC-F12-2 |

### 5.2 Scenario Details

#### TC-KALI-001 - Default install (no `--editor`) is backward compatible and fast

**Scenario Type**: Regression
**Impact Level**: Critical
**Priority**: High
**Related IDs**: F-9, AC-F9-1, NFR-1
**Test Type(s)**: Integration
**Automation Level**: Automated
**Target Layer / Location**: `scripts/.tests/test-install-samourai.sh`
**Tags**: @bash @install

**Preconditions**:

- Local environment can run bash.
- A temporary git repo can be created (test harness uses `git init`).

**Steps**:

1. Create a temporary git repo (as done by `new_git_repo()` in `scripts/.tests/test-install-samourai.sh`).
2. Run `scripts/install-samourai.sh` without `--editor` (default behavior).
3. Verify exit code is 0.
4. Verify OpenCode artifacts expected for backward compatibility are present (e.g., `.opencode/opencode.jsonc`).
5. (Optional automation enhancement) Measure wall time and assert ≤ 30 seconds.

**Expected Outcome**:

- Default install succeeds with behavior matching prior OpenCode default.
- No unexpected editor artifacts are installed.
- (If timed) duration is within threshold.

**Notes / Clarifications**:

- Timing is inherently environment-dependent; if flaky, record timings in execution log rather than hard-failing.

#### TC-KALI-002 - `--editor opencode` installs the 11 cyber commands

**Scenario Type**: Happy Path
**Impact Level**: Critical
**Priority**: High
**Related IDs**: F-1, F-9, AC-F1-2
**Test Type(s)**: Integration
**Automation Level**: Automated
**Target Layer / Location**: `scripts/.tests/test-install-samourai.sh` (extend)
**Tags**: @bash @install

**Preconditions**:

- A list of the 11 expected command filenames is known from the spec (investigate, recon, hunt, analyze-vuln, cve-lookup, score, poc, collect-evidence, cve-report, remediate, status).

**Steps**:

1. Create a temporary git repo.
2. Run install with `--editor opencode`.
3. Verify `.opencode/command/` exists.
4. Verify each expected command file exists under `.opencode/command/`.

**Expected Outcome**:

- All 11 command files are present in the installed `.opencode/command/` directory.

#### TC-KALI-003 - `/investigate` command definition delegates to @pm and meets contract

**Scenario Type**: Happy Path
**Impact Level**: Important
**Priority**: High
**Related IDs**: F-1, AC-F1-1, AC-F1-3, DM-1
**Test Type(s)**: Contract
**Automation Level**: Automated
**Target Layer / Location**: `core/commands/investigate.md` (source) and installed `.opencode/command/investigate.md`
**Tags**: @bash @contract

**Preconditions**:

- Command source file exists under `core/commands/`.

**Steps**:

1. Verify `core/commands/investigate.md` exists.
2. Parse YAML front matter and assert fields exist:
   - `description` is present and non-empty.
   - `agent` is present and references the @pm agent.
   - `subtask` is present and boolean.
3. Verify install places the command under `.opencode/command/` and preserves front matter.
4. (Content contract) Verify the command body includes an investigation initialization step (e.g., “initialise investigation context”) consistent with spec Flow 1 intent.

**Expected Outcome**:

- `/investigate` delegates to @pm and has valid command front matter.
- The command text indicates investigation context initialization.

#### TC-KALI-004 - All cyber command files have valid front matter (schema + types)

**Scenario Type**: Regression
**Impact Level**: Critical
**Priority**: High
**Related IDs**: F-1, AC-F1-3, NFR-2, DM-1
**Test Type(s)**: Contract
**Automation Level**: Automated
**Target Layer / Location**: `tools/` validator (preferred) and/or `scripts/.tests/test-install-samourai.sh` (fallback)
**Tags**: @bash @contract

**Preconditions**:

- All 11 command files exist under `core/commands/`.

**Steps**:

1. Run a front matter validation across `core/commands/{investigate,recon,hunt,analyze-vuln,cve-lookup,score,poc,collect-evidence,cve-report,remediate,status}.md`.
2. Assert each file has `description`, `agent`, `subtask` and `subtask` is boolean.

**Expected Outcome**:

- Validation passes for all new cyber command files.

**Notes / Clarifications**:

- If the CLI tool from F-11 is a front matter validator (recommended in spec OQ-4), this scenario should call that tool directly.

#### TC-KALI-005 - Orphaned agents are migrated and no orphan remains after install

**Scenario Type**: Regression
**Impact Level**: Critical
**Priority**: High
**Related IDs**: F-2, AC-F2-1, AC-F2-2, NFR-5, DM-2
**Test Type(s)**: Integration
**Automation Level**: Automated
**Target Layer / Location**: `scripts/.tests/test-install-samourai.sh` (extend)
**Tags**: @bash @install

**Preconditions**:

- The four migrated agent files exist under `core/agents/`: designer, image-generator, review-feedback-applier, tdd-orchestrator.

**Steps**:

1. Create a temporary git repo.
2. Run install with `--editor opencode`.
3. Verify the four migrated agents exist under `.opencode/agent/`.
4. Compare agent basenames in `.opencode/agent/` vs `core/agents/` and assert there are no extra agents in `.opencode/agent/`.

**Expected Outcome**:

- All four agents are present after install.
- No orphan remains (installed agent set is a subset of canonical core/agents).

#### TC-KALI-006 - Deprecated file removed and lifecycle docs not duplicated

**Scenario Type**: Regression
**Impact Level**: Important
**Priority**: Medium
**Related IDs**: F-3, AC-F3-1, AC-F3-2
**Test Type(s)**: Contract, Manual
**Automation Level**: Semi-automated
**Target Layer / Location**: repo filesystem + docs review
**Tags**: @bash @docs

**Preconditions**:

- Repo working tree is available.

**Steps**:

1. Verify `pr-instructions-template.md` does not exist anywhere in the repo.
2. (Manual check) Review the `lifecycle/` (and/or canonical governance lifecycle location) and confirm there is a single authoritative lifecycle definition per concept; duplicates were removed or consolidated.

**Expected Outcome**:

- Deprecated file is absent.
- No duplicated lifecycle definition remains.

#### TC-KALI-007 - Docs and templates exist and satisfy minimum content requirements

**Scenario Type**: Happy Path
**Impact Level**: Important
**Priority**: Medium
**Related IDs**: F-4, F-5, F-6, AC-F4-1, AC-F5-1, AC-F6-1, NFR-4, DM-3
**Test Type(s)**: Contract, Manual
**Automation Level**: Semi-automated
**Target Layer / Location**: documentation files (repo root / docs / templates)
**Tags**: @docs

**Preconditions**:

- Documentation artifacts are present in their decided locations.

**Steps**:

1. Verify `CONTRIBUTING.md` exists at repo root.
2. Verify `CONTRIBUTING.md` contains coverage for: agent contribution, skill contribution, command contribution, and PR workflow.
3. Verify an architecture document exists and describes the layered model from `core/` through install, editor adapters, commands, agents, and skills.
4. Verify investigation template exists and includes scaffolding for: target, scope, findings, evidence, recommendations.
5. Verify the investigation template includes a reminder about sensitive data handling (per spec privacy notes).

**Expected Outcome**:

- Required documentation and templates exist and meet minimum content expectations.

#### TC-KALI-008 - `--editor claude` install generates valid adapter config

**Scenario Type**: Happy Path
**Impact Level**: Important
**Priority**: Medium
**Related IDs**: F-7, F-9, AC-F7-1, NFR-1, NFR-3
**Test Type(s)**: Integration, Contract
**Automation Level**: Automated
**Target Layer / Location**: `scripts/.tests/test-install-samourai.sh` (extend once format decided)
**Tags**: @bash @install

**Preconditions**:

- OQ-1 resolved: exact Claude Code config format and location is known.

**Steps**:

1. Create a temporary git repo.
2. Run install with `--editor claude`.
3. Verify exit code is 0.
4. Verify expected Claude adapter config file(s) exist.
5. Verify config file(s) are parseable (JSON/YAML as applicable).

**Expected Outcome**:

- Claude adapter config is generated correctly and install succeeds.

**Notes / Clarifications**:

- Until OQ-1 is resolved, keep this scenario as TODO in automation mapping.

#### TC-KALI-009 - `--editor cursor` install generates valid adapter config

**Scenario Type**: Happy Path
**Impact Level**: Important
**Priority**: Medium
**Related IDs**: F-8, F-9, AC-F8-1, NFR-1, NFR-3
**Test Type(s)**: Integration, Contract
**Automation Level**: Automated
**Target Layer / Location**: `scripts/.tests/test-install-samourai.sh` (extend once format decided)
**Tags**: @bash @install

**Preconditions**:

- OQ-2 resolved: exact Cursor config format and location is known.

**Steps**:

1. Create a temporary git repo.
2. Run install with `--editor cursor`.
3. Verify exit code is 0.
4. Verify expected Cursor adapter config file(s) exist.
5. Verify config file(s) are parseable (JSON/YAML as applicable).

**Expected Outcome**:

- Cursor adapter config is generated correctly and install succeeds.

#### TC-KALI-011 - Stage gates file defines ≥ 5 gates with required fields

**Scenario Type**: Happy Path
**Impact Level**: Important
**Priority**: Medium
**Related IDs**: F-10, AC-F10-1
**Test Type(s)**: Contract
**Automation Level**: Semi-automated
**Target Layer / Location**: `lifecycle/stage-gates.md` (canonical location per implementation)
**Tags**: @docs

**Preconditions**:

- Stage gates file exists at the canonical path chosen by implementation.

**Steps**:

1. Verify the stage gates file exists.
2. Verify at least 5 named gates are defined.
3. For each gate, verify presence of: entry criteria, responsible agent, exit criteria.

**Expected Outcome**:

- Stage gates document meets minimum structure requirements.

#### TC-KALI-012 - CLI tool exits 0 on clean repo and non-zero on malformed commands

**Scenario Type**: Negative
**Impact Level**: Critical
**Priority**: High
**Related IDs**: F-11, AC-F11-1, AC-F11-2, NFR-6, NFR-2, DM-1
**Test Type(s)**: Integration, Contract
**Automation Level**: Automated
**Target Layer / Location**: `tools/` + `scripts/.tests/test-install-samourai.sh` (extend)
**Tags**: @bash @tools

**Preconditions**:

- OQ-4 resolved and at least one CLI tool exists under `tools/`.

**Steps**:

1. Run the CLI tool on a clean repo.
2. Assert exit code is 0 and output is non-empty / meaningful.
3. Create a temporary malformed command file (e.g., missing `agent` or `subtask` not boolean) in a controlled temp location.
4. Run the CLI tool against that target.
5. Assert exit code is non-zero and output identifies the offending file.

**Expected Outcome**:

- Tool behaves reliably and enforces command-format correctness.

#### TC-KALI-013 - MCP config and adapter configs are parseable and contain required fields

**Scenario Type**: Regression
**Impact Level**: Important
**Priority**: Medium
**Related IDs**: F-12, F-13, DM-4, NFR-3
**Test Type(s)**: Contract
**Automation Level**: Semi-automated
**Target Layer / Location**: MCP config file(s) (location per OQ-5)
**Tags**: @bash @config

**Preconditions**:

- OQ-5 resolved: MCP config file location and format is decided.

**Steps**:

1. Verify the MCP config file(s) exist.
2. Parse config (JSON/YAML) and ensure it is syntactically valid.
3. Verify an NVD entry exists with:
   - `base_url`
   - `auth_env_var: NVD_API_KEY`
   - `consuming_skills[]`
4. Verify an EPSS entry exists with:
   - `base_url`
   - no auth requirement (or explicit `auth_env_var` absent/empty)
   - `consuming_skills[]`
5. Verify no credentials are embedded in config files.

**Expected Outcome**:

- Config is parseable and contains required NVD/EPSS integration metadata.

#### TC-KALI-014 - Manual: `/cve-lookup` and `/score` work with network and required env vars

**Scenario Type**: Happy Path
**Impact Level**: Important
**Priority**: Low
**Related IDs**: F-12, F-13, AC-F12-1, AC-F13-1
**Test Type(s)**: Manual
**Automation Level**: Manual
**Target Layer / Location**: Supported editor command invocation (OpenCode/adapter as implemented)
**Tags**: @manual @mcp

**Preconditions**:

- Network access is available.
- NVD API key is available and set as `NVD_API_KEY` in the environment.
- MCP configuration is installed for the chosen editor.

**Steps**:

1. Invoke `/cve-lookup CVE-2024-XXXXX`.
2. Verify the response includes structured CVE data (at minimum: identifier, summary/description, references).
3. Invoke `/score` for a known CVE.
4. Verify the response includes an EPSS probability score.

**Expected Outcome**:

- Commands return results without crashing and provide structured output.

**Notes / Clarifications**:

- Use a non-sensitive, public CVE identifier for testing.

#### TC-KALI-015 - Manual: `/cve-lookup` degrades gracefully without NVD key

**Scenario Type**: Negative
**Impact Level**: Important
**Priority**: Low
**Related IDs**: F-12, AC-F12-2
**Test Type(s)**: Manual
**Automation Level**: Manual
**Target Layer / Location**: Supported editor command invocation (OpenCode/adapter as implemented)
**Tags**: @manual @mcp

**Preconditions**:

- `NVD_API_KEY` is absent or intentionally invalid.

**Steps**:

1. Invoke `/cve-lookup CVE-2024-XXXXX`.
2. Observe the agent/system response.

**Expected Outcome**:

- The system provides an informative error (e.g., guidance to set `NVD_API_KEY`) and does not crash.

## 6. Environments and Test Data

- **Primary environment**: Local developer machine running bash.
- **Automated harness isolation**: `scripts/.tests/test-install-samourai.sh` creates temporary repos under a temporary root and cleans up.
- **Test data**:
  - Synthetic repo targets created by the harness.
  - Public placeholder CVE identifiers (manual only).
- **Secrets policy**: Never commit or print real secrets. For manual NVD tests, set `NVD_API_KEY` in the shell environment only.

## 7. Automation Plan and Implementation Mapping

| TC ID | Automation Target | Command | Implementation Status |
|-------|-------------------|---------|------------------------|
| TC-KALI-001 | `scripts/.tests/test-install-samourai.sh` | `bash scripts/.tests/test-install-samourai.sh` | Existing – Update (assert default install compatibility + optional timing) |
| TC-KALI-002 | `scripts/.tests/test-install-samourai.sh` | `bash scripts/.tests/test-install-samourai.sh` | Existing – Update (assert 11 commands installed) |
| TC-KALI-003 | `scripts/.tests/test-install-samourai.sh` + repo file checks | `bash scripts/.tests/test-install-samourai.sh` | To Implement (front matter + content contract checks) |
| TC-KALI-004 | `tools/<validator>` or test harness | `bash scripts/.tests/test-install-samourai.sh` | TODO (depends on tool choice OQ-4) |
| TC-KALI-005 | `scripts/.tests/test-install-samourai.sh` | `bash scripts/.tests/test-install-samourai.sh` | Existing – Update (agent presence + orphan detection) |
| TC-KALI-006 | simple filesystem checks + manual review | `bash scripts/.tests/test-install-samourai.sh` (for automated parts) | Semi-automated |
| TC-KALI-007 | lightweight grep/content checks + manual review | N/A (manual review + optional scripted checks) | Manual/Semi-automated |
| TC-KALI-008 | `scripts/.tests/test-install-samourai.sh` | `bash scripts/.tests/test-install-samourai.sh` | TODO (blocked by OQ-1) |
| TC-KALI-009 | `scripts/.tests/test-install-samourai.sh` | `bash scripts/.tests/test-install-samourai.sh` | TODO (blocked by OQ-2) |
| TC-KALI-011 | content checklist / optional scripted count | N/A | Semi-automated |
| TC-KALI-012 | `tools/<tool-name>` + test harness | `bash scripts/.tests/test-install-samourai.sh` | TODO (blocked by OQ-4) |
| TC-KALI-013 | config parse checks (json/yaml) | N/A (scripted parse check) | TODO (blocked by OQ-5 and adapter format decisions) |
| TC-KALI-014 | manual editor invocation | N/A | Manual Only |
| TC-KALI-015 | manual editor invocation | N/A | Manual Only |

## 8. Risks, Assumptions, and Open Questions

### 8.1 Risks

- Adapter config formats may vary by editor version, leading to false failures or incorrect installation paths.
  - Mitigation: pin/document format version used and validate parsability (NFR-3).
- Install timing (NFR-1) may be flaky across machines.
  - Mitigation: prefer “record-and-monitor” timing, or use generous thresholds and avoid hard-fail if consistently noisy.
- MCP manual smoke depends on network availability and third-party uptime.
  - Mitigation: keep manual checks optional for merge gating unless explicitly required; never automate live calls.

### 8.2 Assumptions

- Installer test harness remains the primary verification mechanism (testing strategy).
- No secrets are required for automated tests; NVD key tests are manual only.
- The canonical list of cyber commands and orphaned agents is exactly as defined in the spec.

### 8.3 Open Questions

| ID | Question | Impact on tests | Owner |
|----|----------|----------------|-------|
| OQ-1 | Exact Claude Code adapter config format + location | Blocks TC-KALI-008 automation + NFR-3 coverage | @architect / maintainers |
| OQ-2 | Exact Cursor adapter config format + location | Blocks TC-KALI-009 automation + NFR-3 coverage | @architect / maintainers |
| OQ-3 | Should install support `--editor all`? | May require additional install tests and expectations | engineering |
| OQ-4 | Which CLI tool in `tools/`? (validator vs other) | Blocks TC-KALI-012 and preferred validation path for AC-F1-3 | engineering |
| OQ-5 | Where does MCP config live (top-level vs `.opencode/config/` vs editor-native)? | Blocks TC-KALI-013 automation and manual setup guidance | engineering |

## 9. Plan Revision Log

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2026-04-30 | @test-plan-writer | Initial test plan derived from `chg-GH-13-spec.md`, aligned with repo bash-first testing strategy |

## 10. Test Execution Log

| TC ID | Run Date | Result | Notes |
|-------|----------|--------|-------|
