# Choix d'Architecture — NovaSphere

## 1. Schéma d'architecture

```text
                           Internet
                              │
                              ▼ HTTP (port 80)
                   [ Application Load Balancer ]
                    (2 zones : us-east-1a, 1b)
                              │
                    ┌─────────┴─────────┐
                    ▼                   ▼
            [ Public Subnet 1 ]  [ Public Subnet 2 ]
               (us-east-1a)         (us-east-1b)
                    │                   │
                    ▼                   ▼
             [ EC2 Web Dev ]     [ EC2 Web Dev ]
             (Auto Scaling Group : 2 à 4 instances)
                    │
                    ▼ Récupère le mot de passe au boot
          [ AWS SSM Parameter Store ]
          (/novasphere/dev/db_password)
```

## 2. Nos choix techniques

### Séparation par dossiers (envs/dev et envs/prod) vs Workspaces
Nous avons choisi de séparer dev et prod dans deux dossiers distincts avec chacun leur propre code, leur fichier `terraform.tfvars` et leur propre backend S3.
Nous n'avons pas pris les workspaces Terraform car ils partagent le même fichier d'état racine : une mauvaise commande `terraform workspace select` et on risquait d'écraser la prod en voulant tester en dev. Avec deux dossiers, l'isolation est totale.

### Sous-réseaux publics sans NAT Gateway
Nous avons mis nos instances dans les sous-réseaux publics en désactivant la NAT Gateway (`enable_nat_gateway = false`).
* **Pourquoi ?** Une NAT Gateway coûte environ 0,05 $ de l'heure (~35 $ par mois). Avec le budget limité de 100 $ sur l'AWS Learner Lab, deux NAT Gateways en multi-AZ auraient vidé nos crédits en quelques jours.
* **Et la sécurité ?** Même si les instances ont une IP publique pour télécharger les paquets et le playbook Ansible, leur Security Group bloque tout : aucun port SSH (22) n'est ouvert, et le port 80 n'accepte que le trafic qui vient du Security Group de l'ALB. Personne ne peut attaquer les VM directement depuis Internet.

### Haute disponibilité (Multi-AZ)
L'ALB et l'Auto Scaling Group sont répartis sur deux zones (`us-east-1a` et `us-east-1b`). On a fixé l'ASG à 2 instances minimum (et 4 au max). Si une instance plante, l'ASG la remplace automatiquement.

### Durcissement de la sécurité
* **IMDSv2 obligatoire** : On a forcé `http_tokens = "required"` dans le Launch Template pour bloquer les failles SSRF.
* **Headers ALB** : On a activé `drop_invalid_header_fields = true` pour rejeter les requêtes HTTP malformées.
* **Secrets** : Le mot de passe DB est envoyé dans SSM Parameter Store en `SecureString` avec `value_wo = var.db_password` pour qu'il n'apparaisse jamais en clair dans le state S3 ni dans les logs du plan.

## 3. Extension Ansible (ansible-pull)
Au lieu de pousser la conf depuis une machine avec des clés SSH, les instances s'auto-configurent au démarrage (`user_data`) :
1. Le script `bootstrap.sh` (6 lignes) installe Ansible et AWS CLI.
2. Il récupère le mot de passe depuis SSM et le met dans `/etc/novasphere/app.conf` (droits 0640).
3. Il lance `ansible-pull` sur notre repo GitHub avec le tag de l'environnement (`-e "web_environment=${environment}"`).
