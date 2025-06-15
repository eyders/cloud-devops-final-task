output "ecr_repo_url" {
  description = "ECR registry/repository URL"
  value       = aws_ecr_repository.app.repository_url
}

output "github_actions_role_arn" {
  description = "IAM role to assume from GitHub Actions"
  value       = aws_iam_role.github_actions_ecr.arn
}

output "github_actions_terraform_role_arn" {
  description = "IAM role that the infra pipeline will assume"
  value       = aws_iam_role.github_actions_terraform.arn
}