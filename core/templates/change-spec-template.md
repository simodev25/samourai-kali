---
change:
  ref: <workItemRef>                     # e.g., PDEV-123, GH-456
  type: <conventional-type>              # feat | fix | refactor | docs | test | chore | perf | build | ci | revert | style
  status: Proposed                       # Proposed | Accepted | Rejected | Superseded | Deprecated
  slug: <kebab-case-short-name>          # ≤60 chars
  title: "<Human readable title>"
  owners: [<at-least-one>]
  service: <primary-impacted-service>
  labels: [<zero-or-more>]
  version_impact: <none|patch|minor|major>
  audience: <internal|external|mixed>
  security_impact: <none|low|medium|high>
  risk_level: <low|medium|high>
  dependencies:
    internal: [<services-or-components>]
    external: [<vendors-or-APIs>]
---

<!-- TEMPLATE INSTRUCTIONS
1. Copy this file to the change folder: .samourai/docai/changes/YYYY-MM/YYYY-MM-DD--<workItemRef>--<slug>/chg-<workItemRef>-spec.md
2. Replace all <...> placeholders with actual values
3. Remove these instructions before finalizing
4. See .samourai/docai/documentation-handbook.md for conventions
-->

# VULNERABILITY SPECIFICATION

> **PURPOSE**: <!-- One-sentence purpose statement describing what this change achieves and why it matters -->

## 1. SUMMARY

<!-- 2-3 sentences describing the change at a high level. What is being delivered? -->

## 2. CONTEXT

### 2.1 Current State Snapshot

<!-- Describe the system's current behavior relevant to this change -->

### 2.2 Pain Points / Gaps

<!-- List specific problems, gaps, or pain points that motivate this change -->

## 3. VULNERABILITY DESCRIPTION

<!-- Single paragraph: "Because <limitation>, <user> cannot <outcome>, resulting in <impact>." -->

## 4. INVESTIGATION OBJECTIVES

<!-- List goals using G-# IDs:
- **G-1**: ...
- **G-2**: ...
-->

### 4.1 Success Metrics / KPIs

<!-- Table format:
| Metric | Target |
|--------|--------|
| ...    | ...    |
-->

### 4.2 Non-Goals

<!-- List items explicitly excluded:
- **NG-1**: ...
-->

## 5. VULNERABILITY DETAILS

<!-- Table format:
| ID | Detail | Value |
|----|--------|-------|
| V-1 | CWE | CWE-... |
| V-2 | CVSS | CVSS:3.1/... |
| V-3 | Affected versions | ... |
-->

### 5.1 Vulnerability Detail Notes

<!-- Expand on each V-# with vulnerability-specific description. No implementation details. -->

## 6. ATTACKER & SYSTEM FLOWS

<!-- Describe key attacker/system flows. Use text diagrams or Mermaid if helpful.
```
Flow 1: ...
  Actor does X → System responds with Y → ...
```
-->

## 7. SCOPE & BOUNDARIES

### 7.1 In Scope

<!-- Bullet list of what is included -->

### 7.2 Out of Scope

<!-- Bullet list prefixed with [OUT]:
- [OUT] ...
-->

### 7.3 Deferred / Maybe-Later

<!-- Items to consider in future changes -->

## 8. INTERFACES & INTEGRATION CONTRACTS

### 8.1 REST / HTTP Endpoints

<!-- Table or description of new/modified endpoints. N/A if none. -->

### 8.2 Events / Messages

<!-- Table or description of new/modified events. N/A if none. -->

### 8.3 Data Model Impact

<!-- Table format:
| ID | Element | Description |
|----|---------|-------------|
| DM-1 | ... | ... |
-->

### 8.4 External Integrations

<!-- External APIs or services affected. N/A if none. -->

### 8.5 Backward Compatibility

<!-- Describe backward compatibility implications -->

## 9. NON-FUNCTIONAL REQUIREMENTS (NFRs)

<!-- Table format:
| ID | Requirement | Threshold |
|----|-------------|-----------|
| NFR-1 | ... | ... |
-->

