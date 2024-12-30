vpc_cidr        = "10.0.0.0/16"
private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

instance_class         = "db.t3.micro"
db_name               = "api_staging"
db_username           = "api_user"
service_desired_count = 2

availability_zones = ["eu-west-3a", "eu-west-3b"]