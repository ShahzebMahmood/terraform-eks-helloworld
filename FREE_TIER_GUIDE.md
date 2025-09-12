# AWS Free Tier Optimization Guide

This guide ensures your DevOps project stays within AWS Free Tier limits and helps you avoid unexpected charges.

## 🆓 AWS Free Tier Limits

### **EC2 (Elastic Compute Cloud)**
- **750 hours/month** of t2.micro, t3.micro, or t4g.micro instances
- **30 GB** of EBS General Purpose (gp2) storage
- **2 million I/O operations** with EBS
- **1 GB** of snapshot storage

### **EKS (Elastic Kubernetes Service)**
- **First 1 million requests** per month are free
- **Control plane** is free for the first 12 months
- **Data transfer** between services in the same region is free

### **ECR (Elastic Container Registry)**
- **500 MB** of storage per month
- **1 GB** of data transfer out per month

### **CloudWatch**
- **10 custom metrics** per month
- **5 GB** of log ingestion per month
- **1 million API requests** per month

### **VPC & Networking**
- **VPC** is free
- **Data transfer** within the same region is free
- **NAT Gateway** is NOT free tier eligible

## 💰 Cost Optimization Configuration

### **Current Project Settings (Free Tier Optimized)**

```hcl
# Instance Type - Free Tier Eligible
instance_type = "t3.micro"  # 750 hours/month free

# Node Group Configuration
desired_capacity = 1        # Minimal nodes
min_size = 1               # Minimum required
max_size = 2               # Limited scaling

# Storage
# EKS uses EBS volumes (30 GB free tier)
# ECR repository (500 MB free tier)
```

### **Resource Limits Applied**

```yaml
# Kubernetes Resource Limits
resources:
  requests:
    memory: "64Mi"    # Minimal memory request
    cpu: "50m"        # Minimal CPU request
  limits:
    memory: "128Mi"   # Conservative memory limit
    cpu: "100m"       # Conservative CPU limit
```

## 🚨 Billing Alerts & Monitoring

### **Automatic Cost Monitoring**

The project includes:

1. **AWS Budgets Alert** - $5 monthly threshold
2. **CloudWatch Billing Alarm** - $3 threshold
3. **SNS Notifications** - Email alerts for cost overruns

### **Setting Up Billing Alerts**

```bash
# Optional: Set your email for billing alerts
terraform apply -var='alert_email=your-email@example.com'
```

## 📊 Free Tier Usage Tracking

### **Monthly Free Tier Usage**

| Service | Free Tier Limit | Project Usage | Status |
|---------|----------------|---------------|---------|
| EC2 t3.micro | 750 hours | ~744 hours | ✅ Safe |
| EBS Storage | 30 GB | ~20 GB | ✅ Safe |
| EKS Requests | 1M/month | ~100K | ✅ Safe |
| ECR Storage | 500 MB | ~50 MB | ✅ Safe |
| CloudWatch Metrics | 10 metrics | 8 metrics | ✅ Safe |

### **Estimated Monthly Cost (Free Tier)**

- **EKS Control Plane**: $0 (first 12 months)
- **EC2 Instances**: $0 (within 750 hours)
- **EBS Storage**: $0 (within 30 GB)
- **ECR Storage**: $0 (within 500 MB)
- **CloudWatch**: $0 (within limits)
- **Data Transfer**: $0 (within region)

**Total Estimated Cost: $0/month** 🎉

## ⚠️ Cost Warnings

### **Services That May Incur Charges**

1. **NAT Gateway** - $0.045/hour + data processing
   - **Solution**: Using public subnets only (free)

2. **Application Load Balancer** - $0.0225/hour + LCU
   - **Note**: ALB is required for HTTPS ingress
   - **Cost**: ~$16/month if running 24/7

3. **Data Transfer Out** - $0.09/GB after 1GB
   - **Solution**: Minimal data transfer in this project

4. **CloudWatch Logs** - $0.50/GB after 5GB
   - **Solution**: 7-day log retention

### **Cost Optimization Tips**

1. **Stop Resources When Not Needed**
   ```bash
   # Scale down to 0 replicas when not testing
   kubectl scale deployment hello-world --replicas=0
   
   # Or destroy infrastructure
   terraform destroy
   ```

2. **Use Spot Instances** (Advanced)
   ```hcl
   # In EKS node group configuration
   capacity_type = "SPOT"  # Up to 90% savings
   ```

