# Règles d'équipe

- Une branche par changement, jamais de commit direct sur main.
- Chaque pull request est relue par un autre membre avant le merge sur main.
- Un tag par séance (ex. v5.1.0).
- Le .gitignore n'est pas négociable : *.tfstate, *.tfvars, *.pem, .env, inventaires générés.
- Avant de quitter la salle : terraform destroy ou scripts/stop-evening.sh.
- On ne lève jamais un verrou (force-unlock) sans avoir vérifié avec l'équipe que personne n'a d'opération en cours.
- Verrouillage du state : use_lockfile = true ; dynamodb_table est déprécié selon la doc du backend S3.
- Chaque membre commite depuis son poste, sous son propre nom.
