# Decision Records

Decision records for all decision types: ADR (Architecture), PDR (Product), TDR (Technical), BDR (Business), and ODR (Operational).

## Purpose

This directory contains the project's decision records — durable artifacts that capture the context, drivers, alternatives, and rationale behind significant decisions. They serve as:

- **Historical reference** — understand why decisions were made
- **Onboarding aid** — new team members learn the reasoning behind the current architecture
- **Change triggers** — when context changes, review existing decisions for relevance

## Naming Convention

```
<TYPE>-<zeroPad4>-<slug>.md
```

Examples:
- `ADR-0001-event-bus-selection.md`
- `PDR-0001-free-tier-scope.md`
- `TDR-0001-state-management-library.md`

## Lifecycle

Proposed → Under Review → Accepted → (Deprecated | Superseded)

## References

- [Decision Records Management Guide](../guides/decision-records-management.md) — full standard including governance, types, and lifecycle
- [Decision Record Template](../templates/decision-record-template.md) — template for authoring new records
- `.samourai/docai/documentation-handbook.md` — repository documentation standard
