"""Cache utilities for the application.

This module provides Redis client configuration and cache utilities.
"""

import logging
from typing import Optional

try:
    import redis.asyncio as redis
except ImportError:
    redis = None

from app.core.config import settings

logger = logging.getLogger(__name__)

# Global Redis client instance
_redis_client: Optional[redis.Redis] = None

def get_redis_client() -> Optional[redis.Redis]:
    """Get Redis client instance.
    
    Returns:
        Redis client instance or None if Redis is not available
    """
    global _redis_client
    
    if redis is None:
        logger.warning("Redis not available - caching disabled")
        return None
    
    if _redis_client is None:
        try:
            # Use default Redis configuration for now
            _redis_client = redis.Redis(
                host=getattr(settings, 'REDIS_HOST', 'localhost'),
                port=getattr(settings, 'REDIS_PORT', 6379),
                db=getattr(settings, 'REDIS_DB', 0),
                decode_responses=True
            )
            logger.info("Redis client initialized")
        except Exception as e:
            logger.error(f"Failed to initialize Redis client: {e}")
            return None
    
    return _redis_client

async def close_redis_client():
    """Close Redis client connection."""
    global _redis_client
    
    if _redis_client:
        try:
            await _redis_client.close()
            _redis_client = None
            logger.info("Redis client closed")
        except Exception as e:
            logger.error(f"Error closing Redis client: {e}")

class MockRedisClient:
    """Mock Redis client for when Redis is not available."""
    
    def __init__(self):
        self._data = {}
    
    async def get(self, key: str) -> Optional[str]:
        """Mock get operation."""
        return self._data.get(key)
    
    async def set(self, key: str, value: str) -> bool:
        """Mock set operation."""
        self._data[key] = value
        return True
    
    async def setex(self, key: str, ttl: int, value: str) -> bool:
        """Mock setex operation."""
        self._data[key] = value
        return True
    
    async def delete(self, *keys: str) -> int:
        """Mock delete operation."""
        deleted = 0
        for key in keys:
            if key in self._data:
                del self._data[key]
                deleted += 1
        return deleted
    
    async def smembers(self, key: str) -> set:
        """Mock smembers operation."""
        return set()
    
    async def sadd(self, key: str, *values: str) -> int:
        """Mock sadd operation."""
        return len(values)
    
    async def expire(self, key: str, ttl: int) -> bool:
        """Mock expire operation."""
        return True
    
    async def info(self, section: str = None) -> dict:
        """Mock info operation."""
        return {
            'used_memory': 0,
            'used_memory_human': '0B'
        }

def get_cache_client():
    """Get cache client (Redis or mock).
    
    Returns:
        Redis client or mock client if Redis is not available
    """
    redis_client = get_redis_client()
    if redis_client is None:
        logger.info("Using mock cache client")
        return MockRedisClient()
    return redis