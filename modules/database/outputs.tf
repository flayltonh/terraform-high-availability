output "rds_endpoint" {
  description = "Endpoint de conexão do RDS MySQL."
  value       = aws_db_instance.main.endpoint
}

output "rds_port" {
  description = "Porta do RDS MySQL."
  value       = aws_db_instance.main.port
}

output "rds_id" {
  description = "ID da instância RDS."
  value       = aws_db_instance.main.id
}

output "rds_arn" {
  description = "ARN da instância RDS."
  value       = aws_db_instance.main.arn
}
