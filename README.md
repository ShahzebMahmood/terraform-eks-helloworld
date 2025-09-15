# Hello-World DevOps Project

A technical project demonstrating a complete DevOps pipeline for deploying a web application on AWS.

## 🎯 Requirements Completion Status

This project fulfills all specified requirements and exceeds expectations with bonus features:

### ✅ **Core Requirements (100% Complete)**

| Requirement | Implementation | Status |
|-------------|---------------|--------|
| **Infrastructure Provisioning** | Terraform with modular architecture | ✅ |
| - Virtual Private Cloud (VPC) | Custom VPC with public subnets across 2 AZs | ✅ |
| - Container Orchestration | Amazon EKS with managed node groups | ✅ |
| - Load Balancer | Application Load Balancer with SSL/TLS | ✅ |
| - Auto-scaling | HPA + EKS node group auto-scaling | ✅ |
| **Application Deployment** | Node.js Hello World app | ✅ |
| - Containerization | Docker multi-stage builds | ✅ |
| - Kubernetes Deployment | Kustomize with environment overlays | ✅ |
| - CI/CD Pipeline | GitHub Actions with security scanning | ✅ |
| - Container Registry | Amazon ECR with vulnerability scanning | ✅ |
| **Monitoring & Logging** | CloudWatch + SNS + Billing Alerts | ✅ |
| - Basic Metrics | CPU, Memory, Request metrics exposed | ✅ |
| - Alerting | Email/SNS notifications configured | ✅ |
| - Dashboards | CloudWatch dashboards available | ✅ |

### ⭐ **Bonus Features (Exceeded Expectations)**

| Bonus Feature | Implementation | Status |
|---------------|---------------|--------|
| **HTTPS/TLS** | ALB with SSL certificates and HTTP→HTTPS redirect | ✅ |
| **Blue-Green Deployment** | ArgoCD manifests and deployment strategies | ✅ |
| **Secrets Management** | AWS Secrets Manager integration | ✅ |
| **Health Checks** | Kubernetes liveness/readiness probes | ✅ |
| **Advanced Security** | Pod Security Standards + Network Policies | ✅ |
| **Dual Authentication** | Both IRSA and Pod Identity implementations | ✅ |
| **Cost Optimization** | Free-tier friendly with billing alerts | ✅ |

### 💰 **Cost Structure**
- **Free Tier Usage**: $0-3/month (stays within AWS limits)
- **Typical Learning Cost**: $5-15/month
- **Production Ready**: Scales with usage

## What This Demonstrates

- **Terraform** - Infrastructure as code
- **Amazon EKS** - Kubernetes in the cloud
- **GitHub Actions** - Automated CI/CD
- **CloudWatch** - Monitoring and alerting
- **Docker** - Containerization
- **AWS Secrets Manager** - Secure credential storage
- **Application Load Balancer** - Traffic management

## Architecture

```
GitHub Repo → GitHub Actions → AWS ECR
     ↓
Terraform → AWS EKS ← AWS VPC
     ↓
CloudWatch ← SNS Alerts ← Load Balancer
```

## Implementation Details

### Infrastructure
- VPC with public subnets across 2 availability zones
- EKS Cluster with managed node groups
- Application Load Balancer for internet access
- Auto-scaling with HPA and metrics server

### Application
- Node.js Hello-World app
- Dockerized with multi-stage builds
- Kubernetes deployment with 2 replicas
- Health checks and proper resource limits

### CI/CD
- GitHub Actions workflow for automated builds
- Docker images pushed to ECR
- Automatic deployment to EKS
- Security scanning with Trivy

### Security
- IAM roles with least privilege
- Secrets Manager for sensitive data
- Pod Security Standards set to restricted
- Network policies for micro-segmentation
- Encrypted Terraform state in S3

## Authentication Methods

This project implements both authentication approaches for AWS service access:

### IRSA
- **Deployment**: `hello-world` (2 replicas)
- Mature and stable since 2019
- Wide compatibility with all AWS services
- Manual OIDC setup with full control
- More complex configuration

