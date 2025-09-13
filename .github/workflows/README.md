# GitHub Actions Workflows

This repository contains two main GitHub Actions workflows for managing the AWS infrastructure.

## 🚀 Deploy Workflow (`deploy.yaml`)

**Triggers:** Automatic on push to `main` or `develop` branches

**What it does:**
- Runs tests and linting
- Creates all AWS infrastructure via Terraform (37 resources)
- Builds and pushes Docker image to ECR
- Deploys application to EKS cluster
- Runs security scans with Trivy

**Resources created:**
- EKS cluster with node groups
- VPC and networking
- ECR repository
- IAM roles and policies
- Secrets Manager secrets
- CloudWatch monitoring
- Billing alerts

## 💥 Destroy Workflow (`destroy.yaml`)

**Triggers:** Manual (workflow_dispatch) - On-demand only

**What it does:**
- Safely destroys all AWS infrastructure
- Cleans up ECR images before destroy
- Verifies destruction was successful
- Provides detailed logging

**How to use:**
1. Go to **Actions** tab in GitHub
2. Select **"Destroy Infrastructure"** workflow
3. Click **"Run workflow"**
4. Type **"DESTROY"** in the confirmation field
5. Click **"Run workflow"** to confirm

## 🔒 Security Features

- **Environment Secrets**: Uses GitHub Environment secrets for AWS credentials
- **Confirmation Required**: Destroy workflow requires explicit confirmation
- **Resource Verification**: Checks that resources are actually destroyed
- **Safe Cleanup**: Removes ECR images before destroying repository

## 💰 Cost Management

- **Free Tier Optimized**: All resources stay within AWS Free Tier limits
- **Easy Cleanup**: One-click destroy to stop all charges
- **Billing Alerts**: Automatic alerts at $3 and $5 thresholds
- **Resource Limits**: Conservative scaling to prevent overruns

## 🛠️ Troubleshooting

### Common Issues:

1. **"Credentials could not be loaded"**
   - Ensure GitHub Environment secrets are configured
   - Check that `AWS_ACCESS_KEY_ID` environment exists

2. **"ECR Repository not empty"**
   - The destroy workflow automatically handles this
   - Images are cleaned up before repository destruction

3. **"OIDC Provider not found"**
   - This is normal for the first run
   - The deploy workflow creates the OIDC provider

### Manual Cleanup:

If the destroy workflow fails, you can manually clean up:

```bash
# Delete ECR images
aws ecr batch-delete-image --repository-name hello-world --image-ids "$(aws ecr list-images --repository-name hello-world --query 'imageIds[*]' --output json)"

# Run terraform destroy
terraform destroy -auto-approve
```

## 📊 Workflow Dependencies

```
test → deploy-infrastructure → build-and-push → deploy-application
```

The destroy workflow runs independently and can be executed at any time.

## 🎯 Best Practices

1. **Always destroy when done testing** to avoid charges
2. **Use the destroy workflow** instead of manual `terraform destroy`
3. **Monitor AWS billing** dashboard regularly
4. **Keep GitHub secrets updated** if you rotate AWS credentials
5. **Test the full cycle** (deploy → test → destroy) regularly
