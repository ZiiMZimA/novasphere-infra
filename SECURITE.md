# Registre de Sécurité

## Gestion des secrets
Le mot de passe de la DB ne traîne jamais en clair. Terraform l'envoie dans AWS Parameter Store en mode écriture seule (`value_wo`). L'instance le récupère toute seule au démarrage.

## Rôles IAM
Vu qu'on travaille sur l'AWS Learner Lab, on est contraints d'utiliser le profil préexistant `LabInstanceProfile`. Si on avait les droits IAM complets, la politique restreindrait la lecture SSM strictement au chemin `/novasphere/dev/*` ou `/novasphere/prod/*`.

## Scans Checkov
* **CKV_AWS_79 (IMDSv2 sur Launch Template) :** Corrigé. Ajout du bloc `metadata_options` avec `http_tokens = "required"`.
* **CKV_AWS_131 (Headers ALB) :** Corrigé. Ajout de `drop_invalid_header_fields = true` sur le Load Balancer.
* **CKV_AWS_2 (ALB HTTPS) :** Ignoré via `#checkov:skip=CKV_AWS_2:Pas de nom de domaine ni de certificat HTTPS pour le dev`. Le projet étant académique et hébergé sur le Learner Lab, nous restons sur du HTTP standa

## Exemple des modifications pour les correstions :
CKV_AWS_79 (IMDSv2) :

resource "aws_launch_template" "web" {
  # Forcer IMDSv2 pour la sécurité (Correction CKV_AWS_79)
  metadata_options {
    http_tokens = "required"
  }
}


CKV_AWS_131 (Headers ALB)

resource "aws_lb" "web" {
  # Rejeter les en-têtes invalides (Correction CKV_AWS_131)
  drop_invalid_header_fields = true
}

ignoré CKV_AWS_2 car on n'a pas de certificat.
#checkov:skip=CKV_AWS_2:Pas de nom de domaine ni de certificat HTTPS pour le dev
resource "aws_lb_listener" "http" {
  # ...
}


##Liste des alertes suite au checkov préalable :

