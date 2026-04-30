# Guide utilisateur Samourai Devkit

Ce guide présente l'installation et l'utilisation de Samourai Devkit dans un
projet logiciel existant. Il s'adresse à des utilisateurs techniques qui veulent
comprendre le périmètre réel du kit, ses artefacts, ses limites et son mode
d'exploitation.

## Périmètre

Samourai Devkit installe un cadre de travail assisté par IA dans un dépôt Git:

- agents spécialisés;
- commandes de workflow;
- prompts;
- skills;
- conventions de gouvernance;
- templates documentaires;
- adapters pour OpenCode et VS Code/GitHub Copilot.

Le kit ne fournit pas un service hébergé, un moteur d'orchestration autonome, ni
une garantie d'exécution identique entre éditeurs. Il installe des fichiers dans
un projet cible; l'exécution dépend ensuite de l'environnement utilisé, de la
configuration locale, des outils disponibles et des validations humaines.

Samourai Devkit ne remplace pas la responsabilité d'architecture, de revue ou de
validation. Il structure le travail et rend les livrables plus explicites:

- cadrage du changement;
- spécification;
- plan de test;
- plan d'implémentation;
- exécution contrôlée;
- revue;
- checks qualité;
- synchronisation documentaire;
- commit et PR/MR.

## Modèle d'installation

Samourai sépare les ressources du kit, les artefacts projet et les traces
temporaires.

### Core

Le core contient les références réutilisables du kit:

```text
core/agents/
core/commands/
core/skills/
core/governance/
core/templates/
core/decisions/
```

Dans un projet cible, le script installe sous `.samourai/core/` les ressources
de référence suivantes:

```text
.samourai/core/governance/
.samourai/core/templates/
.samourai/core/decisions/
```

Les agents, commandes et skills sources restent dans le dépôt du kit. Ils sont
rendus ou copiés dans l'adapter éditeur choisi.

### Adapters éditeur

Un adapter convertit les sources Samourai dans le format attendu par un éditeur.

OpenCode:

```text
.opencode/agent/
.opencode/command/
.opencode/skills/
.opencode/opencode.jsonc
```

VS Code/GitHub Copilot:

```text
.github/agents/
.github/prompts/
.github/skills/
.github/copilot-instructions.md
.vscode/settings.json
.vscode/mcp.json
```

Blueprints:

```text
.samourai/blueprints/
```

Les blueprints sont des références de structure utilisées par `/bootstrap`,
`/generate-project-skills`, `/write-test-plan`, `/review`, `/pr` et
`@toolsmith`. Ils guident la forme des artefacts générés, sans ajouter de
nouveaux droits d'écriture aux commandes.

### Artefacts projet

Les documents produits pendant les workflows vont sous `.samourai/docai/`:

```text
.samourai/docai/changes/
.samourai/docai/spec/
.samourai/docai/decisions/
.samourai/docai/planning/
```

Les fichiers temporaires produits par les agents vont sous `.samourai/tmpai/`:

```text
.samourai/tmpai/run-logs-runner/
.samourai/tmpai/code-review/
.samourai/tmpai/review-feedback/
.samourai/tmpai/pr/
```

Le profil projet généré par `/bootstrap` va sous:

```text
.samourai/ai/agent/project-profile.md
```

Il indique si le projet est en mode `TMA`, `Build`, `Guide` ou `Mix`. Les agents
s'en servent pour adapter les plans, le développement, les corrections, la revue
et la présentation des résultats. Exemple: en `TMA`, ils limitent le périmètre
des corrections et mettent en avant le risque de régression; en `Build`, ils
mettent en avant les incréments livrables, les tests et la compatibilité.

`.samourai/AGENTS.md` n'est pas copié depuis le kit. Il doit être généré par
`/bootstrap` dans le projet cible, car son contenu dépend du contexte réel du
dépôt. Un `AGENTS.md` minimal peut aussi être généré à la racine pour les outils
qui chargent automatiquement ce fichier; il doit pointer vers
`.samourai/AGENTS.md`.

### Manifest d'installation

Le script maintient l'état local sous:

```text
.samourai/install/installed-files.txt
.samourai/install/overwritten-files.txt
.samourai/install/installed-files.sha256
.samourai/install/last-install-summary.txt
```

Le manifest permet de désinstaller les fichiers ajoutés. Les checksums évitent
de supprimer automatiquement un fichier installé puis modifié localement.

## Installation

