# Cloud DevOps – FastAPI App

Minimal FastAPI application with health and info endpoints

## Endpoints
* `/healthz`
* `/api/v1/info`

## Local run
```bash
python -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
uvicorn app.main:app --reload
```

## Tests
```bash
pytest -rp
```

## Docker
```bash
docker build -t fastapi-app .
docker run -p 8000:8000 fastapi-app
```
