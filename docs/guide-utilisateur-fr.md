# Guide utilisateur Samourai Kali

Ce guide présente l'installation et l'utilisation de Samourai Kali dans un
environnement de cybersécurité. Il s'adresse à des pentesters, vulnerability
researchers et security analysts qui veulent structurer leur travail avec des
agents IA spécialisés.

## Périmètre

Samourai Kali installe un cadre de travail assisté par IA dans un environnement
de sécurité :

- agents cyber spécialisés (recon, hunting, analysis, POC, evidence, reporting) ;
- commandes de workflow d'investigation ;
- skills basés sur les outils Kali Linux réels ;
- conventions de gouvernance et garde-fous éthiques ;
- templates de reporting CVE-ready ;
- adapters pour OpenCode et VS Code/GitHub Copilot.

Le kit ne remplace pas l'expertise humaine en sécurité. Il structure le travail,
automatise les tâches répétitives et garantit la traçabilité des preuves.



## Modèle d'installation

Identique au modèle original (core/, adapters, blueprints). Voir le README.md
pour les détails d'installation.

### Core

```text
core/agents/       → agents cyber (attack-surface, bug-hunting, etc.)
core/commands/     → commandes d'investigation
core/skills/       → skills basés sur outils Kali
core/governance/   → policies, lifecycle, permissions
core/templates/    → templates de reporting
core/decisions/    → décisions de sécurité (SDR)
```

### Artefacts investigation

Les documents produits pendant les investigations vont sous `.samourai/docai/` :

```text
.samourai/docai/changes/    → dossiers d'investigation par vulnérabilité
.samourai/docai/spec/       → base de connaissances vulnérabilités
.samourai/docai/decisions/  → décisions de sécurité
```

Les fichiers temporaires (logs de scan, preuves brutes) :

```text
.samourai/tmpai/run-logs-runner/  → logs d'exécution des scans
.samourai/tmpai/code-review/      → résultats de revue de findings
.samourai/tmpai/pr/               → rapports pour publication
```

## Workflow d'investigation

Une investigation de vulnérabilité suit cet ordre :

```text
/plan-change <ref>          → cadrage de l'investigation
/write-spec <ref>           → spécification de la vulnérabilité
/write-test-plan <ref>      → plan de validation POC
/write-plan <ref>           → plan d'investigation
/run-plan <ref>             → exécution des phases (recon → analyse → POC → evidence)
/review <ref>               → revue par les pairs
/check                      → vérification qualité des preuves
/sync-docs <ref>            → archivage des preuves et findings
/commit                     → commit des artefacts
/pr                         → publication du rapport
```

Pour un ticket GitHub :

```text
/plan-change GH-42
/write-spec GH-42
/write-test-plan GH-42
/write-plan GH-42
/run-plan GH-42
/review GH-42
/check
/sync-docs GH-42
/commit
/pr
```

L'orchestration peut être déléguée au Mission Control :

```text
@pm investigate GH-42
```

## Rôles des agents

### Agents cyber (investigation)

| Agent | Responsabilité | Kali Tools |
|-------|----------------|------------|
| `@attack-surface-agent` | Cartographie de la surface d'attaque | nmap, masscan, amass, subfinder, whatweb, gobuster, nikto |
| `@bug-hunting-agent` | Recherche active de vulnérabilités | sqlmap, nuclei, ffuf, nikto, hydra, semgrep, sslscan |
| `@vulnerability-analysis-agent` | Analyse technique approfondie | burpsuite, zaproxy, tcpdump, strace, semgrep |
| `@cve-intelligence-agent` | Recherche CVE et intelligence | searchsploit, NVD API, EPSS API |
| `@exploitability-agent` | Scoring CVSS/EPSS | CVSS calculators, EPSS API |
| `@safe-poc-agent` | POC minimal et sécurisé  | curl, netcat, msfconsole, python3, nmap NSE |
| `@evidence-agent` | Collecte de preuves forensic-grade | sha256sum, tcpdump, tshark, script, scrot |
| `@cve-report-agent` | Rapport CVE conforme aux standards | Rédaction uniquement |
| `@remediation-agent` | Correctifs et vérification | nmap, nikto, nuclei, sqlmap, semgrep |

### Agents infrastructure

| Agent | Responsabilité |
|-------|----------------|
| `@pm` | Mission Control — orchestre l'investigation complète |
| `@architect` | Threat Modeling — STRIDE/DREAD, attack trees, trust boundaries |
| `@reviewer` | Revue par les pairs des findings, POC et rapports |
| `@runner` | Exécution de commandes et capture de logs |
| `@committer` | Commits Conventional Commit |
| `@pr-manager` | Publication de rapports |
| `@external-researcher` | Intelligence sécurité via MCP (NVD, exploit-db, advisories) |
| `@editor` | Rédaction technique sécurité (CVE, advisories, disclosure) |
| `@fixer` | Debugging et résolution de problèmes |
| `@toolsmith` | Création/modification d'agents, skills, commandes |
| `@image-reviewer` | Analyse de captures d'écran de vulnérabilités |
| `@code-reviewer` | Revue code : sécurité, vulnérabilités, fiabilité |

### Chaîne d'investigation typique

```text
pm → attack-surface-agent → bug-hunting-agent → vulnerability-analysis-agent
   → cve-intelligence-agent → exploitability-agent → safe-poc-agent
   → evidence-agent → cve-report-agent → reviewer → remediation-agent
```

### Exemples d'usage

