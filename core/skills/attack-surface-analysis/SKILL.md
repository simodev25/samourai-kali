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

## Safety Guardrails
- LAB-ONLY unless a signed authorization explicitly permits the target.
- NO WEAPONIZATION: do not develop or deploy offensive payloads in this phase.
- Respect provider and customer terms of engagement, including prohibited techniques.
- Minimize operational impact with conservative scan rates and retry settings.
- Stop and escalate any accidental sensitive data exposure to authorized stakeholders only.
