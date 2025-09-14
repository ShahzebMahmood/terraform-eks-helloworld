# Kubernetes Manifests with Kustomize

This directory contains Kubernetes manifests organized using Kustomize for configuration management.

## Directory Structure

```
k8s/
├── base/                    # Base Kubernetes manifests
│   ├── kustomization.yaml  # Base Kustomize configuration
│   ├── deployment.yaml     # Application deployment
│   ├── service.yaml        # LoadBalancer service
│   ├── service-clusterip.yaml # ClusterIP service
│   ├── ingress.yaml        # Ingress configuration
│   ├── hpa.yaml           # Horizontal Pod Autoscaler
│   ├── network-policy.yaml # Network security policies
│   └── pod-security-policy.yaml # Pod security standards
├── overlays/               # Environment-specific overlays
│   ├── dev/               # Development environment
│   │   └── kustomization.yaml
│   └── prod/              # Production environment
│       └── kustomization.yaml
└── deploy.sh              # Deployment script
```

## Usage

### Using GitHub Actions (Recommended)
The GitHub Actions workflow automatically deploys using Kustomize with dynamic values from Terraform.

### Manual Deployment

#### Deploy to Development
```bash
kubectl apply -k k8s/overlays/dev
```

#### Deploy to Production
```bash
kubectl apply -k k8s/overlays/prod
```

#### Deploy Base Configuration
```bash
kubectl apply -k k8s/base
```

### Using the Deployment Script
```bash
./k8s/deploy.sh dev    # Deploy to development
./k8s/deploy.sh prod   # Deploy to production
```

## Dynamic Values

The following values are automatically updated by the GitHub Actions workflow:

- **IAM Role ARN**: `arn:aws:iam::ACCOUNT_ID:role/hello-world-pod-role`
- **ECR Image URI**: `ACCOUNT_ID.dkr.ecr.REGION.amazonaws.com/hello-world:TAG`
- **Certificate ARN**: `arn:aws:acm:REGION:ACCOUNT_ID:certificate/CERTIFICATE_ID`

## Environment Differences

### Development (`overlays/dev`)
- 1 replica (minimal resources)
- HPA: 1-3 replicas
- Host: `hello-world-dev.example.com`

### Production (`overlays/prod`)
- 3 replicas (high availability)
- HPA: 3-10 replicas
- Higher resource limits
- Host: `hello-world.example.com`

## Benefits of Kustomize

1. **Configuration Management**: Environment-specific configurations without duplication
2. **Dynamic Values**: Automatic injection of values from CI/CD pipeline
3. **Native Integration**: Works seamlessly with `kubectl`
4. **Version Control**: All configurations are versioned in Git
5. **Rollback Support**: Easy rollback to previous configurations

## Troubleshooting

### View Generated Manifests
```bash
kubectl kustomize k8s/base
kubectl kustomize k8s/overlays/dev
```

### Check Deployment Status
```bash
kubectl get pods -n hello-world
kubectl get services -n hello-world
kubectl get ingress -n hello-world
```

### Debug Kustomize Build
```bash
kubectl kustomize k8s/base --enable-helm
```
