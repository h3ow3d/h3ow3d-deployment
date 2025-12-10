# GitHub Actions Workflows for h3ow3d-deployment

This repository uses GitHub Actions for automated Terraform deployment management.

## Workflows

### 1. Terraform Plan (`terraform-plan.yml`)
**Trigger:** Pull requests to `main` with Terraform file changes

**What it does:**
- ✅ Format check
- ✅ Terraform init & validate
- ✅ Generate plan
- ✅ Comment plan on PR
- ✅ Security scans (tfsec, Checkov)

### 2. Terraform Apply (`terraform-apply.yml`)
**Trigger:** 
- Push to `main` with Terraform changes (auto-deploy)
- Manual workflow dispatch (requires typing "apply")

**What it does:**
- 🚀 Run terraform apply
- 📊 Post deployment summary
- 🔒 Requires production environment approval

### 3. Terraform Destroy (`terraform-destroy.yml`)
**Trigger:** Manual workflow dispatch only

**What it does:**
- 💥 Destroy all infrastructure
- ⚠️ Requires typing "destroy-production" to confirm
- 🔒 Production environment protection required

### 4. Drift Detection (`drift-detection.yml`)
**Trigger:** 
- Daily at 9 AM UTC
- Manual workflow dispatch

**What it does:**
- 🔍 Detect infrastructure drift
- 📋 Create GitHub issue if drift found
- ✅ Silent if no drift

## Setup Required

### 1. AWS Credentials
Add to GitHub repository secrets:
```
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
```

Add to repository variables:
```
AWS_REGION (default: eu-west-2)
```

### 2. Environment Protection (Optional but Recommended)
Go to: Settings → Environments → Create `production` environment

Then add to workflow files:
```yaml
jobs:
  terraform-apply:
    environment: production  # Add this line
```

Configure:
- ✅ Required reviewers (you)
- ✅ Wait timer (optional)
- ✅ Deployment branches: `main` only

### 3. Backend Configuration
Ensure `backend.tf` is configured with your S3 state backend.

## Usage Examples

### Deploy via PR
1. Create branch with Terraform changes
2. Open PR → Plan runs automatically
3. Review plan in PR comments
4. Merge PR → Apply runs automatically

### Manual Deployment
1. Go to Actions → Terraform Apply
2. Click "Run workflow"
3. Type "apply" to confirm
4. Approve in production environment

### Check for Drift
1. Go to Actions → Drift Detection
2. Click "Run workflow"
3. Check for new issues

### Emergency Destroy
1. Go to Actions → Terraform Destroy
2. Click "Run workflow"
3. Type "destroy-production" to confirm
4. Approve in production environment

## Best Practices

✅ Always review plans before applying  
✅ Use PR workflow for changes  
✅ Enable environment protection for production  
✅ Monitor drift detection issues  
✅ Keep AWS credentials rotated  
✅ Use specific module versions (tags) in `main.tf`
