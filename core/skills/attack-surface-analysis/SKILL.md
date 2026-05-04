---
name: attack-surface-analysis
description: "Systematic methodology to map and classify a target attack surface."
---

# Attack Surface Analysis

Use this skill to build a complete, evidence-based view of reachable assets before any vulnerability testing.

<HARD-GATE>
- Only perform activities that are explicitly authorized in writing.
- Never run active scans before passive recon and scope confirmation are complete.
- Stop immediately if a discovered host/domain/IP is out of scope.
- Keep all output and notes in approved project storage with timestamps.
</HARD-GATE>

## Use When
- Starting a new target investigation
- Beginning a penetration test engagement
- Preparing for bug bounty work on an approved program
- Before any active testing or exploitation attempts
- Re-baselining target exposure after major infra changes

## Procedure
1. Obtain and validate the scope authorization document (owner, dates, in-scope assets, forbidden actions).
2. Build a scope inventory table with domains, subdomains, IP ranges, applications, APIs, and cloud assets.
3. Run passive recon on in-scope assets: WHOIS, registrar details, ASN info, DNS records, and historical DNS.
4. Query certificate transparency logs to enumerate additional hostnames and validate ownership linkage.
5. Perform OSINT collection from public sources (GitHub, docs, job posts, metadata leaks) without active probing.
6. Normalize passive findings and de-duplicate hostnames, IPs, and service hints into a single asset list.
7. Plan active scanning windows and rate limits to respect scope, stability, and legal boundaries.
8. Execute controlled active scanning using `nmap -sV -sC` against authorized targets only.
9. Identify exposed services by port/protocol/version and record confidence level for each fingerprint.
10. Perform technology fingerprinting for web targets (server, framework, CMS, language, middleware).
11. Enumerate endpoints using directory discovery, API route discovery, robots.txt, and sitemap analysis.
12. Map third-party dependencies: CDNs, analytics scripts, SaaS integrations, external auth providers.
13. Trace trust boundaries and data flows between internal components and external services.
14. Classify each entry point risk (Critical/High/Medium/Low/Info) using exposure, sensitivity, and exploitability.
15. Produce a structured attack surface map (assets, services, endpoints, dependencies, risk tags, notes).
16. Review completeness and reconcile against original scope to ensure nothing unauthorized is included.

## Kali Tools

| Phase | Tool | Command |
|-------|------|---------|
| WHOIS/DNS | `whois`, `dig` | `whois example.com`, `dig example.com ANY` |
| Subdomain enum | `amass`, `subfinder` | `amass enum -passive -d example.com`, `subfinder -d example.com` |
| OSINT | `theHarvester` | `theHarvester -d example.com -b all` |
| Port scan | `nmap`, `masscan` | `nmap -sV -sC -O -Pn -oA results <target>` |
| Web fingerprint | `whatweb`, `wafw00f` | `whatweb -a 3 https://target`, `wafw00f https://target` |
| Dir enum | `gobuster`, `ffuf` | `gobuster dir -u https://target -w /usr/share/wordlists/dirb/common.txt` |
| Web scan | `nikto` | `nikto -h https://target -output nikto.txt` |

## Command Examples

```bash
whois example.com
dig example.com ANY
amass enum -passive -d example.com
subfinder -d example.com
theHarvester -d example.com -b all
nmap -sV -sC -O -Pn -oA results target.example.com
whatweb -a 3 https://target.example.com
wafw00f https://target.example.com
gobuster dir -u https://target.example.com -w /usr/share/wordlists/dirb/common.txt
nikto -h https://target.example.com -output nikto.txt
```

## Output Interpretation

### nmap output
- Key indicators: `open` ports, detected `service/version`, and `OS details` confidence.
- Example output snippet (1-3 lines)
  ```text
  80/tcp open  http  Apache httpd 2.4.57
  OS details: Linux 5.4 - 5.15
  ```
- What it means: exposed service is reachable; version and OS hints drive vulnerability matching and targeting confidence.

### amass output
- Key indicators: discovered subdomains, ASN/IP linkage, and repeated assets across sources.
- Example output snippet (1-3 lines)
  ```text
  api.example.com
  dev-admin.example.com
  ```
- What it means: each new hostname is a potential entry point; prioritize internet-facing and auth-related subdomains first.

### whatweb output
- Key indicators: web server, framework/CMS, plugin/module fingerprints.
- Example output snippet (1-3 lines)
  ```text
  https://target [200 OK] Apache[2.4.57], PHP[8.1.2], WordPress[6.4]
  ```
- What it means: technology stack narrows exploit classes (e.g., CMS/plugin CVEs) and guides focused testing.

### gobuster output
- Key indicators: discovered paths with status codes (200/301/403) and endpoint naming patterns.
- Example output snippet (1-3 lines)
  ```text
  /admin (Status: 302)
  /backup (Status: 200)
  ```
- What it means: 200/302 paths are actionable attack surface; 403 still proves resource existence and access-control target.

## Verification
- [ ] Scope authorization is present, current, and explicitly covers all tested assets
- [ ] Passive recon artifacts are captured and referenced
- [ ] Active scanning logs show only in-scope targets and approved scan profile
- [ ] Service inventory includes ports, protocols, versions, and confidence notes
- [ ] Technology stack is identified for all primary web/API assets
- [ ] Endpoint enumeration includes web paths, API routes, and discovery sources
- [ ] Third-party dependencies and trust boundaries are documented
- [ ] Every entry point has a risk classification with rationale
- [ ] Final attack surface map is structured, versioned, and review-ready

## Anti-Patterns
- Starting nmap or brute-force enumeration without written authorization
- Expanding from one subdomain to entire ASN without explicit scope approval
- Treating passive recon as optional and jumping straight to active scans
- Ignoring wildcard DNS and certificate-derived assets during discovery
- Failing to de-duplicate results, causing blind spots and noisy prioritization
- Assigning risk labels without consistent criteria or evidence

## Tools Used

- Primary Kali/tools: `nmap`, `masscan`, `amass`, `subfinder`, `theHarvester`, `whatweb`, `wafw00f`, `gobuster`, `ffuf`, `nikto`, `curl`.
- Preflight command: `command -v nmap masscan amass subfinder theHarvester whatweb wafw00f gobuster || true`.
- Missing-tool behavior: record `missing_tools`, choose a safe fallback when available, or stop with `NEEDS_TOOLING` before making technical claims.
- Scope behavior: every active command must use only authorized lab targets and must write logs/evidence under `.samourai/tmpai/` or the approved change folder.

## Command Examples

```bash
nmap -sV -sC -Pn --top-ports 1000 -oA .samourai/tmpai/recon/nmap-safe TARGET
amass enum -passive -d DOMAIN -o .samourai/tmpai/recon/amass.txt
gobuster dir -u https://TARGET -w /usr/share/wordlists/dirb/common.txt -t 10 -o .samourai/tmpai/recon/gobuster.txt
```

## Result Interpretation

Attack surface map: assets, ports, services, technologies, endpoints, confidence, evidence path, and next recommended agent.

Interpretation rules:
- Treat scanner output as a lead until independently reproduced.
- Separate confirmed facts from inferred hypotheses.
- Record false-positive risk and evidence path for every result.
- Prefer French for summaries, reports, and final investigation artifacts.
