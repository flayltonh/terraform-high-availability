variable "aws_region" {
  description = "Região AWS onde os recursos serão provisionados."
  type        = string
}

variable "project_name" {
  description = "Nome do projeto, usado como prefixo nos recursos."
  type        = string
}

variable "environment" {
  description = "Ambiente de implantação (ex: dev, staging, prod)."
  type        = string
}

variable "vpc_cidr" {
  description = "Bloco CIDR da VPC."
  type        = string
}

variable "public_subnet_cidrs" {
  description = "Lista de CIDRs para as subnets públicas (mínimo 2 para alta disponibilidade)."
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "Lista de CIDRs para as subnets privadas (mínimo 2 para alta disponibilidade)."
  type        = list(string)
}

variable "instance_type" {
  description = "Tipo de instância EC2 para o Launch Template."
  type        = string
}

variable "ami_id" {
  description = "ID da AMI para as instâncias EC2 (Amazon Linux 2)."
  type        = string
}

variable "asg_min_size" {
  description = "Número mínimo de instâncias no Auto Scaling Group."
  type        = number
}

variable "asg_max_size" {
  description = "Número máximo de instâncias no Auto Scaling Group."
  type        = number
}

variable "asg_desired_capacity" {
  description = "Capacidade desejada de instâncias no Auto Scaling Group."
  type        = number
}

variable "db_name" {
  description = "Nome do banco de dados RDS."
  type        = string
}

variable "db_username" {
  description = "Usuário administrador do banco de dados RDS."
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Senha do administrador do banco de dados RDS."
  type        = string
  sensitive   = true
}

variable "db_instance_class" {
  description = "Classe da instância RDS."
  type        = string
}
