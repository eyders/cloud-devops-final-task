variable "ecr_repo_name" {
  description = "Name of the ECR repository"
  type        = string
  default     = "fastapi-app"
}

variable "github_org" {
  description = "GitHub organization or user (used in OIDC trust policy)"
  type        = string
  default     = "eyders"
}

variable "github_repo" {
  description = "GitHub repository name"
  type        = string
  default     = "cloud-devops-final-task"
}

variable "ecr_image_retention_count" {
  description = "The number of ECR images to retain before older ones are expired by the lifecycle policy."
  type        = number
  default     = 5
}