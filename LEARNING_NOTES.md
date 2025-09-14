# Learning Notes - DevOps Project Insights

## Key Learnings

### Terraform
- **State Management**: Remote state with DynamoDB locking is critical for teams. State drift breaks production.
- **Modules**: Single responsibility and clear interfaces make code maintainable.
- **Dependencies**: Explicit dependencies prevent debugging nightmares.
- **Provider Versioning**: Pin versions or face breaking changes.

### Kubernetes
- **Pods**: Atomic deployment unit. Pod networking is complex.
- **Services**: Service discovery and load balancing. Service mesh can replace complexity.
- **Deployments**: Rolling updates and rollbacks are production essentials.
- **HPA**: Auto-scaling works, but VPA and KEDA optimize costs better.
- **RBAC**: Complex but essential. Service accounts and role bindings are powerful.
- **Network Policies**: Default-deny policies are secure but can break things.

### AWS Services
- **EKS**: Managed Kubernetes eliminates master node management.
- **ECR**: Image scanning is mandatory in production.
- **IAM**: Least privilege is hard but IRSA makes pod auth secure.
- **VPC**: VPC endpoints save money and improve security.
- **CloudWatch**: Custom metrics are expensive but necessary.
- **Secrets Manager**: Rotation is complex but required for compliance.

### Docker
- **Multi-stage builds**: Essential for security and size optimization.
- **Non-root users**: Security best practice, but some apps are hard to run as non-root.
- **Health checks**: Liveness vs readiness probes serve different purposes.
- **Image scanning**: Vulnerability management is ongoing, not one-time.

## Common Mistakes & Lessons

### Terraform
1. **Forgot terraform init** - 30 minutes of debugging for a rookie mistake
2. **Circular dependencies** - had to restructure modules
3. **State conflicts** - remote state is non-negotiable for teams
4. **Provider versioning** - breaking changes destroy weekends. Pin everything!
5. **Resource naming** - inconsistent naming makes debugging hell

### Kubernetes
1. **Wrong image names** - forgot to update ECR URI
2. **Resource limits** - pods kept getting killed
3. **Service selectors** - labels must match exactly (case-sensitive)
4. **Ingress setup** - ALB controller is complex
5. **Network policies** - default-deny can break everything

### AWS
1. **IAM permissions** - hours debugging access denied
2. **VPC networking** - subnets and route tables are complex
3. **EKS scaling** - instance types matter more than expected
4. **ECR auth** - token rotation can break CI/CD
5. **CloudWatch costs** - custom metrics are expensive

## Helpful Resources

### Documentation
- **AWS EKS Getting Started Guide** - Good foundation
- **Terraform AWS Provider Docs** - Comprehensive, examples are gold
- **Kubernetes Official Docs** - Concepts section is excellent
- **Docker Best Practices** - Security-focused patterns
- **AWS Well-Architected Framework** - Security and reliability pillars

### Community
- **Stack Overflow** - Specific errors (but answers can be outdated)
- **GitHub Issues** - Tool problems and feature requests
- **CNCF Slack** - Real-time help from maintainers
- **Kubernetes Slack** - Direct access to maintainers

## What I'd Do Differently

### Planning
1. **Start simpler** - EC2 + Docker first, then evolve to EKS
2. **Learn incrementally** - Terraform → Docker → Kubernetes
3. **Local development** - KindD or minikube for testing
4. **Cost planning** - billing alerts from day one
5. **Security by design** - not bolted on later

### Implementation
1. **Proper error handling** - graceful degradation in production
2. **Testing** - unit, integration, and e2e tests
3. **Structured logging** - correlation IDs for debugging
4. **Monitoring from day one** - can't monitor what you don't measure
5. **Backup strategies** - disaster recovery planning

### Documentation
1. **Document as I go** - documentation debt is as bad as technical debt
2. **Runbooks** - save lives during incidents
3. **Cost estimates** - optimization is ongoing
4. **Architecture decisions** - document why, not just what

## Next Steps

### Short Term
- [ ] **Prometheus & Grafana** - Production monitoring stack
- [ ] **Testing** - Unit, integration, and e2e tests
- [ ] **CI/CD improvements** - Security scanning, dependency checking
- [ ] **Structured logging** - ELK stack or similar
- [ ] **Health checks** - Application and business metrics

### Medium Term
- [ ] **Microservices** - Service boundaries and distributed systems
- [ ] **Service mesh (Istio)** - Advanced networking and security
- [ ] **GitOps** - ArgoCD, Flux, declarative deployments
- [ ] **Multi-cloud** - Vendor lock-in avoidance
- [ ] **Container security** - Runtime security and compliance

### Long Term
- [ ] **AWS certifications** - Solutions Architect, DevOps Engineer
- [ ] **Distributed systems** - CAP theorem, consensus algorithms
- [ ] **System design** - Load balancing, caching patterns
- [ ] **Open source** - CNCF projects, Kubernetes operators
- [ ] **Chaos engineering** - Resilience testing

## Tools to Learn Next

### Monitoring & Observability
- **Prometheus** - Our CloudWatch setup is basic
- **Grafana** - CloudWatch dashboards are limited
- **ELK Stack** - Log aggregation (logging is scattered)

### Security
- **Vault** - More flexible than AWS Secrets Manager
- **Falco** - Runtime security monitoring
- **OPA** - Policy as code for network policies

### Development
- **Helm** - K8s manifests are getting complex
- **ArgoCD** - GitOps is the future
- **Skaffold** - Local development is painful

## Project Issues & Solutions

### Problems We Faced
1. **Terraform State Conflicts** - Multiple people working on project
   - **Solution**: S3 backend with DynamoDB locking
   - **Lesson**: Remote state is mandatory for teams

2. **EKS Node Scaling Issues** - Pods evicted due to resource constraints
   - **Solution**: Upgraded t3.micro → t3.small, added resource limits
   - **Lesson**: Instance sizing matters more than expected

3. **IAM Permission Hell** - GitHub Actions "Access Denied" errors
   - **Solution**: Dedicated IAM roles with least privilege
   - **Lesson**: IAM policy simulator is invaluable

4. **ECR Auth Issues** - Login tokens expiring in CI/CD
   - **Solution**: OIDC provider for GitHub Actions
   - **Lesson**: Long-lived credentials are security risks

5. **K8s Service Discovery** - Pods couldn't communicate
   - **Solution**: Fixed service selectors and network policies
   - **Lesson**: Label matching is case-sensitive

6. **Cost Spiral** - Unexpected AWS bill growth
   - **Solution**: Billing alerts and resource tagging
   - **Lesson**: Cost monitoring = application monitoring

### What We Got Right
- **Modular Terraform** - Maintainable, testable code
- **Security-First** - IRSA, non-root containers, network policies
- **Comprehensive Docs** - README, security docs, workflows
- **CI/CD Pipeline** - Automated testing, security scanning

## Key Takeaways

1. **Start simple, evolve gradually** - EKS taught us more than EC2 + Docker would have
2. **Security is not optional** - Every decision has security implications
3. **Documentation saves lives** - Good docs are priceless at 2 AM
4. **Cost optimization is ongoing** - AWS bills spiral without monitoring
5. **Community is everything** - Stack Overflow, GitHub issues saved hours

**Next phase**: GitOps with ArgoCD, Prometheus/Grafana monitoring, service mesh exploration.
