# Copywriting Guidelines

## Purpose

This guide defines writing conventions for security investigations, vulnerability reports, and disclosure artifacts.

## Core Conventions

- Use precise technical language and standard identifiers.
- Keep descriptions factual, neutral, and reproducible.
- Prioritize clarity, traceability, and risk communication quality.

## Security Writing Standards

### 1) Precision and Referencing

- Use canonical references whenever possible:
  - CVE IDs (e.g., `CVE-2026-12345`)
  - CWE mappings (e.g., `CWE-79`)
  - CVSS vectors (e.g., `CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H`)
  - EPSS values and timestamps when available
- Distinguish clearly between:
  - confirmed facts
  - analyst assumptions
  - hypotheses requiring further validation

### 2) Tone and Framing

- Avoid sensationalism (e.g., "catastrophic", "total compromise") unless objectively justified by evidence.
- Use neutral, factual language in all technical and executive summaries.
- Prefer measurable impact statements over dramatic wording.

### 3) Responsible Disclosure Language

- Follow responsible disclosure norms:
  - describe risk without publishing unnecessary weaponizable detail
  - communicate timelines and coordination status explicitly
  - separate private remediation detail from public disclosure text
- Use explicit qualifiers for embargoed or restricted information.

### 4) Sanitization and Data Handling

- Sanitize sensitive details in public-facing documents:
  - credentials, tokens, secrets
  - internal hostnames/IPs not approved for publication
  - customer-identifying data and personal data
- Use redaction markers consistently (e.g., `[REDACTED]`).
- Confirm that screenshots, logs, and stack traces are sanitized before publication.

### 5) Reproducibility and Evidence Clarity

- Reproduction steps must be deterministic and scoped.
- Every claim should map to evidence artifacts (logs, traces, hashes, timestamps).
- When uncertainty exists, state it explicitly and include next verification steps.

## Recommended Structure for Vulnerability Reports

1. Summary
2. Affected scope and prerequisites
3. Technical details (root cause)
4. Reproduction steps
5. Impact assessment (CVSS/EPSS + rationale)
6. Evidence references
7. Remediation recommendations
8. Disclosure notes and timeline

## Editorial Workflow

- Draft by domain specialist agent (e.g., `@cve-report`).
- Optional editorial pass by `@editor` for readability and consistency.
- Mandatory technical validation by `@reviewer` before publication.

## Anti-Patterns to Avoid

- Overstating impact without evidence.
- Omitting scope/preconditions from exploit claims.
- Mixing confirmed findings and speculative content without labels.
- Publishing sensitive details that are not required for understanding risk.
