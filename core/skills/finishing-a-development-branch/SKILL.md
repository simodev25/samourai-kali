---
name: finishing-a-development-branch
description: "Guide completion of a security investigation — verify evidence, present reporting options"
---

# Finishing an Investigation

## Overview

Guide completion of security investigation work by presenting clear reporting options and handling the chosen workflow.

**Core principle:** Verify evidence → Present options → Execute choice → Archive/cleanup.

**Announce at start:** "I'm using the finishing-a-development-branch skill to complete this investigation."

## The Process

### Step 1: Verify Evidence

**Before presenting options, verify evidence is complete and validated:**

- Reproducible proof available
- Safety constraints validated
- Severity rationale (if applicable) documented
- Artifacts linked and readable

**If evidence incomplete:**
```
Evidence incomplete (<N> gaps). Must resolve before reporting:

[Show gaps]

Cannot proceed to reporting options until evidence is validated.
```

Stop. Don't proceed to Step 2.

### Step 2: Determine Reporting Context

Identify audience and disclosure scope:
- Internal security team?
- External vendor?
- Public disclosure path?

Or ask: "Is this intended for internal advisory, vendor disclosure, or public CVE workflow?"

### Step 3: Present Options

Present exactly these 4 options:

```
Investigation complete. What would you like to do?

1. Submit for CVE consideration
2. Create internal advisory
3. Notify vendor privately
4. Archive investigation without disclosure

Which option?
```

**Don't add explanation** — keep options concise.

### Step 4: Execute Choice

#### Option 1: Submit CVE Consideration

- Prepare standardized vulnerability summary
- Include reproducible proof and impact scope
- Submit via approved CVE CNA workflow
- Record submission reference

#### Option 2: Internal Advisory

- Create internal advisory with severity and remediation guidance
- Attach evidence and reproduction steps
- Notify relevant internal stakeholders

#### Option 3: Vendor Notification

- Prepare private disclosure package
- Include safe reproduction details and impact boundaries
- Send through vendor security contact channel
- Record disclosure timestamp and contact reference

#### Option 4: Archive

**Confirm first:**
```
This will archive the investigation as non-disclosed:
- Investigation branch/context
- Evidence artifacts
- Draft findings

Type 'archive' to confirm.
```

Wait for exact confirmation.

If confirmed:
- Mark outcome as archived/non-disclosed
- Preserve evidence for audit trail

### Step 5: Cleanup / Retention

For Options 1, 2, 3:
- Keep investigation artifacts in retained location
- Ensure report links resolve

For Option 4:
- Keep minimal audit trail and archive bundle

## Quick Reference

| Option | External Disclosure | Internal Stakeholders | Preserve Artifacts | Archive Outcome |
|--------|---------------------|-----------------------|--------------------|-----------------|
| 1. CVE submission | ✓ | optional | ✓ | - |
| 2. Internal advisory | - | ✓ | ✓ | - |
| 3. Vendor notification | ✓ (private) | optional | ✓ | - |
| 4. Archive | - | optional | ✓ (minimal) | ✓ |

## Common Mistakes

**Skipping evidence validation**
- **Problem:** weak or disputed findings
- **Fix:** validate reproducibility and safety before options

**Open-ended next-step questions**
- **Problem:** ambiguous outcomes
- **Fix:** present exactly 4 structured options

**Archiving without confirmation**
- **Problem:** accidental loss of disclosure opportunity
- **Fix:** require typed "archive" confirmation

## Red Flags

**Never:**
- Report without validated evidence
- Escalate severity without proof
- Disclose unsafe POC details publicly
- Archive without explicit confirmation

**Always:**
- Verify evidence before offering options
- Present exactly 4 options
- Require typed confirmation for archive path