```text
@attack-surface-agent map target 192.168.1.0/24 scope authorized
@bug-hunting-agent hunt for SQL injection on https://lab-target
@safe-poc-agent create POC for CVE-2024-1234 in lab environment
@evidence-agent collect and hash all artifacts for GH-42
@cve-report-agent generate CVE report for GH-42
@remediation-agent verify fix for SQL injection on lab-target
```

## Commandes disponibles

| Commande | Usage |
|----------|-------|
| `/bootstrap` | Configurer l'environnement de test (lab setup) |
| `/plan-change [ref]` | Cadrer une investigation avant analyse |
| `/write-spec <ref>` | Spécification de la vulnérabilité |
| `/write-test-plan <ref>` | Plan de validation du POC |
| `/write-plan <ref>` | Plan d'investigation |
| `/run-plan <ref> [directives]` | Exécuter les phases d'investigation |
| `/tdd <ref> [scope]` | Cycle red team (hypothèse → preuve → documentation) |
| `/review <ref>` | Revue du finding contre la spec et le plan |
| `/check` | Vérification qualité des preuves (hashing, timestamps, custody) |
| `/check-fix` | Vérification et correction de la remédiation |
| `/sync-docs <ref>` | Archiver preuves et findings |
| `/commit` | Commit Conventional Commit |
| `/pr` | Publication du rapport |
| `/git-workflow <branch> [flags]` | Flux Git complet avec checkpoints |
| `/generate-project-skills` | Générer des skills spécifiques au projet |
| `/test-api-e2e` | Lancer des scans de sécurité (nmap, nikto, sqlmap) |

## Skills Kali

Chaque skill est basé sur des outils Kali réels avec des commandes concrètes :

| Skill | Tool principal | Commande exemple |
|-------|---------------|-----------------|
| `attack-surface-analysis` | nmap | `nmap -sV -sC -O -Pn -oA results <target>` |
| `bug-hunting-analysis` | sqlmap, nuclei | `sqlmap -u "url?id=1" --batch --dbs` |
| `vulnerability-analysis` | burpsuite, tcpdump | `tcpdump -i eth0 -w capture.pcap host target` |
| `cve-research` | searchsploit | `searchsploit apache 2.4` |
| `exploitability-assessment` | CVSS calculator | Score CVSS v3.1/v4.0 + EPSS |
| `safe-poc-generation` | curl, msfconsole | `curl -s "target/page?id=1' OR '1'='1"` |
| `poc-validation` | tcpdump, sha256sum | `sha256sum poc_output.txt` |
| `evidence-collection` | sha256sum, tshark | `find evidence/ -exec sha256sum {} \;` |
| `cve-reporting` | — | Rédaction CVE JSON 5.0 |
| `remediation-plan` | nmap, nuclei | `nuclei -u target -t template.yaml` |

## Exemple d'investigation

Ticket :

```text
GH-42 : Vulnérabilité SQL Injection potentielle sur /api/search
```

### Cadrage

```text
/plan-change GH-42
```

Préciser : cible, scope, autorisation, outils prioritaires, critères de confirmation.

### Spécification

```text
/write-spec GH-42
```

Livrable :
```text
.samourai/docai/changes/YYYY-MM/YYYY-MM-DD--GH-42--sqli-api-search/chg-GH-42-spec.md
```

### Plan de validation POC

```text
/write-test-plan GH-42
```

Critères : reproductibilité, isolation lab, safety du POC, evidence hashing.

### Plan d'investigation

```text
/write-plan GH-42
```

Phases :
1. Reconnaissance du endpoint /api/search
2. Test d'injection SQL (sqlmap)
3. Analyse root cause
4. Corrélation CVE (searchsploit)
5. Scoring CVSS/EPSS
6. Création POC safe 
7. Collecte de preuves (hash + timestamp)
8. Rédaction rapport CVE

### Exécution

```text
/run-plan GH-42
```

Ou phase par phase :
```text
@attack-surface-agent scan /api/search endpoint on lab-target
@bug-hunting-agent test SQL injection on https://lab-target/api/search
@safe-poc-agent create minimal POC for SQL injection
@evidence-agent collect and hash all findings for GH-42
@cve-report-agent generate report for GH-42
```

### Revue et vérification

```text
/review GH-42
/check
```

### Publication

```text
/commit
/pr
```

## Bonnes pratiques

- Toujours vérifier l'autorisation avant toute investigation.
- Travailler exclusivement en environnement lab isolé.
- Ne jamais créer de POC weaponizable.
- Hasher et horodater toutes les preuves.
- Relire les rapports générés avant publication.
- Suivre le processus de responsible disclosure.
- Documenter les limites et les hypothèses non vérifiées.
- Utiliser `@pm` pour orchestrer les investigations complexes.
- Utiliser `@external-researcher` pour la veille CVE et les advisories.

## Dépannage

### Configuration OpenCode invalide

```bash
cat .opencode/opencode.jsonc
./scripts/install-samourai.sh --target /chemin/vers/lab --editor opencode --force
```

### Outil Kali manquant

Si un agent signale un outil manquant :

```bash
sudo apt install nmap nikto sqlmap hydra gobuster
pip install semgrep
```

### Désinstaller

```bash
./scripts/uninstall-samourai.sh --target /chemin/vers/lab
```

## Synthèse

Pour l'orchestration complète :

```text
OpenCode + /bootstrap + @pm investigate GH-42
```

Pour un usage ciblé :

```text
@attack-surface-agent scan target
@bug-hunting-agent hunt for OWASP Top 10
@safe-poc-agent create POC for finding
```
