# Fiche de Cadrage — Projet NovaSphere (Séance 8)

## 1. Membres du groupe (Groupe 8)
* **Gilles (ZiiMZimA)** : Référent AWS / Infra
* **Erwan (Paynayt)** : Référent Git & CI/CD
* **Théo (HamlyZion)** : Référent Sécurité & IAM
* **Serge (Afro) ** : Référent Qualité & Documentation

*On tourne sur les revues de PR et les manipulations AWS.*

## 2. Contexte métier
NovaSphere est une jeune startup SaaS qui développe une plateforme web d'analyse pour les entreprises. Notre rôle est de déployer et gérer l'infrastructure cloud qui héberge le site web de l'application. On doit garantir que le site reste accessible même en cas de panne d'une machine, tout en séparant bien l'environnement de dev et de prod.

## 3. Ce que servent les instances
Les instances EC2 tournent sous Debian 12 avec un serveur Nginx. Elles affichent la page web de NovaSphere avec le nom de la machine et l'environnement actif (dev ou prod). Elles reçoivent les requêtes HTTP (port 80) renvoyées par l'Application Load Balancer (ALB) et récupèrent le mot de passe de base de données stocké dans AWS Parameter Store au démarrage.

## 4. Extension choisie : Configuration par Ansible (ansible-pull)
On a choisi de configurer les machines avec Ansible en mode pull au boot (`ansible-pull`).
Ce que ça demande :
* Un script de bootstrap simple (`bootstrap.sh`) de moins de 10 lignes qui installe Ansible, Git et AWS CLI.
* L'instance télécharge toute seule le playbook depuis GitHub via HTTPS et l'applique en local (`localhost`).
* Pas besoin d'ouvrir le port SSH (22) ni de gérer des clés privées, ce qui est beaucoup plus sécurisé.
* On passe le tag `-e "web_environment=${environment}"` pour que la prod affiche bien "prod" et non "dev".

## 5. Extensions écartées
* **Bastion SSH / Accès SSH direct** : Écarté car on ne veut ouvrir aucun port d'administration sur Internet. Si on doit se connecter à une instance, on utilise AWS SSM Session Manager.
* **HTTPS / Certificat TLS** : Écarté parce que sur l'AWS Learner Lab, on n'a pas de nom de domaine public ni accès à Route 53 pour valider un certificat ACM.

## 6. Compte AWS pour la démo
* Plateforme : AWS Academy Learner Lab
* Région : `us-east-1`
* Account ID : `058264354274`
* Rôle IAM des instances : `LabInstanceProfile` (rôle imposé par le lab)
