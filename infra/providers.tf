provider "aws" {
  region = var.region
}

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 5.49"
    }
    helm = {
      source = "hashicorp/helm"
      version = "~> 2.0"
    }
  }
}

data "aws_eks_cluster_auth" "eks" {
  name = module.eks.cluster_name
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.eks.token
  }
}
