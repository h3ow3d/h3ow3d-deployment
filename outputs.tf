# Networking Outputs
output "vpc_id" {
  description = "ID of the VPC"
  value       = module.networking.vpc_id
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = module.networking.private_subnet_ids
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = module.networking.public_subnet_ids
}

# ECS Outputs
output "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  value       = module.ecs_cluster.cluster_name
}

output "ecs_cluster_arn" {
  description = "ARN of the ECS cluster"
  value       = module.ecs_cluster.cluster_arn
}

# Auth Service Outputs
output "auth_service_alb_dns_name" {
  description = "DNS name of the auth service Application Load Balancer"
  value       = module.auth_service.alb_dns_name
}

output "auth_service_url" {
  description = "URL to access the auth service"
  value       = module.auth_service.alb_dns_name != null ? "http://${module.auth_service.alb_dns_name}" : null
}

output "auth_service_ecr_repository_url" {
  description = "URL of the ECR repository for auth service"
  value       = module.auth_service.ecr_repository_url
}

output "auth_service_name" {
  description = "Name of the auth ECS service"
  value       = module.auth_service.service_name
}

# Frontend Outputs
output "s3_bucket_name" {
  description = "Name of the S3 bucket for the frontend"
  value       = module.frontend.s3_bucket_name
}

output "cloudfront_domain_name" {
  description = "CloudFront distribution domain name"
  value       = module.frontend.cloudfront_domain_name
}

output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID"
  value       = module.frontend.cloudfront_distribution_id
}

output "artifacts_bucket_name" {
  description = "S3 bucket name for build artifacts"
  value       = module.frontend.artifacts_bucket_name
}

# Cognito Outputs
output "cognito_user_pool_id" {
  description = "Cognito User Pool ID"
  value       = module.cognito.user_pool_id
}

output "cognito_client_id" {
  description = "Cognito App Client ID"
  value       = module.cognito.client_id
}

output "cognito_domain" {
  description = "Cognito hosted UI domain"
  value       = module.cognito.domain
}

# Monitoring Outputs
output "rum_app_monitor_id" {
  description = "CloudWatch RUM App Monitor ID"
  value       = module.monitoring.app_monitor_id
}

output "rum_identity_pool_id" {
  description = "Cognito Identity Pool ID for RUM"
  value       = module.monitoring.identity_pool_id
}

# Deployment Summary
output "deployment_summary" {
  description = "Summary of deployed resources"
  value = {
    environment      = var.environment
    region          = var.aws_region
    frontend_url    = "https://${module.frontend.cloudfront_domain_name}"
    auth_api_url    = module.auth_service.alb_dns_name != null ? "http://${module.auth_service.alb_dns_name}" : null
    cognito_domain  = module.cognito.domain
  }
}
