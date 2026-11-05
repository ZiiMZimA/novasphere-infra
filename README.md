# Infrastructure NovaSphere

Projet d'infrastructure cloud AWS déployée avec Terraform et configurée avec Ansible (Master SRC 5A - Groupe 8).

Ce document permet de déployer l'infrastructure de zéro sur un compte AWS Academy (Learner Lab).

---

## 1. Prérequis
* **Terraform** : v1.14 minimum (`terraform -version`).
* **AWS CLI** : installé et configuré avec les identifiants temporaires du Learner Lab (`~/.aws/credentials`).
* **Région AWS** : `us-east-1` (obligatoire pour le Learner Lab).
* **Bucket S3 backend** : le bucket distant `novasphere-tfstate-gna` doit être créé pour le stockage du state.

---

## 2. Déploiement

### Étape 1 : Exporter le mot de passe applicatif
Pour ne pas écrire de secret en clair dans le code :
```bash
export TF_VAR_db_password="MonMotDePasse123!"
```

### Étape 2 : Déployer l'environnement
Pour déployer le Dev :
```bash
cd envs/dev
terraform init
terraform apply -auto-approve
```

*(Même chose pour la prod : `cd envs/prod`, `terraform init`, `terraform apply -auto-approve`)*

---

## 3. Vérification du bon fonctionnement
Une fois le déploiement terminé, Terraform affiche l'URL DNS du Load Balancer :
```bash
terraform output alb_dns_name
```

1. Attendre environ 1 à 2 minutes (temps d'installation d'Ansible et validation du healthcheck ALB).
2. Tester l'accès dans un navigateur ou via `curl` :
```bash
curl http://$(terraform output -raw alb_dns_name)
```
* **En Dev** : La page affiche `NovaSphere - dev` et le nom du serveur.
* **En Prod** : La page affiche `NovaSphere - prod` et le nom du serveur.

---

## 4. Destruction (Pour préserver les crédits du Lab)
Avant de quitter, détruire impérativement toutes les ressources pour ne pas vider les 100 $ du lab :

```bash
export TF_VAR_db_password="Password123!"

cd envs/prod && terraform destroy -auto-approve
cd ../dev && terraform destroy -auto-approve
```
Puis cliquer sur **Stop Lab** dans la console AWS Academy.
