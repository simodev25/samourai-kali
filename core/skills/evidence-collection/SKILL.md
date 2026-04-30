---
name: evidence-collection
description: Use when security findings require structured, tamper-evident evidence capture for reporting and auditability.
---

# Evidence Collection

## Objective
Collect and preserve investigation artifacts in a structured, tamper-evident manner suitable for internal review, external reporting, and audit trails.

## Use When
- Any security finding must be substantiated with evidence.
- A vulnerability report needs traceable artifacts.
- You must preserve chain of custody for technical investigation outputs.

<HARD-GATE>
- Never store credentials, secrets, or unnecessary PII in raw artifacts.
- Every evidence artifact must be timestamped and hashed.
- If chain of custody is broken, mark evidence integrity as compromised.
</HARD-GATE>

## Evidence Directory Structure
Create and maintain this structure for each work item:

```
evidence/<workItemRef>/
├── evidence-index.yaml
├── logs/
├── screenshots/
├── pcap/
├── tool-output/
└── timeline.md
```

## Procedure
1. Initialize the directory structure under `evidence/<workItemRef>/`.
2. Create `evidence-index.yaml` with metadata header (work item, investigator, created_at, timezone).
3. Define an evidence ID convention (for example: `EV-001`, `EV-002`, ...).
4. For each artifact captured:
   a. Save original artifact into the correct subdirectory.
   b. Redact sensitive data (credentials, tokens, PII, internal IPs as required).
   c. Generate SHA256 hash of the stored artifact.
   d. Record ISO 8601 timestamp of collection.
   e. Add index entry with: `id`, `type`, `hash`, `timestamp`, `description`, `source_tool`, `path`.
5. Preserve raw command context for tool outputs (tool name, command, target, parameters).
6. Maintain chronological `timeline.md` linking each event to evidence IDs.
7. Create chain-of-custody notes including collector, handoffs, and any transformations.
8. Validate evidence completeness against findings list and acceptance/report requirements.
9. Package artifacts for report consumption while preserving index references.

## evidence-index.yaml Recommended Shape
```yaml
work_item_ref: GH-123
created_at: 2026-04-30T10:22:00Z
investigator: analyst-name
artifacts:
  - id: EV-001
    type: log
    hash: sha256:...
    timestamp: 2026-04-30T10:25:12Z
    description: Authentication bypass request/response log
    source_tool: curl
    path: logs/auth-bypass.log
```

## Verification
- [ ] Required directory structure exists.
- [ ] Every artifact has SHA256 hash and ISO 8601 timestamp.
- [ ] `evidence-index.yaml` entries are complete and path-valid.
- [ ] Sensitive data has been redacted appropriately.
- [ ] `timeline.md` is chronological and references evidence IDs.
- [ ] Chain of custody is documented, including handoffs.
- [ ] Evidence set covers all reported findings.
- [ ] Packaged evidence is readable and review-ready.

## Anti-Patterns
- Keeping screenshots/logs without hashes.
- Adding artifacts with missing timestamps or ambiguous origin.
- Storing credentials or full secrets in evidence bundles.
- Editing files without documenting transformation/redaction steps.
- Referencing evidence in reports that is absent from index.

## Deliverables
- Structured `evidence/<workItemRef>/` directory.
- Complete `evidence-index.yaml`.
- Chronological `timeline.md`.
- Chain-of-custody document or section.
- Report-ready package with integrity metadata.

## Exit Criteria
Evidence is considered complete only when indexed, hashed, timestamped, redacted, traceable, and mapped to all findings.
