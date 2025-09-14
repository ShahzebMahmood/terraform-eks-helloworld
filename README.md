# Hello-World DevOps Project

A technical assessment project demonstrating a complete DevOps pipeline for deploying a web application on AWS. This showcases infrastructure as code, containerization, and cloud-native deployment using modern tools and best practices.

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

### IRSA (Legacy)
- **Deployment**: `hello-world` (2 replicas)
- Mature and stable since 2019
- Wide compatibility with all AWS services
- Manual OIDC setup with full control
- More complex configuration

### Pod Identity (Modern)
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

## Quick Start

### Prerequisites
- AWS Account (Free Tier works)
- GitHub Account
- AWS CLI configured
- Basic knowledge of Kubernetes and Terraform

### CI/CD Deployment (Recommended)
1. Fork this repository
2. Add GitHub Secrets (Settings → Secrets → Actions):
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`
3. Run Workflows (Actions tab):
   - "Setup Terraform Backend" → Type "yes" → Run
   - "CI/CD Pipeline for Hello-World App (IRSA + Pod Identity)" → Run
4. Get your app URL from the workflow output

### Local Deployment
```bash
git clone https://github.com/your-username/TF_AWS_Test-1.git
cd TF_AWS_Test-1

terraform init
terraform apply

aws eks update-kubeconfig --name thrive-cluster-test --region us-east-1
kubectl apply -f k8s/

kubectl get ingress hello-world-ingress -n hello-world
```

### Access Your App
- **IRSA App**: `kubectl port-forward service/hello-world-service 8080:80 -n hello-world`
- **Pod Identity App**: `kubectl port-forward service/hello-world-pod-identity-service 8081:80 -n hello-world`
- **Load Balancer URL**: Check ingress output
- **Monitor**: `kubectl get hpa -n hello-world`

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

## Cleanup

```bash
terraform destroy
```

## Technical Skills Demonstrated

- **Infrastructure as Code** - Complete Terraform implementation with modular design
- **Container Orchestration** - Kubernetes deployment with proper resource management
- **CI/CD Automation** - GitHub Actions pipeline with security scanning
- **Cloud Security** - IAM roles, secrets management, and network policies
- **Monitoring & Observability** - CloudWatch integration with alerting
- **Modern AWS Services** - EKS, Pod Identity, ECR, and ALB implementation
- **Authentication Methods** - Both IRSA and Pod Identity for comprehensive understanding

## Resources

- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest)
- [Amazon EKS Documentation](https://docs.aws.amazon.com/eks/)
- [EKS Pod Identity](https://docs.aws.amazon.com/eks/latest/userguide/pod-identities.html)
- [IRSA Documentation](https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html)
- [Pod Identity vs IRSA Comparison](https://aws.amazon.com/blogs/containers/introducing-eks-pod-identity/)

---

**Technical Assessment Complete**