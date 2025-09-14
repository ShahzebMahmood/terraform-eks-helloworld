# ---------------------------
# Data Sources
# ---------------------------
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# ---------------------------
# VPC Module
# ---------------------------
module "vpc" {
  source               = "./modules/vpc"
  vpc_cidr             = var.vpc_cidr
  public_subnets_count = var.public_subnets_count
  availability_zones   = var.availability_zones
  tags                 = var.tags
}

# ---------------------------
# IAM Module (Basic Cluster & Node Roles - No OIDC dependencies)
# ---------------------------
module "iam_basic" {
  source            = "./modules/iam-basic"
  cluster_name      = var.cluster_name
  cluster_role_name = "${var.cluster_name}-cluster-role"
  node_role_name    = "${var.cluster_name}-node-role"
  tags              = var.tags
}
# ---------------------------
module "ecr" {
  source = "./modules/ecr"
  tags   = var.tags
}

# ---------------------------
# EKS Module
# ---------------------------
module "eks" {
  source           = "./modules/eks"
  cluster_name     = var.cluster_name
  cluster_role_arn = module.iam_basic.eks_cluster_role_arn
  node_role_arn    = module.iam_basic.eks_node_role_arn
  subnet_ids       = module.vpc.public_subnet_ids
  desired_capacity = var.desired_capacity
  max_size         = var.max_size
  min_size         = var.min_size
  instance_type    = var.instance_type
  tags             = var.tags
}

# ---------------------------
# Monitoring Module
# ---------------------------
module "monitoring" {
  source       = "./modules/monitoring"
  cluster_name = var.cluster_name
  aws_region   = var.aws_region
  tags         = var.tags
}

# ---------------------------
# IAM Module (OIDC-dependent resources)
# ---------------------------
module "iam_oidc" {
  source                = "./modules/iam-oidc"
  cluster_name          = var.cluster_name
  eks_oidc_issuer_url   = module.eks.cluster_oidc_issuer_url
  eks_oidc_provider_arn = module.eks.cluster_oidc_provider_arn
  tags                  = var.tags
}

# ---------------------------
# IAM Module (Pod Identity resources)
# ---------------------------
module "iam_pod_identity" {
  source             = "./modules/iam-pod-identity"
  secrets_policy_arn = module.secrets.secrets_access_policy_arn
  tags               = var.tags
}

# ---------------------------
# Secrets Management Module
# ---------------------------
module "secrets" {
  source            = "./modules/secrets"
  project_name      = var.cluster_name
  pod_role_name     = "hello-world-pod-role"
  pod_role_arn      = module.iam_oidc.hello_world_pod_role_arn
  oidc_provider_arn = module.eks.cluster_oidc_provider_arn
  oidc_provider_url = module.eks.cluster_oidc_issuer_url
  tags              = var.tags
}

# ---------------------------
# GitHub Actions Module (Secrets Management)
# ---------------------------
module "github_actions" {
  source       = "./modules/github-actions"
  project_name = var.cluster_name
  github_repo  = var.github_repo
  aws_region   = var.aws_region
  ecr_repo_uri = module.ecr.hello_world_repo_uri
  cluster_name = module.eks.cluster_name
  eks_cluster_role_arn  = module.iam_basic.eks_cluster_role_arn
  tags                  = var.tags
}

# ---------------------------
# Billing Alerts Module (Free Tier Monitoring)
# ---------------------------
module "billing" {
  source       = "./modules/billing"
  project_name = var.cluster_name
  alert_email  = var.alert_email
  tags         = var.tags
}

