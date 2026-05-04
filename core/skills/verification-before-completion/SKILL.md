---
name: verification-before-completion
description: Use when about to claim work is complete, fixed, or passing, before committing or creating PRs - requires running verification commands and confirming output before making any success claims; evidence before assertions always
---

# Verification Before Completion

## Overview

Claiming security work is complete without verification is a process failure, not efficiency.

**Core principle:** Evidence before claims, always.

**Violating the letter of this rule is violating the spirit of this rule.**

## The Iron Law

```
NO COMPLETION CLAIMS WITHOUT FRESH VERIFICATION EVIDENCE
```

If you haven't run the verification command in this message, you cannot claim it passes.

## The Gate Function

```
BEFORE claiming any status or expressing satisfaction:

1. IDENTIFY: What command proves this claim?
2. RUN: Execute the FULL command (fresh, complete)
3. READ: Full output, check exit code, count failures
4. VERIFY: Does output confirm the claim?
   - If NO: State actual status with evidence
   - If YES: State claim WITH evidence
5. ONLY THEN: Make the claim

Skip any step = lying, not verifying
```

## Common Failures

| Claim | Requires | Not Sufficient |
|-------|----------|----------------|
| Vulnerability confirmed | Fresh POC run reproduces expected behavior | Old screenshots, one-off anomaly |
| Remediation complete | Original exploit re-run now fails as expected | Config changed, assumed fixed |
| Evidence package complete | Hashes/timestamps/artifact paths verified | "Files are there" assumption |
| Finding reproducible | Independent re-run matches documented steps | "Worked once" memory |
| Scope respected | Logs/commands show authorized targets only | Verbal claim without audit trail |
| Agent completed | VCS diff shows changes | Agent reports "success" |
| Requirements met | Line-by-line checklist | Tests passing |

## Red Flags - STOP

- Using "should", "probably", "seems to"
- Expressing satisfaction before verification ("Great!", "Perfect!", "Done!", etc.)
- About to commit/push/PR without verification
- Trusting agent success reports
- Relying on partial verification
- Thinking "just this once"
- Tired and wanting work over
- **ANY wording implying success without having run verification**

## Rationalization Prevention

| Excuse | Reality |
|--------|---------|
| "Should work now" | RUN the verification |
| "I'm confident" | Confidence ≠ evidence |
| "Just this once" | No exceptions |
| "One payload worked" | Re-run to prove reproducibility |
| "Agent said success" | Verify independently |
| "I'm tired" | Exhaustion ≠ excuse |
| "Partial check is enough" | Partial proves nothing |
| "Different words so rule doesn't apply" | Spirit over letter |

## Key Patterns

**Vulnerability confirmation:**
```
✅ [Re-run POC] [See expected vulnerable behavior] "Vulnerability confirmed"
❌ "Looks exploitable" / "Probably vulnerable"
```

**Remediation verification:**
```
✅ Run original exploit before fix (works) → apply remediation → re-run exploit (fails) → document both outputs
❌ "Patch applied so issue is fixed"
```

**Evidence integrity:**
```
✅ Verify artifact hashes + timestamps + chain-of-custody notes present
❌ "Screenshots/logs exist somewhere"
```

**Requirements:**
```
✅ Re-read plan → Create checklist → Verify each → Report gaps or completion
❌ "Tests pass, phase complete"
```

**Agent delegation:**
```
✅ Agent reports success → Check VCS diff → Verify changes → Report actual state
❌ Trust agent report
```

## Why This Matters

Security conclusions drive risk decisions. Unverified claims can produce false confidence, missed exposure, and expensive rework during incident response or remediation.

## When To Apply

**ALWAYS before:**
- ANY variation of success/completion claims
- ANY expression of satisfaction
- ANY positive statement about work state
- Committing, PR creation, task completion
- Moving to next task
- Delegating to agents
- Declaring a finding confirmed/exploitable
- Declaring a fix validated/closed
- Handing off evidence to stakeholders

**Rule applies to:**
- Exact phrases
- Paraphrases and synonyms
- Implications of success
- ANY communication suggesting completion/correctness

## The Bottom Line

**No shortcuts for verification.**

Run the command. Read the output. THEN claim the result.

This is non-negotiable.

## Tools Used

- Primary mode: no direct offensive tool execution; this skill governs planning, coordination, review, or delivery around Kali-generated evidence.
- Kali evidence consumed or delegated: `nmap`, `nuclei`, `nikto`, `sqlmap`, `ffuf`, `gobuster`, `tcpdump`, `tshark`, `searchsploit`, `semgrep`.
- Preflight command when tool-dependent evidence is required: `command -v nmap nuclei nikto sqlmap ffuf gobuster tcpdump searchsploit semgrep || true`.
- Missing-tool behavior: record `missing_tools`, delegate execution/readiness to the correct agent, or stop with `NEEDS_TOOLING` before making technical claims.

## Command Examples

```bash
command -v nmap nuclei nikto sqlmap ffuf gobuster tcpdump searchsploit semgrep || true
rg -n "nmap|nuclei|nikto|sqlmap|ffuf|gobuster|tcpdump|searchsploit|semgrep" .samourai/docai .samourai/tmpai core || true
sha256sum EVIDENCE_ARTIFACT
```

## Result Interpretation

Use this skill to verify that Kali-derived evidence is present, scoped, reproducible, and routed to the right downstream artifact. Do not treat unsupported scanner output as a confirmed vulnerability.

Interpretation rules:
- Treat scanner output as a lead until independently reproduced.
- Separate confirmed facts from inferred hypotheses.
- Record false-positive risk and evidence path for every result.
- Prefer French for summaries, reports, and final investigation artifacts.
