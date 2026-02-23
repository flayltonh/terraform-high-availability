# =============================================
# DB Subnet Group
# =============================================
resource "aws_db_subnet_group" "main" {
  name        = "${var.project_name}-${var.environment}-db-subnet-group"
  description = "Subnet group para o RDS MySQL em subnets privadas"
  subnet_ids  = var.private_subnet_ids

  tags = {
    Name = "${var.project_name}-${var.environment}-db-subnet-group"
  }
}

# =============================================
# RDS MySQL Instance
# =============================================
resource "aws_db_instance" "main" {
  identifier = "${var.project_name}-${var.environment}-rds"

  # Engine
  engine         = "mysql"
  engine_version = "8.0"

  # Compute
  instance_class = var.db_instance_class

  # Storage
  allocated_storage     = 20
  max_allocated_storage = 100
  storage_type          = "gp2"
  storage_encrypted     = true

  # Credenciais
  db_name  = var.db_name
  username = var.db_username
  password = var.db_password

  # Rede e Segurança
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [var.db_sg_id]
  publicly_accessible    = false
  multi_az               = false # Mude para true em produção

  # Backup e Manutenção
  backup_retention_period = 7
  backup_window           = "02:00-03:00"
  maintenance_window      = "sun:04:00-sun:05:00"
  skip_final_snapshot     = true # Mude para false em produção
  deletion_protection     = false # Mude para true em produção

  # Monitoramento
  monitoring_interval = 0
  performance_insights_enabled = false

  tags = {
    Name = "${var.project_name}-${var.environment}-rds"
  }
}
