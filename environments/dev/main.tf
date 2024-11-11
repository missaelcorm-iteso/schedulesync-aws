# environments/dev/main.tf
locals {
  app_domain = "${var.project}-${var.environment}.${var.root_domain}"
}

# Networking
module "networking" {
  source = "../../modules/networking"

  project         = var.project
  environment     = var.environment
  vpc_cidr        = var.vpc_cidr
  azs             = var.availability_zones
  private_subnets = [for k, v in var.availability_zones : cidrsubnet(var.vpc_cidr, 4, k)]
  public_subnets  = [for k, v in var.availability_zones : cidrsubnet(var.vpc_cidr, 4, k + 4)]
  docdb_subnets   = [for k, v in var.availability_zones : cidrsubnet(var.vpc_cidr, 4, k + 8)]
}

# Security Groups
module "security" {
  source = "../../modules/security"

  project                                         = var.project
  environment                                     = var.environment
  vpc_id                                          = module.networking.vpc_id
  s3_user_uploads_bucket_arn                      = module.s3_user_uploads.bucket_arn
  aws_secretsmanager_secret_docdb_credentials_arn = module.secrets.docdb_secrets_manager_secret_arn
  aws_secretsmanager_secret_app_jwt_secret_arn    = module.secrets.backend_jwt_secret_arn
}

# ECS Cluster
module "ecs_cluster" {
  source = "../../modules/ecs-cluster"

  project                   = var.project
  environment               = var.environment
  vpc_id                    = module.networking.vpc_id
  enable_container_insights = true
}

# Application Load Balancer
module "alb" {
  source = "../../modules/alb"

  project                   = var.project
  environment               = var.environment
  vpc_id                    = module.networking.vpc_id
  public_subnet_ids         = module.networking.public_subnet_ids
  security_group_id         = module.security.alb_security_group_id
  certificate_arn           = module.acm.certificate_validation_arn
  app_domain                = local.app_domain
  backend_health_check_path = "/"

  depends_on = [module.acm]
}

# Backend Service
module "backend_service" {
  source = "../../modules/backend-service"

  project     = var.project
  environment = var.environment

  ecs_cluster_id     = module.ecs_cluster.cluster_id
  private_subnet_ids = module.networking.private_subnet_ids
  security_group_id  = module.security.backend_security_group_id
  execution_role_arn = module.security.ecs_task_execution_backend_role_arn
  task_role_arn      = module.security.backend_task_role_arn
  health_check_path  = "/"

  alb_target_group_arn = module.alb.backend_target_group_arn
  alb_listener_arn     = module.alb.https_listener_arn
  ecr_repository_url   = var.backend_image.repository_url
  container_image_tag  = var.backend_image.tag

  container_port   = 3000
  container_cpu    = 512
  container_memory = 1024
  desired_count    = 2

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
      name  = "MONGO_PROTOCOL"
      value = "mongodb"
    },
    {
      name  = "MONGO_ARGS"
      value = "tls=true&replicaSet=rs0&readPreference=secondaryPreferred&retryWrites=false"
    },
    {
      name : "S3_BUCKET_NAME"
      value : module.s3_user_uploads.bucket_name
    },
    {
      name : "AWS_REGION"
      value : var.aws_region
    }
  ]

  secrets = [
    {
      name      = "MONGO_HOST"
      valueFrom = "${module.secrets.docdb_secrets_manager_secret_arn}:host::"
    },
    {
      name      = "MONGO_PORT"
      valueFrom = "${module.secrets.docdb_secrets_manager_secret_arn}:port::"
    },
    {
      name      = "MONGO_DB"
      valueFrom = "${module.secrets.docdb_secrets_manager_secret_arn}:dbname::"
    },
    {
      name      = "MONGO_USER"
      valueFrom = "${module.secrets.docdb_secrets_manager_secret_arn}:username::"
    },
    {
      name      = "MONGO_PASS"
      valueFrom = "${module.secrets.docdb_secrets_manager_secret_arn}:password::"
    },
    {
      name      = "SECRET_KEY"
      valueFrom = "${module.secrets.backend_jwt_secret_arn}:secretkey::"
    }
  ]

  depends_on = [module.acm]
}

# Frontend Service
module "frontend_service" {
  source = "../../modules/frontend-service"

  project     = var.project
  environment = var.environment

  ecs_cluster_id       = module.ecs_cluster.cluster_id
  private_subnet_ids   = module.networking.private_subnet_ids
  security_group_id    = module.security.frontend_security_group_id
  alb_target_group_arn = module.alb.frontend_target_group_arn
  alb_listener_arn     = module.alb.https_listener_arn
  execution_role_arn   = module.security.ecs_task_execution_frontend_role_arn
  task_role_arn        = module.security.frontend_task_role_arn

  ecr_repository_url  = var.frontend_image.repository_url
  container_image_tag = var.frontend_image.tag

  container_port   = 8080
  container_cpu    = 256
  container_memory = 512
  desired_count    = 2

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

  project            = var.project
  environment        = var.environment
  root_domain        = var.root_domain
  cloudflare_zone_id = var.cloudflare_zone_id
}

module "s3_user_uploads" {
  source = "../../modules/s3_user_uploads"

  bucket_name           = "${var.project}-${var.environment}-user-uploads"
  environment           = var.environment
  project               = var.project
  backend_task_role_arn = module.security.backend_task_role_arn
  allowed_origins = [
    "http://localhost:${module.backend_service.container_port}",
    "https://*${local.app_domain}"
  ]
}

module "secrets" {
  source = "../../modules/secrets"

  project                       = var.project
  environment                   = var.environment
  docdb_host                    = module.documentdb.cluster_endpoint
  docdb_port                    = module.documentdb.cluster_port
  docdb_recovery_window_in_days = 0
}

module "documentdb" {
  source = "../../modules/documentdb"

  project          = var.project
  environment      = var.environment
  master_username  = module.secrets.docdb_credentials_master_username
  master_password  = module.secrets.docdb_credentials_master_password
  documentdb_sg_id = module.security.documentdb_security_group_id
  subnet_ids       = module.networking.docdb_private_subnet_ids

  instance_class = "db.t3.medium"
  instance_count = 1

  backup_retention_period = 7
  deletion_protection     = false
  apply_immediately       = true
  tls_enabled             = true
}