### Prérequis

- Pour le mode local, exécuter le script depuis le dépôt `samourai-devkit`.
- Cibler un projet Git existant.
- Utiliser `--allow-non-root` uniquement si l'installation dans un sous-dossier
  Git est intentionnelle.
- Prévoir OpenCode ou VS Code/GitHub Copilot selon l'adapter choisi.

### Installation distante depuis GitHub

Pour installer sans cloner manuellement le dépôt:

```bash
curl -fsSL https://raw.githubusercontent.com/FR-PAR-SAMOUR-AI/samourai-devkit/main/scripts/install-remote.sh | bash -s -- --target /chemin/vers/projet
```

Le script distant télécharge l'archive GitHub dans un dossier temporaire, puis
lance le script local `scripts/install-samourai.sh` avec les options fournies.
Le comportement d'installation reste donc celui du script local: manifest,
checksums, options éditeur, dry-run, `--force` et désinstallation.

Exemples:

```bash
curl -fsSL https://raw.githubusercontent.com/FR-PAR-SAMOUR-AI/samourai-devkit/main/scripts/install-remote.sh | bash -s -- --target /chemin/vers/projet --editor opencode
curl -fsSL https://raw.githubusercontent.com/FR-PAR-SAMOUR-AI/samourai-devkit/main/scripts/install-remote.sh | bash -s -- --target /chemin/vers/projet --editor vscode --skip-opencode
curl -fsSL https://raw.githubusercontent.com/FR-PAR-SAMOUR-AI/samourai-devkit/main/scripts/install-remote.sh | bash -s -- --target /chemin/vers/projet --core-only
```

Pour figer la version utilisée:

```bash
curl -fsSL https://raw.githubusercontent.com/FR-PAR-SAMOUR-AI/samourai-devkit/main/scripts/install-remote.sh | bash -s -- --ref v1.0.0 -- --target /chemin/vers/projet
```

Pour un dépôt privé, ne pas passer le token dans l'URL. Utiliser un header
`Authorization` et exposer le token au script via `SAMOURAI_GITHUB_TOKEN`, afin
que le téléchargement de l'archive GitHub utilise la même authentification:

```bash
read -rsp 'GitHub token: ' SAMOURAI_GITHUB_TOKEN; echo
export SAMOURAI_GITHUB_TOKEN
curl -H "Authorization: Bearer ${SAMOURAI_GITHUB_TOKEN}" -fsSL https://raw.githubusercontent.com/FR-PAR-SAMOUR-AI/samourai-devkit/main/scripts/install-remote.sh | bash -s -- --target /chemin/vers/projet --editor opencode
unset SAMOURAI_GITHUB_TOKEN
```

Pour un usage de production, préférer un tag ou un commit vérifié plutôt que la
branche `main`.

Options du script distant:

| Option | Usage |
|--------|-------|
| `--repo <owner/repo>` | Télécharger le kit depuis un autre dépôt GitHub. |
| `--ref <ref>` | Utiliser une branche, un tag ou un commit précis. À utiliser en production. |
| `--` | Séparer les options distantes des options transmises au script local. Obligatoire si une option locale peut être confondue avec une option distante. |

Toutes les autres options sont transmises à `scripts/install-samourai.sh`.

### Installation interactive

```bash
./scripts/install-samourai.sh --interactive
```

Le mode interactif demande:

- le projet cible;
- l'adapter éditeur;
- l'installation éventuelle d'OpenCode;
- l'exécution éventuelle en dry-run;
- une confirmation avant écriture.

### Installation OpenCode

```bash
./scripts/install-samourai.sh --target /chemin/vers/projet --editor opencode
```

Par défaut, l'adapter OpenCode est installé. Si `opencode` n'est pas disponible
dans le `PATH`, le script peut lancer l'installateur officiel:

```bash
curl -fsSL https://opencode.ai/install | bash
```

Pour refuser cette installation automatique:

```bash
./scripts/install-samourai.sh --target /chemin/vers/projet --editor opencode --skip-opencode
```

### Installation VS Code/GitHub Copilot

```bash
./scripts/install-samourai.sh --target /chemin/vers/projet --editor vscode --skip-opencode
```

L'adapter VS Code génère des custom agents, des prompt files, des skills, les
instructions Copilot et la configuration VS Code/MCP. Le comportement des
subagents dépend de la version de VS Code, de Copilot et des fonctionnalités
expérimentales disponibles.

