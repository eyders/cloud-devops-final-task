# Terraform AWS EKS Blueprint

This repository contains a **production‑ready Terraform configuration** that provisions an Amazon EKS cluster and the supporting AWS infrastructure that tends to be required in real‑world workloads.

Key components included:

* **Networking** – VPC with public + private subnets across multiple AZs, Internet & NAT Gateways  
* **Compute** – Managed node group for worker nodes  
* **Cluster add‑ons** –  
  * AWS Load Balancer Controller
  * Cluster Autoscaler 
  * Kubernetes Metrics Server  
  * EKS Pod Identity (IRSA replacement)  
* **State locking** – S3 backend + DynamoDB table  
* **Secure by default** – IAM roles for service accounts (IRSA) and least‑privilege policies

> **Status**: the code has been tested in **`us‑east‑1`** but should work in any AWS region that supports EKS Pod Identity.  

---

## Architecture

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
│  │          │         Amazon EKS control‑plane      │                     │  │
│  │          └────────────────────────┬──────────────┘                     │  │
│  │                                   │ kube‑api                           │  │
│  │   ┌───────────────────────────────┴────────────────────────────────┐   │  │
│  │   │             Managed node group (EC2)                           │   │  │
│  │   │  – AWS LBC  |  Cluster Autoscaler  |  Metrics Server  |  IRSA  │   │  │
│  │   └────────────────────────────────────────────────────────────────┘   │  │
│  └────────────────────────────────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────────────────────────────────┘
```

---

## Prerequisites

| Tool | Version (min) | Notes |
|------|---------------|-------|
| [Terraform](https://terraform.io) | **1.0** | Tested with 1.8.x |
| [AWS CLI](https://aws.amazon.com/cli/) | any | Auth must allow EKS + IAM + VPC |
| [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/)  | 1.32+ | Matches the cluster version |
| [helm](https://helm.sh/docs/intro/install/) | 3.x | Needed only for manual addon management |

Create **one‑off** resources for the backend (replace placeholders):

```bash
aws s3api create-bucket --bucket <YOUR_TF_STATE_BUCKET> --region us-east-1
aws dynamodb create-table   --table-name terraform-locks   --attribute-definitions AttributeName=LockID,AttributeType=S   --key-schema AttributeName=LockID,KeyType=HASH   --billing-mode PAY_PER_REQUEST
```

Update `backend.tf` with your bucket and (optionally) an S3 key prefix.

---

## Quick Start

```bash
# 1. Clone
git clone https://github.com/<your‑org>/<repo>.git
cd <repo>

# 2. Initialise providers & backend
terraform init

# 3. Review the execution plan
terraform plan

# 4. Apply (creates resources)
terraform apply
```

The apply takes ~15 minutes. Once finished retrieve your kubeconfig:

```bash
aws eks --region <region> update-kubeconfig --name $(terraform output -raw cluster_name)
```

### Destroy

```bash
terraform destroy
```

---

## Configuration

Below are the inputs you can tweak. Any of them can be overridden with `-var` or a `terraform.tfvars` file.

| Name | Description | Default |
|------|-------------|---------|
| env | Environment name | `"dev"` |
| region | AWS region | `"us-east-1"` |
| availability_zones | List of availability zones | `["us-east-1a", "us-east-1b"]` |
| private_subnets | List of private subnet CIDR blocks | `["10.0.0.0/19", "10.0.32.0/19"]` |
| public_subnets | List of public subnet CIDR blocks | `["10.0.64.0/19", "10.0.96.0/19"]` |
| vpc_cidr | VPC CIDR block | `"10.0.0.0/16"` |
| eks_name | EKS cluster name | `"devops-demo"` |
| eks_version | EKS cluster version | `"1.32"` |

---

## Outputs

| Output | Description |
|--------|-------------|
| cluster_endpoint | Endpoint for EKS control plane |
| cluster_security_group_id | Security group ids attached to the cluster control plane |
| cluster_name | Kubernetes Cluster Name |
| cluster_arn | ARN of the EKS Cluster |
| cluster_certificate_authority_data | Base64 encoded certificate data required to communicate with the cluster |
| cluster_version | EKS Kubernetes version |
| node_group_iam_role_arn | IAM role ARN associated with workers |
| managed_node_group_status | Status of the managed node group |
| vpc_id | VPC ID |
| private_subnets | Private subnet IDs |
| public_subnets | Public subnet IDs |

---

## Add‑ons

| Add‑on | How it is deployed | Docs |
|--------|--------------------|------|
| AWS Load Balancer Controller | Helm chart (`aws-load-balancer-controller` v1.13.2) | <https://docs.aws.amazon.com/eks/latest/userguide/aws-load-balancer-controller.html> |
| Cluster Autoscaler | Helm chart (`cluster-autoscaler`) with IRSA‑backed IAM role | <https://github.com/kubernetes/autoscaler/tree/master/cluster-autoscaler> |
| Metrics Server | Helm chart (`metrics-server`) | <https://github.com/kubernetes-sigs/metrics-server> |
| Pod Identity | `aws_eks_addon` resource (v1.3.7‑eksbuild.2) | <https://docs.aws.amazon.com/eks/latest/userguide/pod-identities.html> |
