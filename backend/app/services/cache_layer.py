"""Cache Layer Service for Context-Aware Care Plans v2

This service provides Redis-based caching for care plans, environmental data, and ML predictions
to achieve the ≤300ms response time requirement. It implements intelligent cache invalidation,
preemptive warming, and fallback strategies.

Key Features:
- Multi-level caching (L1: in-memory, L2: Redis)
- Intelligent cache warming and invalidation
- Performance monitoring and metrics
- Fallback handling for cache misses
- TTL management based on data volatility
"""

import asyncio
import json
import logging
from datetime import datetime, timedelta
from typing import Dict, List, Optional, Any, Union, Callable
from dataclasses import dataclass, asdict
from enum import Enum
import hashlib
import time

import redis.asyncio as redis
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.config import settings
from app.core.cache import get_redis_client
from app.models.care_plan import CarePlanV2
from app.services.environmental_data import EnvironmentalContext

logger = logging.getLogger(__name__)

class CacheLevel(Enum):
    """Cache level enumeration"""
    L1_MEMORY = "l1_memory"
    L2_REDIS = "l2_redis"
    L3_DATABASE = "l3_database"

class CacheStrategy(Enum):
    """Cache strategy enumeration"""
    WRITE_THROUGH = "write_through"
    WRITE_BEHIND = "write_behind"
    CACHE_ASIDE = "cache_aside"

@dataclass
class CacheMetrics:
    """Cache performance metrics"""
    hits: int = 0
    misses: int = 0
    evictions: int = 0
    write_time_ms: float = 0.0
    read_time_ms: float = 0.0
    
    @property
    def hit_rate(self) -> float:
        total = self.hits + self.misses
        return self.hits / total if total > 0 else 0.0

@dataclass
class CacheEntry:
    """Cache entry with metadata"""
    key: str
    data: Any
    created_at: datetime
    expires_at: Optional[datetime]
    access_count: int = 0
    last_accessed: Optional[datetime] = None
    size_bytes: int = 0
    tags: List[str] = None
    
    def __post_init__(self):
        if self.tags is None:
            self.tags = []
        if self.last_accessed is None:
            self.last_accessed = self.created_at

