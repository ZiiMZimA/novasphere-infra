variable "owner" {
  type        = string
  description = "Nom du propriétaire de l'infrastructure"
}

variable "instance_type" {
  type        = string
  description = "Type d'instance EC2"
  default     = "t3.micro"
}

variable "ssh_public_key_path" {
  type        = string
  description = "Chemin vers votre clé publique SSH"
}