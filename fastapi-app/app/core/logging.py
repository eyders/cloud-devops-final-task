"""Global JSON logging configuration."""
import logging
import sys
from pythonjsonlogger import jsonlogger

def configure_logging() -> None:
    """Configure root logger to emit JSON lines."""
    root = logging.getLogger()
    if root.handlers:
        return
    root.setLevel(logging.INFO)
    handler = logging.StreamHandler(sys.stdout)
    handler.setFormatter(
        jsonlogger.JsonFormatter("%(asctime)s %(levelname)s %(name)s %(message)s")
    )
    root.addHandler(handler)
