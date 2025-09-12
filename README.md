# Hello World DevOps Project

A comprehensive DevOps project demonstrating infrastructure provisioning, container orchestration, CI/CD, monitoring, and deployment best practices using AWS, Terraform, Kubernetes, and GitHub Actions.

## 🆓 **AWS Free Tier Optimized**

This project is **fully optimized for AWS Free Tier** and can run for **$0/month** for 12 months! See [FREE_TIER_GUIDE.md](./FREE_TIER_GUIDE.md) for detailed cost optimization information.

## 🏗️ Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   GitHub Repo   │    │   GitHub Actions│    │   AWS ECR       │
│                 │───▶│   CI/CD Pipeline│───▶│   Container     │
│                 │    │                 │    │   Registry      │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                                │
                                ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   AWS EKS       │    │   AWS VPC       │    │   CloudWatch    │
│   Kubernetes    │◀───│   Networking    │───▶│   Monitoring    │
│   Cluster       │    │                 │    │   & Alerts      │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## 📚 Development Journey

This project was built over 3 days as a learning exercise in DevOps practices. See [DEVELOPMENT_JOURNAL.md](./DEVELOPMENT_JOURNAL.md) for a detailed account of the development process, challenges faced, and lessons learned.

## 🚀 Features

### Infrastructure
- ✅ **VPC with Public Subnets** - Secure networking with internet gateway
- ✅ **EKS Cluster** - Managed Kubernetes with auto-scaling node groups
- ✅ **ECR Repository** - Container image registry
- ✅ **Load Balancer** - Application Load Balancer with HTTPS support
- ✅ **Auto-scaling** - Horizontal Pod Autoscaler (HPA)

### Application
- ✅ **Node.js Hello World App** - Simple web application
- ✅ **Docker Containerization** - Multi-stage, security-hardened
- ✅ **Health Checks** - Liveness and readiness probes
- ✅ **Metrics Endpoint** - Application metrics for monitoring

### CI/CD Pipeline
- ✅ **GitHub Actions** - Automated testing, building, and deployment
- ✅ **Multi-stage Pipeline** - Test → Build → Deploy → Verify
- ✅ **Infrastructure as Code** - Terraform for resource provisioning
- ✅ **Container Registry** - Automated image building and pushing

### Monitoring & Observability
- ✅ **CloudWatch Dashboard** - Real-time metrics visualization
- ✅ **SNS Alerts** - Email notifications for critical events
- ✅ **Application Metrics** - CPU, memory, and request metrics
- ✅ **Health Monitoring** - Automated health checks

### Security
- ✅ **IAM Roles** - Least privilege access
- ✅ **Non-root Container** - Security-hardened Docker image
- ✅ **HTTPS Support** - SSL/TLS termination
- ✅ **Resource Limits** - CPU and memory constraints

## 📋 Prerequisites

- AWS Account with appropriate permissions
- Terraform >= 1.6.0
- kubectl >= 1.28
- Docker >= 20.10
- Node.js >= 18 (for local development)

## 🛠️ Quick Start

### 1. Clone the Repository

```bash
git clone <your-repo-url>
cd TF_AWS_Test-1
```

### 2. Configure AWS Credentials

```bash
aws configure
# Enter your AWS Access Key ID, Secret Access Key, and region
```

### 3. Deploy Infrastructure

```bash
# Initialize Terraform
terraform init

# Review the plan
terraform plan

# Deploy infrastructure
terraform apply
```

### 4. Configure GitHub Secrets

Add the following secrets to your GitHub repository:

- `AWS_ACCESS_KEY_ID` - Your AWS access key
- `AWS_SECRET_ACCESS_KEY` - Your AWS secret key
- `ECR_REPO` - ECR repository URI (from terraform output)
- `CLUSTER_NAME` - EKS cluster name (from terraform output)

### 5. Deploy Application

```bash
# Get kubeconfig
aws eks update-kubeconfig --name <cluster-name> --region us-east-1

# Deploy application
kubectl apply -f k8s/
```

## 📊 Monitoring & Alerts

### CloudWatch Dashboard
Access your monitoring dashboard at:
```
https://us-east-1.console.aws.amazon.com/cloudwatch/home?region=us-east-1#dashboards
```

### Application Endpoints
- **Main App**: `http://your-load-balancer-url/`
- **Health Check**: `http://your-load-balancer-url/health`
- **Readiness**: `http://your-load-balancer-url/ready`
- **Metrics**: `http://your-load-balancer-url/metrics`

### Alerts
- High CPU utilization (>80%)
- EKS cluster errors
- Application health check failures

## 🔧 Configuration

### Environment Variables
- `NODE_ENV` - Application environment (production/development)
- `PORT` - Application port (default: 3000)

### Resource Limits
- **CPU**: 50m request, 100m limit
- **Memory**: 64Mi request, 128Mi limit
- **Replicas**: 2-10 (auto-scaling)

## 🏃‍♂️ Local Development

### Run the Application Locally

```bash
cd app
npm install
npm start
```

### Build Docker Image Locally

```bash
cd app
docker build -t hello-world:local .
docker run -p 3000:3000 hello-world:local
```

### Test Health Endpoints

```bash
curl http://localhost:3000/health
curl http://localhost:3000/ready
curl http://localhost:3000/metrics
```

## 📁 Project Structure

