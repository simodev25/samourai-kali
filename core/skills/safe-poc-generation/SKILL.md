---
name: safe-poc-generation
description: Use when a vulnerability is confirmed and a minimal, non-weaponized lab proof-of-concept is needed.
---

# Safe POC Generation

## Objective
Create a minimal and safe proof-of-concept (POC) that demonstrates a confirmed vulnerability exists, without adding weaponization features.

## Use When
- Vulnerability is confirmed through analysis and triage.
- Exploitability has already been assessed and documented.
- You need reproducible demonstration evidence for internal validation or reporting.
- The testing environment is an isolated lab, not production.

<HARD-GATE>
- NEVER create or run a POC without verifying lab isolation first.
- NEVER include persistence, propagation, exfiltration, or C2 functionality.
- If environment isolation cannot be proven, STOP and escalate.
</HARD-GATE>

## Procedure
1. Review the vulnerability specification and exploitability assessment.
2. Confirm scope: target system, affected version, preconditions, expected vulnerable behavior.
3. Verify lab isolation controls (network segmentation, no production routes, disposable targets).
4. Define success criteria for a minimal POC: one clear signal that confirms vulnerability.
5. Design the POC to do only what is required to prove existence.
6. Add this mandatory SAFETY HEADER at the top of the POC file:
   ```
   # ⚠️ SECURITY POC — LAB USE ONLY
   # Vulnerability: [CVE/CWE ID]
   # Purpose: Demonstrate vulnerability existence only
   # Environment: Isolated lab ONLY — NEVER run against production
   # Author: [name] | Date: [ISO 8601]
   ```
7. Implement bounded execution controls (timeout, max retries/iterations, deterministic stop condition).
8. Enforce safety constraints in code and comments:
   - no persistence mechanisms
   - no lateral movement capability
   - no data exfiltration
   - no command-and-control logic
9. Add explicit prerequisites and runtime guard checks (environment assertions).
10. Add cleanup/rollback instructions that restore the lab target to pre-test state.
11. Execute in isolated lab and capture expected output vs actual output.
12. Document interpretation: why output confirms vulnerability and what it does NOT prove.
13. Store metadata with the POC (author, date, target version, safety assumptions, hash if required).
14. Version control the POC and documentation together for traceability.

## Verification
- [ ] Safety header exists and is complete.
- [ ] Lab isolation was verified before execution.
- [ ] POC demonstrates vulnerability with minimal steps only.
- [ ] Execution is bounded and deterministic.
- [ ] No persistence/propagation/exfiltration/C2 behavior exists.
- [ ] Cleanup/rollback instructions are present and tested.
- [ ] Expected vs actual output is documented.
- [ ] Versioned artifacts include safety metadata.

## Anti-Patterns
- Building a full exploit framework instead of a minimal demonstration.
- Omitting safety header or leaving placeholder fields unresolved.
- Running against shared staging or production-like environments without isolation proof.
- Capturing sensitive data unnecessarily during execution.
- Shipping a POC without rollback steps.

## Deliverables
- POC script or command set with mandatory safety header.
- Execution notes with expected output, actual output, and interpretation.
- Cleanup/rollback guide.
- Traceability metadata committed with the POC.

## Exit Criteria
The POC is accepted only if it is minimal, safely bounded, lab-only verified, reproducible, and accompanied by tested cleanup instructions.
