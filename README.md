# 🏗️ Terraform — Arquitetura Web 3 Camadas na AWS

![Terraform](https://img.shields.io/badge/Terraform-1.5%2B-7B42BC?style=for-the-badge&logo=terraform&logoColor=white)
![AWS](https://img.shields.io/badge/AWS-Cloud-FF9900?style=for-the-badge&logo=amazonaws&logoColor=white)
![IaC](https://img.shields.io/badge/IaC-Infrastructure_as_Code-blue?style=for-the-badge)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)

Infraestrutura como Código provisionando uma **Arquitetura Web de Alta Disponibilidade** na AWS, totalmente modularizada e parametrizada com Terraform.

---

## 📐 Arquitetura

![Diagrama da Arquitetura](docs/diagrama-arquitetura.png)

A arquitetura é composta por **3 camadas** distribuídas em **2 Availability Zones** para garantir alta disponibilidade:

| Camada | Recursos | Subnet |
|--------|----------|--------|
| **Apresentação** | Application Load Balancer | Pública |
| **Aplicação** | EC2 + Apache (Auto Scaling Group) | Privada |
| **Dados** | RDS MySQL 8.0 | Privada |

---

## ✅ Recursos Provisionados

- **VPC** com subnets públicas e privadas em 2 AZs (`us-east-1a` e `us-east-1b`)
- **Internet Gateway** — ponto de entrada da VPC
- **NAT Gateways** — saída segura para instâncias privadas (um por AZ)
- **Application Load Balancer** — distribui tráfego entre as AZs com Health Check
- **Auto Scaling Group** — escala EC2 automaticamente baseado em CPU (2–4 instâncias)
- **Launch Template** — EC2 com User Data exibindo a AZ servida (prova de HA)
- **Security Groups em camadas** — `Internet → ALB → EC2 → RDS`
- **RDS MySQL 8.0** — em subnet privada com Subnet Group nas 2 AZs
- **CloudWatch Alarms** — monitora CPU para trigger do ASG
- **Remote State** — `terraform.tfstate` no S3 com lock via DynamoDB

> 🚀 **31 recursos** provisionados com um único `terraform apply`

---

## 📁 Estrutura do Projeto

```
terraform-high-availability/
├── main.tf              # Orquestrador — chama os módulos
├── variables.tf         # Declaração das variáveis globais
├── terraform.tfvars     # Valores das variáveis (não versionado)
├── outputs.tf           # DNS do ALB + Endpoint do RDS
├── provider.tf          # Configuração do provider AWS
├── backend.tf           # Backend remoto S3
└── modules/
    ├── network/         # VPC, Subnets, IGW, NAT GW, Security Groups
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── compute/         # ALB, Target Group, Launch Template, ASG, CloudWatch
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    └── database/        # RDS MySQL + DB Subnet Group
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

---

## 🔒 Segurança — Security Groups em Camadas

```
Internet (0.0.0.0/0)
      ↓  :80 / :443
   SG-ALB
      ↓  :80
   SG-WEB (EC2)
      ↓  :3306
   SG-DB  (RDS)
```

Cada camada **só aceita tráfego da camada anterior** — nenhum recurso privado é exposto diretamente à internet.

---

## ⚙️ Pré-requisitos

- [Terraform](https://developer.hashicorp.com/terraform/downloads) >= 1.5.0
- [AWS CLI](https://aws.amazon.com/cli/) configurado (`aws configure`)
- Bucket S3 e tabela DynamoDB criados para o Remote State
- Permissões IAM para criar os recursos listados

---

## 🚀 Como usar

### 1. Clone o repositório
```bash
git clone https://github.com/flayltonh/terraform-high-availability.git
cd terraform-high-availability
```

### 2. Configure o backend
Edite o `backend.tf` com seus dados:
```hcl
bucket         = "seu-bucket-tfstate"
key            = "terraform-high-availability/terraform.tfstate"
region         = "us-east-1"
dynamodb_table = "sua-tabela-lock"
```

### 3. Configure as variáveis
Crie o arquivo `terraform.tfvars`:
```hcl
aws_region           = "us-east-1"
project_name         = "meu-projeto"
environment          = "dev"
vpc_cidr             = "10.0.0.0/16"
public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs = ["10.0.10.0/24", "10.0.11.0/24"]
instance_type        = "t3.micro"
ami_id               = "ami-0c02fb55956c7d316"
asg_min_size         = 2
asg_max_size         = 4
asg_desired_capacity = 2
db_name              = "appdb"
db_username          = "admin"
db_password          = "SuaSenhaForte123!"
db_instance_class    = "db.t3.micro"
```

### 4. Inicialize e aplique
```bash
terraform init
terraform plan
terraform apply
```

### 5. Acesse a aplicação
Após o `apply`, o output exibe o DNS do ALB:
```
Outputs:
alb_dns_name = "seu-alb-xxxxx.us-east-1.elb.amazonaws.com"
```
Acesse no browser e recarregue para ver o **ALB alternando entre `us-east-1a` e `us-east-1b`** — prova da Alta Disponibilidade! 🟠

### 6. Destrua a infraestrutura
```bash
terraform destroy
```

---

## 🌐 Prova de Alta Disponibilidade

O **User Data** de cada instância EC2 consulta os metadados via IMDSv2 e exibe a AZ na página HTML. Ao recarregar o browser, o ALB alterna entre as instâncias nas duas AZs em tempo real:

| Requisição | AZ Servida |
|------------|-----------|
| F5 🔄 | `us-east-1a` |
| F5 🔄 | `us-east-1b` |
| F5 🔄 | `us-east-1a` |

---

## 📌 Variáveis Principais

| Variável | Descrição |
|----------|-----------|
| `aws_region` | Região AWS de deployment |
| `project_name` | Prefixo usado em todos os recursos |
| `environment` | Ambiente (`dev`, `staging`, `prod`) |
| `instance_type` | Tipo de instância EC2 |
| `asg_min_size` | Mínimo de instâncias no ASG |
| `asg_max_size` | Máximo de instâncias no ASG |
| `db_instance_class` | Classe da instância RDS |

---

## 📤 Outputs

| Output | Descrição |
|--------|-----------|
| `alb_dns_name` | DNS público do Load Balancer |
| `rds_endpoint` | Endpoint de conexão do RDS |
| `vpc_id` | ID da VPC criada |
| `public_subnet_ids` | IDs das subnets públicas |
| `private_subnet_ids` | IDs das subnets privadas |

---

## 📚 Tecnologias

- **Terraform** >= 1.5 · HashiCorp Configuration Language (HCL)
- **AWS** · VPC, EC2, ALB, RDS, S3, DynamoDB, CloudWatch
- **Apache HTTP Server** · User Data bootstrap
- **WSL Ubuntu** · Ambiente de desenvolvimento

---

> ⚠️ **Atenção com custos AWS:** NAT Gateways e RDS geram custos mesmo em ambiente `dev`. Lembre-se de rodar `terraform destroy` após os testes.
