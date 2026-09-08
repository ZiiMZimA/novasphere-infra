output "public_ip" {
  description = "Adresse IP publique de l'instance"
  value       = aws_instance.this.public_ip
}

output "id" {
  description = "ID de l'instance EC2"
  value       = aws_instance.this.id
}