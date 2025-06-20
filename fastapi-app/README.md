# Cloud DevOps – FastAPI App

A minimal, production-ready FastAPI application designed for cloud-native deployment with comprehensive health monitoring and API information endpoints.

## 🚀 Features

- **Health Check Endpoint** - Monitor application status
- **API Information Endpoint** - Retrieve application metadata
- **Docker Support** - Containerized for consistent deployment
- **Production Ready** - Configured for cloud deployment
- **Unit Tests** - Comprehensive test coverage

## 📋 Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/healthz` | GET | Health check endpoint for load balancers and monitoring |
| `/api/v1/info` | GET | Application information and metadata |

## 🏃‍♂️ Local Development

### Prerequisites

- Python 3.11+
- pip (Python package installer)

### Setup and Run

1. **Create virtual environment**
   ```bash
   python -m venv .venv
   source .venv/bin/activate  # On Windows: .venv\Scripts\activate
   ```

2. **Install dependencies**
   ```bash
   pip install -r requirements.txt
   ```

4. **Run the application**
   ```bash
   uvicorn app.main:app --reload
   ```

5. **Access the application**
   - API: http://localhost:8000/api/v1/info
   - Interactive Docs: http://localhost:8000/docs
   - Alternative Docs: http://localhost:8000/redoc

## 🧪 Testing

### Run Unit Tests

```bash
# Run all tests
pytest

# Run with verbose output
pytest -v

# Run specific test file
pytest tests/test_main.py

# Run tests with sort summary
pytest -rp
```

## 🐳 Docker

### Build Image

```bash
docker build -t fastapi-app .
```

### Run Container

```bash
# Run on port 8000
docker run -p 8000:8000 fastapi-app

# Run with environment variables
docker run -p 8000:8000 -e APP_ENV=production fastapi-app

# Run in background
docker run -d -p 8000:8000 --name fastapi-app fastapi-app
```

## 📊 API Documentation

### Health Check Response

```json
{
  "status": "ok"
}
```

### Info Endpoint Response

```json
{
  "app": "Cloud DevOps Demo API",
  "version": "0.1.0",
  "timestamp": "2025-06-19T03:26:03.098441+00:00"
}
```

## 🚀 Deployment

### CI/CD Integration

Automated deployment through GitHub Actions:

1. **Unit Tests** - Runs `pytest` on every commit
2. **Docker Build** - Creates container image
3. **ECR Push** - Uploads to Amazon ECR
4. **EKS Deploy** - Updates Kubernetes deployment

## 🔍 Monitoring

### Health Monitoring

The `/healthz` endpoint provides:
- Application status