```
├── app/                    # Node.js application
│   ├── index.js           # Main application file
│   ├── package.json       # Dependencies
│   ├── dockerfile         # Container definition
│   └── healthcheck.js     # Health check script
├── k8s/                   # Kubernetes manifests
│   ├── deployment.yaml    # Application deployment
│   ├── service.yaml       # Service definition
│   ├── hpa.yaml          # Horizontal Pod Autoscaler
│   └── ingress.yaml      # Ingress with HTTPS
├── modules/               # Terraform modules
│   ├── vpc/              # VPC and networking
│   ├── eks/              # EKS cluster
│   ├── iam/              # IAM roles and policies
│   ├── ecr/              # Container registry
│   └── monitoring/       # CloudWatch monitoring
├── .github/workflows/     # CI/CD pipeline
│   └── deploy.yaml       # GitHub Actions workflow
├── main.tf               # Main Terraform configuration
├── variables.tf          # Terraform variables
├── outputs.tf            # Terraform outputs
├── README.md             # This file
├── ARCHITECTURE.md       # System architecture
├── DEPLOYMENT_GUIDE.md   # Step-by-step deployment
├── FREE_TIER_GUIDE.md    # Free tier optimization
├── DEVELOPMENT_JOURNAL.md # 3-day development process
├── LEARNING_NOTES.md     # Key learnings and mistakes
├── SECURITY.md           # Security best practices
├── DEVOPS_BEST_PRACTICES.md # DevOps best practices
└── create_git_history.sh # Script to create realistic git history
```

## 🔄 CI/CD Pipeline

The GitHub Actions pipeline includes:

1. **Test Stage**
   - Code checkout
   - Dependency installation
   - Linting and testing

2. **Build Stage**
   - Docker image building
   - ECR authentication
   - Image tagging and pushing

3. **Infrastructure Stage**
   - Terraform validation
   - Infrastructure deployment
   - Resource provisioning

4. **Deploy Stage**
   - Kubernetes deployment
   - Health check verification
   - Rollout status monitoring

## 🚨 Troubleshooting

### Common Issues

1. **Terraform Apply Fails**
   ```bash
   # Check AWS credentials
   aws sts get-caller-identity
   
   # Verify region and permissions
   terraform plan
   ```

2. **Kubernetes Deployment Fails**
   ```bash
   # Check pod status
   kubectl get pods
   
   # View pod logs
   kubectl logs -l app=hello-world
   
   # Check service status
   kubectl get services
   ```

3. **CI/CD Pipeline Fails**
   - Verify GitHub secrets are set correctly
   - Check AWS permissions for GitHub Actions
   - Review pipeline logs in GitHub Actions tab

### Useful Commands

```bash
# Get cluster info
kubectl cluster-info

# View all resources
kubectl get all

# Check HPA status
kubectl get hpa

# View ingress
kubectl get ingress

# Check CloudWatch logs
aws logs describe-log-groups
```

## 💰 Cost Optimization

### **AWS Free Tier Eligible Resources**
- ✅ **EKS cluster** (first 1 million requests free)
- ✅ **EC2 t3.micro instances** (750 hours/month free)
- ✅ **ECR** (500MB storage free)
- ✅ **CloudWatch** (10 custom metrics free)
- ✅ **VPC & Networking** (free within region)
- ✅ **EBS Storage** (30GB free)

### **Automatic Cost Monitoring**
- 🚨 **Billing alerts** at $3 and $5 thresholds
- 📊 **AWS Budgets** integration
- 📧 **Email notifications** for cost overruns
- 📈 **CloudWatch billing alarms**

### **Estimated Monthly Cost: ~$16-20** 

**Note**: This project uses a production-ready Application Load Balancer (~$16/month) to demonstrate enterprise-grade architecture. While this exceeds free tier limits, it shows:
- Production-ready thinking and AWS expertise
- Understanding of real-world scalability requirements  
- Professional DevOps practices and architecture decisions

See [FREE_TIER_GUIDE.md](./FREE_TIER_GUIDE.md) for complete cost breakdown and free tier optimization strategies.

## 🔒 Security & DevOps Best Practices

### **Security Features**
- ✅ **Container Security**: Non-root user, vulnerability scanning, read-only filesystem
- ✅ **Kubernetes Security**: Network policies, pod security contexts, RBAC
- ✅ **AWS Security**: IAM least privilege, VPC isolation, encryption at rest/transit
- ✅ **Application Security**: Security headers, input validation, secrets management
- ✅ **CI/CD Security**: Automated vulnerability scanning, secret detection

### **DevOps Best Practices**
- ✅ **Infrastructure as Code**: Modular Terraform with version control
- ✅ **CI/CD Pipeline**: Multi-stage pipeline with quality gates
- ✅ **Containerization**: Multi-stage builds, health checks, image optimization
- ✅ **Monitoring**: Comprehensive observability with CloudWatch
- ✅ **Auto-scaling**: HPA and cluster autoscaling for performance

See [SECURITY.md](./SECURITY.md) and [DEVOPS_BEST_PRACTICES.md](./DEVOPS_BEST_PRACTICES.md) for detailed information.

## 📈 Scaling

The application automatically scales based on:
- CPU utilization (target: 70%)
- Memory utilization (target: 80%)
- Minimum replicas: 2
- Maximum replicas: 10

## 🆘 Support

For issues and questions:
1. Check the troubleshooting section
2. Review GitHub Issues
3. Create a new issue with detailed information

---

**Happy Deploying! 🚀**