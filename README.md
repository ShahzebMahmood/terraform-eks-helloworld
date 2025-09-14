# Hello-World DevOps Project

This is a real-world DevOps project I built to showcase how to deploy a scalable web application on AWS using modern tools and best practices. It's not just another tutorial it's a production-ready setup that you can actually use.

## What This Project Does

I've put together a complete DevOps pipeline that covers everything from infrastructure to deployment:

- **Terraform** for managing AWS infrastructure as code
- **Amazon EKS** for running Kubernetes in the cloud
- **GitHub Actions** for automated CI/CD
- **CloudWatch** for monitoring and alerting
- **Security** built in from the ground up with IAM, Secrets Manager, and proper pod security
- **Auto-scaling** works with HPA

## How It All Fits Together

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
- **VPC** with public subnets across 2 availability zones (because single points of failure are no best pratice for site realiabilty)
- **EKS Cluster** with managed node groups (no more managing master nodes)
- **Application Load Balancer** so your app is actually accessible from the internet (opted to go with classic)
- **Auto-scaling** that responds to real traffic with HPA and metric server, however you can use promethues or open telemtry as well

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
- **Dual Authentication**: Both IRSA (legacy) and Pod Identity (modern) for AWS service access

## Authentication Options

This project supports **two authentication methods** for pods to access AWS services. Both are deployed by default, giving you flexibility to choose:

### Option 1: IRSA (IAM Roles for Service Accounts) - Legacy
**Deployment**: `hello-world` (2 replicas)
- ✅ **Mature and stable** - Been around since 2019
- ✅ **Wide compatibility** - Works with all AWS services
- ✅ **Manual OIDC setup** - Full control over configuration
- ⚠️ **More complex** - Requires manual OIDC provider management
- ⚠️ **Slower token refresh** - Standard AWS token lifetime

### Option 2: Pod Identity - Modern (Recommended)
**Deployment**: `hello-world-pod-identity` (1 replica)
- ✅ **AWS recommended** - Latest authentication method
- ✅ **Better performance** - Faster token refresh
- ✅ **Simpler setup** - EKS addon handles everything
- ✅ **Enhanced security** - Shorter token lifetime
- ✅ **Future-proof** - AWS's direction for pod authentication

### Which Should You Use?

| Use Case | Recommendation |
|----------|---------------|
| **New projects** | 🎯 **Pod Identity** - Modern, performant, AWS recommended |
| **Existing IRSA setups** | 🔄 **Either** - Both work identically |
| **Complex OIDC needs** | 🔧 **IRSA** - More control over configuration |
| **Maximum performance** | ⚡ **Pod Identity** - Faster token refresh |
| **Learning/Testing** | 🧪 **Both** - Compare and learn |

### Switching Between Methods

**To use only Pod Identity:**
```bash
kubectl scale deployment hello-world --replicas=0 -n hello-world
kubectl scale deployment hello-world-pod-identity --replicas=2 -n hello-world
```

**To use only IRSA:**
```bash
kubectl scale deployment hello-world-pod-identity --replicas=0 -n hello-world
kubectl scale deployment hello-world --replicas=2 -n hello-world
```

## Quick Deployment

### Prerequisites
- AWS Account (Free Tier works)
- GitHub Account
- AWS CLI configured (`aws configure`)

### Option 1: CI/CD Deployment (Recommended)
1. **Fork this repository**
2. **Add GitHub Secrets** (Settings → Secrets → Actions):
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`
3. **Run Workflows** (Actions tab):
   - "Setup Terraform Backend" → Type "yes" → Run
   - "CI/CD Pipeline for Hello-World App (IRSA + Pod Identity)" → Run
4. **Get your app URL** from the workflow output

### Option 2: Local Deployment
```bash
# Clone and setup
git clone https://github.com/your-username/TF_AWS_Test-1.git
cd TF_AWS_Test-1

# Deploy infrastructure
terraform init
terraform apply

# Deploy app to EKS
aws eks update-kubeconfig --name thrive-cluster-test --region us-east-1
kubectl apply -f k8s/

# Get app URL
kubectl get ingress hello-world-ingress -n hello-world
```

### Access Your App

**Both deployments are available:**

- **IRSA App**: `kubectl port-forward service/hello-world-service 8080:80 -n hello-world`
- **Pod Identity App**: `kubectl port-forward service/hello-world-pod-identity-service 8081:80 -n hello-world`
- **Load Balancer URL**: Check ingress output (routes to IRSA by default)
- **Monitor**: `kubectl get hpa -n hello-world` (auto-scaling)
- **Check both deployments**: `kubectl get pods -n hello-world`

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

4. **Authentication Issues**
   ```bash
   # Check Pod Identity addon
   aws eks describe-addon --cluster-name thrive-cluster-test --addon-name eks-pod-identity-agent
   
   # Check service accounts
   kubectl get serviceaccounts -n hello-world
   
   # Check pod AWS environment
   kubectl exec -it <pod-name> -n hello-world -- env | grep AWS
   
   # Test both deployments
   kubectl get pods -n hello-world -l app=hello-world
   kubectl get pods -n hello-world -l app=hello-world-pod-identity
   ```

## Learning Resources

### General
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest)
- [Amazon EKS Documentation](https://docs.aws.amazon.com/eks/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [GitHub Actions](https://docs.github.com/en/actions)

### Authentication Methods
- [EKS Pod Identity](https://docs.aws.amazon.com/eks/latest/userguide/pod-identities.html) - Modern approach
- [IRSA (IAM Roles for Service Accounts)](https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html) - Legacy approach
- [Pod Identity vs IRSA Comparison](https://aws.amazon.com/blogs/containers/introducing-eks-pod-identity/) - AWS blog post

## Need Help?

If you run into issues:
1. Check the troubleshooting section above
2. Look at the GitHub Actions logs
3. Check CloudWatch logs
4. Open an issue on GitHub

---

**Happy Deploying!**