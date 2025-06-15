variable "env" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "private_subnets" {
  description = "List of private subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.0.0/19", "10.0.32.0/19"]
}

variable "public_subnets" {
  description = "List of public subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.64.0/19", "10.0.96.0/19"]
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "eks_name" {
  description = "EKS cluster name"
  type        = string
  default     = "devops-demo"
}

variable "eks_version" {
  description = "EKS cluster version"
  type        = string
  default     = "1.32"
}

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