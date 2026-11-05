# Règles d'équipe — Projet NovaSphere

*Règles vues en séance 1 et adaptées à notre projet.*

1. **Pas de commit direct sur `main`** : Toute modification passe par une branche dédiée (`feature/`, `fix/`, `docs/`). Pour les corrections post-gel, on travaille uniquement sur la branche `correction`.
2. **Revue de PR obligatoire** : Chaque Pull Request doit être relue et approuvée par au moins un autre membre du groupe avant d'être mergée.
3. **Commits individuels et clairs** : Chacun commite depuis sa machine sous son propre nom GitHub. On utilise des préfixes clairs (`feat:`, `fix:`, `docs:`, `refactor:`, `chore:`).
4. **Le `.gitignore` est sacré** : Jamais de fichiers `.tfstate`, `.tfvars`, `.env` ou clés privées dans le repo.
5. **Verrouillage du state S3** : On utilise `use_lockfile = true`. Si un verrou reste bloqué, on demande TOUJOURS aux autres avant de faire un `force-unlock`.
6. **Arrêt du lab et destruction obligatoire** : Pour ne pas bouffer les 100 $ du lab, on détruit tout avec `terraform destroy` et on clique sur **Stop Lab** avant de quitter chaque session.
7. **Déploiements par la CI/CD** : Pas d'apply manuel en prod. Le plan tourne en PR, le dev s'applique au merge, et la prod demande une approbation dans GitHub Actions.
8. **Le tag `rendu-final` est gelé** : On ne touche jamais au tag `rendu-final` posé au 31 octobre. Toutes les améliorations se font sur la branche `correction`.
