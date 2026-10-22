variable "server_name" {
  type        = string
  description = "Nom de la machine EC2"
}

variable "instance_type" {
  type        = string
  description = "Type d'instance EC2"
}

variable "ami" {
  type        = string
  description = "ID de l'AMI Debian"
}

variable "key_name" {
  type        = string
  description = "Nom de la paire de clés SSH"
}

variable "vpc_security_group_ids" {
  type        = list(string)
  description = "Liste des IDs de security groups"
}

variable "role" {
  type        = string
  description = "Rôle du serveur (web, monitoring...)"
}