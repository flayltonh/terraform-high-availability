variable "project_name" {
  description = "Nome do projeto."
  type        = string
}

variable "environment" {
  description = "Ambiente de implantação."
  type        = string
}

variable "aws_region" {
  description = "Região AWS."
  type        = string
}

variable "vpc_cidr" {
  description = "Bloco CIDR da VPC."
  type        = string
}

variable "public_subnet_cidrs" {
  description = "Lista de CIDRs para subnets públicas."
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "Lista de CIDRs para subnets privadas."
  type        = list(string)
}