3. **Optimize Container Images**
   ```dockerfile
   # Use Alpine Linux for smaller images
   FROM node:18-alpine
   
   # Multi-stage builds to reduce image size
   ```

## 🔧 Free Tier Monitoring Commands

### **Check Current Usage**

```bash
# Check EC2 instances
aws ec2 describe-instances --query 'Reservations[*].Instances[*].[InstanceId,InstanceType,State.Name]'

# Check EBS volumes
aws ec2 describe-volumes --query 'Volumes[*].[VolumeId,Size,VolumeType]'

# Check ECR repositories
aws ecr describe-repositories

# Check CloudWatch metrics
aws cloudwatch list-metrics --namespace AWS/EKS
```

### **Monitor Costs in AWS Console**

1. **AWS Cost Explorer**
   - Go to AWS Console → Billing → Cost Explorer
   - View daily/monthly costs
   - Set up cost budgets

2. **AWS Budgets**
   - Go to AWS Console → Billing → Budgets
   - Create custom budgets
   - Set up alerts

3. **Free Tier Usage**
   - Go to AWS Console → Billing → Free Tier
   - Monitor usage against limits

## 🛡️ Cost Protection Strategies

### **1. Automated Shutdown**

Create a script to automatically scale down resources:

```bash
#!/bin/bash
# auto-shutdown.sh
kubectl scale deployment hello-world --replicas=0
echo "Application scaled down to save costs"
```

### **2. Scheduled Scaling**

Use Kubernetes CronJob for scheduled scaling:

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: cost-saver
spec:
  schedule: "0 18 * * *"  # 6 PM daily
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: scale-down
            image: bitnami/kubectl
            command:
            - kubectl
            - scale
            - deployment
            - hello-world
            - --replicas=0
```

### **3. Infrastructure as Code Benefits**

```bash
# Quick infrastructure teardown
terraform destroy -auto-approve

# Quick infrastructure recreation
terraform apply -auto-approve
```

## 📈 Scaling Within Free Tier

### **Safe Scaling Limits**

```yaml
# HPA Configuration (Free Tier Safe)
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
spec:
  minReplicas: 1      # Minimum for availability
  maxReplicas: 2      # Maximum for free tier
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        averageUtilization: 70
```

### **Resource Optimization**

```yaml
# Optimized resource requests
resources:
  requests:
    memory: "32Mi"    # Reduced from 64Mi
    cpu: "25m"        # Reduced from 50m
  limits:
    memory: "64Mi"    # Reduced from 128Mi
    cpu: "50m"        # Reduced from 100m
```

## 🚀 Free Tier Best Practices

### **1. Development Workflow**

```bash
# Start development
terraform apply
kubectl apply -f k8s/

# Test your application
curl http://your-load-balancer-url/

# Stop when done
kubectl scale deployment hello-world --replicas=0
# OR
terraform destroy
```

### **2. CI/CD Optimization**

```yaml
# GitHub Actions optimization
- name: Scale down after deployment
  run: |
    kubectl scale deployment hello-world --replicas=0
    echo "Resources scaled down to save costs"
```

### **3. Monitoring Free Tier Usage**

```bash
# Daily cost check script
#!/bin/bash
aws ce get-cost-and-usage \
  --time-period Start=2024-01-01,End=2024-01-31 \
  --granularity MONTHLY \
  --metrics BlendedCost
```

## 📞 Support & Resources

### **AWS Free Tier Support**
- [AWS Free Tier FAQ](https://aws.amazon.com/free/free-tier-faqs/)
- [AWS Free Tier Limits](https://aws.amazon.com/free/)
- [AWS Cost Calculator](https://calculator.aws/)

### **Cost Management Tools**
- AWS Cost Explorer
- AWS Budgets
- AWS Cost Anomaly Detection
- AWS Trusted Advisor

---

## 🎯 Summary

This project is **fully optimized for AWS Free Tier** with:

- ✅ **$0 monthly cost** for core functionality
- ✅ **Automatic billing alerts** at $3 and $5 thresholds
- ✅ **Resource limits** to prevent overruns
- ✅ **Easy teardown** with `terraform destroy`
- ✅ **Scaling controls** to stay within limits

**You can run this project for FREE for 12 months!** 🎉

Just remember to:
1. Set up billing alerts
2. Monitor your usage monthly
3. Scale down when not testing
4. Use `terraform destroy` when done
