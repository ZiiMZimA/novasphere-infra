# Registre de Sécurité — NovaSphere

## 1. Gestion des secrets
* **Zéro secret dans Git** : Aucun mot de passe ni clé n'est commité. Le `.gitignore` bloque `*.tfvars`, `*.tfstate`, `.env` et les fichiers de clés.
* **Variable d'environnement** : En local, on exporte `TF_VAR_db_password` dans le terminal. En CI/CD sur GitHub Actions, il est stocké dans les secrets du repo (`${{ secrets.DB_PASSWORD }}`).
* **Stockage dans AWS SSM** : Terraform pousse le mot de passe dans Parameter Store (`/novasphere/${environment}/db_password`) en type `SecureString`.
* **Pas de fuite dans le state (`value_wo`)** : On utilise l'option `value_wo = var.db_password` et `value_wo_version = 1`. Ça évite que Terraform n'enregistre le mot de passe en clair dans le fichier `terraform.tfstate` sur S3 ou dans les logs du `terraform plan`.
* **Récupération sur la machine** : L'instance récupère le mot de passe au boot via la CLI AWS (`aws ssm get-parameter --with-decryption`) et l'écrit dans `/etc/novasphere/app.conf` avec des droits restreints (`chmod 0640`).

## 2. Politique IAM minimale (droits de l'instance)
Comme on est sur l'AWS Learner Lab, on n'a pas les droits pour créer des rôles IAM (`iam:CreateRole` est refusé). On est donc obligés d'attacher le profil préexistant `LabInstanceProfile`.

Si on était sur un vrai compte AWS d'entreprise, on aurait créé ce rôle IAM avec le strict minimum de droits (principe du moindre privilège) :

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "LectureParametreSSMEnvironnement",
      "Effect": "Allow",
      "Action": [
        "ssm:GetParameter",
        "ssm:GetParameters"
      ],
      "Resource": "arn:aws:ssm:us-east-1:*:parameter/novasphere/${environment}/*"
    },
    {
      "Sid": "ConnexionSSMSessionManager",
      "Effect": "Allow",
      "Action": [
        "ssmmessages:CreateControlChannel",
        "ssmmessages:CreateDataChannel",
        "ssmmessages:OpenControlChannel",
        "ssmmessages:OpenDataChannel"
      ],
      "Resource": "*"
    }
  ]
}
```

## 3. Résultats du scan Checkov et corrections
On a passé le scanner de sécurité Checkov sur notre code Terraform (`checkov -d . --framework terraform`). Voici les alertes traitées :

| Règle | Ce qu'elle demande | Notre action | Justification |
| :--- | :--- | :--- | :--- |
| **CKV_AWS_79** | Forcer IMDSv2 sur EC2 | **Corrigé** | Ajout de `http_tokens = "required"` dans le Launch Template pour bloquer les attaques SSRF. |
| **CKV_AWS_131** | Rejeter les mauvais headers sur l'ALB | **Corrigé** | Ajout de `drop_invalid_header_fields = true` sur le Load Balancer. |
| **CKV_AWS_260** | Pas de port sensible ouvert sur 0.0.0.0/0 | **Corrigé** | On a supprimé la règle SSH (port 22). Seul le port 80 venant du Security Group de l'ALB est autorisé. |
| **CKV_AWS_2** | Utiliser HTTPS sur l'ALB | **Ignoré (`#checkov:skip`)** | Pas de nom de domaine public ni de certificat ACM possible sur le Learner Lab. |
| **CKV_AWS_337** | Utiliser une clé KMS personnalisée (CMK) | **Ignoré (`#checkov:skip`)** | Le lab bloque la création de clés KMS CMK. On utilise la clé par défaut `alias/aws/ssm`. |
