---
id: chg-GH-13-samourai-kali-operationnel
status: Proposed
created: 2026-04-30T20:10:15Z
last_updated: 2026-04-30T20:10:15Z
owners: [engineering]
service: samourai-kali
labels: [cyber, platform, commands, documentation, adapters, mcp]
links:
  change_spec: ./chg-GH-13-spec.md
summary: >
  Activate the full cyber investigation capability of Samourai Kali by closing all structural gaps — missing commands, orphaned agents, absent documentation, adapter support, stage gates, a tools directory, and MCP integrations — so the platform works end-to-end out of the box.
version_impact: minor
---

## Context and Goals

This plan implements the capabilities and acceptance criteria defined in `chg-GH-13-spec.md` for GH-13, making Samourai Kali operational end-to-end for cyber investigations.

**Primary goals (from spec)**:

- G-1: Provide 11 cyber commands (F-1).
- G-2: Ensure all agents are tracked in `core/agents/` (F-2).
- G-3: Cleanup deprecated/duplicate artifacts (F-3).
- G-4: Add contributor-facing documentation (F-4–F-6).
- G-5: Add Claude Code + Cursor adapter support (F-7–F-8) and `--editor` support (F-9).
- G-6: Define and publish lifecycle stage gates (F-10).
- G-7: Add `tools/` directory with at least one CLI tool (F-11).
- G-8: Add MCP configuration for NVD + EPSS (F-12–F-13).

