resource "aws_eks_addon" "pod_identity" {
  cluster_name  = module.eks.cluster_name
  addon_name    = "eks-pod-identity-agent"
  addon_version = "v1.3.7-eksbuild.2"
  
  depends_on = [module.eks]
}
