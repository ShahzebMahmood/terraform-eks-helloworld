# 🚀 Hello-World DevOps Project

A complete DevOps solution that provisions AWS infrastructure and deploys a scalable web application with monitoring, CI/CD, and security best practices.

## 📋 Project Overview

This project demonstrates a full DevOps workflow including:
- **Infrastructure as Code** with Terraform
- **Container Orchestration** with Amazon EKS
- **CI/CD Pipeline** with GitHub Actions
- **Monitoring & Alerting** with CloudWatch
- **Security** with IAM, Secrets Manager, and Pod Security Standards
- **Auto-scaling** with Horizontal Pod Autoscaler

## 🏗️ Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   GitHub Repo   │───▶│  GitHub Actions │───▶│   AWS ECR       │
│                 │    │   CI/CD Pipeline│    │   Container     │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                                │
                                ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   AWS EKS       │◀───│   Terraform     │───▶│   AWS VPC       │
│   Kubernetes    │    │   Infrastructure│    │   Networking    │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │
         ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   CloudWatch    │    │   SNS Alerts    │    │   Load Balancer │
│   Monitoring    │    │   Notifications │    │   (ALB)         │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## 🎯 Features

### ✅ Infrastructure Provisioning
- **VPC** with public subnets across 2 AZs
- **EKS Cluster** with managed node groups
- **Application Load Balancer** for external access
- **Auto-scaling** with HPA (Horizontal Pod Autoscaler)

### ✅ Application Deployment
- **Node.js Hello-World** application
- **Docker containerization**
- **Kubernetes deployment** with 2 replicas
- **Health checks** and readiness probes

### ✅ CI/CD Pipeline
- **GitHub Actions** workflow
- **Docker image building** and pushing to ECR
- **Automatic deployment** to EKS
- **Security scanning** with Trivy

### ✅ Monitoring & Logging
- **CloudWatch dashboards** for cluster metrics
- **CPU and memory monitoring**
- **Request rate tracking**
- **Email alerts** via SNS

### ✅ Security
- **IAM roles** with least privilege
- **Secrets Manager** for sensitive data
- **Pod Security Standards** (restricted)
- **Network policies** for micro-segmentation
- **Encrypted state** in S3 backend

## 🚀 Quick Start (5 Minutes)

### ⚠️ Important: Workflow Order
**You must run workflows in this order:**
1. **Setup Terraform Backend** (creates S3 bucket and DynamoDB table)
2. **CI/CD Pipeline** (deploys infrastructure and application)
3. **Destroy Infrastructure** (cleanup when done)

### Prerequisites
- AWS Account (Free Tier eligible)
- GitHub Account
- AWS CLI installed and configured
- kubectl installed

### Step 1: Clone the Repository
```bash
git clone https://github.com/your-username/TF_AWS_Test-1.git
cd TF_AWS_Test-1
```

### Step 2: Configure AWS Credentials
```bash
aws configure
# Enter your AWS Access Key ID
# Enter your AWS Secret Access Key
# Enter your region (e.g., us-east-1)
# Enter output format (json)
```

### Step 3: Set Up GitHub Secrets
Go to your GitHub repository → Settings → Secrets and variables → Actions

Add these secrets:
- `AWS_ACCESS_KEY_ID`: Your AWS access key
- `AWS_SECRET_ACCESS_KEY`: Your AWS secret key

### Step 4: Set Up Backend Infrastructure
**Option A: Using GitHub Actions (Recommended)**
1. Go to Actions tab in GitHub
2. Select "Setup Terraform Backend"
3. Click "Run workflow"
4. Type "yes" to confirm
5. Click "Run workflow"

**Option B: Using Local Script**
```bash
# Make scripts executable
chmod +x scripts/*.sh

# Set up Terraform backend
./scripts/setup-terraform-backend.sh
```

### Step 5: Deploy Infrastructure
**Option A: Using GitHub Actions (Recommended)**
1. Go to Actions tab in GitHub
2. Select "CI/CD Pipeline for Hello-World App"
3. Click "Run workflow"
4. Click "Run workflow"

**Option B: Using Local Commands**
```bash
# Deploy infrastructure
terraform init
terraform plan
terraform apply
```

### Step 6: Deploy Application
```bash
# Update kubeconfig
aws eks update-kubeconfig --name thrive-cluster-test --region us-east-1

# Deploy application
kubectl apply -f k8s/
```

### Step 7: Access Your Application
```bash
# Get the load balancer URL
kubectl get ingress hello-world-ingress -n hello-world

# Or use port-forward for testing
kubectl port-forward service/hello-world-service 8080:80 -n hello-world
```

Visit: `http://localhost:8080` or the load balancer URL

## 🧹 Cleanup

### Destroy Infrastructure
```bash
# Destroy everything
terraform destroy

# Or use the cleanup script
./scripts/cleanup-aws-resources.sh
```

## 🚨 Troubleshooting

### Common Issues

1. **EKS Cluster Not Ready**
   ```bash
   aws eks describe-cluster --name thrive-cluster-test
   kubectl get nodes
   ```

2. **Pods Not Starting**
   ```bash
   kubectl get pods -n hello-world
   kubectl describe pod <pod-name> -n hello-world
   ```

3. **Load Balancer Not Working**
   ```bash
   kubectl get ingress -n hello-world
   kubectl get services -n hello-world
   ```

## 📚 Learning Resources

- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest)
- [Amazon EKS Documentation](https://docs.aws.amazon.com/eks/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [GitHub Actions](https://docs.github.com/en/actions)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🆘 Support

If you encounter any issues:
1. Check the troubleshooting section
2. Review the GitHub Actions logs
3. Check CloudWatch logs
4. Open an issue on GitHub

---

**Happy Deploying! 🚀**