### Pod Identity
- **Deployment**: `hello-world-pod-identity` (1 replica)
- AWS recommended approach
- Better performance with faster token refresh
- Simpler setup via EKS addon
- Enhanced security with shorter token lifetime

### Switching Between Methods

**Use only Pod Identity:**
```bash
kubectl scale deployment hello-world --replicas=0 -n hello-world
kubectl scale deployment hello-world-pod-identity --replicas=2 -n hello-world
```

**Use only IRSA:**
```bash
kubectl scale deployment hello-world-pod-identity --replicas=0 -n hello-world
kubectl scale deployment hello-world --replicas=2 -n hello-world
```

## Monitoring & Dashboards

After deployment, access your monitoring resources:

- **CloudWatch Dashboard**: AWS Console → CloudWatch → Dashboards → `thrive-cluster-test-dashboard`
- **SNS Alerts**: AWS Console → SNS → Topics → `thrive-cluster-test-alerts`
- **Billing Alerts**: AWS Console → Billing & Cost Management → Budgets
- **EKS Logs**: AWS Console → CloudWatch → Log groups → `/aws/eks/thrive-cluster-test/cluster`

Monitor your applications:
```bash
# Check HPA status
kubectl get hpa -n hello-world

# View pod metrics
kubectl top pods -n hello-world

# Check ingress status
kubectl get ingress -n hello-world
```

## Quick Start

### Prerequisites
- AWS Account (Free Tier works)
- GitHub Account
- AWS CLI configured
- Basic knowledge of Kubernetes and Terraform

### CI/CD Deployment (Recommended - 15-20 minutes)
1. Fork this repository
2. Add GitHub Secrets (Settings → Secrets → Actions):
   - `AWS_ACCESS_KEY_ID` (for initial setup)
   - `AWS_SECRET_ACCESS_KEY` (for initial setup)
   - `AWS_ACCOUNT_ID` (your AWS account ID)
3. Run Workflows (Actions tab):
   - **Step 1**: "Setup Terraform Backend" → Type "yes" → Run (5 mins - creates OIDC + backend)
   - **Step 2**: "CI/CD Pipeline for Hello-World App" → Run (10-15 mins - deploys everything)
4. **Success**: Get your app URL from the workflow output logs

**Note**: Setup-backend uses access keys (one-time), deploy uses OIDC (ongoing).

### Local Deployment (30-45 minutes)
**For Local Testing & Development**
```bash
git clone https://github.com/your-username/terraform-eks-helloworld.git
cd terraform-eks-helloworld

# This is needed as the action uses OIDC provider, otherwise comment out the OIDC provider block in Terraform to ignore this step
# Create OIDC provider manually before running Terraform
aws iam create-open-id-connect-provider \
  --url https://token.actions.githubusercontent.com \
  --client-id-list sts.amazonaws.com \
  --thumbprint-list 6938fd4d98bab03faadb97b34396831e3780aea1 \
  --tags Key=Name,Value="GitHub Actions OIDC" Key=Environment,Value=dev

# Update kustomization.yaml with your AWS account details
# Replace these placeholders in k8s/base/kustomization.yaml:
# - ACCOUNT_ID → Your AWS Account ID
# - REGION → Your AWS Region (e.g., us-east-1)
# - CERTIFICATE_ID → Your ACM certificate ID (optional for testing) 

# Get your AWS Account ID and update kustomization.yaml
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
AWS_REGION="us-east-1"

# Update kustomization.yaml placeholders
sed -i "s|ACCOUNT_ID|$AWS_ACCOUNT_ID|g" k8s/base/kustomization.yaml
sed -i "s|REGION|$AWS_REGION|g" k8s/base/kustomization.yaml

# Comment out the remote backend in backend.tf for local testing
# Then run simple commands:
terraform init
terraform plan
terraform apply

# Build and push Docker image to ECR
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin $(aws sts get-caller-identity --query Account --output text).dkr.ecr.us-east-1.amazonaws.com
docker build -t hello-world ./app
docker tag hello-world:latest $(aws sts get-caller-identity --query Account --output text).dkr.ecr.us-east-1.amazonaws.com/hello-world:latest
docker push $(aws sts get-caller-identity --query Account --output text).dkr.ecr.us-east-1.amazonaws.com/hello-world:latest

# Deploy to EKS
aws eks update-kubeconfig --name thrive-cluster-test --region us-east-1
kubectl apply -k k8s/base/

kubectl get ingress hello-world-ingress -n hello-world
```
### Access Your App
- **IRSA App**: `kubectl port-forward service/hello-world-service 8080:80 -n hello-world`
- **Pod Identity App**: `kubectl port-forward service/hello-world-pod-identity-service 8081:80 -n hello-world`
- **Load Balancer URL**: Check ingress output
- **Monitor**: `kubectl get hpa -n hello-world`

