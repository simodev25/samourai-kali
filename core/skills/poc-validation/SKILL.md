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

## Kali Tools

| Validation Step | Tool | Command |
|-----------------|------|---------|
| Environment isolation | `ip`, `iptables` | `ip route show`, `iptables -L -n` |
| Network monitoring | `tcpdump` | `tcpdump -i any -c 100 not host lab-gateway` |
| POC execution | `script` | `script -q validation_session.log` |
| Hash verification | `sha256sum` | `sha256sum poc_output.txt` |
| Cleanup verification | `diff` | `diff before_state.txt after_cleanup.txt` |

## Command Examples

```bash
ip route show
iptables -L -n
tcpdump -i any -c 100 not host lab-gateway
script -q validation_session.log
sha256sum poc_output.txt
diff before_state.txt after_cleanup.txt
```

## Output Interpretation

### diff output
- Key indicators: unexpected line-level differences between expected and actual files/states.
- Example output snippet (1-3 lines)
  ```text
  < expected_status=403
  > actual_status=200
  ```
- What it means: mismatch shows claim drift or side effects; validation should be FAIL or PASS WITH NOTES pending explanation.

### sha256sum output
- Key indicators: identical hash value for expected immutable artifacts before/after validation.
- Example output snippet (1-3 lines)
  ```text
  a3f5...9c1b  baseline.bin
  a3f5...9c1b  after_cleanup.bin
  ```
- What it means: hash match indicates integrity preserved; mismatch suggests modification or incomplete cleanup.

### tcpdump validation capture output
- Key indicators: only expected lab traffic, no unexpected egress destinations, no persistence callbacks.
- Example output snippet (1-3 lines)
  ```text
  IP 10.10.10.5 > 10.10.10.20: HTTP POST /test
  ```
- What it means: bounded traffic supports safe behavior; unknown outbound hosts indicate safety control failure.

## Verification
- [ ] Safety header is present and complete.
- [ ] Static review found  weaponization indicators.
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

## Tools Used

- Primary Kali/tools: `curl`, `python3`, `nc`, `nmap`, `msfconsole`.
- Preflight command: `command -v curl python3 nc nmap msfconsole || true`.
- Missing-tool behavior: record `missing_tools`, choose a safe fallback when available, or stop with `NEEDS_TOOLING` before making technical claims.
- Scope behavior: every active command must use only authorized lab targets and must write logs/evidence under `.samourai/tmpai/` or the approved change folder.

## Command Examples

```bash
curl -k -i --max-time 10 --path-as-is "https://LAB_TARGET/MINIMAL_TEST"
python3 poc.py --target https://LAB_TARGET --safe-mode --dry-run
nmap --script SAFE_NSE_SCRIPT -p PORT LAB_TARGET -oN .samourai/tmpai/poc/nse.txt
```

## Result Interpretation

Safe POC package: hypothesis, lab markers, minimal command/script, expected signal, cleanup, logs,  notes.

Interpretation rules:
- Treat scanner output as a lead until independently reproduced.
- Separate confirmed facts from inferred hypotheses.
- Record false-positive risk and evidence path for every result.
- Prefer French for summaries, reports, and final investigation artifacts.
