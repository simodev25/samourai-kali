---
id: chg-<workItemRef>-<slug>             # e.g., chg-GH-456-units-display
status: Proposed                         # Proposed | Updated
created: <YYYY-MM-DD>T00:00:00Z
last_updated: <YYYY-MM-DD>T00:00:00Z
owners: [<from-spec>]
service: <from-spec>
labels: [<from-spec>]
links:
  change_spec: <relative-path>           # e.g., ./chg-GH-456-spec.md
summary: >
  <from-spec-summary>
version_impact: <from-spec>
---

<!-- TEMPLATE INSTRUCTIONS
1. Copy this file to the change folder: .samourai/docai/changes/YYYY-MM/YYYY-MM-DD--<workItemRef>--<slug>/chg-<workItemRef>-plan.md
2. Replace all <...> placeholders with actual values
3. Remove these instructions before finalizing
4. Derive all requirements from the change spec — do not invent
-->

# INVESTIGATION PLAN — <workItemRef>: <Finding Title>

## Context and Objectives

<!-- Summarize what this plan delivers, how it connects to the change spec, and any resolved open questions.
     If there are unresolved questions, list them as "Open questions" bullets. -->

## Scope

### In Scope

<!-- Bullet list of what is included, referencing spec V-# IDs -->

### Out of Scope

<!-- Bullet list of what is excluded -->

### Constraints

<!-- Technical and process constraints -->

### Risks

<!-- Key risks from spec, with mitigation strategy:
- **RSK-#**: Description. Mitigated by...
-->

### Success Metrics

<!-- Key success metrics from spec -->

## Phases

<!-- Each phase follows this format:

### Phase N: <Short Title>

**Goal**: <What this phase achieves>

**Tasks**:

- [ ] **N.1** <Task description>
- [ ] **N.2** <Task description>

**Confirmation Criteria**:

- Must: <Criterion from spec CC-#>
- Should: <Nice-to-have criterion>

**Files and modules**:

- <artifact path> (new | updated)

**Tests**:

- <Validation step or test to run>

**Completion signal**: <Commit message for this phase>

---
-->

### Phase 1: Reconnaissance

**Goal**: <!-- Establish target scope, assets, and initial exposure map -->

**Tasks**:

- [ ] **1.1** Inventory exposed services, versions, and trust boundaries.
- [ ] **1.2** Capture initial reconnaissance evidence and environment notes.

**Confirmation Criteria**:

- Must: Recon artifacts identify relevant attack surface and constraints.

**Files and modules**:

- <!-- reconnaissance artifact -->

**Tests**:

- <!-- reconnaissance validation command -->

**Completion signal**: `<type>(workItemRef): phase 1 — reconnaissance complete>`

---

<!-- Add more phases as needed. Final phase should include:
- Version bump per repo conventions
- Spec reconciliation
-->

### Phase 2: Analysis

**Goal**: <!-- Analyze findings, isolate likely vulnerable paths, and form hypotheses -->

**Tasks**:

- [ ] **2.1** Correlate reconnaissance data with observed anomalous behavior.
- [ ] **2.2** Build and prioritize exploitation hypotheses.

**Confirmation Criteria**:

- Must: Hypotheses are evidence-backed and ranked by likelihood/impact.

**Files and modules**:

- <!-- analysis artifact -->

**Tests**:

- <!-- focused validation command -->

**Completion signal**: `<type>(workItemRef): phase 2 — analysis complete>`

---

### Phase 3: CVE Research

**Goal**: <!-- Map findings to known CVEs, advisories, and weakness classes -->

**Tasks**:

- [ ] **3.1** Search CVE/advisory sources for matching patterns and versions.
- [ ] **3.2** Document CVE/CWE relevance and confidence.

**Confirmation Criteria**:

- Must: CVE/CWE mapping is documented with references or justified as none.

**Files and modules**:

- <!-- cve research artifact -->

**Tests**:

- <!-- source verification step -->

**Completion signal**: `<type>(workItemRef): phase 3 — cve research complete>`

---

### Phase 4: Exploitability Assessment

**Goal**: <!-- Determine practical exploitability, prerequisites, and impact -->

**Tasks**:

- [ ] **4.1** Evaluate exploitation prerequisites and attacker model.
- [ ] **4.2** Score impact/severity (CVSS or equivalent) with rationale.

**Confirmation Criteria**:

- Must: Exploitability and impact are assessed with reproducible reasoning.

**Files and modules**:

- <!-- exploitability assessment artifact -->

**Tests**:

- <!-- exploitability check command -->

**Completion signal**: `<type>(workItemRef): phase 4 — exploitability assessed>`

---

### Phase 5: POC Development


**Tasks**:

- [ ] **5.1** Implement minimal non-weaponized POC in isolated lab.
- [ ] **5.2** Validate POC reproducibility and cleanup steps.

**Confirmation Criteria**:

- Must: POC confirms finding without enabling weaponization.

**Files and modules**:

- <!-- poc artifact -->

**Tests**:

- <!-- poc execution command -->

**Completion signal**: `<type>(workItemRef): phase 5 — poc developed>`

---

### Phase 6: Evidence Collection

**Goal**: <!-- Collect, hash, and organize reproducible evidence -->

**Tasks**:

- [ ] **6.1** Capture logs/screenshots/pcaps/tool output for each claim.
- [ ] **6.2** Hash and timestamp evidence with chain-of-custody notes.

**Confirmation Criteria**:

- Must: Evidence package is complete, reproducible, and integrity-checked.

**Files and modules**:

- <!-- evidence artifact -->

**Tests**:

- <!-- evidence integrity command -->

**Completion signal**: `<type>(workItemRef): phase 6 — evidence collected>`

---

### Phase 7: Reporting

**Goal**: <!-- Produce investigation report and disclosure-ready summary -->

**Tasks**:

- [ ] **7.1** Draft investigation report with timeline, CVSS, CWE, and impact.
- [ ] **7.2** Validate report completeness and safety language.

**Confirmation Criteria**:

- Must: Report is complete, accurate, and ready for internal review/disclosure process.

**Files and modules**:

- <!-- report artifact -->

**Tests**:

- <!-- report checklist step -->

**Completion signal**: `<type>(workItemRef): phase 7 — reporting complete>`

---

### Phase 8: Remediation

**Goal**: <!-- Define and validate remediation recommendation -->

**Tasks**:

- [ ] **8.1** Propose remediation options and risk trade-offs.
- [ ] **8.2** Define validation steps for post-fix verification.

**Confirmation Criteria**:

- Must: Remediation recommendation is actionable and verification-ready.

**Files and modules**:

- <!-- remediation artifact -->

**Tests**:

- <!-- remediation validation step -->

**Completion signal**: `<type>(workItemRef): phase 8 — remediation planned>`

## Validation Scenarios

<!-- Map validation scenarios to phases and confirmation criteria:
| ID | Scenario | Phases | CC |
|----|----------|--------|----|
-->

## Artifacts and Links

<!-- Table of all artifacts created or modified:
| Artifact | Location | Type |
|----------|----------|------|
| Change specification | ./chg-<workItemRef>-spec.md | Spec |
-->

## Plan Revision Log

<!-- Table format:
| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | YYYY-MM-DD | plan-writer | Initial plan |
-->

## Execution Log

<!-- Populated during execution:
| Phase | Status | Started | Completed | Commit | Notes |
|-------|--------|---------|-----------|--------|-------|
-->
