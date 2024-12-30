# Networking
module "networking" {
  source = "../../modules/networking"

  environment         = var.environment
  vpc_cidr           = var.vpc_cidr
  private_subnets    = var.private_subnets
  public_subnets     = var.public_subnets
  availability_zones = var.availability_zones
}

# Database
module "database" {
  source = "../../modules/database"

  environment           = var.environment
  vpc_id               = module.networking.vpc_id
  private_subnet_ids   = module.networking.private_subnet_ids
  instance_class       = var.instance_class
  db_name              = var.db_name
  db_username          = var.db_username
  db_password          = var.db_password
  ecs_security_group_id = module.ecs.ecs_security_group_id

  depends_on = [module.networking]
}

# ECS Cluster et Service
module "ecs" {
  source = "../../modules/ecs"

  environment         = var.environment
  vpc_id             = module.networking.vpc_id
  private_subnet_ids = module.networking.private_subnet_ids
  
  ecr_repository_url = var.ecr_repository_url
  image_tag          = var.image_tag
  
  cpu                 = 256
  memory              = 512
  service_desired_count = var.service_desired_count

  # Configuration de la base de données
  db_host         = module.database.db_endpoint
  db_name         = var.db_name
  db_username     = var.db_username
  db_password_arn = module.database.db_password_secret_arn

  depends_on = [module.networking, module.database]
}

# Outputs
output "api_endpoint" {
  description = "L'endpoint de l'API"
  value       = module.ecs.api_endpoint
}

output "database_endpoint" {
  description = "L'endpoint de la base de données"
  value       = module.database.db_endpoint
}