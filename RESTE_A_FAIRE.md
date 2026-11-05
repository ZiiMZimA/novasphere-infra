# Fiche Reste à Faire — Suivi Séance 9 et Corrections

> Bilan suite à la fiche de la séance 9 et au gel du dépôt (tag `rendu-final` du 31 octobre).
> Ce document fait le point sur les écarts constatés et sur la répartition des correctifs sur la branche `correction`.

## 1. État au moment du gel (tag `rendu-final`)
* [x] Environnement dev fonctionnel avec ALB.
* [x] Mot de passe géré via AWS SSM Parameter Store (`SecureString`, `value_wo`).
* [x] Environnement `prod` protégé par approbation manuelle dans GitHub Actions.
* [ ] **Écart 1 (Ansible)** : La prod affichait "dev" sur la page web car le tag d'environnement n'était pas passé à `ansible-pull`.
* [ ] **Écart 2 (Nettoyage)** : Dossiers de test résiduels (`envs/dev/dev/`, `modules/`) et règle SSH encore présente dans le Security Group.
* [ ] **Écart 3 (CI/CD)** : Le plan bloquait sur GitHub Actions par manque de la variable `TF_VAR_environment` et de `-input=false`.
* [ ] **Écart 4 (Docs & Déploiement from scratch)** : Le `README.md` initial omettait l'étape `cp terraform.tfvars.example terraform.tfvars` lors d'un `git clone` vierge, provoquant un arrêt interactif sur `var.environment` ; il manquait aussi la commande de vérification de l'URL de l'ALB.

## 2. Répartition du travail sur la branche `correction`

### Gilles (ZiiMZimA) — Référent AWS / Infra
* [x] Nettoyage des dossiers parasites et suppression de la règle SSH du Security Group.
* [x] Correction du script `bootstrap.sh` avec `-e "web_environment=${environment}"`.
* [x] Rédaction de `CADRAGE.md`, `ARCHITECTURE.md`, et refonte du `README.md`.

### Erwan (Paynayt) — Référent CI/CD
* [x] Correction du workflow `pr-plan.yml` (ajout de `TF_VAR_environment` et `-input=false`).
* [x] Déblocage des verrous S3 suite aux runs interrompus (`force-unlock`).
* [x] Validation du pipeline avec la PR #9 (`test/validiation-ci`) qui passe au vert en 34s.

### Théo (HamlyZion) — Référent Sécurité
* [x] Scan Checkov et traitement des alertes (IMDSv2, headers ALB, skips justifiés).
* [x] Rédaction de la politique IAM minimale SSM dans `SECURITE.md`.

### Ariel (Afro) — Référent Qualité & Documentation
* [x] Mise au propre des 8 règles d'équipe dans `CONTRIBUTING.md`.
* [x] Suivi et mise à jour de la présente fiche `RESTE_A_FAIRE.md`.
* [x] Relecture croisée des PRs du groupe.
