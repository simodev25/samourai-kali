---
description: Orchestrate the full git pipeline — code review, tests, conventional commit, push, PR creation — with explicit user checkpoints before each irreversible action.
agent: committer
subtask: true
---

<purpose>
Orchestrer le pipeline git complet depuis les changements non committés jusqu'à la PR créée, avec checkpoints utilisateur bloquants avant chaque opération irréversible (commit, push, PR).

Complémente /commit et /pr en ajoutant : pre-commit review via @code-reviewer, validation des tests, génération de commit message Conventional Commits, et description PR enrichie.

Utilisé en fin de delivery après /review et /check, comme alternative plus structurée à /commit + /pr séquentiels.
</purpose>

<command>
User invocation:
  /git-workflow <target-branch> [flags]
Examples:
  /git-workflow main
  /git-workflow main --skip-tests
  /git-workflow main --draft-pr
  /git-workflow main --no-push
  /git-workflow develop --draft-pr --conventional
</command>

<inputs>
  <item>target-branch='$1' — Branche cible pour la PR (défaut: main). REQUIRED.</item>
  <item>flags='$ARGUMENTS' — Flags optionnels.</item>
</inputs>

<flags>
- `--skip-tests` : passer la phase de validation des tests (Phase 2)
- `--draft-pr` : créer la PR en mode draft
- `--no-push` : s'arrêter après le commit, ne pas pousser ni créer de PR
- `--conventional` : forcer le format Conventional Commits (activé par défaut)
- `--dry-run` : simuler sans exécuter d'opérations git
</flags>

<session_state>
Maintenir l'état dans `.git-workflow/state.json` pour permettre la reprise :
```json
{
  "target_branch": "main",
  "status": "in_progress",
  "current_phase": 1,
  "completed_phases": [],
  "flags": {},
  "started_at": "ISO_TIMESTAMP"
}
```
Au démarrage : vérifier si une session existante est en cours et proposer reprise ou restart.
</session_state>

<pipeline>

## Phase 1 — Pré-commit review

Collecter le contexte git :
```bash
git status
git diff --stat
git diff
git log --oneline -10
git branch --show-current
```

Déléguer à @code-reviewer pour analyser les changements :
- Sécurité, correctness, performance, testing gaps
- Produire rapport dans `.git-workflow/01-code-review.md`

### CHECKPOINT 1 — Approbation requise
```
Pré-commit review terminé.
Issues trouvés : [X critical, Y major, Z minor, W nit]

1. Approuver → continuer vers les tests
2. Corriger d'abord → adresser les issues critical/major
3. Pause → sauvegarder et arrêter
```
Ne pas continuer sans approbation explicite.

---

## Phase 2 — Tests & validation

Si `--skip-tests` : documenter le skip, passer à Phase 3.

Détecter et exécuter les tests du projet (selon conventions repo) :
- Tests unitaires
- Tests d'intégration
- Vérification de couverture si disponible

Produire rapport dans `.git-workflow/03-test-results.md`.

### CHECKPOINT 2 — Approbation requise
```
Tests terminés.
Résultats : [X passed, Y failed, Z skipped]

1. Approuver → générer commit message
2. Corriger les tests en échec
3. Pause
```

---

## Phase 3 — Commit message (Conventional Commits)

Analyser les changements et catégoriser :

**Types** : `feat` | `fix` | `docs` | `style` | `refactor` | `perf` | `test` | `build` | `ci` | `chore` | `revert`

Format strict :
```
<type>(<scope>): <subject>    ← 72 chars max, impératif, pas de point final
<blank line>
<body>                         ← why + what (pas how), 1-4 lignes
<blank line>
BREAKING CHANGE: <desc>        ← si applicable
Refs: #<issue> / <workItemRef>
```

Proposer dans `.git-workflow/06-commit-messages.md`.

### CHECKPOINT 3 — Approbation requise
```
Commit message proposé :
[afficher le message complet]

1. Approuver → exécuter les opérations git
2. Modifier → indiquer les changements
3. Pause
```

---

## Phase 4 — Push & branch (sauf --no-push)

Vérifications pré-push :
- Branch name conforme aux conventions du repo
- Pas de conflits avec la branche cible
- Pas de données sensibles dans les commits
- Règles de protection respectées

Afficher les commandes exactes planifiées :
```
Opérations planifiées :
  git add -A
  git commit -F .git-workflow/06-commit-messages.md
  git push origin <branch> -u

1. Exécuter
2. Modifier
3. Annuler
```

Exécuter uniquement après confirmation explicite (option 1).

### CHECKPOINT 4 (si --no-push non activé)
```
Push terminé. Branch : <branch>
1. Approuver → créer la PR
2. Pause
```

---

## Phase 5 — PR creation (sauf --no-push)

Générer description PR complète :
- Résumé des changements (quoi + pourquoi)
- Type de changement
- Tests effectués
- Breaking changes si applicable
- Checklist reviewer
- Références aux issues/tickets (extraits du commit message)

Créer via `gh pr create` :
- Titre = commit subject
- Body = description générée
- Draft si `--draft-pr`
- Base = target-branch

Afficher la commande avant exécution et demander confirmation.

</pipeline>

<output>
Rapport final :
- Phases complétées
- Issues trouvés en review (counts par sévérité)
- Résultats de tests
- Commit SHA + message
- PR URL (si créée)
- Fichiers produits dans `.git-workflow/`
</output>

<cleanup>
Les fichiers `.git-workflow/` sont temporaires.
Ajouter `.git-workflow/` au `.gitignore` si absent.
Ne jamais committer le contenu de `.git-workflow/`.
</cleanup>

<errors>
- Working tree propre (rien à committer) → informer et STOP
- Tests en échec non approuvés → bloquer Phase 4
- `gh` non disponible → Phase 5 : afficher la commande manuelle PR
- Branch protection empêche le push → informer, ne pas forcer
</errors>
