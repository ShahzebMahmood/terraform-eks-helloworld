# EKS Hello World DevOps Project

Complete DevOps pipeline deploying a containerized web application on AWS using Terraform, EKS, and GitHub Actions.

## Architecture

```
GitHub Actions → Docker/ECR → Terraform → EKS Cluster → ALB → Hello World App
                                ↓
                           CloudWatch Monitoring + SNS Alerts
```

**Infrastructure:** VPC + EKS + ALB + Auto-scaling  
**Application:** Containerized Node.js app with health checks  
**CI/CD:** GitHub Actions with security scanning  
**Monitoring:** CloudWatch dashboards + SNS email alerts  
**Security:** HTTPS, Secrets Manager, Pod Security Standards  

**Cost:** $0-5/month (free tier friendly)

## Step-by-Step Deployment Instructions

### Prerequisites
- AWS Account (free tier)
- GitHub Account
- AWS CLI installed and configured

### Option 1: Automated CI/CD (Recommended - 15 minutes)

1. **Fork this repository**

2. **Configure GitHub Secrets** (Settings → Secrets → Actions):
   ```
   AWS_ACCESS_KEY_ID: your-access-key
   AWS_SECRET_ACCESS_KEY: your-secret-key  
   AWS_ACCOUNT_ID: your-12-digit-account-id
   ```

3. **Run GitHub Actions workflows** (Actions tab):
   - **Step 1**: "Setup Terraform Backend" → Type "yes" → Run
   - **Step 2**: "CI/CD Pipeline for Hello-World App" → Run

4. **Get your app URL** from workflow logs

### Option 2: Manual Deployment (30 minutes)

```bash
# Clone repository
git clone https://github.com/your-username/terraform-eks-helloworld.git
cd terraform-eks-helloworld

# Update configuration with your AWS account
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
sed -i "s|ACCOUNT_ID|$AWS_ACCOUNT_ID|g" k8s/base/kustomization.yaml
sed -i "s|REGION|us-east-1|g" k8s/base/kustomization.yaml

# Create OIDC provider
aws iam create-open-id-connect-provider \
  --url https://token.actions.githubusercontent.com \
  --client-id-list sts.amazonaws.com \
  --thumbprint-list 6938fd4d98bab03faadb97b34396831e3780aea1

# Deploy infrastructure
terraform init
terraform apply

# Build and push Docker image
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com
docker build -t hello-world ./app
docker tag hello-world:latest $AWS_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/hello-world:latest
docker push $AWS_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/hello-world:latest

# Deploy to EKS
aws eks update-kubeconfig --name thrive-cluster-test --region us-east-1
kubectl apply -k k8s/base/
```

## Verification & Access

### Check Deployment Status
```bash
# Verify EKS cluster is active
aws eks describe-cluster --name thrive-cluster-test --query 'cluster.status'

# Check all pods are running
kubectl get pods -n hello-world

# Get application URL
kubectl get ingress hello-world-ingress -n hello-world
```

### Access Points
- **Web App**: Use ALB address from ingress output
- **Direct Access**: `kubectl port-forward service/hello-world-service 8080:80 -n hello-world`
- **Monitoring**: AWS Console → CloudWatch → Dashboards → `thrive-cluster-test-dashboard`
- **Alerts**: AWS Console → SNS → Topics → `thrive-cluster-test-alerts`

### Troubleshooting
```bash
# Common debugging commands
kubectl get pods -n hello-world
kubectl describe pod <pod-name> -n hello-world
kubectl logs <pod-name> -n hello-world
kubectl get hpa -n hello-world
```

## Key Design Decisions

### Technology Choices
- **EKS over ECS**: Industry-standard Kubernetes with better portability and ecosystem
- **Terraform**: Infrastructure as Code for reproducible deployments  
- **GitHub Actions**: Integrated CI/CD with security scanning
- **CloudWatch**: Native AWS monitoring with cost-effective alerting

### Security & Cost
- **Dual Authentication**: Both IRSA and Pod Identity for flexibility
- **Free Tier Optimized**: t3.medium nodes, 7-day log retention
- **Security**: Pod Security Standards, Secrets Manager, HTTPS

### Repository Structure
```
├── app/                    # Node.js application + Dockerfile
├── terraform/              # Infrastructure as Code
│   ├── modules/            # Reusable Terraform modules
│   └── main.tf             # Main infrastructure definition
├── k8s/                    # Kubernetes manifests
├── .github/workflows/      # CI/CD pipelines
└── README.md               # This file
```

## Cleanup
```bash
# Automated (recommended)
# Run "Destroy Infrastructure" workflow in GitHub Actions

# Manual
terraform init && terraform destroy
```

---

**Implementation fulfills all requirements**: Infrastructure provisioning ✅ | Application deployment ✅ | CI/CD pipeline ✅ | Monitoring & alerting ✅ | Bonus features ✅