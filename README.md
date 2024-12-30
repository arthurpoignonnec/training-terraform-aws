# Infrastructure as Code avec Terraform, GitHub Actions et AWS

## Table des matières

1. Introduction
2. Prérequis
3. Concepts fondamentaux
4. Configuration de l'environnement
5. Terraform - Notions de base
6. GitHub Actions - Introduction
7. Création de l'infrastructure AWS
8. Automatisation du déploiement
9. Bonnes pratiques
10. Exercices pratiques

## 1. Introduction

L'Infrastructure as Code (IaC) permet d'automatiser le déploiement et la gestion des infrastructures cloud. Dans ce cours, nous allons apprendre à :

- Utiliser Terraform pour définir et gérer l'infrastructure AWS
- Automatiser les déploiements avec GitHub Actions
- Appliquer les bonnes pratiques DevOps

## 2. Prérequis

### Outils nécessaires

- Un compte AWS
- Un compte GitHub
- Terraform installé localement
- AWS CLI configuré
- Un éditeur de code (VS Code recommandé)

### Connaissances requises

- Bases de Git
- Compréhension basique d'AWS
- Notions de YAML et HCL (HashiCorp Configuration Language)

## 3. Concepts fondamentaux

### Terraform

- Outil d'Infrastructure as Code
- Déclaratif et indépendant du fournisseur
- Gestion de l'état de l'infrastructure
- Plan d'exécution et application des changements

### GitHub Actions

- Service d'intégration continue (CI) et de déploiement continu (CD)
- Déclencheurs automatiques sur événements Git
- Workflows configurables en YAML
- Gestion des secrets et variables d'environnement

### AWS

- Services principaux utilisés
- IAM et gestion des droits
- Concepts de VPC, EC2, S3, etc.

## 4. Configuration de l'environnement

### Configuration AWS

```bash
# Installation de AWS CLI
aws configure
AWS Access Key ID [None]: VOTRE_ACCESS_KEY
AWS Secret Access Key [None]: VOTRE_SECRET_KEY
Default region name [None]: eu-west-3
Default output format [None]: json
```

### Configuration Terraform

```hcl
# Configuration du provider AWS
provider "aws" {
  region = "eu-west-3"
}

# Configuration du backend S3
terraform {
  backend "s3" {
    bucket = "terraform-state-bucket"
    key    = "terraform.tfstate"
    region = "eu-west-3"
  }
}
```

### Configuration GitHub

- Création des secrets dans GitHub :
  - AWS_ACCESS_KEY_ID
  - AWS_SECRET_ACCESS_KEY
  - TERRAFORM_STATE_BUCKET

## 5. Terraform - Notions de base

### Structure d'un projet Terraform

```
project/
├── main.tf
├── variables.tf
├── outputs.tf
└── terraform.tfvars
```

### Exemple de configuration réseau

```hcl
# Création d'un VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "main-vpc"
    Environment = var.environment
  }
}

# Création d'un sous-réseau public
resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "public-subnet"
  }
}
```

## 6. GitHub Actions - Introduction

### Structure d'un workflow

```yaml
name: "Terraform Deploy"

on:
  push:
    branches:
      - main
  pull_request:

jobs:
  terraform:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v2

      - name: Terraform Init
        run: terraform init

      - name: Terraform Plan
        run: terraform plan

      - name: Terraform Apply
        if: github.ref == 'refs/heads/main'
        run: terraform apply -auto-approve
```

## 7. Création de l'infrastructure AWS

### Infrastructure complète

```hcl
# VPC et réseau
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
}

# Sous-réseaux publics
resource "aws_subnet" "public" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.${count.index + 1}.0/24"
  availability_zone = data.aws_availability_zones.available.names[count.index]
}

# Security Group
resource "aws_security_group" "app" {
  name        = "app-sg"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 Instance
resource "aws_instance" "app" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public[0].id

  tags = {
    Name = "app-server"
  }
}
```

## 8. Automatisation du déploiement

### Workflow complet

```yaml
name: "Infrastructure Deployment"

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  terraform:
    name: "Terraform"
    runs-on: ubuntu-latest

    env:
      AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
      AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}

    steps:
      - name: Checkout
        uses: actions/checkout@v3

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v2

      - name: Terraform Format
        run: terraform fmt -check

      - name: Terraform Init
        run: terraform init

      - name: Terraform Plan
        run: terraform plan -no-color

      - name: Terraform Apply
        if: github.ref == 'refs/heads/main' && github.event_name == 'push'
        run: terraform apply -auto-approve
```

## 9. Bonnes pratiques

### Sécurité

- Utilisation de rôles IAM avec privilèges minimaux
- Chiffrement des secrets et données sensibles
- Isolation des environnements

### Organisation du code

- Utilisation de modules Terraform
- Variables pour la configuration
- Documentation du code
- Tests d'infrastructure

### Gestion des états

- Stockage distant des états Terraform
- Verrouillage des états
- Sauvegarde des états

## 10. Exercices pratiques

### Exercice 1 : Déploiement basique

1. Créer un VPC avec deux sous-réseaux
2. Déployer une instance EC2
3. Configurer la sécurité

### Exercice 2 : Pipeline CI/CD

1. Créer un workflow GitHub Actions
2. Automatiser les tests
3. Déployer automatiquement

### Exercice 3 : Haute disponibilité

1. Configurer un load balancer
2. Déployer dans plusieurs AZ
3. Mettre en place l'auto-scaling
