variable "project_name" {
  description = "Nome do projeto."
  type        = string
}

variable "environment" {
  description = "Ambiente de implantação."
  type        = string
}

variable "vpc_id" {
  description = "ID da VPC."
  type        = string
}

variable "public_subnet_ids" {
  description = "IDs das subnets públicas (para o ALB)."
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "IDs das subnets privadas (para o ASG)."
  type        = list(string)
}

variable "alb_sg_id" {
  description = "ID do Security Group do ALB."
  type        = string
}

variable "web_sg_id" {
  description = "ID do Security Group da camada web."
  type        = string
}

variable "instance_type" {
  description = "Tipo de instância EC2."
  type        = string
}

variable "ami_id" {
  description = "ID da AMI para o Launch Template."
  type        = string
}

variable "asg_min_size" {
  description = "Número mínimo de instâncias no ASG."
  type        = number
}

variable "asg_max_size" {
  description = "Número máximo de instâncias no ASG."
  type        = number
}

variable "asg_desired_capacity" {
  description = "Capacidade desejada de instâncias no ASG."
  type        = number
}
