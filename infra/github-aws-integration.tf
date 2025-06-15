# Amazon ECR Repository
resource "aws_ecr_repository" "app" {
  name                 = var.ecr_repo_name
  image_tag_mutability = "MUTABLE"
}

# Lifecycle policy
resource "aws_ecr_lifecycle_policy" "keep_last" {
  repository = aws_ecr_repository.app.name

  policy = jsonencode({
    rules = [{
      rulePriority = 10
      description  = "Expire images beyond the 10 most recent"
      selection    = {
        tagStatus   = "any"
        countType   = "imageCountMoreThan"
        countNumber = var.ecr_image_retention_count
      }
      action = { type = "expire" }
    }]
  })
}

# GitHub ↔︎ AWS OIDC Federation
resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = ["sts.amazonaws.com"]

  # SHA-1 thumbprint of GitHub’s OIDC cert
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}

# IAM Role for GitHub Actions
data "aws_iam_policy_document" "github_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = [
        "repo:${var.github_org}/${var.github_repo}:ref:refs/heads/*"
      ]
    }
  }
}

resource "aws_iam_role" "github_actions_ecr" {
  name               = "github-actions-ecr"
  assume_role_policy = data.aws_iam_policy_document.github_assume_role.json
}

# Push / pull image ECR
resource "aws_iam_role_policy_attachment" "ecr_power_user" {
  role       = aws_iam_role.github_actions_ecr.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}

# eks cluster policy
data "aws_iam_policy_document" "eks_describe_cluster" {
  statement {
    effect    = "Allow"
    actions   = ["eks:DescribeCluster"]
    resources = ["*"]
  }
}

# This policy allows GitHub Actions to describe EKS clusters, 
# enabling commands like 'aws eks update-kubeconfig' and IAM kubectl token generation.
resource "aws_iam_role_policy" "eks_describe_cluster" {
  name   = "GitHubActionsEKSDescribeCluster"
  role   = aws_iam_role.github_actions_ecr.id
  policy = data.aws_iam_policy_document.eks_describe_cluster.json
}