# environments/dev/main.tf
locals {
  name_prefix = "${var.project}-${var.environment}"
}

# Networking
module "networking" {
  source = "../../modules/networking"

  project           = var.project
  environment       = var.environment
  vpc_cidr         = var.vpc_cidr
  azs              = var.availability_zones
  private_subnets  = [for k, v in var.availability_zones : cidrsubnet(var.vpc_cidr, 4, k)]
  public_subnets   = [for k, v in var.availability_zones : cidrsubnet(var.vpc_cidr, 4, k + 4)]
}

# Security Groups
module "security" {
  source = "../../modules/security"

  project     = var.project
  environment = var.environment
  vpc_id      = module.networking.vpc_id
  vpc_cidr    = var.vpc_cidr
}

# ECS Cluster
module "ecs_cluster" {
  source = "../../modules/ecs-cluster"

  project                = var.project
  environment           = var.environment
  vpc_id                = module.networking.vpc_id
  enable_container_insights = true
}

# Application Load Balancer
module "alb" {
  source = "../../modules/alb"

  project              = var.project
  environment          = var.environment
  vpc_id               = module.networking.vpc_id
  public_subnet_ids    = module.networking.public_subnet_ids
  security_group_id    = module.security.alb_security_group_id
  certificate_arn      = module.acm.certificate_arn
  domain_name          = var.domain_name
}

# Backend Service
module "backend_service" {
  source = "../../modules/backend-service"

  project     = var.project
  environment = var.environment
  vpc_id      = module.networking.vpc_id

  ecs_cluster_id = module.ecs_cluster.cluster_id
  private_subnet_ids = module.networking.private_subnet_ids
  security_group_id = module.security.backend_security_group_id
  execution_role_arn = module.security.ecs_task_execution_role_arn
  task_role_arn = module.security.backend_task_role_arn

  service_discovery_namespace_id = module.ecs_cluster.service_discovery_namespace_id
  ecr_repository_url = var.backend_image.repository_url
  container_image_tag = var.backend_image.tag

  container_port = 3000
  container_cpu = 512
  container_memory = 1024
  desired_count = 2

  environment_variables = [
    {
      name  = "NODE_ENV"
      value = var.environment
    },
    {
      name  = "PORT"
      value = "3000"
    }
  ]

  secrets = [
    {
      name      = "DATABASE_URL"
      valueFrom = "arn:aws:ssm:${var.aws_region}:${data.aws_caller_identity.current.account_id}:parameter/${var.project}/${var.environment}/database_url"
    }
  ]
}

# Frontend Service
module "frontend_service" {
  source = "../../modules/frontend-service"

  project     = var.project
  environment = var.environment
  vpc_id      = module.networking.vpc_id

  ecs_cluster_id = module.ecs_cluster.cluster_id
  private_subnet_ids = module.networking.private_subnet_ids
  security_group_id = module.security.frontend_security_group_id
  alb_target_group_arn = module.alb.frontend_target_group_arn
  alb_listener_arn     = module.alb.https_listener_arn
  execution_role_arn = module.security.ecs_task_execution_role_arn
  task_role_arn = module.security.frontend_task_role_arn

  ecr_repository_url = var.frontend_image.repository_url
  container_image_tag = var.frontend_image.tag
  backend_service_url = "${var.domain_name}/api"

  container_port = 80
  container_cpu = 256
  container_memory = 512
  desired_count = 2

  depends_on = [module.alb]

  environment_variables = [
    {
      name  = "NODE_ENV"
      value = var.environment
    },
    {
      name  = "API_URL"
      value = "https://${var.domain_name}/api"
    }
  ]
}

# Route 53 DNS Records
module "dns" {
  source = "../../modules/dns"

  project            = var.project
  environment        = var.environment
  domain_name        = var.domain_name
  cloudflare_zone_id = var.cloudflare_zone_id
  alb_dns_name       = module.alb.alb_dns_name
  enable_proxy       = true
}

module "acm" {
  source = "../../modules/acm"

  project     = var.project
  environment = var.environment
  domain_name = var.domain_name
  
  # Include all domains you need to secure
  subject_alternative_names = [
    "*.${var.domain_name}",                    # Wildcard for subdomains
    "api.schedulesync-${var.environment}.${var.domain_name}" # API subdomain
  ]

  cloudflare_zone_id      = var.cloudflare_zone_id
}

# Data sources
data "aws_caller_identity" "current" {}