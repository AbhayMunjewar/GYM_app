import json
import logging
from django.core.cache import cache

logger = logging.getLogger(__name__)

class SaaSCacheService:
    """
    SaaS Cache Service with custom key generation scoped by Tenant/Gym.
    Supports safe LocMemCache fallbacks if Redis goes offline.
    """

    @staticmethod
    def _make_key(tenant_id, area, unique_id=None):
        if unique_id:
            return f"tenant:{tenant_id}:{area}:{unique_id}"
        return f"tenant:{tenant_id}:{area}"

    @classmethod
    def get_cached_dashboard(cls, tenant_id, branch_id=None):
        key = cls._make_key(tenant_id, "dashboard", branch_id)
        try:
            val = cache.get(key)
            if val:
                return json.loads(val)
        except Exception as e:
            logger.error("Cache read failed: %s", str(e))
        return None

    @classmethod
    def set_cached_dashboard(cls, tenant_id, data, branch_id=None, timeout=300):
        key = cls._make_key(tenant_id, "dashboard", branch_id)
        try:
            cache.set(key, json.dumps(data), timeout)
        except Exception as e:
            logger.error("Cache write failed: %s", str(e))

    @classmethod
    def invalidate_dashboard(cls, tenant_id, branch_id=None):
        key = cls._make_key(tenant_id, "dashboard", branch_id)
        try:
            cache.delete(key)
        except Exception as e:
            logger.error("Cache delete failed: %s", str(e))

    @classmethod
    def get_cached_feature_flags(cls, tenant_id):
        key = cls._make_key(tenant_id, "feature_flags")
        try:
            val = cache.get(key)
            if val:
                return json.loads(val)
        except Exception as e:
            logger.error("Cache read failed: %s", str(e))
        return None

    @classmethod
    def set_cached_feature_flags(cls, tenant_id, data, timeout=3600):
        key = cls._make_key(tenant_id, "feature_flags")
        try:
            cache.set(key, json.dumps(data), timeout)
        except Exception as e:
            logger.error("Cache write failed: %s", str(e))

    @classmethod
    def invalidate_feature_flags(cls, tenant_id):
        key = cls._make_key(tenant_id, "feature_flags")
        try:
            cache.delete(key)
        except Exception as e:
            logger.error("Cache delete failed: %s", str(e))
