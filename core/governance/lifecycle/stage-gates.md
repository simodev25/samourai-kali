# Stage Gates

## Gate 1 - Scope Authorization Verified

- Entry criteria:
  - `workItemRef` validé
  - périmètre de test explicitement autorisé
- Responsible agent: `@pm`
- Exit criteria:
  - cibles hors-scope identifiées
  - autorisation et contraintes consignées

## Gate 2 - Attack Surface Mapped

- Entry criteria:
  - scope autorisé validé
- Responsible agent: `@attack-surface-agent`
- Exit criteria:
  - cartographie recon disponible
  - points d’entrée documentés
  - journal des outils/commandes conservé

## Gate 3 - Findings Documented with Evidence

- Entry criteria:
  - phase recon terminée
- Responsible agent: `@bug-hunting-agent`
- Exit criteria:
  - findings décrits de façon reproductible
  - contexte, préconditions et impact initial précisés
  - liens vers preuves brutes présents

## Gate 4 - PoC Created and Validated (Safe)

- Entry criteria:
  - finding validé et scénario de test approuvé
- Responsible agent: `@safe-poc-agent`
- Exit criteria:
  - PoC implémenté en environnement lab isolé
  - reproductibilité confirmée par rerun
  - contrôles de sécurité (cleanup/rollback) vérifiés

## Gate 5 - Evidence Package Complete (Hashed, Timestamped)

- Entry criteria:
  - exécution PoC finalisée
- Responsible agent: `@evidence-agent`
- Exit criteria:
  - package d’évidence structuré
  - hash des artefacts enregistré
  - horodatage disponible et traçable
  - données sensibles redigées

## Gate 6 - Report Peer-Reviewed

- Entry criteria:
  - package d’évidence complet
- Responsible agent: `@reviewer`
- Exit criteria:
  - exactitude technique validée
  - cohérence CVE/CWE/CVSS vérifiée
  - qualité rédactionnelle et neutralité confirmées

## Gate 7 - Remediation Verified

- Entry criteria:
  - revue et rapport validés
- Responsible agent: `@remediation-agent`
- Exit criteria:
  - recommandations de remédiation documentées
  - efficacité validée en lab
  - risque résiduel explicité

## Gate 8 - Ready for Disclosure / Publication

- Entry criteria:
  - remédiation vérifiée ou acceptation du risque documentée
- Responsible agent: `@pr-manager`
- Exit criteria:
  - contraintes de divulgation respectées
  - artefacts de publication à jour
  - validation humaine finale enregistrée
