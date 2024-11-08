# environments/dev/main.tf
locals {
  app_domain = "${var.project}-${var.environment}.${var.root_domain}"
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
  s3_user_uploads_bucket_arn = module.s3_user_uploads.bucket_arn
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
  certificate_arn      = module.acm.certificate_validation_arn
  app_domain           = local.app_domain
  backend_health_check_path = "/"

  depends_on = [module.acm]
}

# Backend Service
module "backend_service" {
  source = "../../modules/backend-service"

  project     = var.project
  environment = var.environment

  ecs_cluster_id = module.ecs_cluster.cluster_id
  private_subnet_ids = module.networking.private_subnet_ids
  security_group_id = module.security.backend_security_group_id
  execution_role_arn = module.security.ecs_task_execution_backend_role_arn
  task_role_arn = module.security.backend_task_role_arn
  health_check_path = "/"

  alb_target_group_arn = module.alb.backend_target_group_arn
  alb_listener_arn     = module.alb.https_listener_arn
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
      name  = "APP_PORT"
      value = "3000"
    },
    {
      name: "S3_BUCKET_NAME"
      value: module.s3_user_uploads.bucket_name
    }
  ]

  secrets = [
    {
      name      = "MONGO_PROTOCOL"
      valueFrom = "arn:aws:ssm:${var.aws_region}:${data.aws_caller_identity.current.account_id}:parameter/${var.project}/${var.environment}/mongo_protocol"
    },
    {
      name      = "MONGO_HOST"
      valueFrom = "arn:aws:ssm:${var.aws_region}:${data.aws_caller_identity.current.account_id}:parameter/${var.project}/${var.environment}/mongo_host"
    },
    {
      name      = "MONGO_DB"
      valueFrom = "arn:aws:ssm:${var.aws_region}:${data.aws_caller_identity.current.account_id}:parameter/${var.project}/${var.environment}/mongo_db"
    },
    {
      name      = "MONGO_USER"
      valueFrom = "arn:aws:ssm:${var.aws_region}:${data.aws_caller_identity.current.account_id}:parameter/${var.project}/${var.environment}/mongo_user"
    },
    {
      name      = "MONGO_PASS"
      valueFrom = "arn:aws:ssm:${var.aws_region}:${data.aws_caller_identity.current.account_id}:parameter/${var.project}/${var.environment}/mongo_pass"
    },
    {
      name      = "SECRET_KEY"
      valueFrom = "arn:aws:ssm:${var.aws_region}:${data.aws_caller_identity.current.account_id}:parameter/${var.project}/${var.environment}/secret_key"
    }
  ]

  depends_on = [module.acm]
}

# Frontend Service
module "frontend_service" {
  source = "../../modules/frontend-service"

  project     = var.project
  environment = var.environment

  ecs_cluster_id = module.ecs_cluster.cluster_id
  private_subnet_ids = module.networking.private_subnet_ids
  security_group_id = module.security.frontend_security_group_id
  alb_target_group_arn = module.alb.frontend_target_group_arn
  alb_listener_arn     = module.alb.https_listener_arn
  execution_role_arn = module.security.ecs_task_execution_frontend_role_arn
  task_role_arn = module.security.frontend_task_role_arn

  ecr_repository_url = var.frontend_image.repository_url
  container_image_tag = var.frontend_image.tag
  backend_service_url = "api.${local.app_domain}"

  container_port = 8080
  container_cpu = 256
  container_memory = 512
  desired_count = 2

  depends_on = [module.alb, module.acm]

  environment_variables = [
    {
      name  = "NODE_ENV"
      value = var.environment
    },
    {
      name  = "APP_API_URL"
      value = "https://api-${local.app_domain}"
    }
  ]
}

# Cloudflare DNS Records
module "dns" {
  source = "../../modules/dns"

  project            = var.project
  environment        = var.environment
  cloudflare_zone_id = var.cloudflare_zone_id
  alb_dns_name       = module.alb.alb_dns_name
  enable_proxy       = true
}

module "acm" {
  source = "../../modules/acm"

  project     = var.project
  environment = var.environment
  root_domain  = var.root_domain
  cloudflare_zone_id      = var.cloudflare_zone_id
}

module "s3_user_uploads" {
  source = "../../modules/s3_user_uploads"

  bucket_name = "${var.project}-${var.environment}-user-uploads"
  environment = var.environment
  project     = var.project
  allowed_origins = [
    "http://localhost:${module.backend_service.container_port}",
    "https://*${local.app_domain}"
  ]
}

# Data sources
data "aws_caller_identity" "current" {}