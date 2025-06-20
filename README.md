# Cloud DevOps Final Task

A complete DevOps solution demonstrating modern cloud-native application deployment using AWS EKS, Terraform, GitHub Actions, and Kubernetes.

## 🏗️ Architecture Overview

This project implements a production-ready infrastructure with:

- **FastAPI Application** - Modern Python web API with health checks
- **AWS EKS Cluster** - Managed Kubernetes service with autoscaling
- **Infrastructure as Code** - Terraform for AWS resource provisioning
- **CI/CD Pipeline** - GitHub Actions for automated testing and deployment
- **Container Registry** - Amazon ECR for Docker image storage
- **Load Balancing** - AWS Application Load Balancer with SSL termination

## 📁 Project Structure

```
├── .github/workflows/     # GitHub Actions CI/CD pipelines
│   ├── app-ci-cd.yml     # Application build, test, and deploy
│   └── infra-ci-cd.yml   # Infrastructure provisioning
├── fastapi-app/          # FastAPI application source code
├── infra/                # Terraform infrastructure code
│   └── bootstrap/        # Initial AWS resources setup
├── k8s/                  # Kubernetes manifests and overlays
│   ├── base/            # Base Kubernetes resources
│   └── overlays/        # Environment-specific customizations
└── README.md            # This file
```

## 🚀 Getting Started

### Prerequisites

- AWS CLI configured with appropriate permissions
- Terraform >= 1.0
- kubectl >= 1.32
- Docker
- Python 3.11+

### Quick Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/eyders/cloud-devops-final-task.git
   cd cloud-devops-final-task
   ```

2. **Bootstrap AWS resources**
   ```bash
   cd infra/bootstrap
   terraform init
   terraform apply
   ```

3. **Deploy infrastructure**
   ```bash
   cd ../
   terraform init
   terraform apply
   ```

4. **Configure kubectl**
   ```bash
   aws eks update-kubeconfig --region us-east-1 --name $(terraform output -raw cluster_name)
   ```

5. **Deploy application**
   ```bash
   kubectl apply -k k8s/overlays/prod
   ```

## 📖 Documentation

Each component has detailed documentation:

- **[FastAPI Application](./fastapi-app/README.md)** - Application development, testing, and local deployment
- **[Infrastructure](./infra/README.md)** - Terraform configuration, AWS resources, and infrastructure management
- **[Kubernetes](./k8s/README.md)** - Kubernetes manifests, deployment strategies, and configuration management

## 🔄 CI/CD Pipeline

The project includes two main pipelines:

### Application Pipeline (`app-ci-cd.yml`)
- Runs unit tests
- Builds Docker image
- Pushes to Amazon ECR
- Deploys to EKS cluster
- Triggered on changes to `fastapi-app/` or `k8s/`

### Infrastructure Pipeline (`infra-ci-cd.yml`)
- Validates Terraform syntax
- Plans infrastructure changes
- Comments plan on PRs
- Applies changes on merge to main
- Triggered on changes to `infra/`

## 🔧 Configuration

### GitHub Secrets Required

```
AWS_ACCOUNT_ID=123456789012
EKS_CLUSTER_NAME=devops-demo
```

### Environment Variables

The application uses the following environment variables:
- `APP_ENV` - Application environment (production/development)

## 🌐 Endpoints

Once deployed, the application exposes:

- **Health Check**: `https://eks.serviscloud.com/healthz`
- **API Info**: `https://eks.serviscloud.com/api/v1/info`

## 🛡️ Security Features

- **OIDC Integration** - Secure GitHub Actions authentication
- **IAM Roles** - Least privilege access principles
- **Private Subnets** - Worker nodes in private networks
- **SSL Termination** - HTTPS encryption with ACM certificates
- **Pod Security** - Kubernetes security contexts and policies

## 🔍 Monitoring & Observability

- **Health Probes** - Kubernetes readiness and liveness checks
- **Metrics Server** - Resource usage monitoring
- **Cluster Autoscaler** - Automatic node scaling
- **AWS Load Balancer Controller** - Intelligent traffic routing

## 🏷️ Technologies Used

- **Languages**: Python, HCL (Terraform), YAML
- **Frameworks**: FastAPI, Kubernetes
- **Cloud**: AWS (EKS, ECR, VPC, ALB, IAM)
- **Tools**: Terraform, kubectl, Docker, GitHub Actions
- **Monitoring**: Kubernetes Metrics Server, AWS CloudWatch

## 📧 Contact

- **GitHub**: [@eyders](https://github.com/eyders)
- **Project**: [cloud-devops-final-task](https://github.com/eyders/cloud-devops-final-task)

---