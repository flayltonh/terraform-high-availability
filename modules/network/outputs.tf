output "vpc_id" {
  description = "ID da VPC."
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "Lista de IDs das subnets públicas."
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "Lista de IDs das subnets privadas."
  value       = aws_subnet.private[*].id
}

output "alb_sg_id" {
  description = "ID do Security Group do ALB."
  value       = aws_security_group.alb.id
}

output "web_sg_id" {
  description = "ID do Security Group da camada web (EC2)."
  value       = aws_security_group.web.id
}

output "db_sg_id" {
  description = "ID do Security Group do banco de dados."
  value       = aws_security_group.db.id
}
