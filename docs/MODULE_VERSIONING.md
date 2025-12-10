# Module Versioning Guide

## Using Git Refs for Modules

The h3ow3d-deployment repo references modules from h3ow3d-infra using git refs.

### Syntax

```hcl
module "networking" {
  source = "git::https://github.com/h3ow3d/h3ow3d-infra.git//modules/networking?ref=v1.0.0"
  # ...
}
```

### Ref Types

#### 1. **Tags** (Recommended for Production)
```hcl
infra_module_version = "v1.0.0"
```

**Benefits:**
- ✅ Immutable - won't change
- ✅ Semantic versioning
- ✅ Easy rollback
- ✅ Clear release history

**When to use:** Production deployments

#### 2. **Branches**
```hcl
infra_module_version = "main"
infra_module_version = "development"
infra_module_version = "feature/new-module"
```

**Benefits:**
- ✅ Always get latest changes
- ✅ Good for development/testing

**Drawbacks:**
- ⚠️ Can change unexpectedly
- ⚠️ Not reproducible

**When to use:** Development, staging, testing new features

#### 3. **Commit SHA**
```hcl
infra_module_version = "abc123def456789"
```

**Benefits:**
- ✅ Exact version pinning
- ✅ Reproducible
- ✅ For emergency fixes

**When to use:** Pin to specific commit, troubleshooting

## Workflow

### Development
```bash
# Use latest from main branch
infra_module_version = "main"
```

### Staging
```bash
# Use release candidate
infra_module_version = "v1.1.0-rc.1"
```

### Production
```bash
# Use stable release
infra_module_version = "v1.1.0"
```

## Updating Modules

### 1. Update and Test in h3ow3d-infra
```bash
cd h3ow3d-infra
git checkout -b feature/update-networking
# Make changes to modules/networking/
git commit -m "Update networking module"
git push origin feature/update-networking
```

### 2. Test in Deployment (Development)
```bash
cd h3ow3d-deployment

# Update to use feature branch
infra_module_version = "feature/update-networking"

terraform init -upgrade
terraform plan
terraform apply
```

### 3. Release Module Version
```bash
cd h3ow3d-infra
git checkout main
git merge feature/update-networking
git tag -a v1.1.0 -m "Release v1.1.0: Updated networking module"
git push origin main
git push origin v1.1.0
```

### 4. Update Production
```bash
cd h3ow3d-deployment

# Update to stable version
infra_module_version = "v1.1.0"

terraform init -upgrade
terraform plan
terraform apply
```

## Terraform Commands

### Initialize with Modules
```bash
terraform init
```

### Upgrade to New Module Version
```bash
# After changing infra_module_version
terraform init -upgrade
```

### View Module Sources
```bash
terraform providers
```

### Clear Module Cache
```bash
rm -rf .terraform/modules
terraform init
```

## Benefits of This Approach

### ✅ **Version Control**
- Track which module version is deployed
- Easy to see what changed between versions

### ✅ **Reproducibility**
- Same module version = same infrastructure
- Critical for disaster recovery

### ✅ **Testing**
- Test module changes before production
- Use different versions in different environments

### ✅ **Rollback**
- Revert to previous module version easily
- No need to undo git commits

### ✅ **Collaboration**
- Multiple environments can use different versions
- Infrastructure team can work independently

## Alternative: Local Modules (Development Only)

For local development and testing:

```hcl
module "networking" {
  source = "../h3ow3d-infra/modules/networking"
  # ...
}
```

**Use case:** Rapid iteration during module development

**Don't use for:** Production, staging, any shared environments

## Semantic Versioning for Modules

Follow semantic versioning for module releases:

- `v1.0.0` - Initial release
- `v1.0.1` - Bug fixes (backward compatible)
- `v1.1.0` - New features (backward compatible)
- `v2.0.0` - Breaking changes (not backward compatible)

### Breaking Changes

Document breaking changes in release notes:

```markdown
## v2.0.0 (Breaking Changes)

### Changed
- `subnet_count` variable removed, now uses `availability_zones` list length
- Output `subnet_id` renamed to `subnet_ids` (now returns list)

### Migration
1. Update variable: `subnet_count` → `availability_zones = ["az-1", "az-2"]`
2. Update references: `module.networking.subnet_id` → `module.networking.subnet_ids[0]`
```

## Module Registry (Future Enhancement)

Consider publishing modules to:
- **Terraform Registry** (public)
- **Terraform Cloud Private Registry**
- **AWS S3 Private Registry**

Benefits:
- Easier versioning
- Dependency management
- Documentation hosting
