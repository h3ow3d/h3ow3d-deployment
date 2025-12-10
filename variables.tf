variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
  default     = "h3ow3d"
}

variable "environment" {
  description = "Environment name (production, staging, development)"
  type        = string
  default     = "production"
}

variable "aws_region" {
  description = "AWS region to deploy resources into"
  type        = string
  default     = "eu-west-2"
}

variable "infra_module_version" {
  description = "Git ref for h3ow3d-infra modules (tag, branch, or commit SHA)"
  type        = string
  default     = "main"  # Change to a tag like "v1.0.0" for production
}

variable "google_client_id" {
  description = "Google OAuth 2.0 client ID for Social Identity Provider"
  type        = string
  sensitive   = true
}

variable "google_client_secret" {
  description = "Google OAuth 2.0 client secret for Social Identity Provider"
  type        = string
  sensitive   = true
}

# Network Configuration
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of availability zones for multi-AZ deployment"
  type        = list(string)
  default     = ["eu-west-2a", "eu-west-2b"]
}

# ECS Configuration
variable "auth_service_desired_count" {
  description = "Desired number of auth service tasks"
  type        = number
  default     = 2
}

variable "auth_service_cpu" {
  description = "CPU units for auth service (256 = 0.25 vCPU)"
  type        = number
  default     = 256
}

variable "auth_service_memory" {
  description = "Memory for auth service in MB"
  type        = number
  default     = 512
}

variable "auth_service_image_tag" {
  description = "Docker image tag for auth service"
  type        = string
  default     = "latest"
}

# Application Configuration
variable "allowed_origins" {
  description = "List of allowed CORS origins for auth service"
  type        = list(string)
  default     = ["*"]
}

variable "domain_name" {
  description = "Custom domain name for the site (optional)"
  type        = string
  default     = ""
}

# Tags
variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}
