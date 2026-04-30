---
name: bug-hunting-analysis
description: "Structured vulnerability hunting workflow aligned with OWASP Top 10."
---

# Bug Hunting Analysis

Apply this skill to run disciplined, repeatable vulnerability hunting after attack surface mapping is complete.

<HARD-GATE>
- Do not begin class-based testing until attack surface mapping is finalized.
- Every claimed vulnerability must be reproducible with clear evidence.
- Test only approved assets and approved vulnerability classes within engagement scope.
- Maintain a traceable test log: target, method, timestamp, and outcome.
</HARD-GATE>

## Use When
- Attack surface mapping is complete and validated
- You need to hunt for specific vulnerability classes
- You are prioritizing OWASP Top 10 coverage
- You are converting exploratory testing into a structured campaign
- You need triaged, deduplicated findings for reporting

## Procedure
1. Review the attack surface map and identify high-value assets (auth flows, admin panels, payment/data APIs).
2. Define a testing matrix mapped to OWASP Top 10 categories and target components.
3. Prioritize vulnerability classes by business impact, exposure, and likelihood.
4. Prepare test cases per class, including positive/negative controls and expected secure behavior.
5. Configure tools and interception proxies with safe defaults, scope filters, and logging enabled.
6. Execute injection testing: SQLi, XSS, command injection, SSTI, LDAP injection, XXE.
7. Execute authentication testing: brute-force resistance, MFA bypass checks, session lifecycle, token integrity.
8. Execute authorization testing: IDOR, horizontal/vertical privilege escalation, access control bypass.
9. Execute configuration/security-hardening checks: default creds, debug interfaces, verbose errors, information disclosure.
10. Capture evidence for each potential finding: request/response pairs, payload, context, observed behavior.
11. Validate reproducibility with independent rerun under the same preconditions.
12. Classify findings with type, CWE, affected location, severity, and exploitation conditions.
13. Deduplicate overlapping findings by root cause and affected surface.
14. Prioritize by risk and remediation urgency, noting likely exploit paths and blast radius.
15. Produce a structured findings register ready for deeper vulnerability analysis and reporting.

## Kali Tools

| Vuln Class | Tool | Command |
|------------|------|---------|
| SQL Injection | `sqlmap` | `sqlmap -u "https://target/page?id=1" --batch --dbs` |
| XSS | `dalfox`, XSStrike | `dalfox url "https://target/search?q=test"` |
| Command Injection | `commix` | `commix -u "https://target/ping?ip=127.0.0.1"` |
| Directory traversal | `ffuf` | `ffuf -u https://target/FUZZ -w /usr/share/wordlists/dirb/common.txt` |
| Vuln scanning | `nuclei` | `nuclei -u https://target -severity critical,high` |
| Web scanning | `nikto` | `nikto -h https://target -Format json` |
| Auth brute force | `hydra` | `hydra -l admin -P /usr/share/wordlists/rockyou.txt target http-post-form` |
| TLS/SSL | `sslscan`, `testssl.sh` | `sslscan target`, `testssl.sh target` |
| SAST | `semgrep`, `bandit` | `semgrep --config=auto ./src/`, `bandit -r ./src/` |
| Secrets | `trufflehog` | `trufflehog filesystem --directory=./src/` |

## Command Examples

```bash
sqlmap -u "https://target/page?id=1" --batch --dbs
dalfox url "https://target/search?q=test"
commix -u "https://target/ping?ip=127.0.0.1"
ffuf -u https://target/FUZZ -w /usr/share/wordlists/dirb/common.txt
nuclei -u https://target -severity critical,high
nikto -h https://target -Format json
hydra -l admin -P /usr/share/wordlists/rockyou.txt target http-post-form
sslscan target
testssl.sh target
semgrep --config=auto ./src/
bandit -r ./src/
trufflehog filesystem --directory=./src/
```

## Verification
- [ ] OWASP Top 10 coverage matrix exists and is complete for in-scope components
- [ ] High-value targets were explicitly selected and justified
- [ ] Injection, authentication, authorization, and config checks were executed
- [ ] Each finding includes CWE mapping and precise affected location
- [ ] Reproduction steps are documented and independently verified
- [ ] Evidence artifacts are attached (HTTP traces, logs, screenshots where relevant)
- [ ] Duplicate findings were merged with clear root-cause linkage
- [ ] Final prioritization reflects impact and exploitability, not just scanner output

## Anti-Patterns
- Running tools without a testing matrix or objective coverage plan
- Skipping difficult categories (authz/authn) and over-focusing on reflected XSS
- Reporting scanner noise as confirmed vulnerabilities
- Claiming severity without validating real impact or exploit path
- Failing to retest and verify reproduction before reporting
- Mixing out-of-scope endpoints into findings to inflate results

## Safety Guardrails
- LAB-ONLY unless legal authorization exists for the exact target and method.
- NO WEAPONIZATION: no persistence, no payloads intended for destructive outcomes.
- Avoid denial-of-service behavior; keep tests controlled and minimally disruptive.
- Do not access or exfiltrate sensitive data beyond proof-of-concept minimum.
- Immediately report unintended exposure or instability through approved channels.
