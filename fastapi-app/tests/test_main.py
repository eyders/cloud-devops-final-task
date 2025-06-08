"""Smoke‑tests covering public endpoints."""
from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

def test_healthz() -> None:
    """Health check endpoint returns 200 and expected JSON."""
    response = client.get("/healthz")
    assert response.status_code == 200
    assert response.json() == {"status": "ok"}

def test_info() -> None:
    """Info endpoint returns application metadata."""
    response = client.get("/api/v1/info")
    assert response.status_code == 200
    data = response.json()
    assert data["app"] == "Cloud DevOps Demo API"
    assert data["version"] == "0.1.0"