class CacheLayerService:
    """Advanced caching service for care plans and related data"""
    
    def __init__(self, redis_client: Optional[redis.Redis] = None):
        self.redis = redis_client or get_redis_client()
        self.l1_cache: Dict[str, CacheEntry] = {}  # In-memory cache
        self.metrics = CacheMetrics()
        self.max_l1_size = 1000  # Maximum L1 cache entries
        
        # Cache TTL configurations (in seconds)
        self.ttl_config = {
            'care_plan': 3600,           # 1 hour
            'care_plan_summary': 1800,   # 30 minutes
            'environmental_data': 300,   # 5 minutes
            'species_rules': 86400,      # 24 hours
            'ml_predictions': 1800,      # 30 minutes
            'user_preferences': 7200,    # 2 hours
            'plant_health': 600,         # 10 minutes
            'weather_data': 300,         # 5 minutes
        }
        
        # Cache key prefixes
        self.key_prefixes = {
            'care_plan': 'cp',
            'care_plan_summary': 'cps',
            'environmental_data': 'env',
            'species_rules': 'sr',
            'ml_predictions': 'ml',
            'user_preferences': 'up',
            'plant_health': 'ph',
            'weather_data': 'wd',
        }
    
    async def get(
        self, 
        key: str, 
        cache_type: str = 'default',
        use_l1: bool = True
    ) -> Optional[Any]:
        """Get data from cache with multi-level fallback
        
        Args:
            key: Cache key
            cache_type: Type of cached data for TTL management
            use_l1: Whether to use L1 (memory) cache
            
        Returns:
            Cached data or None if not found
        """
        start_time = time.time()
        
        try:
            # Try L1 cache first
            if use_l1:
                l1_result = await self._get_from_l1(key)
                if l1_result is not None:
                    self.metrics.hits += 1
                    self.metrics.read_time_ms += (time.time() - start_time) * 1000
                    return l1_result
            
            # Try L2 (Redis) cache
            l2_result = await self._get_from_l2(key)
            if l2_result is not None:
                self.metrics.hits += 1
                
                # Warm L1 cache if enabled
                if use_l1:
                    await self._set_to_l1(key, l2_result, cache_type)
                
                self.metrics.read_time_ms += (time.time() - start_time) * 1000
                return l2_result
            
            # Cache miss
            self.metrics.misses += 1
            self.metrics.read_time_ms += (time.time() - start_time) * 1000
            return None
            
        except Exception as e:
            logger.error(f"Cache get error for key {key}: {e}")
            self.metrics.misses += 1
            return None
    
    async def set(
        self, 
        key: str, 
        data: Any, 
        cache_type: str = 'default',
        ttl_override: Optional[int] = None,
        tags: Optional[List[str]] = None,
        use_l1: bool = True
    ) -> bool:
        """Set data in cache with multi-level storage
        
        Args:
            key: Cache key
            data: Data to cache
            cache_type: Type of cached data for TTL management
            ttl_override: Override default TTL
            tags: Tags for cache invalidation
            use_l1: Whether to use L1 (memory) cache
            
        Returns:
            True if successful, False otherwise
        """
        start_time = time.time()
        
        try:
            ttl = ttl_override or self.ttl_config.get(cache_type, 3600)
            
            # Set in L2 (Redis) cache
            success = await self._set_to_l2(key, data, ttl, tags)
            
            # Set in L1 cache if enabled and L2 was successful
            if success and use_l1:
                await self._set_to_l1(key, data, cache_type, ttl, tags)
            
            self.metrics.write_time_ms += (time.time() - start_time) * 1000
            return success
            
        except Exception as e:
            logger.error(f"Cache set error for key {key}: {e}")
            return False
    
    async def delete(self, key: str, use_l1: bool = True) -> bool:
        """Delete data from all cache levels
        
        Args:
            key: Cache key to delete
            use_l1: Whether to delete from L1 cache
            
        Returns:
            True if successful, False otherwise
        """
        try:
            # Delete from L1
            if use_l1 and key in self.l1_cache:
                del self.l1_cache[key]
            
            # Delete from L2 (Redis)
            result = await self.redis.delete(key)
            return result > 0
            
        except Exception as e:
            logger.error(f"Cache delete error for key {key}: {e}")
            return False
    
    async def invalidate_by_tags(self, tags: List[str]) -> int:
        """Invalidate cache entries by tags
        
        Args:
            tags: List of tags to invalidate
            
        Returns:
            Number of entries invalidated
        """
        try:
            invalidated = 0
            
            # Invalidate L1 cache
            keys_to_remove = []
            for key, entry in self.l1_cache.items():
                if any(tag in entry.tags for tag in tags):
                    keys_to_remove.append(key)
            
            for key in keys_to_remove:
                del self.l1_cache[key]
                invalidated += 1
            
            # Invalidate L2 cache using tag sets
            for tag in tags:
                tag_key = f"tag:{tag}"
                tagged_keys = await self.redis.smembers(tag_key)
                
                if tagged_keys:
                    # Delete the actual cache entries
                    await self.redis.delete(*tagged_keys)
                    # Delete the tag set
                    await self.redis.delete(tag_key)
                    invalidated += len(tagged_keys)
            
            logger.info(f"Invalidated {invalidated} cache entries for tags: {tags}")
            return invalidated
            
        except Exception as e:
            logger.error(f"Cache invalidation error for tags {tags}: {e}")
            return 0
    
    async def warm_cache(
        self, 
        plant_id: int, 
        data_fetcher: Callable,
        cache_type: str = 'care_plan'
    ) -> bool:
        """Preemptively warm cache with fresh data
        
        Args:
            plant_id: Plant ID to warm cache for
            data_fetcher: Async function to fetch fresh data
            cache_type: Type of data being cached
            
        Returns:
            True if successful, False otherwise
        """
        try:
            # Generate cache key
            key = self._generate_key(cache_type, plant_id)
            
            # Fetch fresh data
            fresh_data = await data_fetcher(plant_id)
            
            if fresh_data is not None:
                # Cache the fresh data
                tags = [f"plant:{plant_id}", cache_type]
                return await self.set(key, fresh_data, cache_type, tags=tags)
            
            return False
            
        except Exception as e:
            logger.error(f"Cache warming error for plant {plant_id}: {e}")
            return False
    
    async def get_care_plan(self, plant_id: int, version: Optional[str] = None) -> Optional[Dict[str, Any]]:
        """Get cached care plan with optimized key structure
        
        Args:
            plant_id: Plant ID
            version: Specific version (defaults to 'latest')
            
        Returns:
            Cached care plan data or None
        """
        version = version or 'latest'
        key = f"cp:{plant_id}:{version}"
        return await self.get(key, 'care_plan')
    
    async def set_care_plan(
        self, 
        plant_id: int, 
        care_plan_data: Dict[str, Any],
        version: Optional[str] = None
    ) -> bool:
        """Cache care plan with proper tagging
        
        Args:
            plant_id: Plant ID
            care_plan_data: Care plan data to cache
            version: Specific version (defaults to 'latest')
            
        Returns:
            True if successful, False otherwise
        """
        version = version or 'latest'
        key = f"cp:{plant_id}:{version}"
        tags = [f"plant:{plant_id}", "care_plan", f"version:{version}"]
        
        return await self.set(key, care_plan_data, 'care_plan', tags=tags)
    
    async def get_environmental_context(self, plant_id: int) -> Optional[EnvironmentalContext]:
        """Get cached environmental context
        
        Args:
            plant_id: Plant ID
            
        Returns:
            Cached environmental context or None
        """
        key = f"env:{plant_id}"
        cached_data = await self.get(key, 'environmental_data')
        
        if cached_data:
            # Reconstruct EnvironmentalContext from cached dict
            try:
                from app.services.environmental_data import EnvironmentalContext, WeatherCondition, Season
                
                return EnvironmentalContext(
                    temperature=cached_data['temperature'],
                    humidity=cached_data['humidity'],
                    light_ppfd=cached_data.get('light_ppfd'),
                    air_pressure=cached_data.get('air_pressure'),
                    weather_condition=WeatherCondition(cached_data['weather_condition']),
                    uv_index=cached_data.get('uv_index'),
                    precipitation_mm=cached_data.get('precipitation_mm', 0.0),
                    wind_speed_kmh=cached_data.get('wind_speed_kmh'),
                    season=Season(cached_data['season']),
                    day_length_hours=cached_data.get('day_length_hours', 12.0),
                    temp_trend=cached_data.get('temp_trend', 0.0),
                    humidity_trend=cached_data.get('humidity_trend', 0.0),
                    light_trend=cached_data.get('light_trend'),
                    heatwave_days=cached_data.get('heatwave_days', 0),
                    cold_snap_days=cached_data.get('cold_snap_days', 0),
                    drought_days=cached_data.get('drought_days', 0),
                    data_freshness_minutes=cached_data.get('data_freshness_minutes', 999),
                    sensor_reliability_score=cached_data.get('sensor_reliability_score', 0.0),
                    weather_api_status=cached_data.get('weather_api_status', 'unknown')
                )
            except Exception as e:
                logger.error(f"Error reconstructing EnvironmentalContext: {e}")
                return None
        
        return None
    
    async def get_metrics(self) -> Dict[str, Any]:
        """Get cache performance metrics
        
        Returns:
            Dictionary with cache metrics
        """
        # Get Redis info
        redis_info = await self.redis.info('memory')
        
        return {
            'l1_cache': {
                'size': len(self.l1_cache),
                'max_size': self.max_l1_size,
                'utilization': len(self.l1_cache) / self.max_l1_size
            },
            'l2_cache': {
                'memory_used': redis_info.get('used_memory', 0),
                'memory_human': redis_info.get('used_memory_human', '0B')
            },
            'performance': {
                'hits': self.metrics.hits,
                'misses': self.metrics.misses,
                'hit_rate': self.metrics.hit_rate,
                'avg_read_time_ms': self.metrics.read_time_ms / max(1, self.metrics.hits + self.metrics.misses),
                'avg_write_time_ms': self.metrics.write_time_ms / max(1, self.metrics.hits + self.metrics.misses)
            }
        }
    
    async def _get_from_l1(self, key: str) -> Optional[Any]:
        """Get data from L1 (memory) cache"""
        if key not in self.l1_cache:
            return None
        
        entry = self.l1_cache[key]
        
        # Check expiration
        if entry.expires_at and datetime.utcnow() > entry.expires_at:
            del self.l1_cache[key]
            return None
        
        # Update access metadata
        entry.access_count += 1
        entry.last_accessed = datetime.utcnow()
        
        return entry.data
    
    async def _set_to_l1(
        self, 
        key: str, 
        data: Any, 
        cache_type: str,
        ttl: Optional[int] = None,
        tags: Optional[List[str]] = None
    ):
        """Set data in L1 (memory) cache"""
        # Evict if at capacity
        if len(self.l1_cache) >= self.max_l1_size:
            await self._evict_l1_lru()
        
        ttl = ttl or self.ttl_config.get(cache_type, 3600)
        expires_at = datetime.utcnow() + timedelta(seconds=ttl) if ttl > 0 else None
        
        # Estimate size (rough approximation)
        size_bytes = len(json.dumps(data, default=str)) if data else 0
        
        entry = CacheEntry(
            key=key,
            data=data,
            created_at=datetime.utcnow(),
            expires_at=expires_at,
            size_bytes=size_bytes,
            tags=tags or []
        )
        
        self.l1_cache[key] = entry
    
    async def _get_from_l2(self, key: str) -> Optional[Any]:
        """Get data from L2 (Redis) cache"""
        try:
            cached_data = await self.redis.get(key)
            if cached_data:
                return json.loads(cached_data)
            return None
        except Exception as e:
            logger.error(f"L2 cache get error for key {key}: {e}")
            return None
    
    async def _set_to_l2(
        self, 
        key: str, 
        data: Any, 
        ttl: int,
        tags: Optional[List[str]] = None
    ) -> bool:
        """Set data in L2 (Redis) cache"""
        try:
            # Serialize data
            serialized_data = json.dumps(data, default=str)
            
            # Set with TTL
            await self.redis.setex(key, ttl, serialized_data)
            
            # Add to tag sets for invalidation
            if tags:
                for tag in tags:
                    tag_key = f"tag:{tag}"
                    await self.redis.sadd(tag_key, key)
                    await self.redis.expire(tag_key, ttl + 300)  # Tag set expires 5 min after data
            
            return True
            
        except Exception as e:
            logger.error(f"L2 cache set error for key {key}: {e}")
            return False
    
    async def _evict_l1_lru(self):
        """Evict least recently used entry from L1 cache"""
        if not self.l1_cache:
            return
        
        # Find LRU entry
        lru_key = min(
            self.l1_cache.keys(),
            key=lambda k: self.l1_cache[k].last_accessed or datetime.min
        )
        
        del self.l1_cache[lru_key]
        self.metrics.evictions += 1
    
    def _generate_key(self, cache_type: str, *args) -> str:
        """Generate cache key with consistent format
        
        Args:
            cache_type: Type of cached data
            *args: Additional key components
            
        Returns:
            Formatted cache key
        """
        prefix = self.key_prefixes.get(cache_type, cache_type)
        key_parts = [prefix] + [str(arg) for arg in args]
        return ':'.join(key_parts)
    
    def _hash_key(self, key: str) -> str:
        """Generate hash for long keys
        
        Args:
            key: Original key
            
        Returns:
            Hashed key if original is too long, otherwise original
        """
        if len(key) > 250:  # Redis key length limit
            return hashlib.sha256(key.encode()).hexdigest()
        return key