### Installation OpenCode et VS Code

```bash
./scripts/install-samourai.sh --target /chemin/vers/projet --editor all
```

### Installation core uniquement

```bash
./scripts/install-samourai.sh --target /chemin/vers/projet --core-only
```

Ce mode installe uniquement les ressources de référence sous `.samourai/core/`.
Il n'installe pas d'agents ni de commandes directement utilisables dans un
éditeur.

### Diagnostic

```bash
./scripts/install-samourai.sh --target /chemin/vers/projet --doctor
```

Le diagnostic vérifie notamment:

- la présence d'un dépôt Git;
- le core Samourai;
- le manifest;
- les adapters OpenCode/VS Code;
- les fichiers de configuration principaux;
- la présence de `.samourai/AGENTS.md` ou du point d'entrée racine `AGENTS.md`.

### Dry-run et écrasement

Prévisualisation:

```bash
./scripts/install-samourai.sh --target /chemin/vers/projet --dry-run
```

Écrasement des fichiers Samourai déjà présents:

```bash
./scripts/install-samourai.sh --target /chemin/vers/projet --force
```

Sans `--force`, un fichier existant est conservé, n'est pas ajouté au manifest
et ne sera pas supprimé par la désinstallation.

Avec `--force`, les chemins écrasés sont enregistrés dans
`.samourai/install/overwritten-files.txt`. Ce fichier est un journal d'audit; il
ne contient pas de sauvegarde.

### Référence des options d'installation

| Option | Quand l'utiliser |
|--------|------------------|
| `--target <dir>` | Installer dans un projet cible précis. Par défaut: répertoire courant. |
| `--source <dir>` | Utiliser une copie locale différente du kit. Rare; utile pour tests ou fork. |
| `--editor opencode` | Installer OpenCode uniquement. C'est le défaut. |
| `--editor vscode` | Installer VS Code/GitHub Copilot uniquement. Ajouter `--skip-opencode`. |
| `--editor all` ou `--editor opencode,vscode` | Installer les deux adapters. |
| `--core-only` | Installer seulement `.samourai/core/` et `.samourai/blueprints/`, sans commandes ni agents utilisables. |
| `--symlink-stack` | Installer la stack dans un dossier frère `<projet>-samurai` et créer des symlinks `.opencode` / `.samourai` dans le projet cible. |
| `--stack-dir <dir>` | Choisir explicitement le dossier de stack utilisé par `--symlink-stack`. |
| `--skip-opencode` | Ne pas lancer l'installateur OpenCode même si l'adapter OpenCode est demandé. |
| `--interactive` | Laisser le script demander le projet cible, l'éditeur et la prévisualisation. |
| `--doctor` | Diagnostiquer une installation existante sans écrire de fichiers. |
| `--dry-run` ou `-n` | Prévisualiser les écritures. À utiliser avant une première installation ou un `--force`. |
| `--force` ou `-f` | Remplacer les fichiers déjà présents. À utiliser après revue du dry-run ou pour mettre à jour l'adapter. |
| `--allow-non-root` | Autoriser l'installation dans un sous-dossier Git. À éviter sauf cas volontaire. |
| `--list-editors` | Afficher les adapters supportés puis quitter. |
| `--verbose` ou `-v` | Obtenir des logs de debug. |
| `--help`, `--version` | Afficher l'aide ou la version du script. |

## Initialisation d'un projet

Après installation, ouvrir le projet cible dans l'environnement choisi.

Avec OpenCode:

```bash
opencode
```

Puis lancer:

```text
/bootstrap
```

ou, si le nom détecté risque d'être ambigu:

```text
/bootstrap mon-service-facturation
```

Le bootstrap analyse le projet et génère les artefacts projet initiaux, dont
`.samourai/AGENTS.md` et, si nécessaire, un `AGENTS.md` racine minimal. Cette
étape doit être revue: le contexte projet généré devient une entrée structurante
pour les agents.

`/bootstrap` est une commande multi-session. Elle reprend son état depuis
`.samourai/ai/local/bootstrapper-context.yaml` si ce fichier existe. Le flux réel
est:

```text
scan -> assess -> interview -> mcp-setup -> draft -> review -> write
```

La première question doit fixer la langue des artefacts, puis le bootstrap pose
les questions manquantes. La phase `mcp-setup` peut ajuster
`.opencode/opencode.jsonc` pour activer les MCP pertinents détectés. Le
bootstrapper ne doit pas modifier le code applicatif, ne doit pas stocker de
secret, et reste limité à ses chemins d'écriture projet.