## 10. TELEMETRY & OBSERVABILITY REQUIREMENTS

<!-- Metrics, logs, traces, alerts needed. N/A if none. -->

## 11. RISKS & MITIGATIONS

<!-- Table format:
| ID | Risk | Impact | Probability | Mitigation | Residual Risk |
|----|------|--------|-------------|------------|---------------|
| RSK-1 | ... | H/M/L | H/M/L | ... | ... |
-->

## 12. ASSUMPTIONS

<!-- Bullet list of assumptions -->

## 13. DEPENDENCIES

<!-- Table format:
| Direction | Item | Notes |
|-----------|------|-------|
| Depends on | ... | ... |
| Blocks | ... | ... |
-->

## 14. OPEN QUESTIONS

<!-- Table format:
| ID | Question | Context | Status |
|----|----------|---------|--------|
| OQ-1 | ... | ... | Decision needed: consult `@architect` |
-->

## 15. DECISION LOG

<!-- Table format:
| ID | Decision | Rationale | Date |
|----|----------|-----------|------|
| DEC-1 | ... | ... | YYYY-MM-DD |
-->

## 16. AFFECTED COMPONENTS (HIGH-LEVEL)

<!-- Table format:
| Component | Impact |
|-----------|--------|
| ... | Updated / New / Deprecated |
-->

## 17. CONFIRMATION CRITERIA

<!-- Group by feature area. Use Given/When/Then format.
| ID | Criterion | Linked |
|----|-----------|--------|
| CC-V1-1 | **Given** ..., **when** ..., **then** ... | V-1 |
-->

## 18. DISCLOSURE & CHANGE MANAGEMENT (HIGH-LEVEL)

<!-- Disclosure order, remediation coordination, communication, adoption notes -->

## 19. DATA MIGRATION / SEEDING (IF APPLICABLE)

<!-- Describe data migration needs. N/A if none. -->

## 20. PRIVACY / COMPLIANCE REVIEW

<!-- Privacy or compliance implications. N/A if none. -->

## 21. SECURITY REVIEW HIGHLIGHTS

<!-- Security considerations. N/A if none. -->

## 22. CVE REFERENCES

<!-- List CVE IDs, advisory links, CNA references, and publication status. -->

## 23. EXPLOITATION PREREQUISITES

<!-- Required attacker position, access level, environment assumptions, and tooling prerequisites. -->

## 24. IMPACT ASSESSMENT

<!-- Table format:
| Impact Area | Description | Severity |
|-------------|-------------|----------|
| Confidentiality | ... | H/M/L |
| Integrity | ... | H/M/L |
| Availability | ... | H/M/L |
| Business/Operational | ... | H/M/L |
-->

## 25. MAINTENANCE & OPERATIONS IMPACT

<!-- Ongoing maintenance implications -->

## 26. GLOSSARY

<!-- Table format:
| Term | Definition |
|------|------------|
| ... | ... |
-->

## 27. APPENDICES

<!-- Supporting material, diagrams, data -->

## 28. DOCUMENT HISTORY

<!-- Table format:
| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | YYYY-MM-DD | ... | Initial specification |
-->

---

## AUTHORING GUIDELINES

<!-- Notes on how this spec was authored — sources, approach, constraints -->

## VALIDATION CHECKLIST

- [ ] `change.ref` matches provided `workItemRef`
- [ ] `owners` has at least one entry
- [ ] `status` is "Proposed"
- [ ] All sections present in order (1-28 + guidelines + checklist)
- [ ] ID prefixes consistent and unique (V-, CC-, NFR-, RSK-, DEC-, DM-, OQ-)
- [ ] Confirmation criteria reference at least one V-/NFR- ID and use Given/When/Then
- [ ] NFRs include measurable values
- [ ] Risks include Impact & Probability
- [ ] No implementation details (no file-level code paths, no step-by-step tasks)
- [ ] No content duplicated from linked docs
- [ ] Front matter validates per front_matter_rules
