import time
import logging
import psutil
from django.db import connection
from django.core.cache import cache
from rest_framework.views import APIView
from rest_framework.permissions import AllowAny
from core.responses import success_response, failure_response

logger = logging.getLogger(__name__)

class SREHealthView(APIView):
    """
    SRE Platform Health & Telemetry View for Prometheus/Grafana integrations.
    Exposes CPU, Memory, Database latency, Redis ping latency, and Celery status.
    """
    permission_classes = [AllowAny]

    def get(self, request):
        status_data = {
            "status": "healthy",
            "cpu_usage_pct": 0.0,
            "memory_usage_pct": 0.0,
            "database_latency_ms": 0.0,
            "redis_latency_ms": -1.0,
            "celery_workers_online": False,
        }

        # 1. CPU & Memory
        try:
            status_data["cpu_usage_pct"] = psutil.cpu_percent(interval=None)
            status_data["memory_usage_pct"] = psutil.virtual_memory().percent
        except Exception as e:
            logger.error("Failed to query system metrics: %s", str(e))

        # 2. Database Connectivity and Latency
        try:
            start_time = time.time()
            with connection.cursor() as cursor:
                cursor.execute("SELECT 1;")
            status_data["database_latency_ms"] = round((time.time() - start_time) * 1000, 2)
        except Exception as e:
            status_data["status"] = "unhealthy"
            logger.error("Health check Database connection failed: %s", str(e))

        # 3. Redis Connectivity and Latency
        try:
            start_time = time.time()
            cache.set("health_check_ping", "pong", timeout=5)
            ping_val = cache.get("health_check_ping")
            if ping_val == "pong":
                status_data["redis_latency_ms"] = round((time.time() - start_time) * 1000, 2)
        except Exception as e:
            logger.warning("Health check Redis cache connectivity failed: %s", str(e))

        # 4. Celery Workers status check
        try:
            from config.celery import app as celery_app
            inspect = celery_app.control.inspect(timeout=0.5)
            active_workers = inspect.ping()
            if active_workers:
                status_data["celery_workers_online"] = True
        except Exception as e:
            logger.warning("Health check Celery workers check failed: %s", str(e))

        if status_data["status"] == "healthy":
            return success_response("System telemetry retrieved successfully", data=status_data)
        return failure_response("System telemetry reported failures", errors=[status_data], status_code=503)