Artefacts générés par défaut:

- `AGENTS.md`, point d'entrée racine minimal;
- `.samourai/AGENTS.md`, instructions projet principales;
- `.samourai/ai/agent/pm-instructions.md`, configuration backlog/tracker;
- `.samourai/ai/agent/pr-instructions.md`, configuration PR/MR;
- `.samourai/ai/agent/project-profile.md`, profil `TMA`, `Build`, `Guide` ou
  `Mix`;
- `.samourai/docai/documentation-handbook.md`, si le dépôt en a besoin.

Artefacts générés seulement si le contexte le justifie ou si l'utilisateur le
demande: overview, specs de features, nonfunctional spec, guides projet,
templates projet, décisions, backlog local, epics et archive. Aucun de ces
artefacts ne doit être considéré comme définitif sans revue humaine.

Pour générer des skills propres au projet:

```text
/generate-project-skills
```

Cette commande doit rester ciblée. Le kit limite volontairement la génération à
de petits lots afin d'éviter des skills génériques ou non vérifiés.

## Workflow standard

Un changement suivi par Samourai suit généralement cet ordre:

```text
/plan-change <ref>
/write-spec <ref>
/write-test-plan <ref>
/write-plan <ref>
/run-plan <ref>
/review <ref>
/check
/sync-docs <ref>
/commit
/pr
```

Pour une issue GitHub:

```text
/plan-change GH-123
/write-spec GH-123
/write-test-plan GH-123
/write-plan GH-123
/run-plan GH-123
/review GH-123
/check
/sync-docs GH-123
/commit
/pr
```

`/test-api-e2e` doit être ajouté uniquement si le projet dispose d'un workflow
backend/API compatible et si le changement le justifie.

L'orchestration peut aussi être confiée à `pm`:

```text
@pm deliver change GH-123
```

Dans ce cas, `pm` doit cadrer, déléguer, contrôler les livrables et escalader
les ambiguïtés. Il ne doit pas masquer les risques ni considérer une phase comme
terminée sans preuve exploitable.

## Rôles des agents

Un agent représente une responsabilité de workflow. Les limites de rôle sont
importantes: elles évitent qu'un agent modifie le code, la documentation ou Git
hors de son périmètre.

| Agent | Responsabilité |
|-------|----------------|
| `bootstrapper` | Analyse le projet cible et génère les artefacts d'initialisation. |
| `pm` | Orchestre le changement, clarifie le périmètre, délègue et suit l'avancement. |
| `architect` | Analyse les décisions techniques, les impacts structurels et les compromis. |
| `spec-writer` | Produit ou met à jour la spécification d'un changement. |
| `test-plan-writer` | Produit le plan de test lié à la spécification. |
| `plan-writer` | Produit le plan d'implémentation. |
| `coder` | Implémente les tâches validées dans le plan. |
| `tdd-orchestrator` | Cadre un cycle test-first lorsque le changement s'y prête. |
| `runner` | Exécute des commandes et restitue les résultats utiles. |
| `reviewer` | Vérifie le changement contre la spec, le plan et les règles du dépôt. |
| `code-reviewer` | Approfondit la revue code: sécurité, fiabilité, performance, maintenabilité. |
| `fixer` | Reproduit et corrige un problème ciblé. |
| `doc-syncer` | Synchronise la documentation après un changement accepté. |
| `committer` | Prépare un commit Conventional Commit. |
| `pr-manager` | Prépare ou met à jour une PR/MR. |
| `review-feedback-applier` | Traite les retours de review acceptés. |
| `designer` | Travaille sur les interfaces et l'expérience utilisateur. |
| `editor` | Améliore les contenus textuels et les formulations. |
| `external-researcher` | Recherche des informations externes via les outils disponibles. |
| `image-generator` | Génère des images si l'outil image est installé et configuré. |
| `image-reviewer` | Analyse des captures, images et résultats visuels. |
| `toolsmith` | Fait évoluer les agents, commandes ou skills Samourai. |

Usage typique:

```text
pm -> spec-writer -> test-plan-writer -> plan-writer -> coder -> runner -> reviewer
```

Exemples ciblés:

```text
@runner run npm test and summarize failures
@reviewer review GH-123 against the spec and plan
@coder implement phase 1 of GH-123
```

Règle pratique:

