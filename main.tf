# Main deployment orchestration
# This file composes modules from GitHub repositories
# Note: Module source must be static - cannot use variables or locals
# To update module versions, change the ?ref= value directly

locals {
  common_tags = merge(var.tags, {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  })
}

# Networking Module
module "networking" {
  source = "git::https://github.com/h3ow3d/h3ow3d-infra-networking.git?ref=main"

  project_name       = var.project_name
  environment        = var.environment
  vpc_cidr           = var.vpc_cidr
  availability_zones = var.availability_zones
  tags               = local.common_tags
}

# ECS Cluster Module
module "ecs_cluster" {
  source = "git::https://github.com/h3ow3d/h3ow3d-infra-ecs-cluster.git?ref=main"

  project_name = var.project_name
  environment  = var.environment
  tags         = local.common_tags
}

# Cognito Module
module "cognito" {
  source = "git::https://github.com/h3ow3d/h3ow3d-infra-cognito.git?ref=main"

  project_name         = var.project_name
  environment          = var.environment
  google_client_id     = var.google_client_id
  google_client_secret = var.google_client_secret
  callback_urls        = [
    "http://localhost:5173",
    var.domain_name != "" ? "https://${var.domain_name}" : ""
  ]
  tags = local.common_tags
}

# Frontend Module (S3 + CloudFront + Artifacts)
module "frontend" {
  source = "git::https://github.com/h3ow3d/h3ow3d-infra-frontend.git?ref=main"

  project_name = var.project_name
  environment  = var.environment
  tags         = local.common_tags
}

# Auth Service Module (Generic ECS Service)
module "auth_service" {
  source = "git::https://github.com/h3ow3d/h3ow3d-infra-ecs-service.git?ref=main"

  project_name       = var.project_name
  environment        = var.environment
  service_name       = "auth"
  aws_region         = var.aws_region
  
  # ECS Configuration
  ecs_cluster_id     = module.ecs_cluster.cluster_id
  desired_count      = var.auth_service_desired_count
  cpu                = var.auth_service_cpu
  memory             = var.auth_service_memory
  
  # Networking
  vpc_id             = module.networking.vpc_id
  private_subnet_ids = module.networking.private_subnet_ids
  public_subnet_ids  = module.networking.public_subnet_ids
  security_group_ids = [module.networking.ecs_tasks_security_group_id]
  alb_security_group_id = module.networking.alb_security_group_id
  
  # Container Configuration
  container_port = 3001
  image_tag      = var.auth_service_image_tag
  
  environment_variables = {
    NODE_ENV             = var.environment
    COGNITO_USER_POOL_ID = module.cognito.user_pool_id
    COGNITO_CLIENT_ID    = module.cognito.client_id
    COGNITO_REGION       = var.aws_region
    ALLOWED_ORIGINS      = join(",", var.allowed_origins)
  }
  
  # Logging
  log_group_name = module.ecs_cluster.log_group_name
  
  # Health Checks
  health_check_command = ["CMD-SHELL", "wget --no-verbose --tries=1 --spider http://localhost:3001/health || exit 1"]
  health_check_path    = "/health"
  
  # IAM - Custom policy for Cognito access
  task_role_policy_json = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "cognito-idp:GetUser",
        "cognito-idp:AdminGetUser",
        "cognito-idp:AdminUpdateUserAttributes"
      ]
      Resource = module.cognito.user_pool_arn
    }]
  })
  
  tags = local.common_tags
}

# CloudWatch RUM Module
module "monitoring" {
  source = "git::https://github.com/h3ow3d/h3ow3d-infra-monitoring.git?ref=main"

  project_name = var.project_name
  environment  = var.environment
  tags         = local.common_tags
}
