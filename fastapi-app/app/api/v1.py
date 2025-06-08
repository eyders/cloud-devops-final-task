"""Version 1 of the public API."""
from datetime import datetime, timezone
from fastapi import APIRouter

router = APIRouter(tags=["info"])


@router.get("/info")
async def get_info() -> dict[str, str]:
    """Return static application metadata with a timestamp."""
    return {
        "app": "Cloud DevOps Demo API",
        "version": "0.1.0",
        "timestamp": datetime.now(timezone.utc).isoformat()
    }
