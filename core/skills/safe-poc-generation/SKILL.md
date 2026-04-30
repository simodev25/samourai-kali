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

## Kali Tools

| POC Type | Tool | Example Command |
|----------|------|-----------------|
| Web (HTTP) | `curl` | `curl -s "https://lab-target/page?id=1' OR '1'='1"` |
| Web (fuzzing) | `ffuf` | `ffuf -u https://lab-target/FUZZ -w wordlist.txt` |
| Exploit framework | `msfconsole` | `msfconsole -q -x "use auxiliary/scanner/http/dir_listing; set RHOSTS lab; run; exit"` |
| NSE scripts | `nmap` | `nmap --script=http-vuln-cve2017-5638 -p 8080 lab-target` |
| Network | `netcat` | `nc -lvnp 4444` (lab listener) |
| Custom | `python3` | `python3 poc.py --target lab --safe-mode --log output.log` |

## Command Examples

```bash
curl -s "https://lab-target/page?id=1' OR '1'='1"
ffuf -u https://lab-target/FUZZ -w /usr/share/wordlists/dirb/common.txt
msfconsole -q -x "use auxiliary/scanner/http/dir_listing; set RHOSTS lab-target; run; exit"
nmap --script=http-vuln-cve2017-5638 -p 8080 lab-target
nc -lvnp 4444
python3 poc.py --target lab-target --safe-mode --log output.log
```

## Output Interpretation

### curl output
- Key indicators: HTTP status code, controlled error message, and reflected/injected marker in response body.
- Example output snippet (1-3 lines)
  ```text
  HTTP/1.1 500 Internal Server Error
  SQL syntax error near '1'='1'
  ```
- What it means: behavior indicates unsafe input handling; confirms vulnerability signal, not full compromise proof.

### msfconsole output
- Key indicators: module result, session type (meterpreter/shell), and privilege context.
- Example output snippet (1-3 lines)
  ```text
  Meterpreter session 1 opened
  uid=33(www-data)
  ```
- What it means: session success proves exploit path viability; access level shows impact boundary (service user vs root).

### nmap NSE output
- Key indicators: script ID result, `VULNERABLE` marker, and affected service endpoint.
- Example output snippet (1-3 lines)
  ```text
  | http-vuln-cve2017-5638:
  |   VULNERABLE: Apache Struts RCE
  ```
- What it means: NSE indicates likely vulnerable state; validate with a minimal non-destructive POC before final claim.

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

## Safety Guardrails
- **LAB-ONLY**: All testing and exploitation MUST occur in isolated lab environments
- **NO WEAPONIZATION**: POCs must be minimal and non-weaponizable
- **AUTHORIZATION**: Verify written scope authorization before any active testing
- **LOGGING**: All actions must be logged and timestamped
- **RESPONSIBLE DISCLOSURE**: Follow responsible disclosure for any findings

## Deliverables
- POC script or command set with mandatory safety header.
- Execution notes with expected output, actual output, and interpretation.
- Cleanup/rollback guide.
- Traceability metadata committed with the POC.

