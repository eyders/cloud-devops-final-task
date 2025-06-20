# Kubernetes Manifests

This directory contains all Kubernetes manifests and configuration files for deploying the FastAPI application to Amazon EKS using Kustomize for configuration management.

## 📁 Directory Structure

```
k8s/
├── base/                    # Base Kubernetes resources
│   ├── deployment.yaml      # Application deployment
│   ├── service.yaml         # ClusterIP service
│   ├── ingress.yaml         # AWS ALB ingress
│   ├── configmap.yaml       # Application configuration
│   └── kustomization.yaml   # Base kustomization
└── overlays/                # Environment-specific customizations
    └── prod/                # Production environment
        └── kustomization.yaml
```

## 🏗️ Architecture Overview

The Kubernetes deployment follows cloud-native best practices:

- **Deployment**: Manages application pods with rolling updates
- **Service**: Provides stable network endpoint for pods
- **Ingress**: AWS Application Load Balancer for external access
- **ConfigMap**: Environment-specific configuration
- **Health Probes**: Readiness and liveness checks

## 🚀 Deployment Methods

### Method 1: Using Kustomize (Recommended)

```bash
# Deploy to production
kubectl apply -k overlays/prod

# Verify deployment
kubectl get all -l app=fastapi

# Check application logs
kubectl logs -l app=fastapi

# Check ingres
kubectl get ingress fastapi