- utiliser une commande `/...` quand le workflow doit résoudre les chemins,
  charger les blueprints, appliquer le profil projet ou écrire l'artefact attendu;
- appeler un agent `@...` directement pour une tâche ciblée, déjà contextualisée,
  ou quand un humain orchestre manuellement les étapes;
- passer par `@pm` quand le changement traverse plusieurs rôles et que le ticket
  ou le backlog doit rester le point d'entrée;
- passer par `@runner` pour les commandes longues ou log-heavy, afin de conserver
  des logs sous `.samourai/tmpai/run-logs-runner/`;
- passer par `@committer` ou `/commit` pour tout commit; les autres agents ne
  doivent pas contourner le format Conventional Commit.

## Commandes disponibles

| Commande | Usage | Options et cas d'usage |
|----------|-------|------------------------|
| `/bootstrap [nom-projet]` | Initialiser Samourai dans un projet existant. | Ajouter `nom-projet` si le nom du dépôt n'est pas assez clair. Reprend l'état local si un bootstrap est déjà en cours. |
| `/plan-change [ref] [idée]` | Cadrer un changement avant spécification. | Sans `ref`, la commande aide à choisir ou créer la référence. Avec texte libre, elle l'utilise comme contexte de départ. N'écrit pas de fichier. |
| `/write-spec <ref>` | Générer ou mettre à jour la spécification. | Nécessite un contexte de cadrage. Crée le dossier `.samourai/docai/changes/...` si absent et écrit seulement `chg-<ref>-spec.md`. |
| `/write-test-plan <ref> [options]` | Générer ou mettre à jour le plan de test. | Options libres comme `focus=backend`, `nfr-only`, `no-manual`. Nécessite la spec et `.samourai/ai/rules/testing-strategy.md`. |
| `/write-plan <ref>` | Générer ou mettre à jour le plan d'implémentation. | Nécessite la spec. Lit le profil projet si présent. Écrit seulement `chg-<ref>-plan.md`. |
| `/run-plan <ref> [directives]` | Exécuter les tâches prévues. | Directives: `execute next N phases`, `execute all remaining phases`, `execute phase N`, `dry run`, `no review`, `commit per task`. Par défaut: une phase puis pause review. |
| `/tdd <ref> [scope]` | Exécuter une tâche en mode test-first. | `scope`: `phase N`, `next task` ou description libre. À utiliser quand l'ordre red-green-refactor est important. |
| `/review <ref> [directives]` | Relire un changement contre la spec, le plan et les règles du dépôt. | Directives: `dry run`, `preview only`, `base=<branch>`, `head=<ref>`, `no commit`. Ajoute une phase de remédiation si nécessaire. |
| `/check [fast/slow/all/gate...] [--skip-autofix] [--dry-run]` | Lancer les gates qualité sans correction automatique. | Passe les arguments au script qualité résolu depuis `.samourai/AGENTS.md` ou `./scripts/quality-gates.sh`. |
| `/check-fix` | Lancer les gates qualité et corriger les problèmes détectés. | À utiliser après un échec reproductible ou avant livraison si l'on accepte des corrections automatiques ciblées. Termine par un commit via `@committer`. |
| `/sync-docs <ref> [directives]` | Synchroniser la documentation après changement. | Directives: `dry run`, `contracts only`, `force`, `no commit`, `base=<branch>`. À lancer après un changement accepté ou avec `force`. |
| `/commit [intention]` | Créer un commit Conventional Commit. | L'intention est optionnelle et sert d'indice pour le message. Ne pousse jamais. |
| `/pr [args]` | Créer ou mettre à jour une PR/MR. | Utilise les instructions de `.samourai/ai/agent/pr-instructions.md` et écrit la description sous `.samourai/tmpai/pr/<branch>/`. Ne merge jamais. |
| `/git-workflow <branche-cible> [flags]` | Piloter le flux Git complet avec checkpoints utilisateur. | Flags: `--skip-tests`, `--draft-pr`, `--no-push`, `--conventional`, `--dry-run`. À utiliser en fin de delivery si l'on veut review, tests, commit, push et PR dans un seul flux contrôlé. |
| `/generate-project-skills [directives]` | Générer des skills spécifiques au projet. | Directives: `dry run`, `preview only`, `refresh`, `max=1..3`, `domain=<nom>`, `focus=run,test,architecture,build,review,debug,migration,ci`. |
| `/test-api-e2e [fast/all/target] [--dry-run]` | Lancer les tests E2E backend/API configurés dans le dépôt. | À ajouter seulement si le dépôt expose un workflow API E2E. Échoue avec `NEEDS_INPUT` si aucune commande n'est détectée. |

