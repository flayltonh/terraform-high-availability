variable "project_name" {
  description = "Nome do projeto."
  type        = string
}

variable "environment" {
  description = "Ambiente de implantação."
  type        = string
}

variable "private_subnet_ids" {
  description = "IDs das subnets privadas para o Subnet Group do RDS."
  type        = list(string)
}

variable "db_sg_id" {
  description = "ID do Security Group do banco de dados."
  type        = string
}

variable "db_name" {
  description = "Nome do banco de dados."
  type        = string
}

variable "db_username" {
  description = "Usuário administrador do RDS."
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Senha do administrador do RDS."
  type        = string
  sensitive   = true
}

variable "db_instance_class" {
  description = "Classe da instância RDS."
  type        = string
}
