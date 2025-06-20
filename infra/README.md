# Terraform AWS EKS

This repository contains a **production‑ready Terraform configuration** that provisions an Amazon EKS cluster and the supporting AWS infrastructure that tends to be required in real‑world workloads.

## 🏗️ Key Components

* **Networking** – VPC with public + private subnets across multiple AZs, Internet & NAT Gateways  
* **Compute** – Managed node group for worker nodes  
* **Cluster add‑ons** –  
  * AWS Load Balancer Controller
  * Cluster Autoscaler 
  * Kubernetes Metrics Server  
  * EKS Pod Identity (IRSA replacement)  
* **State locking** – S3 backend + DynamoDB table  
* **Secure by default** – IAM roles for service accounts (IRSA) and least‑privilege policies
* **Bootstrap resources** – ECR repository, GitHub OIDC integration, and IAM roles

> **Status**: the code has been tested in **`us‑east‑1`** but should work in any AWS region that supports EKS Pod Identity.

## 📁 Project Structure

```
infra/
├── bootstrap/
│   ├── backend.tf 
│   ├── iam.tf
│   ├── providers.tf 
│   ├── variables.tf
│   └── outputs.tf
├── vpc.tf
├── variables.tf
├── outputs.tf
├── backend.tf
├── providers.tf
├── eks.tf
├── aws-lbl.tf
├── cluster-autoscaler.tf
├── metrics-server.tf
├── pod-identity-addon.tf
└── README.md
```

---

## 🏛️ Architecture

```
┌──────────────────────────────────────────────────────────────────────────────┐
│                               AWS Account (env)                              │
│                                                                              │
│  ┌──────────────┐    ┌─────────────────┐    ┌─────────────────────────────┐  │
│  │   S3 Bucket  │    │  DynamoDB table │    │   Terraform Cloud / local   │  │
│  │  tf‑state    │    │  tf‑locks       │    │  workstation                │  │
│  └──────────────┘    └─────────────────┘    └─────────────────────────────┘  │
│                                                                              │
│  ┌──────────────────────── VPC (10.0.0.0/16) ─────────────────────────────┐  │
│  │ public subnets         | private subnets                               │  │
│  │  IGW  ↕                |  NAT GW ↕                                     │  │
│  │          ┌───────────────────────────────────────┐                     │  │
│  │          │         Amazon EKS control‑plane      │                     │  │
│  │          └────────────────────────┬──────────────┘                     │  │
│  │                                   │ kube‑api                           │  │
│  │   ┌───────────────────────────────┴────────────────────────────────┐   │  │
│  │   │             Managed node group (EC2)                           │   │  │
│  │   │  – AWS LBC  |  Cluster Autoscaler  |  Metrics Server  |  IRSA  │   │  │
│  │   └────────────────────────────────────────────────────────────────┘   │  │
│  └────────────────────────────────────────────────────────────────────────┘  │
│                                                                              │
│  ┌──────────────────────── Bootstrap Resources ──────────────────────────┐   │
│  │  • ECR Repository                                                     │   │
│  │  • GitHub OIDC Provider                                               │   │ 
│  │  • IAM Roles (GitHub Actions)                                         │   │
│  │  • S3 Bucket (Terraform State)                                        │   │
│  │  • DynamoDB Table (State Locking)                                     │   │
│  └───────────────────────────────────────────────────────────────────────┘   │
└──────────────────────────────────────────────────────────────────────────────┘
```

---

## 🚀 Prerequisites