zima@debian:~/novasphere-infra-starter/envs/dev$ checkov -d . --framework terraform --compact
2026-10-22 12:46:56,424 [MainThread  ] [WARNI]  Failed to download module terraform-aws-modules/vpc/aws:~> 6.0 (for external modules, the --download-external-modules flag is required)
2026-10-22 12:46:56,425 [MainThread  ] [WARNI]  Module /home/zima/novasphere-infra-starter/envs/modules/ec2-server:latest failed to load via <class 'checkov.terraform.module_loading.loaders.local_path_loader.LocalPathLoader'> due to: /home/zima/novasphere-infra-starter/envs/modules/ec2-server
2026-10-22 12:46:56,425 [MainThread  ] [WARNI]  Unable to load module - source: /home/zima/novasphere-infra-starter/envs/modules/ec2-server, version: latest, error: /home/zima/novasphere-infra-starter/envs/modules/ec2-server
2026-10-22 12:46:56,425 [MainThread  ] [WARNI]  Module /home/zima/novasphere-infra-starter/envs/modules/ec2-server:latest failed to load via <class 'checkov.terraform.module_loading.loaders.local_path_loader.LocalPathLoader'> due to: /home/zima/novasphere-infra-starter/envs/modules/ec2-server
2026-10-22 12:46:56,425 [MainThread  ] [WARNI]  Unable to load module - source: /home/zima/novasphere-infra-starter/envs/modules/ec2-server, version: latest, error: /home/zima/novasphere-infra-starter/envs/modules/ec2-server
[ terraform framework ]: 100%|████████████████████|[13/13], Current File Scanned=versions.tf                   

       _               _
   ___| |__   ___  ___| | _______   __
  / __| '_ \ / _ \/ __| |/ / _ \ \ / /
 | (__| | | |  __/ (__|   < (_) \ V /
  \___|_| |_|\___|\___|_|\_\___/ \_/

By Prisma Cloud | version: 3.3.30 

terraform scan results:

Passed checks: 29, Failed checks: 26, Skipped checks: 0

Check: CKV_AWS_25: "Ensure no security groups allow ingress from 0.0.0.0:0 to port 3389"
	PASSED for resource: aws_security_group.web
	File: /dev/main.tf:32-58
	Guide: https://docs.prismacloud.io/en/enterprise-edition/policy-reference/aws-policies/aws-networking-policies/networking-2
Check: CKV_AWS_24: "Ensure no security groups allow ingress from 0.0.0.0:0 to port 22"
	PASSED for resource: aws_security_group.web
	File: /dev/main.tf:32-58
	Guide: https://docs.prismacloud.io/en/enterprise-edition/policy-reference/aws-policies/aws-networking-policies/networking-1-port-security
Check: CKV_AWS_277: "Ensure no security groups allow ingress from 0.0.0.0:0 to port -1"
	PASSED for resource: aws_security_group.web
	File: /dev/main.tf:32-58
	Guide: https://docs.prismacloud.io/en/enterprise-edition/policy-reference/aws-policies/aws-networking-policies/ensure-aws-security-group-does-not-allow-all-traffic-on-all-ports
Check: CKV_AWS_386: "Reduce potential for WhoAMI cloud image name confusion attack"
	PASSED for resource: aws_ami.debian
	File: /dev/main.tf:2-15
	Guide: https://docs.prismacloud.io/en/enterprise-edition/policy-reference/aws-policies/aws-supply-chain-policies/bc-aws-386
Check: CKV_AWS_25: "Ensure no security groups allow ingress from 0.0.0.0:0 to port 3389"
	PASSED for resource: aws_security_group.alb
	File: /main.tf:48-67
	Guide: https://docs.prismacloud.io/en/enterprise-edition/policy-reference/aws-policies/aws-networking-policies/networking-2
Check: CKV_AWS_24: "Ensure no security groups allow ingress from 0.0.0.0:0 to port 22"
	PASSED for resource: aws_security_group.alb
	File: /main.tf:48-67
	Guide: https://docs.prismacloud.io/en/enterprise-edition/policy-reference/aws-policies/aws-networking-policies/networking-1-port-security
Check: CKV_AWS_277: "Ensure no security groups allow ingress from 0.0.0.0:0 to port -1"
	PASSED for resource: aws_security_group.alb
	File: /main.tf:48-67
	Guide: https://docs.prismacloud.io/en/enterprise-edition/policy-reference/aws-policies/aws-networking-policies/ensure-aws-security-group-does-not-allow-all-traffic-on-all-ports
Check: CKV_AWS_25: "Ensure no security groups allow ingress from 0.0.0.0:0 to port 3389"
	PASSED for resource: aws_security_group.web
	File: /main.tf:70-97
	Guide: https://docs.prismacloud.io/en/enterprise-edition/policy-reference/aws-policies/aws-networking-policies/networking-2
Check: CKV_AWS_260: "Ensure no security groups allow ingress from 0.0.0.0:0 to port 80"
	PASSED for resource: aws_security_group.web
	File: /main.tf:70-97
	Guide: https://docs.prismacloud.io/en/enterprise-edition/policy-reference/aws-policies/aws-networking-policies/ensure-aws-security-groups-do-not-allow-ingress-from-00000-to-port-80
Check: CKV_AWS_24: "Ensure no security groups allow ingress from 0.0.0.0:0 to port 22"
	PASSED for resource: aws_security_group.web
	File: /main.tf:70-97
	Guide: https://docs.prismacloud.io/en/enterprise-edition/policy-reference/aws-policies/aws-networking-policies/networking-1-port-security
Check: CKV_AWS_277: "Ensure no security groups allow ingress from 0.0.0.0:0 to port -1"
	PASSED for resource: aws_security_group.web
	File: /main.tf:70-97
	Guide: https://docs.prismacloud.io/en/enterprise-edition/policy-reference/aws-policies/aws-networking-policies/ensure-aws-security-group-does-not-allow-all-traffic-on-all-ports
Check: CKV_AWS_88: "EC2 instance should not have public IP."
	PASSED for resource: aws_launch_template.web
	File: /main.tf:100-120
	Guide: https://docs.prismacloud.io/en/enterprise-edition/policy-reference/aws-policies/public-policies/public-12
Check: CKV_AWS_46: "Ensure no hard-coded secrets exist in EC2 user data"
	PASSED for resource: aws_launch_template.web
	File: /main.tf:100-120
	Guide: https://docs.prismacloud.io/en/enterprise-edition/policy-reference/aws-policies/secrets-policies/bc-aws-secrets-1
Check: CKV_AWS_341: "Ensure Launch template should not have a metadata response hop limit greater than 1"
	PASSED for resource: aws_launch_template.web
	File: /main.tf:100-120
	Guide: https://docs.prismacloud.io/en/enterprise-edition/policy-reference/aws-policies/aws-general-policies/bc-aws-341
Check: CKV_AWS_328: "Ensure that ALB is configured with defensive or strictest desync mitigation mode"
	PASSED for resource: aws_lb.web
	File: /main.tf:123-128
	Guide: https://docs.prismacloud.io/en/enterprise-edition/policy-reference/aws-policies/aws-networking-policies/bc-aws-328
Check: CKV_AWS_261: "Ensure HTTP HTTPS Target group defines Healthcheck"
	PASSED for resource: aws_lb_target_group.web
	File: /main.tf:131-144
	Guide: https://docs.prismacloud.io/en/enterprise-edition/policy-reference/aws-policies/aws-general-policies/ensure-aws-kendra-index-server-side-encryption-uses-customer-managed-keys-cmks
Check: CKV_AWS_315: "Ensure EC2 Auto Scaling groups use EC2 launch templates"
	PASSED for resource: aws_autoscaling_group.web
	File: /main.tf:159-176
	Guide: https://docs.prismacloud.io/en/enterprise-edition/policy-reference/aws-policies/aws-general-policies/bc-aws-315
Check: CKV_TF_2: "Ensure Terraform module sources use a tag with a version number"
	PASSED for resource: vpc
	File: /main.tf:28-40
	Guide: https://docs.prismacloud.io/en/enterprise-edition/policy-reference/supply-chain-policies/terraform-policies/ensure-terraform-module-sources-use-tag
Check: CKV_AWS_386: "Reduce potential for WhoAMI cloud image name confusion attack"
	PASSED for resource: aws_ami.debian
	File: /main.tf:2-15
	Guide: https://docs.prismacloud.io/en/enterprise-edition/policy-reference/aws-policies/aws-supply-chain-policies/bc-aws-386
Check: CKV_AWS_88: "EC2 instance should not have public IP."
	PASSED for resource: aws_instance.this
	File: /modules/ec2-server/main.tf:1-11
	Guide: https://docs.prismacloud.io/en/enterprise-edition/policy-reference/aws-policies/public-policies/public-12
Check: CKV_AWS_46: "Ensure no hard-coded secrets exist in EC2 user data"
	PASSED for resource: aws_instance.this
	File: /modules/ec2-server/main.tf:1-11
	Guide: https://docs.prismacloud.io/en/enterprise-edition/policy-reference/aws-policies/secrets-policies/bc-aws-secrets-1
Check: CKV_AWS_41: "Ensure no hard coded AWS access key and secret key exists in provider"
	PASSED for resource: aws.default
	File: /versions.tf:23-33
	Guide: https://docs.prismacloud.io/en/enterprise-edition/policy-reference/aws-policies/secrets-policies/bc-aws-secrets-5
Check: CKV2_AWS_5: "Ensure that Security Groups are attached to another resource"
	PASSED for resource: aws_security_group.web
	File: /main.tf:70-97
	Guide: https://docs.prismacloud.io/en/enterprise-edition/policy-reference/aws-policies/aws-networking-policies/ensure-that-security-groups-are-attached-to-ec2-instances-or-elastic-network-interfaces-enis
Check: CKV2_AWS_5: "Ensure that Security Groups are attached to another resource"
	PASSED for resource: aws_security_group.alb
	File: /main.tf:48-67
	Guide: https://docs.prismacloud.io/en/enterprise-edition/policy-reference/aws-policies/aws-networking-policies/ensure-that-security-groups-are-attached-to-ec2-instances-or-elastic-network-interfaces-enis
Check: CKV2_AWS_34: "AWS SSM Parameter should be Encrypted"
	PASSED for resource: aws_ssm_parameter.db_password
	File: /secrets.tf:1-6
	Guide: https://docs.prismacloud.io/en/enterprise-edition/policy-reference/aws-policies/aws-general-policies/ensure-aws-ssm-parameter-is-encrypted
Check: CKV2_AWS_74: "Ensure AWS Load Balancers use strong ciphers"
	PASSED for resource: aws_lb_listener.http
	File: /main.tf:147-156
	Guide: https://docs.prismacloud.io/en/enterprise-edition/policy-reference/aws-policies/aws-networking-policies/bc-aws-2-74
Check: CKV2_AWS_76: "Ensure AWS ALB attached WAFv2 WebACL is configured with AMR for Log4j Vulnerability"
	PASSED for resource: aws_lb.web
	File: /main.tf:123-128
Check: CKV2_AWS_36: "Ensure terraform is not sending SSM secrets to untrusted domains over HTTP"
	PASSED for resource: http.my_ip
	File: /dev/main.tf:18-20
	Guide: https://docs.prismacloud.io/en/enterprise-edition/policy-reference/aws-policies/aws-general-policies/ensure-aws-terraform-does-not-send-ssm-secrets-to-untrusted-domains-over-http
Check: CKV2_AWS_36: "Ensure terraform is not sending SSM secrets to untrusted domains over HTTP"
	PASSED for resource: http.my_ip
	File: /main.tf:18-20
	Guide: https://docs.prismacloud.io/en/enterprise-edition/policy-reference/aws-policies/aws-general-policies/ensure-aws-terraform-does-not-send-ssm-secrets-to-untrusted-domains-over-http
Check: CKV_AWS_23: "Ensure every security group and rule has a description"
	FAILED for resource: aws_security_group.web
	File: /dev/main.tf:32-58
	Guide: https://docs.prismacloud.io/en/enterprise-edition/policy-reference/aws-policies/aws-networking-policies/networking-31
Check: CKV_AWS_382: "Ensure no security groups allow egress from 0.0.0.0:0 to port -1"
	FAILED for resource: aws_security_group.web
	File: /dev/main.tf:32-58
	Guide: https://docs.prismacloud.io/en/enterprise-edition/policy-reference/aws-policies/aws-networking-policies/bc-aws-382
Check: CKV_AWS_260: "Ensure no security groups allow ingress from 0.0.0.0:0 to port 80"
	FAILED for resource: aws_security_group.web
	File: /dev/main.tf:32-58
	Guide: https://docs.prismacloud.io/en/enterprise-edition/policy-reference/aws-policies/aws-networking-policies/ensure-aws-security-groups-do-not-allow-ingress-from-00000-to-port-80
Check: CKV_AWS_23: "Ensure every security group and rule has a description"
	FAILED for resource: aws_security_group.alb
	File: /main.tf:48-67
	Guide: https://docs.prismacloud.io/en/enterprise-edition/policy-reference/aws-policies/aws-networking-policies/networking-31
Check: CKV_AWS_382: "Ensure no security groups allow egress from 0.0.0.0:0 to port -1"
	FAILED for resource: aws_security_group.alb
	File: /main.tf:48-67
	Guide: https://docs.prismacloud.io/en/enterprise-edition/policy-reference/aws-policies/aws-networking-policies/bc-aws-382
Check: CKV_AWS_260: "Ensure no security groups allow ingress from 0.0.0.0:0 to port 80"
	FAILED for resource: aws_security_group.alb
	File: /main.tf:48-67
	Guide: https://docs.prismacloud.io/en/enterprise-edition/policy-reference/aws-policies/aws-networking-policies/ensure-aws-security-groups-do-not-allow-ingress-from-00000-to-port-80
Check: CKV_AWS_23: "Ensure every security group and rule has a description"
	FAILED for resource: aws_security_group.web
	File: /main.tf:70-97
	Guide: https://docs.prismacloud.io/en/enterprise-edition/policy-reference/aws-policies/aws-networking-policies/networking-31
Check: CKV_AWS_382: "Ensure no security groups allow egress from 0.0.0.0:0 to port -1"
	FAILED for resource: aws_security_group.web
	File: /main.tf:70-97
	Guide: https://docs.prismacloud.io/en/enterprise-edition/policy-reference/aws-policies/aws-networking-policies/bc-aws-382
Check: CKV_AWS_79: "Ensure Instance Metadata Service Version 1 is not enabled"
	FAILED for resource: aws_launch_template.web
	File: /main.tf:100-120
	Guide: https://docs.prismacloud.io/en/enterprise-edition/policy-reference/aws-policies/aws-general-policies/bc-aws-general-31
Check: CKV_AWS_91: "Ensure the ELBv2 (Application/Network) has access logging enabled"
	FAILED for resource: aws_lb.web
	File: /main.tf:123-128
	Guide: https://docs.prismacloud.io/en/enterprise-edition/policy-reference/aws-policies/aws-logging-policies/bc-aws-logging-22
Check: CKV_AWS_150: "Ensure that Load Balancer has deletion protection enabled"
	FAILED for resource: aws_lb.web
	File: /main.tf:123-128
	Guide: https://docs.prismacloud.io/en/enterprise-edition/policy-reference/aws-policies/aws-general-policies/bc-aws-150
Check: CKV_AWS_131: "Ensure that ALB drops HTTP headers"
	FAILED for resource: aws_lb.web
	File: /main.tf:123-128
	Guide: https://docs.prismacloud.io/en/enterprise-edition/policy-reference/aws-policies/aws-networking-policies/ensure-that-alb-drops-http-headers
Check: CKV_AWS_2: "Ensure ALB protocol is HTTPS"
	FAILED for resource: aws_lb_listener.http
	File: /main.tf:147-156
	Guide: https://docs.prismacloud.io/en/enterprise-edition/policy-reference/aws-policies/aws-networking-policies/networking-29
Check: CKV_AWS_153: "Autoscaling groups should supply tags to launch configurations"
	FAILED for resource: aws_autoscaling_group.web
	File: /main.tf:159-176
	Guide: https://docs.prismacloud.io/en/enterprise-edition/policy-reference/aws-policies/aws-general-policies/autoscaling-groups-should-supply-tags-to-launch-configurations
Check: CKV_TF_1: "Ensure Terraform module sources use a commit hash"
	FAILED for resource: vpc
	File: /main.tf:28-40
	Guide: https://docs.prismacloud.io/en/enterprise-edition/policy-reference/supply-chain-policies/terraform-policies/ensure-terraform-module-sources-use-git-url-with-commit-hash-revision
Check: CKV_AWS_135: "Ensure that EC2 is EBS optimized"
	FAILED for resource: aws_instance.this
	File: /modules/ec2-server/main.tf:1-11
	Guide: https://docs.prismacloud.io/en/enterprise-edition/policy-reference/aws-policies/aws-general-policies/ensure-that-ec2-is-ebs-optimized
Check: CKV_AWS_126: "Ensure that detailed monitoring is enabled for EC2 instances"
	FAILED for resource: aws_instance.this
	File: /modules/ec2-server/main.tf:1-11
	Guide: https://docs.prismacloud.io/en/enterprise-edition/policy-reference/aws-policies/aws-logging-policies/ensure-that-detailed-monitoring-is-enabled-for-ec2-instances
Check: CKV_AWS_79: "Ensure Instance Metadata Service Version 1 is not enabled"
	FAILED for resource: aws_instance.this
	File: /modules/ec2-server/main.tf:1-11
	Guide: https://docs.prismacloud.io/en/enterprise-edition/policy-reference/aws-policies/aws-general-policies/bc-aws-general-31
Check: CKV_AWS_8: "Ensure all data stored in the Launch configuration or instance Elastic Blocks Store is securely encrypted"
	FAILED for resource: aws_instance.this
	File: /modules/ec2-server/main.tf:1-11
	Guide: https://docs.prismacloud.io/en/enterprise-edition/policy-reference/aws-policies/aws-general-policies/general-13
Check: CKV_AWS_337: "Ensure SSM parameters are using KMS CMK"
	FAILED for resource: aws_ssm_parameter.db_password
	File: /secrets.tf:1-6
	Guide: https://docs.prismacloud.io/en/enterprise-edition/policy-reference/aws-policies/aws-general-policies/bc-aws-337
Check: CKV2_AWS_5: "Ensure that Security Groups are attached to another resource"
	FAILED for resource: aws_security_group.web
	File: /dev/main.tf:32-58
	Guide: https://docs.prismacloud.io/en/enterprise-edition/policy-reference/aws-policies/aws-networking-policies/ensure-that-security-groups-are-attached-to-ec2-instances-or-elastic-network-interfaces-enis
Check: CKV2_AWS_20: "Ensure that ALB redirects HTTP requests into HTTPS ones"
	FAILED for resource: aws_lb.web
	File: /main.tf:123-128
	Guide: https://docs.prismacloud.io/en/enterprise-edition/policy-reference/aws-policies/aws-networking-policies/ensure-that-alb-redirects-http-requests-into-https-ones
Check: CKV2_AWS_41: "Ensure an IAM role is attached to EC2 instance"
	FAILED for resource: aws_instance.this
	File: /modules/ec2-server/main.tf:1-11
	Guide: https://docs.prismacloud.io/en/enterprise-edition/policy-reference/aws-policies/aws-iam-policies/ensure-an-iam-role-is-attached-to-ec2-instance
Check: CKV_AWS_378: "Ensure AWS Load Balancer doesn't use HTTP protocol"
	FAILED for resource: aws_lb_target_group.web
	File: /main.tf:131-144
	Guide: https://docs.prismacloud.io/en/enterprise-edition/policy-reference/aws-policies/aws-networking-policies/bc-aws-378
Check: CKV_AWS_103: "Ensure that load balancer is using at least TLS 1.2"
	FAILED for resource: aws_lb_listener.http
	File: /main.tf:147-156
	Guide: https://docs.prismacloud.io/en/enterprise-edition/policy-reference/aws-policies/aws-general-policies/bc-aws-general-43
Check: CKV2_AWS_28: "Ensure public facing ALB are protected by WAF"
	FAILED for resource: aws_lb.web
	File: /main.tf:123-128
	Guide: https://docs.prismacloud.io/en/enterprise-edition/policy-reference/aws-policies/aws-networking-policies/ensure-public-facing-alb-are-protected-by-waf



