output "alb_dns_name" {
  description = "DNS de l'Application Load Balancer"
  value       = aws_lb.web.dns_name
}

output "asg_name" {
  description = "Nom du groupe d'auto-scaling"
  value       = aws_autoscaling_group.web.name
}

output "vpc_id" {
  description = "ID du VPC"
  value       = module.vpc.vpc_id
}
