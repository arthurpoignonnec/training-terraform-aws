vpc_cidr        = "10.1.0.0/16"
private_subnets = ["10.1.1.0/24", "10.1.2.0/24"]
public_subnets  = ["10.1.101.0/24", "10.1.102.0/24"]

instance_class         = "db.t3.micro"
db_name               = "api_production"
db_username           = "api_user"
service_desired_count = 3

availability_zones = ["eu-west-3a", "eu-west-3b"]