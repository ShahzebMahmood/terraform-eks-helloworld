# GitHub Actions Workflows

This repository contains GitHub Actions workflows for deploying and managing the Hello-World project.

## 📋 Available Workflows

### 1. Setup Terraform Backend (`setup-backend.yaml`)
**Purpose**: Creates the S3 bucket and DynamoDB table needed for Terraform state storage.

**When to run**: 
- First time setup
- When you need to recreate the backend infrastructure

**How to run**:
1. Go to Actions tab in GitHub
2. Select "Setup Terraform Backend"
3. Click "Run workflow"
4. Type "yes" to confirm
5. Click "Run workflow"

**What it creates**:
- S3 bucket: `thrive-cluster-test-terraform-state`
- DynamoDB table: `thrive-cluster-test-terraform-locks`

### 2. CI/CD Pipeline (`deploy.yaml`)
**Purpose**: Main deployment workflow that builds, tests, and deploys the application.

**When to run**:
- After backend setup is complete
- On code changes (if auto-triggered)
- Manual deployment

**How to run**:
1. Go to Actions tab in GitHub
2. Select "CI/CD Pipeline for Hello-World App"
3. Click "Run workflow"
4. Click "Run workflow"

**What it does**:
- Builds and tests the application
- Creates AWS infrastructure with Terraform
- Deploys application to EKS
- Sets up monitoring and alerting

### 3. Destroy Infrastructure (`destroy.yaml`)
**Purpose**: Destroys all AWS resources to clean up and avoid charges.

**When to run**:
- When you're done with the project
- To clean up resources
- To start fresh

**How to run**:
1. Go to Actions tab in GitHub
2. Select "Destroy Infrastructure"
3. Click "Run workflow"
4. Type "yes" to confirm
5. Click "Run workflow"

## 🚀 Quick Start Guide

### First Time Setup

1. **Set up GitHub Secrets**:
   - Go to repository Settings → Secrets and variables → Actions
   - Add these secrets:
     - `AWS_ACCESS_KEY_ID`: Your AWS access key
     - `AWS_SECRET_ACCESS_KEY`: Your AWS secret key

2. **Create Backend Infrastructure**:
   - Run the "Setup Terraform Backend" workflow
   - Wait for it to complete successfully

3. **Deploy the Application**:
   - Run the "CI/CD Pipeline for Hello-World App" workflow
   - Wait for deployment to complete, this can take about 10-15 minutes

4. **Access Your Application**:
   - Check the workflow logs for the load balancer URL
   - Or use `kubectl get ingress` to get the URL

### Daily Usage

- **Deploy changes**: Just run the "CI/CD Pipeline" workflow
- **Clean up**: Run the "Destroy Infrastructure" workflow when done

## 🔧 Workflow Dependencies

```
Setup Backend → Deploy Infrastructure → Deploy Application
     ↓
Destroy Infrastructure (can run independently)
```

## 📊 Workflow Status

| Workflow | Status | Purpose |
|----------|--------|---------|
| Setup Backend | ✅ Ready | Creates S3/DynamoDB for state |
| Deploy | ✅ Ready | Main CI/CD pipeline |
| Destroy | ✅ Ready | Cleanup resources |

## 🚨 Troubleshooting

### Common Issues

1. **"S3 backend bucket not found"**
   - Solution: Run the "Setup Terraform Backend" workflow first

2. **"DynamoDB lock table not found"**
   - Solution: Run the "Setup Terraform Backend" workflow first

3. **"AWS credentials not configured"**
   - Solution: Add AWS secrets to GitHub repository

4. **"EKS cluster not ready"**
   - Solution: Wait for cluster creation to complete (5-10 minutes)

### Getting Help

1. Check workflow logs in the Actions tab
2. Review the main README.md for detailed troubleshooting
3. Check AWS CloudWatch logs for application issues

## 💡 Pro Tips

- **Always run backend setup first** on new AWS accounts
- **Check workflow logs** for detailed error messages
- **Use destroy workflow** to clean up and avoid charges
- **Monitor costs** in AWS Billing dashboard

---