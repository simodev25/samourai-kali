# Security Policy: <scope>

## Scope

<scope>

## Sensitive Data

- Secrets, tokens, API keys, cookies, credentials.
- Personal or contractual data.
- Logs containing sensitive information.

## Agent Rules

- Never read, display, store, or copy secrets.
- Mask any sensitive value observed accidentally.
- Ask for approval before GitHub, Jira, CI/CD, publishing, or deployment.
- Ask for approval before deletion, reset, overwrite, merge, or rebase.

## Sensitive Actions

| Action | Approval Required | Notes |
| --- | --- | --- |
| <action> | yes | <notes> |

## Verification

```bash
<security_check_command>
```

## CVE Submission Policy

- Submission authority: <team_or_owner>
- CNA or channel: <cna_or_submission_channel>
- Required package: <reproduction_summary_impact_versions_cvss_cwe>

## Responsible Disclosure Timeline

| Milestone | Target Date | Owner |
| --- | --- | --- |
| Vendor notification | <YYYY-MM-DD> | <owner> |
| Remediation confirmation | <YYYY-MM-DD> | <owner> |
| Public disclosure | <YYYY-MM-DD> | <owner> |

## Lab Environment Requirements

- Isolated lab network with controlled ingress/egress.
- Non-production data only; no real customer secrets.
- Snapshot/restore capability before and after validation.
- Cleanup procedure documented for every POC execution.

## Escalation

Contact: <owner_or_team>
