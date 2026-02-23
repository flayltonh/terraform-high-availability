output "alb_dns_name" {
  description = "DNS público do Application Load Balancer. Acesse este endereço no navegador."
  value       = module.compute.alb_dns_name
}

output "rds_endpoint" {
  description = "Endpoint de conexão do banco de dados RDS MySQL."
  value       = module.database.rds_endpoint
}

output "rds_port" {
  description = "Porta de conexão do banco de dados RDS."
  value       = module.database.rds_port
}

output "vpc_id" {
  description = "ID da VPC criada."
  value       = module.network.vpc_id
}

output "public_subnet_ids" {
  description = "IDs das subnets públicas."
  value       = module.network.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs das subnets privadas."
  value       = module.network.private_subnet_ids
}
