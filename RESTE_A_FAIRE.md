# Reste à faire

> La fiche papier de la séance 9 n'a pas été retrouvée au moment du gel.
> Ce document fait le point sur l'état du dépôt au moment du tag `rendu-final`,
> à partir d'une relecture du dépôt face au cahier des charges.

Équipe :

## État au gel

- [ ] dev déployé par la CI, l'ALB répond
- [x] secret en Parameter Store (SecureString, écrit en `value_wo`)
- [x] prod : environnement GitHub `prod` protégé par approbation

## Écarts connus par rapport au socle

1. **Module d'équipe versionné par tag**
   Le module `ec2-server` est resté en local dans `envs/dev/modules/` et n'est pas utilisé.
   Il aurait fallu le sortir dans son propre dépôt (`terraform-aws-<nom>`), poser un tag `v1.0.0`
   et l'appeler depuis `envs/dev` et `envs/prod` avec `?ref=v1.0.0`.

2. **SSH et IP dynamique sur le Security Group web**
   Le port 22 est ouvert vers l'IP de la machine qui lance Terraform (`data "http"` → `local.my_cidr`).
   Le cahier des charges demande aucun port SSH. Et comme l'IP du runner GitHub change à chaque run,
   le plan en CI n'est jamais vide.
   Correction prévue : supprimer la règle SSH et la data source `http`, passer par SSM Session Manager si besoin d'un accès.

3. **Chaîne CI incomplète**
   - plan pas posté en commentaire de la PR ;
   - apply lancé directement au lieu de partir d'un fichier de plan (`plan -out` puis `apply tfplan`) ;
   - pas de job de détection de dérive (`plan -detailed-exitcode` en `workflow_dispatch`) ;
   - mot de passe factice écrit en clair dans les workflows, à remplacer par un secret GitHub (`${{ secrets.DB_PASSWORD }}`).

## Nettoyage

- Supprimer les dossiers de test inutilisés : `envs/dev/dev/`, `envs/dev/modules/`, `terraform/`.Date de gel (tag `rendu-final`) : ______