# Dependency injection helper
async def get_cache_service():
    """Get cache service instance"""
    return CacheLayerService()

# Cache warming background task
async def warm_cache_background(cache_service: CacheLayerService, db: AsyncSession):
    """Background task to warm frequently accessed cache entries"""
    try:
        from app.services.care_plan import CarePlanService
        from app.services.environmental_data import EnvironmentalDataService
        
        care_plan_service = CarePlanService(db)
        env_service = EnvironmentalDataService(db)
        
        # Get list of active plants (implement based on your needs)
        # This is a placeholder - implement based on your plant activity tracking
        active_plant_ids = [1, 2, 3]  # Replace with actual logic
        
        for plant_id in active_plant_ids:
            try:
                # Warm care plan cache
                await cache_service.warm_cache(
                    plant_id,
                    lambda pid: care_plan_service.get_latest_care_plan(pid),
                    'care_plan'
                )
                
                # Warm environmental data cache
                await cache_service.warm_cache(
                    plant_id,
                    lambda pid: env_service.get_environmental_context(pid),
                    'environmental_data'
                )
                
                # Small delay to avoid overwhelming the system
                await asyncio.sleep(0.1)
                
            except Exception as e:
                logger.error(f"Error warming cache for plant {plant_id}: {e}")
        
        logger.info(f"Cache warming completed for {len(active_plant_ids)} plants")
        
    except Exception as e:
        logger.error(f"Cache warming background task error: {e}")