## Success Validation

### Verify Deployment Works

**Check EKS Cluster:**
```bash
aws eks describe-cluster --name thrive-cluster-test --query 'cluster.status'
# Should return: "ACTIVE"
```

**Test Applications:**
```bash
# Both deployments should be running
kubectl get pods -n hello-world
# Expected: 3 pods total (2 IRSA + 1 Pod Identity)

# Get load balancer URL
kubectl get ingress hello-world-ingress -n hello-world
# Visit the ADDRESS shown to see "Hello World from EKS!"
```

**Verify Monitoring:**
```bash
# HPA should show CPU/memory targets
kubectl get hpa -n hello-world

# Check CloudWatch dashboard exists
aws cloudwatch list-dashboards --query 'DashboardEntries[?contains(DashboardName,`thrive`)].DashboardName'
```

## Troubleshooting

### Common Issues

**EKS Cluster Not Ready:**
```bash
aws eks describe-cluster --name thrive-cluster-test
kubectl get nodes
```

**Pods Not Starting:**
```bash
kubectl get pods -n hello-world
kubectl describe pod <pod-name> -n hello-world
```

**Authentication Issues:**
```bash
# Check Pod Identity addon
aws eks describe-addon --cluster-name thrive-cluster-test --addon-name eks-pod-identity-agent

# Check service accounts
kubectl get serviceaccounts -n hello-world

# Test both deployments
kubectl get pods -n hello-world -l app=hello-world
kubectl get pods -n hello-world -l app=hello-world-pod-identity
```

## Architecture Decisions

### Why EKS over ECS?
- **Kubernetes-native**: Industry standard with better portability
- **Advanced features**: HPA, network policies, rich ecosystem
- **Skills transfer**: Kubernetes knowledge applies everywhere

### Why Both IRSA and Pod Identity?
- **IRSA**: Mature, stable, works everywhere (production-ready since 2019)
- **Pod Identity**: AWS-recommended future approach with better performance
- **Choice**: Pick the method that fits your security/performance needs

### Why Terraform Modules?
- **Reusability**: Each module can be used independently
- **Maintainability**: Changes isolated to specific components
- **Testing**: Easier to test individual pieces

### Cost Optimization Choices
- **t3.medium nodes**: Right balance of cost and performance for learning
- **Spot instances**: Available in terraform but commented for stability
- **7-day log retention**: Reduces CloudWatch costs while keeping debugging capability

## Cleanup

**Automated (Recommended):**
Run the "Destroy Infrastructure" workflow in GitHub Actions.

**Manual:**

**Initialize backend:**
```bash
terraform init
```

**Destroy resources:**
```bash
terraform destroy
```

## Resources

- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest)
- [Amazon EKS Documentation](https://docs.aws.amazon.com/eks/)
- [EKS Pod Identity](https://docs.aws.amazon.com/eks/latest/userguide/pod-identities.html)
- [IRSA Documentation](https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html)
- [Pod Identity vs IRSA Comparison](https://aws.amazon.com/blogs/containers/introducing-eks-pod-identity/)

---