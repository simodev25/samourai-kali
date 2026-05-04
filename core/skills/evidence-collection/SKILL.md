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

## Kali Tools

| Evidence Type | Tool | Command |
|---------------|------|---------|
| File hashing | `sha256sum` | `sha256sum artifact.log >> evidence-hashes.txt` |
| Timestamps | `date` | `date -u +"%Y-%m-%dT%H:%M:%SZ"` |
| Packet capture | `tcpdump` | `tcpdump -i eth0 -w evidence/pcap/capture.pcap host target` |
| Packet analysis | `tshark` | `tshark -r capture.pcap -Y "http" -T fields -e http.request.uri` |
| Session recording | `script` | `script -q evidence/logs/session_$(date +%Y%m%d_%H%M%S).log` |
| Screenshot | `scrot` | `scrot evidence/screenshots/finding_%Y%m%d_%H%M%S.png` |
| Batch hashing | `find` + `sha256sum` | `find evidence/ -type f -exec sha256sum {} \; > hashes.sha256` |

## Command Examples

```bash
sha256sum artifact.log >> evidence-hashes.txt
date -u +"%Y-%m-%dT%H:%M:%SZ"
tcpdump -i eth0 -w evidence/pcap/capture.pcap host target
tshark -r capture.pcap -Y "http" -T fields -e http.request.uri
script -q evidence/logs/session_$(date +%Y%m%d_%H%M%S).log
scrot evidence/screenshots/finding_$(date +%Y%m%d_%H%M%S).png
find evidence/ -type f -exec sha256sum {} \; > hashes.sha256
```

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

## Output Interpretation

### sha256sum output
- Key indicators: 64-hex digest followed by filename, stable across re-hash if file unchanged.
- Example output snippet (1-3 lines)
  ```text
  d2d2f5c9...8b6e1a42f0c1e5c2a7b9e4f3a1d0c6e2b4a8f9d1c3e7b5a9  auth.log
  ```
- What it means: this is valid SHA-256 format; any later digest change indicates file mutation.

### tshark output
- Key indicators: packet counts, protocol distribution, and unusual error/retransmission spikes.
- Example output snippet (1-3 lines)
  ```text
  245 packets captured
  HTTP 180  TCP 65
  ```
- What it means: confirms capture scope and activity volume; sudden protocol anomalies can corroborate finding timelines.

### script session log output
- Key indicators: `Script started`/`Script done` markers and full command/output chronology.
- Example output snippet (1-3 lines)
  ```text
  Script started on 2026-04-30 10:22:11+00:00
  $ curl -v https://target/login
  ```
- What it means: provides tamper-evident execution context and ordering for reproducibility and audit trail.

### evidence-index.yaml validation output
- Key indicators: required keys present (`id,type,hash,timestamp,path`) and paths resolving to files.
- Example output snippet (1-3 lines)
  ```text
  EV-001 OK
  EV-002 missing path
  ```
- What it means: `OK` entries are report-ready; missing/invalid fields break traceability and must be fixed before reporting.

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

## Tools Used

- Primary Kali/tools: `script`, `sha256sum`, `tcpdump`, `tshark`, `curl`, `scrot`.
- Preflight command: `command -v script sha256sum tcpdump tshark curl scrot || true`.
- Missing-tool behavior: record `missing_tools`, choose a safe fallback when available, or stop with `NEEDS_TOOLING` before making technical claims.
- Scope behavior: every active command must use only authorized lab targets and must write logs/evidence under `.samourai/tmpai/` or the approved change folder.

## Command Examples

```bash
script -q .samourai/tmpai/evidence/session.typescript -c "APPROVED_COMMAND"
sha256sum .samourai/tmpai/evidence/* > .samourai/tmpai/evidence/SHA256SUMS
tcpdump -i IFACE -w .samourai/tmpai/evidence/capture.pcap host TARGET_IP
```

## Result Interpretation

Evidence index: artifact path, command, timestamp, SHA256, scope note, redaction status, custody metadata.

Interpretation rules:
- Treat scanner output as a lead until independently reproduced.
- Separate confirmed facts from inferred hypotheses.
- Record false-positive risk and evidence path for every result.
- Prefer French for summaries, reports, and final investigation artifacts.
