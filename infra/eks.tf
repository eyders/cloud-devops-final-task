module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "${var.env}-${var.eks_name}"
  cluster_version = var.eks_version

  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = false
  
  enable_cluster_creator_admin_permissions = true

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets
  control_plane_subnet_ids = module.vpc.private_subnets

  eks_managed_node_groups = {
    general = {
      name = "general"
      
      instance_types = ["t3.small"]
      capacity_type  = "ON_DEMAND"
      
      min_size     = 1
      max_size     = 2
      desired_size = 1

      labels = {
        role = "general"
      }

      tags = {
        Environment = var.env
      }
    }
  }

  tags = {
    Environment = var.env
    Terraform   = "true"
  }
}