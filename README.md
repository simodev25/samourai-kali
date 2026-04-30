# Samourai Devkit — AI Development Operating System

<p align="center">
  <img src="assets/logo.png" alt="Samourai Devkit Logo" width="420" />
</p>

---

# 🧭 Navigation rapide

- 📘 Guide utilisateur : [docs/guide-utilisateur-fr.md](docs/guide-utilisateur-fr.md)
- 🧱 Templates : [core/templates/README.md](core/templates/README.md)
- 🏗️ Onboarding projet : [core/governance/conventions/onboarding-existing-project.md](core/governance/conventions/onboarding-existing-project.md)
- 🔁 Lifecycle : [core/governance/conventions/change-lifecycle.md](core/governance/conventions/change-lifecycle.md)
- 🤖 Agents & commandes : [core/governance/conventions/opencode-agents-and-commands-guide.md](core/governance/conventions/opencode-agents-and-commands-guide.md)

---

# 🧭 Positionnement

Samourai Devkit est un **AI Development Operating System** permettant de transformer un dépôt Git en environnement de développement structuré, piloté par agents IA spécialisés.

---

# 🎯 Problématique adressée

Le développement assisté par IA souffre de :

- variabilité des outputs  
- absence de structuration des workflows  
- duplication des prompts  
- absence de gouvernance  

Samourai Devkit apporte :

- ✅ Un workflow déterministe
- ✅ Des agents spécialisés et orchestrés
- ✅ Une gouvernance intégrée
- ✅ Une standardisation via blueprints

---
---

## 🔁 Workflow standard

1. Cadrage → `/plan-change`
2. Spécification → `/write-spec`
3. Test design → `/write-test-plan`
4. Implémentation → `/run-plan`
5. Revue → `/review`
6. Vérification → `/check`
7. Documentation → `/sync-docs`
8. Livraison → `/commit` → `/pr`

---

# 🧩 Blueprints (élément structurant)

Les blueprints permettent de standardiser :

- workflows
- documents
- comportements des agents
- stratégies de test et review

### Utilisation

Les blueprints sont automatiquement exploités par :

- `/bootstrap`
- `/write-spec`
- `/review`
- `/pr`
- `@toolsmith`

👉 Ils permettent d’industrialiser l’usage des agents et de réduire la variabilité.

---

# 🏗️ Architecture

1. Interaction  
2. Orchestration  
3. Agents  
4. Skills / Tools  
5. Context / Memory  
6. Gouvernance  

---

## ⚙️ Installation rapide

```bash
curl -fsSL https://raw.githubusercontent.com/FR-PAR-SAMOUR-AI/samourai-devkit/main/scripts/install-remote.sh | bash -s -- --target /path/to/project
```

### Installation locale après git clone

Pour garder une copie locale du kit, cloner le dépôt puis lancer le script
d'installation depuis cette copie:

```bash
git clone https://github.com/FR-PAR-SAMOUR-AI/samourai-devkit.git
cd samourai-devkit
./scripts/install-samourai.sh --target /chemin/vers/mon-projet
```

Le chemin passé à `--target` doit pointer vers le projet Git dans lequel
installer Samourai Devkit, pas vers le dépôt `samourai-devkit` lui-même.

### Installation guidée

```bash
./scripts/install-samourai.sh --interactive
```


### Installation dans un projet local

Depuis ce repo:

```bash
./scripts/install-samourai.sh --target /chemin/vers/mon-projet
```
---
Options utiles:

```bash
./scripts/install-samourai.sh --target /chemin/projet --dry-run
./scripts/install-samourai.sh --target /chemin/projet --force
./scripts/install-samourai.sh --target /chemin/projet --skip-opencode
./scripts/install-samourai.sh --target /chemin/projet --editor opencode
./scripts/install-samourai.sh --target /chemin/projet --editor vscode
./scripts/install-samourai.sh --target /chemin/projet --editor opencode,vscode
./scripts/install-samourai.sh --target /chemin/projet --editor all
./scripts/install-samourai.sh --target /chemin/projet --symlink-stack

```

### Installation avec stack séparée par symlinks

Pour garder `.opencode`, `.samourai` et `AGENTS.md` hors du dépôt client tout
en les rendant visibles par OpenCode, utiliser:

```bash
./scripts/install-samourai.sh --target /chemin/vers/projet-client --symlink-stack
```

Le script installe la stack dans un dossier frère nommé:

```text
/chemin/vers/projet-client-samurai
```

Puis il crée des liens symboliques dans le projet client. `AGENTS.md` est lié
uniquement s'il existe déjà ou s'il a été migré vers la stack:

```text
.opencode -> ../projet-client-samurai/.opencode
.samourai -> ../projet-client-samurai/.samourai
AGENTS.md -> ../projet-client-samurai/AGENTS.md
```

Les liens sont ajoutés à `.git/info/exclude`, donc ils restent locaux au clone
et ne sont pas proposés au commit dans le dépôt client. La stack peut être
versionnée et poussée depuis le dépôt `projet-client-samurai`.

## Désinstaller le kit

```bash
./scripts/uninstall-samourai.sh --target /chemin/vers/mon-projet
```

Adapter OpenCode:

- `.opencode/README.md`
- `.opencode/.gitignore`
- `.opencode/opencode.jsonc`
- `.opencode/agent/*.md`
- `.opencode/command/*.md`
- `.opencode/skills/*/SKILL.md`
- `.opencode/skills/project/README.md`

Adapter VS Code/GitHub Copilot:

- `.github/copilot-instructions.md`
- `.github/agents/*.agent.md`
- `.github/prompts/*.prompt.md`
- `.github/skills/*/SKILL.md`
- `.vscode/extensions.json`
- `.vscode/mcp.json`
- `.vscode/settings.json`

## ⚡ Quick start (2 min)

1. Installer le kit
2. Ouvrir le projet dans OpenCode ou VS Code
3. Lancer :

```bash
/bootstrap
```

4. Puis :

```bash
/plan-change JIRA-123
```

---

## 🧠 Ce que ça change concrètement

Avant :
- Développement manuel
- Prompts ad hoc
- Résultats incohérents

Après :
- Workflow structuré
- Agents spécialisés
- Outputs standardisés
- Gouvernance intégrée

---

# 🔐 Gouvernance

- permissions agents  
- contrôle des effets de bord  
- validation avant commit / PR  
- auditabilité  

---


## 🏢 Scalabilité

Samourai Devkit permet :

- Standardisation multi-équipes
- Réutilisation des patterns
- Accélération du delivery
- Réduction des erreurs humaines

---



# 📘 Démarrage rapide (documentation officielle)

1. Lire : [docs/guide-utilisateur-fr.md](docs/guide-utilisateur-fr.md)  
2. Lire : [core/governance/conventions/onboarding-existing-project.md](core/governance/conventions/onboarding-existing-project.md)  
3. Lire : [core/governance/conventions/change-lifecycle.md](core/governance/conventions/change-lifecycle.md)  
4. Consulter : [core/templates/README.md](core/templates/README.md)  
5. Installer puis lancer /bootstrap  