En cas d'incertitude, commencer par:

```text
/plan-change <ref>
```

ou demander explicitement une orientation:

```text
@pm explain the next step for GH-123
```

## Utilisation avec OpenCode

OpenCode est l'adapter principal du kit. Il prend en charge les agents,
commandes et skills installés sous `.opencode/`.

Installation:

```bash
./scripts/install-samourai.sh --target /chemin/vers/projet --editor opencode
```

Lancement dans le projet cible:

```bash
opencode
```

Commandes usuelles:

```text
/bootstrap
@pm deliver change GH-123
```

Les commandes qui modifient le dépôt (`/run-plan`, `/check-fix`, `/commit`,
`/pr`, etc.) doivent être traitées comme des opérations effectives sur le projet
cible. Relire les diffs et les artefacts produits avant validation.

## Utilisation avec VS Code/GitHub Copilot

L'adapter VS Code installe:

- des agents sous `.github/agents/`;
- des prompts sous `.github/prompts/`;
- des skills sous `.github/skills/`;
- les instructions Copilot sous `.github/copilot-instructions.md`;
- la configuration sous `.vscode/`.

Installation:

```bash
./scripts/install-samourai.sh --target /chemin/vers/projet --editor vscode --skip-opencode
```

Selon l'environnement, les agents peuvent apparaître dans le sélecteur Copilot.
Si ce n'est pas le cas, utiliser les prompt files directement.

### Subagents VS Code

Les subagents VS Code/Copilot restent dépendants de fonctionnalités
expérimentales. Samourai déclare des relations de délégation pour se rapprocher
du modèle OpenCode, par exemple:

```text
pm -> coder -> runner
pm -> reviewer -> fixer
coder -> tdd-orchestrator -> runner
```

Ce comportement n'est pas garanti par le kit. Si la délégation automatique n'est
pas disponible, exécuter le workflow manuellement:

```text
1. Utiliser le prompt write-spec.
2. Sélectionner l'agent test-plan-writer.
3. Sélectionner l'agent plan-writer.
4. Sélectionner l'agent coder.
5. Sélectionner l'agent runner.
6. Sélectionner l'agent reviewer.
```

## Exemple de changement

Issue:

```text
GH-123: Ajouter un endpoint GET /health
```

### Cadrage

```text
/plan-change GH-123
```

Le cadrage doit préciser:

- le comportement attendu;
- le format de réponse;
- les fichiers ou modules concernés;
- les tests attendus;
- les limites du changement.

### Spécification

```text
/write-spec GH-123
```

Livrable attendu:

```text
.samourai/docai/changes/YYYY-MM/YYYY-MM-DD--GH-123--health-endpoint/chg-GH-123-spec.md
```

### Plan de test

```text
/write-test-plan GH-123
```

Exemples de cas:

- `GET /health` retourne `200`;
- la réponse contient `status: "ok"`;
- un test échoue si l'endpoint est supprimé ou change de contrat.

### Plan d'implémentation

```text
/write-plan GH-123
```

Le plan doit être découpé en tâches vérifiables. Exemple:

```text
1. Ajouter le test de l'endpoint.
2. Ajouter la route.
3. Vérifier le contrat JSON.
4. Lancer les tests.
5. Mettre à jour la documentation si nécessaire.
```

### Exécution

```text
/run-plan GH-123
```

ou:

```text
@coder implement GH-123 from the plan
```

### Revue et checks

```text
/review GH-123
/check
```

En cas d'échec reproductible:

```text
/check-fix
```

### Commit et PR

```text
/commit
/pr
```

Avant validation, contrôler:

- le diff Git;
- les artefacts `.samourai/docai/`;
- les tests exécutés;
- les limites ou dérogations documentées;
- les fichiers hors périmètre éventuels.

## Bonnes pratiques

- Démarrer par des changements limités et vérifiables.
- Exiger une spécification avant implémentation lorsque le changement a un
  impact fonctionnel ou architectural.
- Ne pas laisser les agents inventer les règles métier manquantes.
- Conserver des plans courts et auditables.
- Relire les artefacts générés avant de les considérer comme source de vérité.
- Ne pas confondre réussite de prompt et validation technique.
- Documenter explicitement les tests non exécutés ou les validations manuelles.
- Utiliser `toolsmith` pour faire évoluer Samourai lui-même, pas pour modifier
  directement l'application cible.

