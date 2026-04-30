# Investigation Lifecycle

## Vue d’ensemble

Cycle V1 orienté investigation cybersécurité, dérivé du framework Samourai:

1. Intake & triage
2. Reconnaissance
3. Discovery de vulnérabilités
4. Analyse de vulnérabilités
5. Intelligence CVE
6. Évaluation de l’exploitabilité
7. Développement PoC (safe)
8. Validation PoC
9. Collecte de preuves
10. Reporting
11. Remédiation
12. Peer review
13. Publication

## Entrées et sorties par phase

### 1) Intake triage (`@pm`)

- Entrée: signalement, cible, backlog sécurité
- Sortie: périmètre autorisé + classification + `workItemRef`

### 2) Reconnaissance (`@attack-surface-agent`)

- Entrée: scope validé
- Sortie: cartographie de surface d’attaque (`chg-<workItemRef>-recon.*`)

### 3) Vulnerability discovery (`@bug-hunting-agent`)

- Entrée: reconnaissance
- Sortie: findings initiaux (`chg-<workItemRef>-findings.*`)

### 4) Vulnerability analysis (`@vulnerability-analysis-agent`)

- Entrée: findings
- Sortie: causes racines et impacts validés (`chg-<workItemRef>-analysis.*`)

### 5) CVE intelligence (`@cve-intelligence-agent`)

- Entrée: analyse technique
- Sortie: corrélation CVE/CWE + veille (`chg-<workItemRef>-cve-intel.*`)

### 6) Exploitability assessment (`@exploitability-agent`)

- Entrée: analyse + intelligence
- Sortie: scoring CVSS/EPSS et justification (`chg-<workItemRef>-exploitability.*`)

### 7) PoC development (`@safe-poc-agent`)

- Entrée: scénario validé
- Sortie: PoC en environnement isolé + protocole d’exécution

### 8) PoC validation (`@reviewer`/`@runner`)

- Entrée: PoC
- Sortie: reproductibilité et sécurité validées (logs + traces)

### 9) Evidence collection (`@evidence-agent`)

- Entrée: logs, captures, résultats PoC
- Sortie: package de preuves structuré, hashé, horodaté

### 10) Reporting (`@cve-report-agent`)

- Entrée: package d’évidence + scoring
- Sortie: rapport de vulnérabilité prêt à divulgation (`chg-<workItemRef>-report.*`)

### 11) Remediation (`@remediation-agent`)

- Entrée: finding validé + rapport
- Sortie: recommandations de correction + validation d’efficacité

### 12) Peer review (`@reviewer`)

- Entrée: dossier complet (finding + PoC + preuves + rapport)
- Sortie: validation finale ou actions de reprise

### 13) Publication (`@pr-manager` + humain)

- Entrée: dossier validé
- Sortie: publication/divulgation orchestrée et tracée

## Réouverture de phase

Les phases peuvent être rouvertes si une lacune est détectée plus tard:

- Si la validation PoC échoue: retour à `poc_development`
- Si le peer review trouve un défaut de preuve: retour à `evidence_collection`
- Si le scoring est incohérent: retour à `exploitability_assessment`
- Si la remédiation ne couvre pas la cause racine: retour à `vulnerability_analysis`
