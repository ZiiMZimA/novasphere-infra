# Choix d'Architecture

## Schéma de base
Internet --> ALB (Port 80) --> Target Group --> ASG --> Instances privées (Port 80)

## Nos choix techniques
* **VPC :** On utilise le module public d'AWS (`terraform-aws-modules/vpc/aws`). On a désactivé la NAT Gateway pour ne pas consommer les crédits de notre Learner Lab.
* **Environnements :** Nous sommes partis sur une séparation stricte dev / prod avec des dossiers distincts comme demandé. Chacun a son propre backend S3.
* **Haute disponibilité :** L'Application Load Balancer répartit le trafic sur deux sous-réseaux publics dans deux zones différentes (us-east-1a et us-east-1b).