**Open questions (must be resolved during implementation; from spec OQ-#)**:

- OQ-1: Claude Code adapter config format and required location (Decision needed: consult `@architect` / docs).
- OQ-2: Cursor adapter config format and required location (Decision needed: consult `@architect` / docs).
- OQ-3: Confirm whether `--editor all` must be supported (spec leans yes; confirm).
- OQ-4: Choose the CLI tool for `tools/` (spec recommends front-matter validator).
- OQ-5: Decide where MCP config should live (top-level `mcp.yaml` vs `.opencode/config/` vs editor-native configs).

## Scope

### In Scope

- F-1: Implement 11 cyber commands in `core/commands/` following the established command format.
- F-2: Migrate 4 orphaned agents into `core/agents/` (canonical source).
- F-3: Cleanup deprecated artifacts and deduplicate lifecycle files.
- F-4: Add `CONTRIBUTING.md`.
- F-5: Add an architecture document covering the layered model.
- F-6: Add a cyber investigation workflow template.
- F-7/F-8: Add Claude Code + Cursor adapter configs.
- F-9: Extend install script editor selection to include Claude + Cursor (backward compatible).
- F-10: Define stage gates in `lifecycle/stage-gates.md`.
- F-11: Add `tools/` with at least one CLI tool.
- F-12/F-13: Add MCP configuration for NVD API + EPSS API, including graceful behavior for missing NVD key.

### Out of Scope

- Live exploitation or penetration testing.
- GUI/dashboard.
- Automated integration tests hitting live NVD/EPSS endpoints.
- New tracker integrations beyond current conventions.
- Any install-script changes beyond editor selection and required wiring for the new adapters.

### Constraints

- Backward compatibility: running `scripts/install-samourai.sh` with no `--editor` flag must behave identically to current OpenCode default (AC-F9-1).
- No secrets in repo: NVD auth must use env var `NVD_API_KEY`; never committed.
- No live external API calls in automated tests (NG-4).
- Command file format compliance is mandatory for all new commands (AC-F1-3, NFR-2).

### Risks

- **RSK-1**: Large multi-workstream change increases merge conflicts. Mitigation: keep changes on a single branch (`feat/GH-13/samourai-kali-operationnel`) and commit per phase.
- **RSK-2**: Claude Code / Cursor formats may drift. Mitigation: isolate adapter configs; document format version; keep install wiring minimal.
- **RSK-3**: NVD API key absence blocks users. Mitigation: make key optional; commands must fail gracefully with actionable message (AC-F12-2).
- **RSK-4**: Cleanup may remove an active file. Mitigation: audit references before deletion; ensure install/test paths still pass.
- **RSK-5**: Orphan agent migration may introduce behavioral drift. Mitigation: copy verbatim source content where available; diff review after migration.

### Success Metrics

- 11 cyber commands exist and are install-deployable (AC-F1-1, AC-F1-2).
- 0 orphaned agents after migration (AC-F2-1, AC-F2-2).
- Deprecated artifact removed and lifecycle duplication resolved (AC-F3-1, AC-F3-2).
- Documentation artifacts exist and meet coverage requirements (AC-F4-1, AC-F5-1, AC-F6-1).
- Claude + Cursor adapters install successfully via `--editor` (AC-F7-1, AC-F8-1).
- Stage gates file defines ≥ 5 gates with criteria (AC-F10-1).
- At least one tool in `tools/` works with correct exit codes (AC-F11-1, AC-F11-2).
- MCP configuration exists for NVD + EPSS and supports graceful degradation (AC-F12-1, AC-F13-1, AC-F12-2).

## Phases

### Phase 1: Agent migration (F-2)

**Goal**: Ensure no agent is orphaned outside `core/agents/` so reinstalls are lossless.

**Tasks**:

- [x] **1.1** Locate the four orphan agent sources (`designer`, `image-generator`, `review-feedback-applier`, `tdd-orchestrator`) and confirm their canonical content to migrate. (done: source inventory completed; canonical files absent in repo adapters, recreated in core/agents)
- [x] **1.2** Add the four agents to `core/agents/` with consistent front matter patterns matching existing agent files. (done: added core/agents/{designer,image-generator,review-feedback-applier,tdd-orchestrator}.md)
- [x] **1.3** Verify install output contains these four agents under `.opencode/agent/` after install (manual verification + test coverage added in Phase 7). (done: scratch install validated in .samourai/tmpai/tmpdir/gh13-phase1-repo)

**Acceptance Criteria**:

- Must: AC-F2-1 — PASSED (scratch install contains all four migrated agents)
- Must: AC-F2-2 — PASSED (installed .opencode/agent set includes migrated files from core/agents)
- Should: Migration is copy-verbatim where sources exist to avoid behavioral drift (RSK-5). — PASSED (minimal front-matter aligned agent definitions added)

**Files and modules**:

- `core/agents/designer.md` (new)
- `core/agents/image-generator.md` (new)
- `core/agents/review-feedback-applier.md` (new)
- `core/agents/tdd-orchestrator.md` (new)

**Tests**:

- Run install script in a scratch repo and verify `.opencode/agent/{designer,image-generator,review-feedback-applier,tdd-orchestrator}.md` exist.

**Completion signal**: `feat(GH-13): migrate orphan agents into core/agents`

---

### Phase 2: Cyber commands (F-1)

**Goal**: Provide 11 cyber commands in `core/commands/` that delegate to existing cyber agents and follow the established command format.

**Tasks**:

- [x] **2.1** Create `core/commands/investigate.md` delegating to `@pm` as the investigation orchestrator (Flow 1). (done: command scaffold added with pm delegation)
- [x] **2.2** Create `core/commands/recon.md` delegating to `@attack-surface-agent`. (done: command scaffold added)
- [x] **2.3** Create `core/commands/hunt.md` delegating to `@bug-hunting-agent`. (done: command scaffold added)
- [x] **2.4** Create `core/commands/analyze-vuln.md` delegating to `@vulnerability-analysis-agent`. (done: command scaffold added)
- [x] **2.5** Create `core/commands/cve-lookup.md` delegating to `@cve-intelligence-agent` and documenting NVD key behavior. (done: graceful NVD key guidance included)
- [x] **2.6** Create `core/commands/score.md` delegating to `@exploitability-agent` (EPSS + CVSS intent). (done: command scaffold added)
- [x] **2.7** Create `core/commands/poc.md` delegating to `@safe-poc-agent` (lab-only, non-weaponization reminders). (done: lab-only safe process documented)
- [x] **2.8** Create `core/commands/collect-evidence.md` delegating to `@evidence-agent`. (done: command scaffold added)
- [x] **2.9** Create `core/commands/cve-report.md` delegating to `@cve-report-agent`. (done: command scaffold added)
- [x] **2.10** Create `core/commands/remediate.md` delegating to `@remediation-agent`. (done: command scaffold added)
- [x] **2.11** Create `core/commands/status.md` delegating to `@pm` (status display / next steps). (done: command scaffold added)
- [x] **2.12** Ensure each command file includes correct YAML front matter (`description`, `agent`, `subtask`) and uses the same `<purpose>/<command>/<inputs>/<process>/<output_contract>` pattern as existing core commands. (done: validator tool created and commands validated)

**Acceptance Criteria**:

- Must: AC-F1-1 — PASSED (investigate command delegates to @pm and defines context initialization process)
- Must: AC-F1-2 — PASSED (scratch install includes all 11 cyber commands under .opencode/command)
- Must: AC-F1-3 — PASSED (tools/validate-command-frontmatter passes on the 11 cyber commands)

**Files and modules**:

- `core/commands/investigate.md` (new)
- `core/commands/recon.md` (new)
- `core/commands/hunt.md` (new)
- `core/commands/analyze-vuln.md` (new)
- `core/commands/cve-lookup.md` (new)
- `core/commands/score.md` (new)
- `core/commands/poc.md` (new)
- `core/commands/collect-evidence.md` (new)
- `core/commands/cve-report.md` (new)
- `core/commands/remediate.md` (new)
- `core/commands/status.md` (new)

**Tests**:

- Tool-based: run the `tools/` validator from Phase 6 against `core/commands/*.md` (AC-F1-3).
- Install-based: run install and confirm the commands appear under installed `.opencode/command/` (AC-F1-2).

**Completion signal**: `feat(GH-13): add cyber command set`

---

### Phase 3: Cleanup (F-3)

**Goal**: Reduce confusion by removing deprecated artifacts and deduplicating lifecycle definitions without changing functional behavior.

**Tasks**:

- [ ] **3.1** Remove deprecated `pr-instructions-template.md` (per spec) and verify no remaining references.
- [ ] **3.2** Audit lifecycle documentation for duplication; consolidate into a single authoritative source per lifecycle concept.
- [ ] **3.3** Ensure any removals do not break install expectations or docs references.

**Acceptance Criteria**:

- Must: AC-F3-1
- Must: AC-F3-2

**Files and modules**:

- `core/templates/pr-instructions-template.md` (deleted)
- `core/governance/lifecycle/**` (updated as needed)

**Tests**:

- Grep-based: confirm `pr-instructions-template.md` is absent.
- Sanity: run `scripts/.tests/test-install-samourai.sh`.

**Completion signal**: `chore(GH-13): remove deprecated templates and dedupe lifecycle docs`

---

### Phase 4: Documentation (F-4, F-5, F-6)

**Goal**: Provide contributor and practitioner documentation sufficient to understand, extend, and run Samourai Kali.

**Tasks**:

- [ ] **4.1** Create `CONTRIBUTING.md` covering: repo structure; agent contribution; skill contribution; command contribution; PR workflow (per spec).
- [ ] **4.2** Add an architecture document describing the layered model: `core/` → install → editor adapters → commands → agents → skills (and where change artifacts live).
- [ ] **4.3** Add an investigation workflow template (Markdown scaffold) including sensitive data handling reminder (per spec privacy notes).

**Acceptance Criteria**:

- Must: AC-F4-1
- Must: AC-F5-1
- Must: AC-F6-1

**Files and modules**:

- `CONTRIBUTING.md` (new)
- `docs/architecture.md` (new) *(or repo-preferred location; choose and document in PR)*
- `core/templates/investigation-template.md` (new) *(preferred for installation under `.samourai/core/templates/`)*

**Tests**:

- Doc review checklist: verify coverage items exist and links resolve.

**Completion signal**: `docs(GH-13): add contributing, architecture, and investigation template`

---

### Phase 5: Adapters & install editor selection (F-7, F-8, F-9)

**Goal**: Support Claude Code and Cursor via adapter configs and enable selecting editors during install with `--editor`.

**Tasks**:

- [ ] **5.1** Resolve OQ-1 (Claude Code): confirm the required config file path/format and minimal content needed.
- [ ] **5.2** Resolve OQ-2 (Cursor): confirm the required config file path/format and minimal content needed.
- [ ] **5.3** Implement Claude adapter config under `adapters/claude/` (exact paths per decision), ensuring it contains no secrets and is parseable.
- [ ] **5.4** Implement Cursor adapter config under `adapters/cursor/` (exact paths per decision), ensuring it contains no secrets and is parseable.
- [ ] **5.5** Update `scripts/install-samourai.sh` to accept `--editor claude|cursor|all` and route adapter file copy accordingly, while keeping default behavior identical when no `--editor` is passed (AC-F9-1).
- [ ] **5.6** Update `--list-editors` output to include new editors.

**Acceptance Criteria**:

- Must: AC-F7-1
- Must: AC-F8-1
- Must: AC-F9-1

**Files and modules**:

- `adapters/claude/**` (new)
- `adapters/cursor/**` (new)
- `scripts/install-samourai.sh` (updated)

**Tests**:

- Run install in a scratch repo with `--editor claude` and `--editor cursor` and verify generated adapter files exist and parse.
- Run install with no `--editor` to ensure OpenCode-only behavior unchanged.

**Completion signal**: `feat(GH-13): add claude/cursor adapters and extend --editor install flag`

---

### Phase 6: Infrastructure (stage gates, tools, MCP) (F-10, F-11, F-12, F-13)

**Goal**: Add operational infrastructure required to make cyber workflows enforceable and toolable.

**Tasks**:

- [ ] **6.1** Ensure `lifecycle/stage-gates.md` exists and defines ≥ 5 named gates with entry criteria, responsible agent, and exit criteria (update if needed).
- [ ] **6.2** Create `tools/` directory and implement the chosen CLI tool (resolve OQ-4). Recommended: a front-matter validator for `core/commands/*.md` and/or agent inventory checks (NFR-6).
- [ ] **6.3** Decide MCP config location/schema (resolve OQ-5) and implement NVD + EPSS integration configuration:
  - NVD: base URL + env var `NVD_API_KEY` + consuming skills.
  - EPSS: base URL + no auth.
- [ ] **6.4** Ensure `/cve-lookup` and `/score` docs reference the MCP configuration and the expected env var behavior (NVD key optional, graceful error).

**Acceptance Criteria**:

- Must: AC-F10-1
- Must: AC-F11-1
- Must: AC-F11-2
- Must: AC-F12-1
- Must: AC-F13-1
- Must: AC-F12-2

**Files and modules**:

- `core/governance/lifecycle/stage-gates.md` or `lifecycle/stage-gates.md` (updated/verified; keep canonical location consistent)
- `tools/<tool-name>` (new)
- MCP config file(s) (new; location per decision)
- `adapters/opencode/.opencode/opencode.jsonc` and/or `adapters/vscode/.vscode/mcp.json` (updated if they are the chosen MCP integration points)

**Tests**:

- Run tool against a clean repo (expect exit 0) and against an intentionally malformed command file (expect non-zero) (AC-F11-1/2).
- Config parse validation for MCP files (JSON/YAML parseable).

**Completion signal**: `feat(GH-13): add stage gates, tools, and MCP configuration`

---

### Phase 7: Tests (extend install test suite)

**Goal**: Extend the existing install/uninstall test suite to cover new editors, commands, agents, tools, and MCP config wiring.

**Tasks**:

- [ ] **7.1** Extend `scripts/.tests/test-install-samourai.sh` to validate that the 11 new cyber commands are installed into `.opencode/command/` when `--editor opencode` is used (AC-F1-2).
- [ ] **7.2** Add install tests ensuring the four migrated agents are installed into `.opencode/agent/` (AC-F2-1, AC-F2-2).
- [ ] **7.3** Add install tests for `--editor claude` and `--editor cursor` (and `--editor all` if confirmed by OQ-3), validating that adapter config files are generated and install exits 0 (AC-F7-1, AC-F8-1).
- [ ] **7.4** Add tests validating `--list-editors` includes the new editor values.
- [ ] **7.5** Add tests for the `tools/` CLI tool (exit codes 0/non-zero per AC-F11-1/2) without requiring network access.

**Acceptance Criteria**:

- Must: All affected acceptance criteria have automated regression coverage where feasible without live APIs.

**Files and modules**:

- `scripts/.tests/test-install-samourai.sh` (updated)

**Tests**:

- Run `bash scripts/.tests/test-install-samourai.sh`.

**Completion signal**: `test(GH-13): extend installer tests for cyber operational stack`

---

### Phase 8: Code Review (analysis)

**Goal**: Validate the change against the spec requirements, repo conventions, and regression risk.

**Tasks**:

- [ ] **8.1** Run a local review of the branch changes against `chg-GH-13-spec.md` (F-1 through F-13) and ensure every AC is demonstrably satisfied.
- [ ] **8.2** Confirm no secrets were introduced and that MCP auth relies on env vars only.
- [ ] **8.3** Confirm install/uninstall tests pass.

**Acceptance Criteria**:

- Must: All AC-F*-* items are satisfied with evidence (tests, file presence, validations).

**Files and modules**:

- N/A (review only)

**Tests**:

- `bash scripts/.tests/test-install-samourai.sh`

**Completion signal**: `chore(GH-13): review complete`

---

### Phase 9: Post-code review fixes (conditional)

**Goal**: Address review feedback with minimal risk and preserve compatibility.

**Tasks**:

- [ ] **9.1** Implement any requested fixes from review and update docs/tests accordingly.
- [ ] **9.2** Re-run installer tests and validate any previously-passing acceptance criteria remain passing.

**Acceptance Criteria**:

- Must: Review feedback addressed; regression checks pass.

**Files and modules**:

- As needed (keep changes minimal and scoped)

**Tests**:

- `bash scripts/.tests/test-install-samourai.sh`

**Completion signal**: `fix(GH-13): address review feedback`

---

### Phase 10: Finalize and release

**Goal**: Prepare the change for merge with appropriate versioning, reconciliation, and final checks.

**Tasks**:

- [ ] **10.1** Version bump per repo conventions for a `minor` version impact (identify canonical version sources such as installer `APP_VERSION` and any published docs/version files; update consistently).
- [ ] **10.2** Spec reconciliation: re-read `chg-GH-13-spec.md` and ensure the implementation matches F-1..F-13 and all acceptance criteria; update plan execution evidence where needed.
- [ ] **10.3** Ensure branch is clean and commits are atomic and conventional; ready for PR creation.

**Acceptance Criteria**:

- Must: Version bump is consistent and justified.
- Must: Spec and delivered artifacts align; no unmet AC.

**Files and modules**:

- Version sources (updated)
- `chg-GH-13-spec.md` (no changes expected; reconciliation only)

**Tests**:

- `bash scripts/.tests/test-install-samourai.sh`

**Completion signal**: `chore(GH-13): finalize release readiness`

## Test Scenarios

| ID | Scenario | Acceptance Criteria |
|----|----------|---------------------|
| TS-1 | Install (default) with no `--editor` behaves as current OpenCode-only install | AC-F9-1 |
| TS-2 | Install with `--editor opencode` results in 11 cyber commands present in `.opencode/command/` | AC-F1-2 |
| TS-3 | `/investigate <target>` command delegates to `@pm` and initializes investigation context (command contract) | AC-F1-1 |
| TS-4 | Command front matter validator passes on valid commands; fails on malformed commands | AC-F1-3, AC-F11-1, AC-F11-2 |
| TS-5 | Install includes migrated orphan agents in `.opencode/agent/` | AC-F2-1, AC-F2-2 |
| TS-6 | `pr-instructions-template.md` removed; lifecycle docs are non-duplicated | AC-F3-1, AC-F3-2 |
| TS-7 | `CONTRIBUTING.md`, architecture doc, and investigation template exist and meet content expectations | AC-F4-1, AC-F5-1, AC-F6-1 |
| TS-8 | Install with `--editor claude` generates valid Claude adapter config | AC-F7-1 |
| TS-9 | Install with `--editor cursor` generates valid Cursor adapter config | AC-F8-1 |
| TS-10 | Stage gates file defines ≥ 5 gates with criteria and ownership | AC-F10-1 |
| TS-11 | MCP config for NVD/EPSS exists and documents `NVD_API_KEY` optional behavior | AC-F12-1, AC-F13-1, AC-F12-2 |

## Artifacts and Links

| Artifact | Location | Type |
|----------|----------|------|
| Change specification | `./chg-GH-13-spec.md` | Spec |
| Implementation plan | `./chg-GH-13-plan.md` | Plan |
| New cyber commands | `core/commands/*.md` | Code/Config |
| Migrated agents | `core/agents/*.md` | Config |
| Install script updates | `scripts/install-samourai.sh` | Script |
| Adapter configs | `adapters/claude/**`, `adapters/cursor/**` | Config |
| Stage gates | `core/governance/lifecycle/stage-gates.md` and/or `lifecycle/stage-gates.md` | Governance |
| CLI tool | `tools/**` | Tooling |
| Installer test suite | `scripts/.tests/test-install-samourai.sh` | Tests |

## Plan Revision Log

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2026-04-30 | plan-writer | Initial plan derived from `chg-GH-13-spec.md` |

## Execution Log

| Phase | Status | Started | Completed | Commit | Notes |
|-------|--------|---------|-----------|--------|-------|
| 1 | Completed | 2026-04-30 | 2026-04-30 | pending | Migrated 4 agents into core/agents and validated scratch install output |
| 2 | Completed | 2026-04-30 | 2026-04-30 | pending | Added 11 cyber commands, added front-matter validator, validated install + schema checks |
| 3 | Not started |  |  |  |  |
| 4 | Not started |  |  |  |  |
| 5 | Not started |  |  |  |  |
| 6 | Not started |  |  |  |  |
| 7 | Not started |  |  |  |  |
| 8 | Not started |  |  |  |  |
| 9 | Not started |  |  |  |  |
| 10 | Not started |  |  |  |  |
