---
id: SPEC-<feature-slug>                  # e.g., SPEC-TENANTS, SPEC-BILLING
status: Current                          # Current | Deprecated
created: <YYYY-MM-DD>
last_updated: <YYYY-MM-DD>
owners: [<team-or-person>]
service: <primary-service>
links:
  related_changes: []                    # workItemRef identifiers that created/modified this spec
  decisions: []                          # Decision record IDs (e.g., ADR-0001)
  contracts: []                          # Paths to related contracts
---

<!-- TEMPLATE INSTRUCTIONS
1. Copy this file to .samourai/docai/spec/features/feature-<slug>.md
2. Replace all <...> placeholders with actual values
3. Remove these instructions before finalizing
4. This is the "source of truth" for a specific system feature — describe current behavior in present tense
-->

# Security Finding Specification: <Finding Name>

> **Role of this Document:** Source of truth for a specific security finding. Captures current vulnerability state, impact context, attack surface mapping, and operational details. Serves as the baseline for understanding the finding and planning remediation.

## 1. Overview

<!-- One-paragraph summary: What is this security finding, who is affected, and what risk does it introduce? -->

## 2. Business Context

### 2.1 Problem Statement

<!-- - **Problem:** Description of the vulnerability condition
     - **Affected Users/Systems:** Exposed personas, assets, or services
     - **Business Impact:** Consequences if vulnerability remains unaddressed -->

### 2.2 Goals & Success Metrics

<!-- - **Primary Goal:** Main measurable objective
     - **KPIs:** Metric → Baseline → Target -->

## 3. Vulnerability Context & Behavior

### 3.1 Current Vulnerability State

<!-- Bulleted list of current vulnerable behavior:
- **State 1:** Description
- **State 2:** Description
-->

### 3.2 Exploitation Flows

<!-- Primary attacker/victim journeys. Use Mermaid diagrams for complex logic. -->

### 3.3 Vulnerability Details

<!-- CWE/CVSS, affected versions, entry points, and constraints -->

### 3.4 Edge Cases & Failure Conditions

<!-- Network failures, validation rules, concurrency, empty states -->

## 4. Technical Architecture & Attack Surface Mapping

### 4.1 High-Level Attack Surface

<!-- Brief architectural pattern description -->

### 4.2 Exposed Components & Directory Structure

<!-- Table: Path | Component | Responsibility -->

### 4.3 Key Classes, Functions, and Entry Points

<!-- Key code artifacts where the logic lives -->

### 4.4 Data and Trust Boundaries

<!-- Entities, schema, storage, data flow -->

### 4.5 API & Interface Exposure

<!-- Endpoints, events, external integrations -->

## 5. Non-Functional Requirements

### 5.1 Security & Privacy

<!-- Auth, data protection, compliance -->

### 5.2 Performance & Scalability

<!-- Latency targets, throughput, caching -->

### 5.3 Localization & Accessibility

<!-- a11y, i18n considerations -->

## 6. Validation Strategy

### 6.1 Validation Approach

<!-- Table: Level | Location | Scope/Goal -->

### 6.2 Evidence Data & Scenarios

<!-- Critical scenarios, test data seeding -->

## 7. Operational & Support

### 7.1 Configuration

<!-- Feature flags, environment variables -->

### 7.2 Observability

<!-- Key logs, metrics, dashboards -->

### 7.3 Cost & Infrastructure

<!-- Infrastructure, cost drivers -->

## 8. Dependencies & Risks

<!-- Internal and external dependencies, known risks -->

## 9. Glossary & References

<!-- Terms, links to decision records, related specs, version history -->
