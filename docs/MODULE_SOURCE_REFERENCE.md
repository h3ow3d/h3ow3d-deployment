# Module Source Reference

Quick reference for different module source scenarios in h3ow3d-deployment.

## Production (Git Tags)

**main.tf:**
```hcl
locals {
  infra_version = var.infra_module_version
}

module "networking" {
  source = "git::https://github.com/h3ow3d/h3ow3d-infra.git//modules/networking?ref=${local.infra_version}"
  # ...
}
```

**terraform.tfvars:**
```hcl
infra_module_version = "v1.0.0"
```

**Commands:**
```bash
terraform init -upgrade
terraform plan
terraform apply
```

## Development (Local Path)

For rapid local development:

**main.tf (temporary change):**
```hcl
module "networking" {
  source = "../h3ow3d-infra/modules/networking"
  # ...
}
```

**⚠️ Important:** Revert to git ref before committing!

## Testing Feature Branch

**terraform.tfvars:**
```hcl
infra_module_version = "feature/new-networking"
```

```bash
terraform init -upgrade
terraform plan
```

## SSH vs HTTPS

### HTTPS (Default)
```hcl
source = "git::https://github.com/h3ow3d/h3ow3d-infra.git//modules/networking?ref=v1.0.0"
```

### SSH (If you use SSH keys)
```hcl
source = "git::git@github.com:h3ow3d/h3ow3d-infra.git//modules/networking?ref=v1.0.0"
```

### Private Repository
```hcl
source = "git::https://oauth2:${var.github_token}@github.com/h3ow3d/h3ow3d-infra.git//modules/networking?ref=v1.0.0"
```

## Module Update Workflow

### 1. Check Current Version
```bash
grep infra_module_version terraform.tfvars
# Output: infra_module_version = "v1.0.0"
```

### 2. Check Available Versions
```bash
cd ../h3ow3d-infra
git fetch --tags
git tag -l
# Output: v1.0.0, v1.1.0, v1.2.0
```

### 3. Update Version
```bash
cd ../h3ow3d-deployment
# Edit terraform.tfvars
infra_module_version = "v1.2.0"
```

### 4. Download New Modules
```bash
terraform init -upgrade
```

### 5. Review Changes
```bash
terraform plan
```

### 6. Apply
```bash
terraform apply
```

## Troubleshooting

### Module Not Found
```
Error: Failed to download module
```

**Solution:**
- Check repository URL is correct
- Verify ref (tag/branch) exists in h3ow3d-infra
- Check network/authentication

```bash
# Verify tag exists
cd ../h3ow3d-infra
git tag -l | grep v1.0.0

# Check remote
git remote -v
```

### Module Cached
```
Error: Module already exists
```

**Solution:**
```bash
rm -rf .terraform/modules
terraform init
```

### Wrong Module Version
```
# Check what's cached
ls -la .terraform/modules/

# Clear and re-download
rm -rf .terraform/modules
terraform init -upgrade
```

## Git Authentication

### Personal Access Token (PAT)

**Create token:**
1. GitHub → Settings → Developer settings → Personal access tokens
2. Generate new token with `repo` scope

**Use in CI/CD:**
```bash
export GITHUB_TOKEN="ghp_your_token_here"

# Terraform will use token from environment
terraform init
```

**Use in source:**
```hcl
source = "git::https://${var.github_token}@github.com/h3ow3d/h3ow3d-infra.git//modules/networking?ref=v1.0.0"
```

### SSH Key

**Setup:**
```bash
# Add SSH key to agent
ssh-add ~/.ssh/id_rsa

# Test connection
ssh -T git@github.com
```

**Use in source:**
```hcl
source = "git::git@github.com:h3ow3d/h3ow3d-infra.git//modules/networking?ref=v1.0.0"
```

## Best Practices

✅ **DO:**
- Use semantic versioning tags (v1.0.0, v1.1.0)
- Pin production to stable tags
- Test new versions in dev/staging first
- Document breaking changes
- Use `-upgrade` flag when updating

❌ **DON'T:**
- Use `main` branch in production
- Skip version testing
- Mix local and remote sources
- Commit with local module paths
- Forget to run `init -upgrade` after version change
