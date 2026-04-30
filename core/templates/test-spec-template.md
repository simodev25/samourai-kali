---
id: TEST-SPEC-<feature-slug>             # e.g., TEST-SPEC-TENANTS
status: Current                          # Current | Deprecated
created: <YYYY-MM-DD>
last_updated: <YYYY-MM-DD>
owners: [<team-or-person>]
service: <primary-service>
links:
  related_changes: []                    # workItemRef identifiers
  feature_spec: <path-to-feature-spec>   # e.g., .samourai/docai/spec/features/feature-tenants.md
  parent_spec: <path-if-applicable>
---

<!-- TEMPLATE INSTRUCTIONS
1. Copy this file to .samourai/docai/quality/test-specs/test-spec-<feature-slug>.md
2. Replace all <...> placeholders with actual values
3. Remove these instructions before finalizing
4. This is the enduring test specification for a feature — derived from per-change test plans
-->

# Evidence Specification: <Finding Name>

## Overview

<!-- High-level evidence strategy for this finding. What evidence is collected and why it proves the claim. -->

## Evidence Scope

<!-- - Components and systems where evidence is collected
     - Integration points and trust boundaries
     - Exclusions (what evidence is NOT collected and why) -->

## Evidence Types

### Logs

<!-- - Purpose: Capture system/runtime evidence
     - Tools: log collectors, parsers
     - Integrity requirements -->

### Screenshots

<!-- - Purpose: Capture visual proof of vulnerable behavior
     - Tools: screenshot tooling
     - Metadata requirements -->

### PCAP

<!-- - Purpose: Capture network-level evidence
     - Tools: packet capture tooling
     - Retention and sanitization rules -->

### Tool Output

<!-- - Purpose: Capture deterministic scanner/exploit/validator outputs
     - Tools: scanner or verification utilities
     - Reproducibility requirements -->

## Evidence Data Handling

<!-- - Data generation strategy
     - Preconditions
     - Cleanup procedures
     - Hashing and timestamping requirements -->

## Evidence Scenarios

### Scenario 1: <Descriptive Name>

<!-- - **Given**: Preconditions
     - **When**: Reproduction or validation action
     - **Then**: Expected evidence artifact
     - **And**: Chain-of-custody assertion -->

### Scenario 2: <Descriptive Name>

<!-- Add more scenarios as needed -->

## Reproduction Scenarios

<!-- - Controlled reproduction steps
     - Validation against fixed versions
     - Regression confirmation after remediation -->

## Validation Scenarios

<!-- - Findings validation logic
     - False positive elimination
     - Boundary-condition checks -->

## Chain of Custody Scenarios

<!-- - Artifact provenance
     - Access controls for evidence
     - Handoff and storage traceability -->

## Automation Strategy

<!-- - Evidence collection automation
     - Execution triggers
     - Evidence reporting -->

## Evidence Environment

<!-- - Required lab services
     - Configuration
     - Isolation and mocking strategies -->

## Evidence Coverage Metrics

<!-- - Evidence completeness targets
     - Reproducibility coverage
     - Risk-based evidence priorities -->

## Evidence Maintenance

<!-- - Evidence data management
     - Integrity drift handling
     - Update procedures when finding context evolves -->

## References

<!-- - Feature specification link
     - Decision records
     - API contracts -->
