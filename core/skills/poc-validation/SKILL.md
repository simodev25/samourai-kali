---
name: poc-validation
description: Use when a vulnerability proof-of-concept must be validated for safety, correctness, and reproducibility before reporting.
---

# POC Validation

## Objective
Validate that a proof-of-concept (POC) correctly demonstrates the claimed vulnerability while remaining strictly safe and non-weaponized.

## Use When
- A POC has been authored and needs approval before inclusion in findings.
- Security reviewers need evidence the POC is accurate and reproducible.
- You must confirm cleanup restores the target environment.

<HARD-GATE>
- Reject any POC missing a complete safety header.
- Do not accept validation based on code reading alone; execution evidence is required.
- Validation must occur in an isolated lab only.
</HARD-GATE>

## Procedure
1. Collect inputs: vulnerability spec, exploitability notes, POC file, expected outcomes, lab context.
2. Review safety header completeness (vulnerability ID, purpose, lab-only warning, author/date).
3. If header is missing or incomplete, fail validation and return required corrections.
4. Perform static safety review for weaponization indicators:
   - persistence mechanisms
   - propagation/lateral movement
   - data exfiltration logic
   - C2 or remote tasking behavior
5. Verify environment isolation before execution (network boundaries, disposable state, no production connectivity).
6. Confirm prerequisites and runtime guards are present (timeouts, iteration limits, safe defaults).
7. Execute the POC in lab and capture full command/output logs.
8. Validate claim alignment: output must demonstrate the exact vulnerability described in the spec.
9. Validate behavioral accuracy: no undocumented side effects beyond stated scope.
10. Execute cleanup procedure and verify target returns to original state.
11. Reproducibility check: run the POC three times under same conditions.
12. Compare run results for consistency and note acceptable variance.
13. Record validation verdict: PASS, PASS WITH NOTES, or FAIL.
14. Document remediation actions if validation fails (what to change before re-test).

## Verification
- [ ] Safety header is present and complete.
- [ ] Static review found no weaponization indicators.
- [ ] Lab isolation verification is documented.
- [ ] Full execution output is captured and archived.
- [ ] POC demonstrates the claimed vulnerability, not a different issue.
- [ ] Behavior matches documentation with no hidden side effects.
- [ ] Cleanup succeeds and environment baseline is restored.
- [ ] Three-run reproducibility check is consistent.
- [ ] Validation report includes evidence and final verdict.

## Anti-Patterns
- Skipping safety checks because the author is trusted.
- Approving POC without executing it.
- Treating one successful run as sufficient evidence.
- Ignoring cleanup validation.
- Accepting broad “works as expected” statements without logs.

## Validation Report Template
- POC Identifier:
- Vulnerability Reference:
- Safety Header Review: PASS/FAIL
- Static Safety Review: PASS/FAIL
- Environment Isolation Check: PASS/FAIL
- Execution Run 1:
- Execution Run 2:
- Execution Run 3:
- Cleanup Verification: PASS/FAIL
- Reproducibility: PASS/FAIL
- Final Verdict:
- Required Follow-Ups:

## Exit Criteria
Validation completes only when safety, correctness, cleanup, and reproducibility are evidenced and traceable.
