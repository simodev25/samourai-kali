---
name: remediation-plan
description: Use when a confirmed vulnerability has been reported and teams need a prioritized, verifiable remediation strategy.
---

# Remediation Plan

## Objective
Design an actionable, risk-based remediation plan that addresses confirmed vulnerabilities while minimizing regression and operational risk.

## Use When
- Vulnerability is confirmed and documented.
- Reporting phase is complete or near-complete.
- Engineering/security teams must choose and execute a fix strategy.

<HARD-GATE>
- Evaluate at least two remediation options before deciding.
- Every implementation plan must include rollback and verification criteria.
- Do not approve remediation without regression testing strategy.
</HARD-GATE>

## Procedure
1. Review root cause, exploit path, impact, and affected systems.
2. Enumerate remediation options, including at minimum:
   - code fix (direct patch)
   - configuration hardening
   - WAF/IPS virtual patching
   - architectural redesign (if needed)
   - compensating controls (monitoring, throttling, segmentation)
3. For each option, assess:
   - expected effectiveness
   - implementation effort
   - regression risk
   - time to deploy
   - operational complexity
4. Score and prioritize options using risk-based weighting:
   - CVSS severity
   - business impact
   - exploit likelihood/time-to-abuse
5. Select recommended path (or phased hybrid strategy).
6. Define implementation plan with concrete steps and owners.
7. Add timeline with milestones (design, implementation, validation, rollout).
8. Define rollback triggers and rollback procedures.
9. Define verification criteria proving vulnerability is remediated.
10. Define regression test suite scope for impacted functionality.
11. Define pre-fix monitoring and detection for active exploitation attempts.
12. Document residual risk and compensating controls if full remediation is delayed.
13. Publish remediation plan and align stakeholders on responsibilities.

## Kali Tools (Verification)

| Check | Tool | Command |
|-------|------|---------|
| Port closure | `nmap` | `nmap -sV -p <port> lab-target` |
| Web vuln fix | `nikto`, `nuclei` | `nuclei -u https://target -t <template>.yaml` |
| SQL fix | `sqlmap` | `sqlmap -u "https://target/page?id=1" --batch \| grep "not injectable"` |
| TLS fix | `sslscan` | `sslscan target \| grep -E "(SSLv\|TLSv)"` |
| Code fix | `semgrep` | `semgrep --config "p/owasp-top-ten" ./src/` |
| Config diff | `diff` | `diff before.conf after.conf` |

## Command Examples

```bash
nmap -sV -p 443 lab-target
nuclei -u https://target -t cves/
sqlmap -u "https://target/page?id=1" --batch | grep "not injectable"
sslscan target | grep -E "(SSLv|TLSv)"
semgrep --config "p/owasp-top-ten" ./src/
diff before.conf after.conf
```

## Output Interpretation

### nmap before/after output
- Key indicators: vulnerable port state transition (`open` -> `closed|filtered`) and service banner removal.
- Example output snippet (1-3 lines)
  ```text
  BEFORE: 8080/tcp open  http-proxy
  AFTER:  8080/tcp closed http-proxy
  ```
- What it means: closed/filtered post-fix indicates exposure reduction; verify this matches intended architecture.

### nuclei re-scan output
- Key indicators: prior template IDs absent on re-test, no critical/high matches on fixed asset.
- Example output snippet (1-3 lines)
  ```text
  [INF] No results found. Better luck next time!
  ```
- What it means: no matches is expected after patching; investigate if templates still trigger to confirm incomplete remediation.

### sqlmap re-test output
- Key indicators: parameter reported as not injectable and payload tests failing safely.
- Example output snippet (1-3 lines)
  ```text
  Parameter 'id' does not seem to be injectable
  ```
- What it means: injection path likely remediated; cross-check with manual negative tests to avoid false assurance.

## Recommended Plan Template
- Vulnerability Reference:
- Root Cause Summary:
- Option Analysis Table:
- Recommended Strategy:
- Implementation Steps:
- Responsible Teams/Owners:
- Timeline and Milestones:
- Rollback Plan:
- Verification Criteria:
- Regression Testing Plan:
- Monitoring and Alerting Plan:
- Residual Risk and Exceptions:

## Verification
- [ ] At least two remediation options evaluated with rationale.
- [ ] Prioritization is risk-based and documented.
- [ ] Recommended plan includes owners and timeline.
- [ ] Rollback triggers/procedures are explicit.
- [ ] Verification criteria clearly prove remediation success.
- [ ] Regression testing scope is defined and feasible.
- [ ] Monitoring covers pre-fix exploitation detection.
- [ ] Residual risk is documented when applicable.

## Anti-Patterns
- Choosing a single fix path without alternatives.
- Omitting rollback because change appears "low risk".
- Defining success as "deployed" instead of "verified fixed".
- Ignoring regressions introduced by hardening changes.
- Delaying remediation without compensating controls.

## Deliverables
- Prioritized remediation plan document.
- Option comparison matrix.
- Verification and regression criteria.
- Monitoring and rollback procedures.

## Exit Criteria
Plan is complete when it is prioritized, actionable, owner-assigned, time-bounded, verifiable, and operationally safe.

## Safety Guardrails
- **LAB-ONLY**: All fix testing and validation MUST occur in isolated lab environments
- **NO WEAPONIZATION**: Remediation documentation must not enable attack reproduction
- **AUTHORIZATION**: Verify authorization before implementing any fixes in target environments
- **LOGGING**: All remediation actions must be logged and timestamped
- **REVERSIBILITY**: All fixes must include rollback procedures
