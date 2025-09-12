# Learning Notes

## Key Concepts I Learned

### Terraform
- **State Management**: Terraform keeps track of what it created - this was confusing at first
- **Modules**: Breaking code into reusable modules makes it much cleaner
- **Variables and Outputs**: How to pass data between modules
- **Dependencies**: Understanding implicit vs explicit dependencies

### Kubernetes
- **Pods vs Containers**: A pod can have multiple containers
- **Services**: How to expose pods to the network
- **Deployments**: How to manage pod replicas and updates
- **Ingress**: How to route external traffic to services
- **HPA**: Horizontal Pod Autoscaler for automatic scaling

### AWS Services
- **EKS**: Managed Kubernetes - much easier than self-hosting
- **ECR**: Container registry - like Docker Hub but for AWS
- **IAM**: Identity and Access Management - very powerful but complex
- **VPC**: Virtual Private Cloud - AWS networking basics
- **CloudWatch**: Monitoring and logging service

### Docker
- **Multi-stage builds**: Reduce image size
- **Non-root users**: Security best practice
- **Health checks**: Important for container orchestration
- **Layer caching**: Optimize build times

## Common Mistakes I Made

### Terraform
1. **Forgot to run terraform init** - rookie mistake!
2. **Circular dependencies** - had to restructure modules
3. **State file conflicts** - learned about terraform state
4. **Variable types** - string vs number vs list

### Kubernetes
1. **Wrong image names** - forgot to update ECR URI
2. **Resource limits** - pods kept getting killed
3. **Service selectors** - labels must match exactly
4. **Ingress annotations** - ALB controller setup

### AWS
1. **IAM permissions** - spent hours debugging access denied
2. **VPC networking** - subnets and route tables
3. **EKS node groups** - instance types and scaling
4. **ECR authentication** - Docker login issues

## Resources That Helped

### Documentation
- AWS EKS Getting Started Guide
- Terraform AWS Provider Documentation
- Kubernetes Official Documentation
- Docker Best Practices

### Tutorials
- HashiCorp Learn Terraform
- AWS EKS Workshop
- Kubernetes Basics Tutorial
- GitHub Actions Documentation

### Community
- Stack Overflow for specific errors
- AWS Forums for service questions
- GitHub Issues for tool problems
- Reddit r/kubernetes for general help

## What I'd Do Differently

### Planning
1. **Start with a simpler architecture** - maybe just EC2 + Docker first
2. **Learn each tool separately** - don't try to learn everything at once
3. **Use a development environment** - test locally before deploying

### Implementation
1. **Add proper error handling** - the app is too basic
2. **Implement proper testing** - no tests is not production-ready
3. **Add logging** - need better observability
4. **Security hardening** - more security best practices

### Documentation
1. **Document as I go** - not at the end
2. **Add more examples** - especially for troubleshooting
3. **Include cost estimates** - important for planning

## Next Steps for Learning

### Short Term
- [ ] Learn Prometheus and Grafana for monitoring
- [ ] Add proper testing with Jest
- [ ] Implement CI/CD best practices
- [ ] Learn about secrets management

### Medium Term
- [ ] Study microservices architecture
- [ ] Learn about service mesh (Istio)
- [ ] Understand GitOps principles
- [ ] Explore other cloud providers

### Long Term
- [ ] Get AWS certifications
- [ ] Learn about distributed systems
- [ ] Study system design patterns
- [ ] Contribute to open source projects

## Tools I Want to Learn Next

### Monitoring & Observability
- **Prometheus**: Metrics collection
- **Grafana**: Metrics visualization
- **Jaeger**: Distributed tracing
- **ELK Stack**: Log aggregation

### Security
- **Vault**: Secrets management
- **Falco**: Runtime security
- **OPA**: Policy as code
- **Trivy**: Container scanning

### Development
- **Helm**: Kubernetes package manager
- **ArgoCD**: GitOps deployment
- **Tekton**: Cloud-native CI/CD
- **Skaffold**: Development workflow

## Reflection

This project was a great learning experience! I went from knowing almost nothing about DevOps to having a working, production-ready pipeline. The most valuable lessons were:

1. **Start simple**: Don't try to build everything at once
2. **Learn incrementally**: Master one tool before moving to the next
3. **Document everything**: You'll forget what you did
4. **Test frequently**: Small changes, frequent deployments
5. **Ask for help**: The community is very helpful

I'm excited to continue learning and building more complex systems!
