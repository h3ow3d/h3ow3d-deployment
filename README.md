# h3ow3d-deployment

Terraform deployment orchestration for h3ow3d platform. This repository manages the deployed state and composes reusable modules from `h3ow3d-infra`.

## Structure

```
h3ow3d-deployment/
├── main.tf              # Root module - orchestrates all infrastructure
├── variables.tf         # Input variables
├── outputs.tf          # Outputs from deployment
├── terraform.tfvars    # Environment-specific values (gitignored)
├── backend.tf          # Terraform state backend
├── versions.tf         # Provider versions
└── scripts/            # Deployment and utility scripts
```

## Architecture

This repository **uses** modules from `h3ow3d-infra`:
- Network module (VPC, subnets, security groups)
- ECS module (cluster, services, ALB)
- Frontend module (S3, CloudFront, artifacts)
- Auth service module (Fargate service, ECR)
- Cognito module (user pool, OAuth)
- Monitoring module (CloudWatch RUM)

## Prerequisites

- Terraform >= 1.14.1
- AWS CLI configured
- Access to h3ow3d-infra modules (local path or git)

## Quick Start

### 1. Initial Setup

```bash
# Clone alongside h3ow3d-infra
cd /Users/samholden/Git/personal
git clone <h3ow3d-deployment-url>

# Directory structure should be:
# personal/
#   ├── h3ow3d-infra/
#   └── h3ow3d-deployment/

cd h3ow3d-deployment
```

### 2. Configure Variables

```bash
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values
```

### 3. Deploy

```bash
terraform init
terraform plan
terraform apply
```

## Module Sources

Modules are sourced from the `h3ow3d-infra` repository using git refs:

```hcl
module "networking" {
  source = "git::https://github.com/h3ow3d/h3ow3d-infra.git//modules/networking?ref=v1.0.0"
  # ...
}
```

### Version Control

Set the module version in `terraform.tfvars`:

```hcl
infra_module_version = "v1.0.0"  # Production: use tags
infra_module_version = "main"     # Development: use latest
```

See [MODULE_VERSIONING.md](docs/MODULE_VERSIONING.md) for detailed guide.

## Deployment Workflow

```
1. Update h3ow3d-infra modules (if needed)
2. cd h3ow3d-deployment
3. terraform plan
4. terraform apply
5. Deploy application code (frontend/auth)
```

## State Management

Terraform state is stored in:
- **Backend**: S3 bucket (configured in backend.tf)
- **Locking**: DynamoDB table
- **Encryption**: AES256

## Deploying Application Code

### Frontend
```bash
./scripts/deploy-frontend.sh [commit-sha]
```

### Auth Service
```bash
./scripts/deploy-auth.sh [version]
```

## Multiple Environments

To deploy multiple environments, use workspaces or separate directories:

```
h3ow3d-deployment/
├── production/
│   ├── main.tf
│   └── terraform.tfvars
├── staging/
│   ├── main.tf
│   └── terraform.tfvars
└── development/
    ├── main.tf
    └── terraform.tfvars
```

## Related Repositories

- [h3ow3d-infra](../h3ow3d-infra): Reusable Terraform modules
- [h3ow3d-frontend](../h3ow3d-frontend): Frontend application
- [h3ow3d-auth](../h3ow3d-auth): Authentication service

## Outputs

Important outputs after deployment:

```bash
terraform output alb_dns_name
terraform output s3_bucket_name
terraform output ecr_repository_url
terraform output cognito_user_pool_id
```

## Troubleshooting

### State Lock Issues
```bash
terraform force-unlock <lock-id>
```

### Module Not Found
Ensure h3ow3d-infra is cloned at `../h3ow3d-infra`

### State Backend Not Configured
Run `terraform init -reconfigure`
