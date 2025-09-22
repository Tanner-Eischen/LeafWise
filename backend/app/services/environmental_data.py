"""Environmental Data Integration Service

This service integrates environmental data from multiple sources for Context-Aware Care Plans v2.
It fetches weather data, indoor sensor readings, and seasonal information to inform care decisions.

Key Features:
- Weather API integration with caching
- Indoor sensor data aggregation
- Seasonal and location-based adjustments
- Environmental trend analysis
- Data validation and fallback handling
"""

import asyncio
import logging
from datetime import datetime, timedelta
from typing import Dict, List, Optional, Tuple, Any
from dataclasses import dataclass
from enum import Enum

import aiohttp
import redis.asyncio as redis
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, and_, desc

from app.core.config import settings
from app.models.user_plant import UserPlant
# Note: Using placeholder for telemetry models until they are implemented
from app.core.cache import get_redis_client

logger = logging.getLogger(__name__)

class WeatherCondition(Enum):
    """Weather condition classifications"""
    CLEAR = "clear"
    CLOUDY = "cloudy"
    RAINY = "rainy"
    STORMY = "stormy"
    SNOWY = "snowy"

class Season(Enum):
    """Season classifications"""
    SPRING = "spring"
    SUMMER = "summer"
    FALL = "fall"
    WINTER = "winter"

@dataclass
class EnvironmentalContext:
    """Environmental context data structure"""
    # Current conditions
    temperature: float
    humidity: float
    light_ppfd: Optional[float]
    air_pressure: Optional[float]
    
    # Weather data
    weather_condition: WeatherCondition
    uv_index: Optional[float]
    precipitation_mm: float
    wind_speed_kmh: Optional[float]
    
    # Temporal context
    season: Season
    day_length_hours: float
    
    # Trends (7-day averages)
    temp_trend: float  # positive = warming, negative = cooling
    humidity_trend: float
    light_trend: Optional[float]
    
    # Environmental alerts
    heatwave_days: int  # consecutive days > 32°C
    cold_snap_days: int  # consecutive days < 10°C
    drought_days: int   # consecutive days without rain
    
    # Data quality
    data_freshness_minutes: int
    sensor_reliability_score: float  # 0.0-1.0
    weather_api_status: str

@dataclass
class LocationData:
    """Location-specific data"""
    latitude: float
    longitude: float
    timezone: str
    elevation_m: Optional[float]
    city: Optional[str]
    country: Optional[str]

