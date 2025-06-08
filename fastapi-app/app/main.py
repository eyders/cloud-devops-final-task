"""FastAPI application entry‑point.

Exposes:
    * `/healthz` – Liveness probe.
    * `/api/v1/info` – Basic metadata endpoint.

Configures structured JSON logging before creating the FastAPI
instance.
"""
from fastapi import FastAPI
from app.api.v1 import router as v1_router
from app.core.logging import configure_logging

configure_logging()

app = FastAPI(
    title="Cloud DevOps Demo API",
    version="0.1.0",
    docs_url="/docs",
    redoc_url="/redoc",
    openapi_url="/openapi.json",
)

@app.get("/healthz", tags=["health"])
async def healthz() -> dict[str, str]:
    """Return service health."""
    return {"status": "ok"}

app.include_router(v1_router, prefix="/api/v1")
