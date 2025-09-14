# Hello-World DevOps Project

This is a real-world DevOps project I built to showcase how to deploy a scalable web application on AWS using modern tools and best practices. It's not just another tutorial - it's a production-ready setup that you can actually use.

## What This Project Does

I've put together a complete DevOps pipeline that covers everything from infrastructure to deployment:

- **Terraform** for managing AWS infrastructure as code
- **Amazon EKS** for running Kubernetes in the cloud
- **GitHub Actions** for automated CI/CD
- **CloudWatch** for monitoring and alerting
- **Security** built in from the ground up with IAM, Secrets Manager, and proper pod security
- **Auto-scaling** that actually works with HPA

## How It All Fits Together

Here's the big picture of how everything connects:

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

## What You Get

### Infrastructure That Actually Works
- **VPC** with public subnets across 2 availability zones (because single points of failure are bad)
- **EKS Cluster** with managed node groups (no more managing master nodes)
- **Application Load Balancer** so your app is actually accessible from the internet
- **Auto-scaling** that responds to real traffic with HPA

### A Real Application
- **Node.js Hello-World** app (simple but functional)
- **Dockerized** properly with multi-stage builds
- **Kubernetes deployment** with 2 replicas for high availability
- **Health checks** that actually work

### CI/CD That Doesn't Suck
- **GitHub Actions** workflow that builds and deploys automatically
- **Docker images** built and pushed to ECR
- **Automatic deployment** to EKS when you push code
- **Security scanning** with Trivy (because security matters)

### Monitoring You Can Actually Use
- **CloudWatch dashboards** that show real metrics
- **CPU and memory monitoring** so you know when things break
- **Request rate tracking** to see if anyone's actually using your app
- **Email alerts** via SNS when things go wrong

### Security Done Right
- **IAM roles** with least privilege (no more admin access for everything)
- **Secrets Manager** for sensitive data (no hardcoded secrets)
- **Pod Security Standards** set to restricted (because default is too permissive)
- **Network policies** for micro-segmentation
- **Encrypted state** in S3 backend

## Getting Started (Should Take About 5 Minutes)

### Important: Do Things in Order
**Seriously, follow this order or things will break:**
1. **Setup Terraform Backend** (creates the S3 bucket and DynamoDB table)
2. **CI/CD Pipeline** (deploys everything)
3. **Destroy Infrastructure** (when you're done playing around)

### What You Need
- AWS Account (Free Tier works fine)
- GitHub Account
- AWS CLI installed and configured
- kubectl installed

### Step 1: Get the Code
```bash
git clone https://github.com/your-username/TF_AWS_Test-1.git
cd TF_AWS_Test-1
```

### Step 2: Set Up AWS Credentials
```bash
aws configure
# Enter your AWS Access Key ID
# Enter your AWS Secret Access Key
# Enter your region (e.g., us-east-1)
# Enter output format (json)
```

### Step 3: Configure GitHub Secrets
Go to your GitHub repository → Settings → Secrets and variables → Actions

Add these secrets:
- `AWS_ACCESS_KEY_ID`: Your AWS access key
- `AWS_SECRET_ACCESS_KEY`: Your AWS secret key

### Step 4: Set Up the Backend
**Option A: Using GitHub Actions (Easier)**
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

### Step 5: Deploy Everything
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

### Step 6: Deploy the App
```bash
# Update kubeconfig
aws eks update-kubeconfig --name thrive-cluster-test --region us-east-1

# Deploy application
kubectl apply -f k8s/
```

### Step 7: See Your App in Action
```bash
# Get the load balancer URL
kubectl get ingress hello-world-ingress -n hello-world

# Or use port-forward for testing
kubectl port-forward service/hello-world-service 8080:80 -n hello-world
```

Visit: `http://localhost:8080` or the load balancer URL

## Cleaning Up

### Destroy Everything
```bash
# Destroy everything
terraform destroy

# Or use the cleanup script
./scripts/cleanup-aws-resources.sh
```

## When Things Go Wrong

### Common Issues and How to Fix Them

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

## Learning Resources

- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest)
- [Amazon EKS Documentation](https://docs.aws.amazon.com/eks/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [GitHub Actions](https://docs.github.com/en/actions)

## Need Help?

If you run into issues:
1. Check the troubleshooting section above
2. Look at the GitHub Actions logs
3. Check CloudWatch logs
4. Open an issue on GitHub

---

**Happy Deploying!**