| Tool | Version (min) | Notes |
|------|---------------|-------|
| [Terraform](https://terraform.io) | **1.0** | Tested with 1.6.x |
| [AWS CLI](https://aws.amazon.com/cli/) | any | Auth must allow EKS + IAM + VPC |
| [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/)  | 1.32+ | Matches the cluster version |
| [helm](https://helm.sh/docs/intro/install/) | 3.x | Needed only for manual addon management |

### AWS Permissions Required

Your AWS credentials must have permissions for:
- **EKS**: Access to create/manage clusters
- **EC2**: VPC, subnets, security groups, instances
- **IAM**: Create/manage roles and policies
- **ECR**: Repository management
- **S3**: State bucket access
- **DynamoDB**: State locking table access

---

## 🏗️ Bootstrap Setup

Before deploying the main infrastructure, you need to create the foundational AWS resources.

### 1. Bootstrap Resources

```bash
cd infra/bootstrap
terraform init
terraform plan
terraform apply
```

The bootstrap creates:
- **S3 Bucket**: `terraform-state-eks-devops-2025` for Terraform state
- **DynamoDB Table**: `terraform-locks` for state locking
- **ECR Repository**: `fastapi-app` for container images
- **GitHub OIDC Provider**: For secure CI/CD authentication
- **IAM Roles**: 
  - `github-actions-ecr` - For application deployment
  - `github-actions-terraform` - For infrastructure management

### 2. Bootstrap Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `ecr_repo_name` | ECR repository name | `"fastapi-app"` |
| `github_org` | GitHub organization/user | `"eyders"` |
| `github_repo` | GitHub repository name | `"cloud-devops-final-task"` |
| `ecr_image_retention_count` | Number of images to retain | `5` |

### 3. Bootstrap Outputs

After bootstrap completion, you'll get:
- **ECR Repository URL**: For container image pushing
- **GitHub Actions IAM Role ARNs**: For CI/CD configuration

---

## 🚀 Main Infrastructure Deployment

### Quick Start

```bash
# 1. Navigate to infrastructure directory
cd infra

# 2. Initialize Terraform
terraform init

# 3. Review the execution plan
terraform plan

# 4. Apply (creates resources)
terraform apply
```

The apply takes ~15 minutes. Once finished, retrieve your kubeconfig:

```bash
aws eks --region us-east-1 update-kubeconfig --name $(terraform output -raw cluster_name)
```

### Manual Backend Setup (Alternative)

If you prefer to create the backend resources manually:

```bash
# Create S3 bucket for state
aws s3api create-bucket \
  --bucket terraform-state-eks-devops-2025 \
  --region us-east-1

# Create DynamoDB table for locking
aws dynamodb create-table \
  --table-name terraform-locks \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST
```

Then update `backend.tf` with your bucket name.

---

## ⚙️ Configuration

### Main Infrastructure Variables

| Name | Description | Default |
|------|-------------|---------|
| `env` | Environment name | `"dev"` |
| `region` | AWS region | `"us-east-1"` |
| `availability_zones` | List of availability zones | `["us-east-1a", "us-east-1b"]` |
| `private_subnets` | Private subnet CIDR blocks | `["10.0.0.0/19", "10.0.32.0/19"]` |
| `public_subnets` | Public subnet CIDR blocks | `["10.0.64.0/19", "10.0.96.0/19"]` |
| `vpc_cidr` | VPC CIDR block | `"10.0.0.0/16"` |
| `eks_name` | EKS cluster name | `"devops-demo"` |
| `eks_version` | EKS cluster version | `"1.32"` |
| `github_actions_ecr_arn` | GitHub Actions ECR role ARN | From bootstrap output |

### Custom Configuration

Create a `terraform.tfvars` file to override defaults:

```hcl
env = "production"
region = "us-west-2"
eks_name = "my-cluster"
availability_zones = ["us-west-2a", "us-west-2b", "us-west-2c"]
private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
public_subnets = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
```

---

## 📊 Outputs

| Output | Description |
|--------|-------------|
| `cluster_endpoint` | Endpoint for EKS control plane |
| `cluster_security_group_id` | Security group IDs attached to the cluster control plane |
| `cluster_name` | Kubernetes Cluster Name |
| `cluster_arn` | ARN of the EKS Cluster |
| `kubectl_config_command` | kubectl config command" |
| `vpc_id` | VPC ID |
| `private_subnets` | Private subnet IDs |
| `public_subnets` | Public subnet IDs |

---

## 🔧 Add‑ons

| Add‑on | Deployment Method | Version | Documentation |
|--------|-------------------|---------|---------------|
| **AWS Load Balancer Controller** | Helm chart | v1.13.2 | [AWS Docs](https://docs.aws.amazon.com/eks/latest/userguide/aws-load-balancer-controller.html) |
| **Cluster Autoscaler** | Helm chart with IRSA | Latest | [GitHub](https://github.com/kubernetes/autoscaler/tree/master/cluster-autoscaler) |
| **Metrics Server** | Helm chart | Latest | [GitHub](https://github.com/kubernetes-sigs/metrics-server) |
| **Pod Identity** | EKS addon | v1.3.7‑eksbuild.2 | [AWS Docs](https://docs.aws.amazon.com/eks/latest/userguide/pod-identities.html) |

### Add‑on Features

- **Auto-scaling**: Cluster Autoscaler automatically adjusts node count
- **Load Balancing**: ALB Controller manages Application Load Balancers
- **Monitoring**: Metrics Server provides resource usage data
- **Security**: Pod Identity for secure AWS service access

---

## 🔄 CI/CD Integration

### GitHub Secrets Required

```
AWS_ACCOUNT_ID=123456789012
EKS_CLUSTER_NAME=devops-demo
```

### Infrastructure Pipeline

The `infra-ci-cd.yml` workflow:
1. **Validates** Terraform syntax
2. **Plans** infrastructure changes
3. **Comments** plan on pull requests
4. **Applies** changes on merge to main

### Permissions

GitHub Actions uses OIDC with these IAM roles:
- `github-actions-terraform` - Infrastructure management
- `github-actions-ecr` - Container registry and EKS access

---

## 🧹 Cleanup

### Destroy Infrastructure

```bash
# Destroy main infrastructure
terraform destroy

# Destroy bootstrap resources
cd bootstrap
terraform destroy
```

---

## 🔧 Troubleshooting

### Debug Commands

```bash
# Check cluster status
kubectl cluster-info

# Check node status
kubectl get nodes

# Check system pods
kubectl get pods -n kube-system

# Check add-on logs
kubectl logs -n kube-system -l app.kubernetes.io/name=aws-load-balancer-controller
```