class EnvironmentalDataService:
    """Service for fetching and processing environmental data"""
    
    def __init__(self, db: AsyncSession, redis_client: Optional[redis.Redis] = None):
        self.db = db
        self.redis = redis_client or get_redis_client()
        self.weather_api_key = settings.WEATHER_API_KEY
        self.weather_base_url = "https://api.openweathermap.org/data/2.5"
        
    async def get_environmental_context(
        self, 
        plant_id: int, 
        location: Optional[LocationData] = None
    ) -> EnvironmentalContext:
        """Get comprehensive environmental context for a plant
        
        Args:
            plant_id: ID of the plant
            location: Optional location override
            
        Returns:
            EnvironmentalContext with current and trend data
        """
        try:
            # Get plant location if not provided
            if not location:
                location = await self._get_plant_location(plant_id)
            
            # Fetch data concurrently
            current_weather, sensor_data, historical_trends = await asyncio.gather(
                self._get_current_weather(location),
                self._get_sensor_data(plant_id),
                self._get_environmental_trends(plant_id, location),
                return_exceptions=True
            )
            
            # Handle exceptions
            if isinstance(current_weather, Exception):
                logger.warning(f"Weather API error: {current_weather}")
                current_weather = await self._get_fallback_weather(location)
                
            if isinstance(sensor_data, Exception):
                logger.warning(f"Sensor data error: {sensor_data}")
                sensor_data = {}
                
            if isinstance(historical_trends, Exception):
                logger.warning(f"Trends calculation error: {historical_trends}")
                historical_trends = {}
            
            # Combine and process data
            context = await self._build_environmental_context(
                current_weather, sensor_data, historical_trends, location
            )
            
            # Cache the result
            await self._cache_environmental_context(plant_id, context)
            
            return context
            
        except Exception as e:
            logger.error(f"Error getting environmental context for plant {plant_id}: {e}")
            # Return fallback context
            return await self._get_fallback_context(plant_id)
    
    async def _get_plant_location(self, plant_id: int) -> LocationData:
        """Get location data for a plant"""
        query = select(UserPlant).where(UserPlant.id == plant_id)
        result = await self.db.execute(query)
        plant = result.scalar_one_or_none()
        
        if not plant or not plant.location_data:
            # Default to system location or user's location
            return LocationData(
                latitude=settings.DEFAULT_LATITUDE,
                longitude=settings.DEFAULT_LONGITUDE,
                timezone=settings.DEFAULT_TIMEZONE,
                elevation_m=None,
                city=None,
                country=None
            )
        
        loc_data = plant.location_data
        return LocationData(
            latitude=loc_data.get('latitude', settings.DEFAULT_LATITUDE),
            longitude=loc_data.get('longitude', settings.DEFAULT_LONGITUDE),
            timezone=loc_data.get('timezone', settings.DEFAULT_TIMEZONE),
            elevation_m=loc_data.get('elevation_m'),
            city=loc_data.get('city'),
            country=loc_data.get('country')
        )
    
    async def _get_current_weather(self, location: LocationData) -> Dict[str, Any]:
        """Fetch current weather data from API"""
        cache_key = f"weather:current:{location.latitude}:{location.longitude}"
        
        # Check cache first (5-minute TTL)
        cached = await self.redis.get(cache_key)
        if cached:
            import json
            return json.loads(cached)
        
        # Fetch from API
        url = f"{self.weather_base_url}/weather"
        params = {
            'lat': location.latitude,
            'lon': location.longitude,
            'appid': self.weather_api_key,
            'units': 'metric'
        }
        
        async with aiohttp.ClientSession() as session:
            async with session.get(url, params=params) as response:
                if response.status == 200:
                    data = await response.json()
                    
                    # Cache for 5 minutes
                    import json
                    await self.redis.setex(cache_key, 300, json.dumps(data))
                    
                    return data
                else:
                    raise Exception(f"Weather API error: {response.status}")
    
    async def _get_sensor_data(self, plant_id: int) -> Dict[str, Any]:
        """Get recent sensor readings for the plant"""
        # TODO: Implement when SensorReading model is available
        # For now, return empty sensor data
        return {
            'temperature': None,
            'humidity': None,
            'light_ppfd': None,
            'reading_count': 0,
            'latest_timestamp': None,
            'reliability_score': 0.0
        }
    
    async def _get_environmental_trends(self, plant_id: int, location: LocationData) -> Dict[str, Any]:
        """Calculate environmental trends over the past week"""
        # TODO: Implement when SensorReading model is available
        # For now, return default trends
        weather_trends = await self._get_weather_trends(location)
        
        trends = {
            'temp_trend': 0.0,
            'humidity_trend': 0.0,
            'light_trend': 0.0,
            'weather_trends': weather_trends
        }
        
        return trends
    
    def _calculate_trend(self, values: List[float]) -> float:
        """Calculate trend from a list of values (simple linear regression slope)"""
        if len(values) < 2:
            return 0.0
        
        n = len(values)
        x_values = list(range(n))
        
        # Calculate slope using least squares
        x_mean = sum(x_values) / n
        y_mean = sum(values) / n
        
        numerator = sum((x - x_mean) * (y - y_mean) for x, y in zip(x_values, values))
        denominator = sum((x - x_mean) ** 2 for x in x_values)
        
        if denominator == 0:
            return 0.0
        
        return numerator / denominator
    
    async def _get_weather_trends(self, location: LocationData) -> Dict[str, Any]:
        """Get weather trends from cached historical data"""
        cache_key = f"weather:trends:{location.latitude}:{location.longitude}"
        
        cached = await self.redis.get(cache_key)
        if cached:
            import json
            return json.loads(cached)
        
        # If no cached trends, return defaults
        return {
            'heatwave_days': 0,
            'cold_snap_days': 0,
            'drought_days': 0,
            'precipitation_7d': 0.0
        }
    
    async def _build_environmental_context(
        self, 
        weather_data: Dict[str, Any], 
        sensor_data: Dict[str, Any], 
        trends: Dict[str, Any],
        location: LocationData
    ) -> EnvironmentalContext:
        """Build the final environmental context from all data sources"""
        
        # Extract weather info
        main_weather = weather_data.get('main', {})
        weather_desc = weather_data.get('weather', [{}])[0]
        
        # Determine season
        season = self._get_season(location.latitude)
        
        # Calculate day length
        day_length = self._calculate_day_length(location.latitude)
        
        # Determine weather condition
        weather_condition = self._classify_weather_condition(weather_desc.get('main', 'Clear'))
        
        # Use sensor data if available, otherwise fall back to weather API
        temperature = sensor_data.get('temperature') or main_weather.get('temp', 20.0)
        humidity = sensor_data.get('humidity') or main_weather.get('humidity', 50.0)
        
        return EnvironmentalContext(
            # Current conditions
            temperature=temperature,
            humidity=humidity,
            light_ppfd=sensor_data.get('light_ppfd'),
            air_pressure=main_weather.get('pressure'),
            
            # Weather data
            weather_condition=weather_condition,
            uv_index=weather_data.get('uvi'),
            precipitation_mm=weather_data.get('rain', {}).get('1h', 0.0),
            wind_speed_kmh=weather_data.get('wind', {}).get('speed', 0.0) * 3.6,
            
            # Temporal context
            season=season,
            day_length_hours=day_length,
            
            # Trends
            temp_trend=trends.get('temp_trend', 0.0),
            humidity_trend=trends.get('humidity_trend', 0.0),
            light_trend=trends.get('light_trend', 0.0),
            
            # Environmental alerts
            heatwave_days=trends.get('weather_trends', {}).get('heatwave_days', 0),
            cold_snap_days=trends.get('weather_trends', {}).get('cold_snap_days', 0),
            drought_days=trends.get('weather_trends', {}).get('drought_days', 0),
            
            # Data quality
            data_freshness_minutes=0,  # Just fetched
            sensor_reliability_score=sensor_data.get('reliability_score', 0.5),
            weather_api_status="ok"
        )
    
    def _get_season(self, latitude: float) -> Season:
        """Determine season based on date and latitude"""
        now = datetime.now()
        month = now.month
        
        # Northern hemisphere
        if latitude >= 0:
            if month in [12, 1, 2]:
                return Season.WINTER
            elif month in [3, 4, 5]:
                return Season.SPRING
            elif month in [6, 7, 8]:
                return Season.SUMMER
            else:
                return Season.FALL
        # Southern hemisphere (seasons reversed)
        else:
            if month in [12, 1, 2]:
                return Season.SUMMER
            elif month in [3, 4, 5]:
                return Season.FALL
            elif month in [6, 7, 8]:
                return Season.WINTER
            else:
                return Season.SPRING
    
    def _calculate_day_length(self, latitude: float) -> float:
        """Calculate approximate day length in hours"""
        # Simplified calculation - in production, use a proper astronomical library
        import math
        
        now = datetime.now()
        day_of_year = now.timetuple().tm_yday
        
        # Solar declination
        declination = 23.45 * math.sin(math.radians(360 * (284 + day_of_year) / 365))
        
        # Hour angle
        lat_rad = math.radians(latitude)
        decl_rad = math.radians(declination)
        
        try:
            hour_angle = math.acos(-math.tan(lat_rad) * math.tan(decl_rad))
            day_length = 2 * hour_angle * 12 / math.pi
            return max(0, min(24, day_length))
        except ValueError:
            # Polar day/night
            return 12.0  # Default to 12 hours
    
    def _classify_weather_condition(self, weather_main: str) -> WeatherCondition:
        """Classify weather condition from API response"""
        weather_main = weather_main.lower()
        
        if 'rain' in weather_main or 'drizzle' in weather_main:
            return WeatherCondition.RAINY
        elif 'thunder' in weather_main or 'storm' in weather_main:
            return WeatherCondition.STORMY
        elif 'snow' in weather_main:
            return WeatherCondition.SNOWY
        elif 'cloud' in weather_main:
            return WeatherCondition.CLOUDY
        else:
            return WeatherCondition.CLEAR
    
    async def _get_fallback_weather(self, location: LocationData) -> Dict[str, Any]:
        """Get fallback weather data when API is unavailable"""
        # Return reasonable defaults based on season and location
        season = self._get_season(location.latitude)
        
        if season == Season.WINTER:
            temp = 5.0 if location.latitude > 0 else 25.0
        elif season == Season.SUMMER:
            temp = 25.0 if location.latitude > 0 else 5.0
        else:
            temp = 15.0
        
        return {
            'main': {
                'temp': temp,
                'humidity': 60.0,
                'pressure': 1013.25
            },
            'weather': [{'main': 'Clear'}],
            'wind': {'speed': 0.0}
        }
    
    async def _get_fallback_context(self, plant_id: int) -> EnvironmentalContext:
        """Get fallback environmental context when all data sources fail"""
        return EnvironmentalContext(
            temperature=20.0,
            humidity=50.0,
            light_ppfd=None,
            air_pressure=None,
            weather_condition=WeatherCondition.CLEAR,
            uv_index=None,
            precipitation_mm=0.0,
            wind_speed_kmh=None,
            season=Season.SPRING,
            day_length_hours=12.0,
            temp_trend=0.0,
            humidity_trend=0.0,
            light_trend=None,
            heatwave_days=0,
            cold_snap_days=0,
            drought_days=0,
            data_freshness_minutes=999,
            sensor_reliability_score=0.0,
            weather_api_status="fallback"
        )
    
    async def _cache_environmental_context(self, plant_id: int, context: EnvironmentalContext):
        """Cache environmental context for 10 minutes"""
        cache_key = f"env_context:{plant_id}"
        
        # Convert to dict for JSON serialization
        context_dict = {
            'temperature': context.temperature,
            'humidity': context.humidity,
            'light_ppfd': context.light_ppfd,
            'weather_condition': context.weather_condition.value,
            'season': context.season.value,
            'temp_trend': context.temp_trend,
            'humidity_trend': context.humidity_trend,
            'heatwave_days': context.heatwave_days,
            'cold_snap_days': context.cold_snap_days,
            'drought_days': context.drought_days,
            'sensor_reliability_score': context.sensor_reliability_score,
            'cached_at': datetime.utcnow().isoformat()
        }
        
        import json
        await self.redis.setex(cache_key, 600, json.dumps(context_dict))

# Dependency injection helper
async def get_environmental_data_service(db: AsyncSession):
    """Get environmental data service instance"""
    return EnvironmentalDataService(db)