Demande de clarification:

```text
@pm clarify GH-123 before implementation
```

Recherche externe:

```text
@external-researcher research the official FastAPI documentation for dependency injection and summarize what matters for GH-123
```

Génération d'image:

```text
@image-generator generate a clean dashboard hero image for a SaaS project, save it to assets/hero-dashboard.avif
```

Si l'outil image n'est pas installé ou configuré, l'agent doit s'arrêter et le
signaler. Il ne doit pas prétendre avoir généré un asset.

## Dépannage

### Configuration OpenCode invalide

Vérifier le fichier généré:

```bash
cat .opencode/opencode.jsonc
```

Réinstaller l'adapter si nécessaire:

```bash
./scripts/install-samourai.sh --target /chemin/vers/projet --editor opencode --force
```

### Agents VS Code absents

Vérifier les fichiers:

```text
.github/agents/*.agent.md
.github/prompts/*.prompt.md
.github/copilot-instructions.md
```

Redémarrer VS Code. Si les agents ne sont toujours pas disponibles, utiliser les
prompt files manuellement.

### Subagents VS Code indisponibles

Utiliser le workflow manuel:

```text
pm -> spec-writer -> test-plan-writer -> plan-writer -> coder -> runner -> reviewer
```

### Prévisualiser une installation

```bash
./scripts/install-samourai.sh --target /chemin/vers/projet --dry-run
```

### Désinstaller

```bash
./scripts/uninstall-samourai.sh --target /chemin/vers/projet
```

La désinstallation suit le manifest local quand il existe. Elle peut supprimer:

- les fichiers listés dans `.samourai/install/installed-files.txt`;
- les dossiers dédiés Samourai restants après confirmation:
  `.opencode`, `.samourai/tmpai`, `.samurai` et les anciens `.docai`/`.tmpai`
  de racine;
- certains anciens fichiers Samourai dans `.ai`;
- l'état local sous `.samourai/ai/local/`.

Elle ne supprime jamais en entier:

- `.github`;
- `.vscode`;
- `.ai`.

Si le script affiche:

```text
Dossier restant: .opencode
Supprimer ce dossier ? Tape "supprime" pour confirmer
```

la suppression nécessite la saisie exacte:

```text
supprime
```

Entrée vide: le dossier est conservé.

Suppression non interactive des dossiers dédiés Samourai:

```bash
./scripts/uninstall-samourai.sh --target /chemin/vers/projet --force
```

Même avec `--force`, `.github`, `.vscode`, `.ai`, `.samourai/docai`,
`.samourai/ai/{agent,rules,context}` et `.samourai/AGENTS.md` ne sont pas
supprimés en entier.

Options de désinstallation:

| Option | Quand l'utiliser |
|--------|------------------|
| `--target <dir>` | Désinstaller depuis un projet cible précis. Par défaut: répertoire courant. |
| `--dry-run` ou `-n` | Prévisualiser les suppressions sans supprimer. Recommandé avant toute désinstallation. |
| `--force` ou `-f` | Supprimer les dossiers dédiés Samourai sans demander la confirmation `supprime`. |
| `--allow-non-root` | Autoriser la désinstallation depuis un sous-dossier Git. À éviter sauf cas volontaire. |
| `--verbose` ou `-v` | Obtenir des logs de debug. |
| `--help`, `--version` | Afficher l'aide ou la version du script. |

Avant désinstallation, vérifier le chemin cible:

```bash
pwd -P
ls -la /chemin/vers/projet
./scripts/uninstall-samourai.sh --target /chemin/vers/projet --dry-run
```

Le script agit uniquement sur `--target`. Si plusieurs copies d'un projet
existent, le chemin doit pointer vers celle qui contient effectivement
`.opencode`, `.samourai`, `.samourai/docai` ou `.samourai/tmpai`.

## Lecture de synthèse

Pour l'orchestration la plus proche du modèle prévu par le kit:

```text
OpenCode + /bootstrap + @pm
```

Pour rester dans VS Code:

```text
VS Code + prompt files + custom agents
```

Si les subagents VS Code sont disponibles, ils peuvent améliorer la continuité
du workflow. Sinon, le workflow reste exploitable manuellement, à condition de
passer explicitement le contexte utile entre agents et de relire les livrables.
