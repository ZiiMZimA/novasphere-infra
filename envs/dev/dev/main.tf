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
  name    = "novasphere-${var.owner}"
}

resource "aws_key_pair" "main" {
  key_name   = "${local.name}-key"
  public_key = file(pathexpand(var.ssh_public_key_path))
}

resource "aws_security_group" "web" {
  name        = "${local.name}-web"
  description = "SSH restreint a mon IP, HTTP ouvert"

  ingress {
    description = "SSH depuis mon poste uniquement"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [local.my_cidr]
  }

  ingress {
    description = "HTTP public"
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

module "web" {
  source                 = "../../modules/ec2-server"
  server_name            = "${local.name}-web"
  instance_type          = var.instance_type
  ami                    = data.aws_ami.debian.id
  key_name               = aws_key_pair.main.key_name
  vpc_security_group_ids = [aws_security_group.web.id]
  role                   = "web"
}

module "monitoring" {
  source                 = "../../modules/ec2-server"
  server_name            = "${local.name}-monitoring"
  instance_type          = var.instance_type
  ami                    = data.aws_ami.debian.id
  key_name               = aws_key_pair.main.key_name
  vpc_security_group_ids = [aws_security_group.web.id]
  role                   = "monitoring"
}

resource "local_file" "inventory" {
  filename        = "${path.module}/../../../../ansible/inventory.ini"
  file_permission = "0644"
  content = templatefile("${path.module}/../../inventory.tftpl", {
    web_ip = module.web.public_ip
  })
}

moved {
  from = aws_instance.web
  to   = module.web.aws_instance.this
}