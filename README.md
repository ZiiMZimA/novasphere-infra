# Infrastructure NovaSphere

Voici le process pour déployer notre infrastructure from scratch. 

## Les Prérequis
* Il faut Terraform installé (v1.14 minimum).
* il AWS CLI configuré (renseigné dans ~/.aws/credentials à jour avec les clés temporaires de l'AWS Learner Lab).

## Déploiement
1. On exporte le mot de passe en variable d'environnement pour ne pas l'écrire en dur :
   exemple : export TF_VAR_db_password="Password_971"`
2. On se place dans l'environnement voulu (ex: dev) : 
   cd envs/dev
3. On initialise Terraform : 
   terraform init
4. On déploie : 
   terraform apply -auto-approve

## Destruction (Très important !)
Pour ne pas gaspiller les crédits du lab, toujours détruire l'infra complète après usage (## Destruction (Très important !):

1. cd envs/prod && terraform destroy -auto-approve
2. cd ../dev && terraform destroy -auto-approve
