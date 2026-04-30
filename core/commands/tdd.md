---
description: Execute a TDD cycle for a specific task or phase — writes failing test first, then implementation, then refactors.
agent: tdd-orchestrator
subtask: true
---

<purpose>
Invoke @tdd-orchestrator pour implémenter une tâche ou une phase du plan en suivant strictement le cycle red-green-refactor. Garantit que les tests sont écrits AVANT le code de production.

Utilisé par @coder dans /run-plan quand le skill tdd-orchestrator est actif, ou invoqué directement pour une tâche spécifique.
</purpose>

<command>
User invocation:
  /tdd <workItemRef> [task description or phase number]
Examples:
  /tdd GH-42
  /tdd GH-42 phase 3
  /tdd GH-42 "implement user authentication"
  /tdd PDEV-123 next task
</command>

<inputs>
  <item>workItemRef='$1' — Tracker reference (e.g., `GH-456`, `PDEV-123`). REQUIRED.</item>
  <item>scope='$ARGUMENTS' — Phase number, task description, or "next task". OPTIONAL (défaut: prochaine tâche incomplète du plan).</item>
</inputs>

<discovery_rules>
<rule>Locate change folder: search `.samourai/docai/changes/**/*--<workItemRef>--*/`</rule>
<rule>Plan file: `chg-<workItemRef>-plan.md` — source de vérité pour les tâches</rule>
<rule>Test-plan file: `chg-<workItemRef>-test-plan.md` — tests à implémenter</rule>
<rule>Spec file: `chg-<workItemRef>-spec.md` — acceptance criteria</rule>
</discovery_rules>

<scope_resolution>
Résoudre la tâche cible depuis $ARGUMENTS :
- "phase N" → toutes les tâches incomplètes de la phase N
- "next task" ou absent → première tâche incomplète dans le plan
- description libre → matcher contre les tâches du plan (fuzzy match)
- Si ambiguïté → lister les candidats et demander confirmation
</scope_resolution>

<process>
1. Résoudre le change folder et localiser plan + test-plan + spec
2. Lire `.samourai/ai/agent/project-profile.md` si présent et le transmettre à @tdd-orchestrator
3. Identifier la/les tâches cibles selon scope_resolution
4. Pour chaque tâche :
   a. Lire le test-plan pour identifier les tests correspondants
   b. Invoquer @tdd-orchestrator avec : task, test_plan_path, spec_path
   c. @tdd-orchestrator exécute le cycle RED → GREEN → REFACTOR
   d. Mettre à jour le plan : marquer [x] + evidence
   e. Committer via /commit (un commit par tâche TDD complète)
5. Rapport final : tâches complètes, tests écrits, couverture, profil projet appliqué
</process>

<integration>
Ce command s'intègre dans le pipeline Samourai :
- Appelé par @coder dans /run-plan quand tdd-orchestrator skill est actif
- Peut remplacer /run-plan pour une tâche spécifique nécessitant TDD strict
- Les commits produits suivent le format Conventional Commits via /commit
</integration>

<output>
Rapport structuré :
- Tâches traitées + statut (COMPLETE / PARTIAL / BLOCKED)
- Tests écrits (N unit / N intégration / N e2e)
- Couverture delta
- Anti-patterns détectés
- Profil projet appliqué (`TMA`, `Build`, `Guide`, `Mix` ou `none`)
- Prochaine action suggérée
</output>

<errors>
- Plan ou test-plan absent → STOP avec message clair
- Tâche cible introuvable → lister les tâches disponibles
- Phase GREEN impossible après 3 tentatives → BLOCKED, documenter dans le plan
</errors>
