module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "${var.env}-main"
  cidr = var.vpc_cidr

  azs             = var.availability_zones
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true
  enable_dns_support   = true

  public_subnet_tags = {
    "kubernetes.io/role/elb"                           = "1"
    "kubernetes.io/cluster/${var.env}-${var.eks_name}" = "owned"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb"                  = "1"
    "kubernetes.io/cluster/${var.env}-${var.eks_name}" = "owned"
  }

  tags = {
    Environment = var.env
    Terraform   = "true"
  }
}
