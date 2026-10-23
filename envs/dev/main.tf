# Image Debian 12 officielle la plus recente 
data "aws_ami" "debian" {
  most_recent = true
  owners      = ["136693071363"]

  filter {
    name   = "name"
    values = ["debian-12-amd64-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# IP publique du poste qui execute Terraform (pattern my_ip, acquis Bac+4) 
data "http" "my_ip" {
  url = "https://api.ipify.org"
}

locals {
  my_cidr = "${chomp(data.http.my_ip.response_body)}/32"
  name    = "novasphere-${var.environment}-${var.owner}"
}

# Module VPC officiel du registre public (S4) : deux zones, sans NAT Gateway, IP publiques au lancement
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 6.0"

  name = "novasphere-${var.environment}"
  cidr = "10.0.0.0/16"

  azs            = ["us-east-1a", "us-east-1b"]
  public_subnets = ["10.0.1.0/24", "10.0.2.0/24"]

  enable_nat_gateway      = false
  map_public_ip_on_launch = true
}

resource "aws_key_pair" "main" {
  key_name   = "${local.name}-key"
  public_key = file(pathexpand(var.ssh_public_key_path))
}

# Security Group pour l'Application Load Balancer (ouvert au public sur le port 80)
resource "aws_security_group" "alb" {
  name        = "novasphere-${var.environment}-alb"
  description = "Acces HTTP public pour ALB"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "HTTP depuis Internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security Group pour les instances web (n'autorise le trafic que depuis l'ALB et SSH depuis mon IP)
resource "aws_security_group" "web" {
  name        = "${local.name}-web"
  description = "SSH restreint a mon IP, HTTP depuis ALB"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "SSH depuis mon poste uniquement"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [local.my_cidr]
  }

  ingress {
    description     = "HTTP depuis ALB uniquement"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Launch Template (le moule des instances pour l'ASG)
resource "aws_launch_template" "web_dev" {
  name_prefix            = "novasphere-${var.environment}-"
  image_id               = data.aws_ami.debian.id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.main.key_name
  vpc_security_group_ids = [aws_security_group.web.id]
  user_data = base64encode(templatefile("${path.module}/bootstrap.sh", {
    environment = var.environment
  }))

  # Forcer IMDSv2 pour la sécurité (Correction CKV_AWS_79)
  metadata_options {
    http_tokens = "required"
  }

  # Ajout du profil d'instance IAM pour les secrets
  iam_instance_profile {
    arn = data.aws_iam_instance_profile.lab.arn
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "novasphere-${var.environment}-web"
      Role = "web"
    }
  }
}

# Application Load Balancer
resource "aws_lb" "web" {
  name               = "novasphere-${var.environment}"
  load_balancer_type = "application"
  subnets            = module.vpc.public_subnets
  security_groups    = [aws_security_group.alb.id]
  # Rejeter les en-têtes invalides (Correction CKV_AWS_131)
  drop_invalid_header_fields = true

}

# Target Group
resource "aws_lb_target_group" "web" {
  name     = "novasphere-${var.environment}-web"
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.vpc.vpc_id

  health_check {
    path                = "/"
    matcher             = "200"
    interval            = 30
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

# Listener HTTP sur l'ALB
#checkov:skip=CKV_AWS_2:Pas de nom de domaine ni de certificat HTTPS pour le dev
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.web.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web.arn
  }
}

# Groupe d'Auto-Scaling (ASG)
resource "aws_autoscaling_group" "web" {
  name                = "novasphere-${var.environment}-web"
  min_size            = 2
  max_size            = 4
  desired_capacity    = 2
  vpc_zone_identifier = module.vpc.public_subnets
  target_group_arns   = [aws_lb_target_group.web.arn]
  health_check_type   = "ELB"

  launch_template {
    id      = aws_launch_template.web_dev.id
    version = "$Latest"
  }

  instance_refresh {
    strategy = "Rolling"
  }
}
moved {
  from = aws_launch_template.web
  to   = aws_launch_template.web_dev
}
# Test de déclenchement CI/CD
