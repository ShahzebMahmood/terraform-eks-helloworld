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
# IAM Module
# ---------------------------
module "iam" {
  source            = "./modules/iam"
  cluster_name      = var.cluster_name
  cluster_role_name = "${var.cluster_name}-cluster-role"
  node_role_name    = "${var.cluster_name}-node-role"
}

# ---------------------------
# EKS Module
# ---------------------------
module "eks" {
  source           = "./modules/eks"
  cluster_name     = var.cluster_name
  cluster_role_arn = module.iam.eks_cluster_role_arn
  node_role_arn    = module.iam.eks_node_role_arn
  subnet_ids       = module.vpc.public_subnet_ids
  desired_capacity = var.desired_capacity
  max_size         = var.max_size
  min_size         = var.min_size
  instance_type    = var.instance_type
}
