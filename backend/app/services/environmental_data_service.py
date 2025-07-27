"""Environmental Data Service for weather API integration and seasonal analysis."""

import asyncio
import hashlib
import json
import logging
import math
from datetime import datetime, date, timedelta
from typing import Dict, List, Optional, Any, Tuple
import pytz
from astral import LocationInfo
from astral.sun import sun
import httpx
import aiohttp
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, and_, or_

from app.core.config import settings
from app.core.database import get_db
from app.schemas.environmental_data import (
    Location, WeatherCondition, WeatherForecast, WeatherProvider,
    DaylightInfo, DaylightPatterns, ClimateData, SeasonalTransition,
    PestRiskData, PestRiskFactor, EnvironmentalDataCache
)

logger = logging.getLogger(__name__)


class EnvironmentalDataService:
    """Service for integrating environmental data from multiple sources."""
    
    def __init__(self):
        self.openweather_api_key = settings.OPENWEATHERMAP_API_KEY
        self.weatherapi_key = settings.WEATHERAPI_KEY
        self.weather_cache_ttl = settings.WEATHER_CACHE_TTL
        self.climate_cache_ttl = settings.CLIMATE_DATA_CACHE_TTL
        
        # API endpoints
        self.openweather_base_url = "https://api.openweathermap.org/data/2.5"
        self.weatherapi_base_url = "https://api.weatherapi.com/v1"
        
    async def get_weather_data(
        self, 
        location: Location, 
        days_ahead: int = 7,
        preferred_provider: Optional[WeatherProvider] = None
    ) -> WeatherForecast:
        """
        Get current weather and forecast data from multiple providers.
        
        Args:
            location: Geographic location
            days_ahead: Number of forecast days (1-14)
            preferred_provider: Preferred weather API provider
            
        Returns:
            WeatherForecast object with current and forecast data
        """
        # Check cache first
        cache_key = self._generate_cache_key("weather", location, {"days": days_ahead})
        cached_data = await self._get_cached_data(cache_key)
        
        if cached_data:
            logger.info(f"Returning cached weather data for {location.latitude}, {location.longitude}")
            return WeatherForecast(**cached_data)
        
        # Try providers in order of preference
        providers = [preferred_provider] if preferred_provider else [WeatherProvider.OPENWEATHERMAP, WeatherProvider.WEATHERAPI]
        
        for provider in providers:
            try:
                if provider == WeatherProvider.OPENWEATHERMAP and self.openweather_api_key:
                    forecast = await self._fetch_openweathermap_data(location, days_ahead)
                elif provider == WeatherProvider.WEATHERAPI and self.weatherapi_key:
                    forecast = await self._fetch_weatherapi_data(location, days_ahead)
                else:
                    continue
                    
                # Cache the result
                await self._cache_data(cache_key, forecast.model_dump(), self.weather_cache_ttl)
                return forecast
                
            except Exception as e:
                logger.warning(f"Failed to fetch weather data from {provider}: {str(e)}")
                continue
        
        raise Exception("Failed to fetch weather data from all available providers")
    
    async def _fetch_openweathermap_data(self, location: Location, days_ahead: int) -> WeatherForecast:
        """Fetch weather data from OpenWeatherMap API."""
        async with httpx.AsyncClient() as client:
            # Current weather
            current_url = f"{self.openweather_base_url}/weather"
            current_params = {
                "lat": location.latitude,
                "lon": location.longitude,
                "appid": self.openweather_api_key,
                "units": "metric"
            }
            
            current_response = await client.get(current_url, params=current_params)
            current_response.raise_for_status()
            current_data = current_response.json()
            
            # Forecast data
            forecast_url = f"{self.openweather_base_url}/forecast"
            forecast_params = {
                "lat": location.latitude,
                "lon": location.longitude,
                "appid": self.openweather_api_key,
                "units": "metric",
                "cnt": min(days_ahead * 8, 40)  # 3-hour intervals, max 5 days
            }
            
            forecast_response = await client.get(forecast_url, params=forecast_params)
            forecast_response.raise_for_status()
            forecast_data = forecast_response.json()
            
            return self._parse_openweathermap_response(location, current_data, forecast_data)
    
    async def _fetch_weatherapi_data(self, location: Location, days_ahead: int) -> WeatherForecast:
        """Fetch weather data from WeatherAPI."""
        async with httpx.AsyncClient() as client:
            url = f"{self.weatherapi_base_url}/forecast.json"
            params = {
                "key": self.weatherapi_key,
                "q": f"{location.latitude},{location.longitude}",
                "days": min(days_ahead, 10),  # WeatherAPI supports up to 10 days
                "aqi": "yes",
                "alerts": "yes"
            }
            
            response = await client.get(url, params=params)
            response.raise_for_status()
            data = response.json()
            
            return self._parse_weatherapi_response(location, data)
    
    def _parse_openweathermap_response(self, location: Location, current_data: Dict, forecast_data: Dict) -> WeatherForecast:
        """Parse OpenWeatherMap API response."""
        # Parse current weather
        current = WeatherCondition(
            temperature=current_data["main"]["temp"],
            humidity=current_data["main"]["humidity"],
            pressure=current_data["main"]["pressure"],
            wind_speed=current_data.get("wind", {}).get("speed", 0),
            wind_direction=current_data.get("wind", {}).get("deg"),
            precipitation=current_data.get("rain", {}).get("1h", 0) + current_data.get("snow", {}).get("1h", 0),
            cloud_cover=current_data["clouds"]["all"],
            uv_index=current_data.get("uvi"),
            visibility=current_data.get("visibility", 0) / 1000 if current_data.get("visibility") else None
        )
        
        # Parse forecast data
        forecast_days = []
        daily_data = {}
        
        for item in forecast_data["list"]:
            dt = datetime.fromtimestamp(item["dt"])
            day_key = dt.date()
            
            if day_key not in daily_data:
                daily_data[day_key] = {
                    "date": day_key,
                    "temp_min": item["main"]["temp"],
                    "temp_max": item["main"]["temp"],
                    "humidity": [],
                    "precipitation": 0,
                    "conditions": []
                }
            
            daily_data[day_key]["temp_min"] = min(daily_data[day_key]["temp_min"], item["main"]["temp"])
            daily_data[day_key]["temp_max"] = max(daily_data[day_key]["temp_max"], item["main"]["temp"])
            daily_data[day_key]["humidity"].append(item["main"]["humidity"])
            daily_data[day_key]["precipitation"] += item.get("rain", {}).get("3h", 0) + item.get("snow", {}).get("3h", 0)
            daily_data[day_key]["conditions"].append(item["weather"][0]["description"])
        
        # Convert to list format
        for day_key, day_data in daily_data.items():
            day_data["humidity_avg"] = sum(day_data["humidity"]) / len(day_data["humidity"])
            day_data["main_condition"] = max(set(day_data["conditions"]), key=day_data["conditions"].count)
            forecast_days.append(day_data)
        
        now = datetime.utcnow()
        return WeatherForecast(
            location=location,
            current=current,
            forecast_days=forecast_days,
            provider=WeatherProvider.OPENWEATHERMAP,
            retrieved_at=now,
            expires_at=now + timedelta(seconds=self.weather_cache_ttl)
        )
    
    def _parse_weatherapi_response(self, location: Location, data: Dict) -> WeatherForecast:
        """Parse WeatherAPI response."""
        current_data = data["current"]
        
        # Parse current weather
        current = WeatherCondition(
            temperature=current_data["temp_c"],
            humidity=current_data["humidity"],
            pressure=current_data["pressure_mb"],
            wind_speed=current_data["wind_kph"] / 3.6,  # Convert to m/s
            wind_direction=current_data["wind_degree"],
            precipitation=current_data.get("precip_mm", 0),
            cloud_cover=current_data["cloud"],
            uv_index=current_data.get("uv"),
            visibility=current_data.get("vis_km")
        )
        
        # Parse forecast data
        forecast_days = []
        for day_data in data["forecast"]["forecastday"]:
            day = day_data["day"]
            forecast_days.append({
                "date": datetime.strptime(day_data["date"], "%Y-%m-%d").date(),
                "temp_min": day["mintemp_c"],
                "temp_max": day["maxtemp_c"],
                "humidity_avg": day["avghumidity"],
                "precipitation": day.get("totalprecip_mm", 0),
                "main_condition": day["condition"]["text"],
                "uv_index": day.get("uv", 0),
                "wind_speed": day["maxwind_kph"] / 3.6  # Convert to m/s
            })
        
        now = datetime.utcnow()
        return WeatherForecast(
            location=location,
            current=current,
            forecast_days=forecast_days,
            provider=WeatherProvider.WEATHERAPI,
            retrieved_at=now,
            expires_at=now + timedelta(seconds=self.weather_cache_ttl)
        )
    
    async def get_daylight_patterns(self, location: Location, year: int) -> DaylightPatterns:
        """
        Calculate daylight patterns for a location and year using astronomical algorithms.
        
        Args:
            location: Geographic location
            year: Year for calculations
            
        Returns:
            DaylightPatterns object with daily daylight information
        """
        cache_key = self._generate_cache_key("daylight", location, {"year": year})
        cached_data = await self._get_cached_data(cache_key)
        
        if cached_data:
            logger.info(f"Returning cached daylight patterns for {location.latitude}, {location.longitude}")
            return DaylightPatterns(**cached_data)
        
        # Create location info for astral calculations
        location_info = LocationInfo(
            name=location.city or "Unknown",
            region=location.country or "Unknown",
            timezone=location.timezone or "UTC",
            latitude=location.latitude,
            longitude=location.longitude
        )
        
        daily_patterns = []
        monthly_averages = {}
        
        # Calculate for each day of the year
        start_date = date(year, 1, 1)
        end_date = date(year, 12, 31)
        current_date = start_date
        
        while current_date <= end_date:
            try:
                sun_info = sun(location_info.observer, date=current_date)
                
                daylight_info = DaylightInfo(
                    date=current_date,
                    sunrise=sun_info['sunrise'],
                    sunset=sun_info['sunset'],
                    daylight_hours=(sun_info['sunset'] - sun_info['sunrise']).total_seconds() / 3600,
                    solar_noon=sun_info['noon'],
                    civil_twilight_begin=sun_info['dawn'],
                    civil_twilight_end=sun_info['dusk'],
                    astronomical_twilight_begin=sun_info.get('dawn', sun_info['dawn']),
                    astronomical_twilight_end=sun_info.get('dusk', sun_info['dusk'])
                )
                
                daily_patterns.append(daylight_info)
                
                # Track monthly averages
                month = current_date.month
                if month not in monthly_averages:
                    monthly_averages[month] = []
                monthly_averages[month].append(daylight_info.daylight_hours)
                
            except Exception as e:
                logger.warning(f"Failed to calculate daylight for {current_date}: {str(e)}")
            
            current_date += timedelta(days=1)
        
        # Calculate monthly averages
        avg_by_month = {
            month: sum(hours) / len(hours) 
            for month, hours in monthly_averages.items()
        }
        
        # Find shortest and longest days
        shortest_day = min(daily_patterns, key=lambda x: x.daylight_hours)
        longest_day = max(daily_patterns, key=lambda x: x.daylight_hours)
        
        patterns = DaylightPatterns(
            location=location,
            year=year,
            daily_patterns=daily_patterns,
            average_daylight_by_month=avg_by_month,
            shortest_day=shortest_day,
            longest_day=longest_day
        )
        
        # Cache the result
        await self._cache_data(cache_key, patterns.model_dump(), self.climate_cache_ttl)
        return patterns
    
    async def get_seasonal_climate_data(
        self, 
        location: Location, 
        start_date: date, 
        end_date: date
    ) -> ClimateData:
        """
        Get historical climate data for seasonal analysis.
        
        Args:
            location: Geographic location
            start_date: Start date for data retrieval
            end_date: End date for data retrieval
            
        Returns:
            ClimateData object with historical weather patterns
        """
        cache_key = self._generate_cache_key("climate", location, {
            "start": start_date.isoformat(),
            "end": end_date.isoformat()
        })
        cached_data = await self._get_cached_data(cache_key)
        
        if cached_data:
            logger.info(f"Returning cached climate data for {location.latitude}, {location.longitude}")
            return ClimateData(**cached_data)
        
        # For now, we'll use current weather API to simulate historical data
        # In production, you'd integrate with historical weather APIs
        climate_data = await self._fetch_historical_climate_data(location, start_date, end_date)
        
        # Cache the result
        await self._cache_data(cache_key, climate_data.model_dump(), self.climate_cache_ttl)
        return climate_data
    
    async def _fetch_historical_climate_data(
        self, 
        location: Location, 
        start_date: date, 
        end_date: date
    ) -> ClimateData:
        """Fetch historical climate data (placeholder implementation)."""
        # This is a simplified implementation
        # In production, integrate with historical weather APIs like:
        # - OpenWeatherMap Historical API
        # - Visual Crossing Weather API
        # - NOAA Climate Data
        
        dates = []
        temp_avg = []
        temp_min = []
        temp_max = []
        precipitation = []
        humidity_avg = []
        daylight_hours = []
        
        current_date = start_date
        while current_date <= end_date:
            # Generate synthetic data based on seasonal patterns
            day_of_year = current_date.timetuple().tm_yday
            
            # Simulate seasonal temperature variation
            base_temp = 15 + 10 * math.sin(2 * math.pi * (day_of_year - 80) / 365)
            temp_variation = 5
            
            dates.append(current_date)
            temp_avg.append(base_temp)
            temp_min.append(base_temp - temp_variation)
            temp_max.append(base_temp + temp_variation)
            precipitation.append(max(0, 2 + 3 * math.sin(2 * math.pi * day_of_year / 365)))
            humidity_avg.append(60 + 20 * math.sin(2 * math.pi * day_of_year / 365))
            
            # Calculate daylight hours
            daylight = 12 + 4 * math.sin(2 * math.pi * (day_of_year - 80) / 365)
            daylight_hours.append(max(6, min(18, daylight)))
            
            current_date += timedelta(days=1)
        
        return ClimateData(
            location=location,
            start_date=start_date,
            end_date=end_date,
            temperature_avg=temp_avg,
            temperature_min=temp_min,
            temperature_max=temp_max,
            precipitation=precipitation,
            humidity_avg=humidity_avg,
            daylight_hours=daylight_hours,
            dates=dates
        )
    
    def _generate_cache_key(self, data_type: str, location: Location, params: Dict[str, Any]) -> str:
        """Generate a cache key for environmental data."""
        location_str = f"{location.latitude:.4f},{location.longitude:.4f}"
        params_str = json.dumps(params, sort_keys=True)
        combined = f"{data_type}:{location_str}:{params_str}"
        return hashlib.md5(combined.encode()).hexdigest()
    
    async def _get_cached_data(self, cache_key: str) -> Optional[Dict[str, Any]]:
        """Retrieve data from cache."""
        # This would integrate with Redis in production
        # For now, return None to always fetch fresh data
        return None
    
    async def _cache_data(self, cache_key: str, data: Dict[str, Any], ttl: int) -> None:
        """Store data in cache."""
        # This would integrate with Redis in production
        # For now, this is a no-op
        pass

    async def detect_seasonal_transitions(self, location: Location) -> List[SeasonalTransition]:
        """
        Detect seasonal transitions based on temperature, daylight, and precipitation patterns.
        
        Args:
            location: Geographic location
            
        Returns:
            List of detected seasonal transitions
        """
        # Use the advanced seasonal pattern service for detection
        from app.services.seasonal_pattern_service import SeasonalPatternService
        
        pattern_service = SeasonalPatternService()
        return await pattern_service.detect_seasonal_transitions(location)
    
    def _analyze_temperature_transitions(self, climate_data: ClimateData) -> List[SeasonalTransition]:
        """Analyze temperature data for seasonal transitions."""
        transitions = []
        temps = climate_data.temperature_avg
        dates = climate_data.dates
        
        if len(temps) < 14:  # Need at least 2 weeks of data
            return transitions
        
        # Calculate moving averages
        window_size = 7
        moving_avg = []
        for i in range(len(temps) - window_size + 1):
            avg = sum(temps[i:i + window_size]) / window_size
            moving_avg.append(avg)
        
        # Detect significant temperature changes
        for i in range(1, len(moving_avg) - 1):
            prev_temp = moving_avg[i - 1]
            curr_temp = moving_avg[i]
            next_temp = moving_avg[i + 1]
            
            # Look for sustained temperature changes
            temp_change = curr_temp - prev_temp
            if abs(temp_change) > 3:  # 3°C threshold
                trend = "warming" if temp_change > 0 else "cooling"
                
                # Determine transition type based on time of year and trend
                transition_date = dates[i + window_size // 2]
                month = transition_date.month
                
                if trend == "warming" and month in [2, 3, 4]:
                    transition_type = "spring_onset"
                elif trend == "warming" and month in [5, 6]:
                    transition_type = "summer_onset"
                elif trend == "cooling" and month in [9, 10, 11]:
                    transition_type = "autumn_onset"
                elif trend == "cooling" and month in [11, 12, 1]:
                    transition_type = "winter_onset"
                else:
                    continue
                
                confidence = min(0.9, abs(temp_change) / 10)  # Scale confidence
                
                transitions.append(SeasonalTransition(
                    location=climate_data.location,
                    transition_type=transition_type,
                    estimated_date=transition_date,
                    confidence=confidence,
                    indicators={
                        "temperature_change": temp_change,
                        "analysis_window": window_size,
                        "previous_temp": prev_temp,
                        "current_temp": curr_temp
                    },
                    temperature_trend=trend,
                    daylight_trend="stable"  # Will be updated by daylight analysis
                ))
        
        return transitions
    
    def _analyze_daylight_transitions(self, daylight_patterns: DaylightPatterns, current_date: date) -> List[SeasonalTransition]:
        """Analyze daylight patterns for seasonal transitions."""
        transitions = []
        
        # Find current position in year
        day_of_year = current_date.timetuple().tm_yday
        
        # Key daylight transition dates (approximate)
        spring_equinox = 80  # Around March 21
        summer_solstice = 172  # Around June 21
        autumn_equinox = 266  # Around September 23
        winter_solstice = 355  # Around December 21
        
        tolerance = 7  # Days tolerance
        
        if abs(day_of_year - spring_equinox) <= tolerance:
            transitions.append(SeasonalTransition(
                location=daylight_patterns.location,
                transition_type="spring_equinox",
                estimated_date=current_date,
                confidence=0.95,
                indicators={
                    "daylight_hours": 12,
                    "daylight_change_rate": "increasing",
                    "astronomical_event": "spring_equinox"
                },
                temperature_trend="stable",
                daylight_trend="increasing"
            ))
        elif abs(day_of_year - summer_solstice) <= tolerance:
            transitions.append(SeasonalTransition(
                location=daylight_patterns.location,
                transition_type="summer_solstice",
                estimated_date=current_date,
                confidence=0.95,
                indicators={
                    "daylight_hours": daylight_patterns.longest_day.daylight_hours,
                    "daylight_change_rate": "peak",
                    "astronomical_event": "summer_solstice"
                },
                temperature_trend="stable",
                daylight_trend="stable"
            ))
        elif abs(day_of_year - autumn_equinox) <= tolerance:
            transitions.append(SeasonalTransition(
                location=daylight_patterns.location,
                transition_type="autumn_equinox",
                estimated_date=current_date,
                confidence=0.95,
                indicators={
                    "daylight_hours": 12,
                    "daylight_change_rate": "decreasing",
                    "astronomical_event": "autumn_equinox"
                },
                temperature_trend="stable",
                daylight_trend="decreasing"
            ))
        elif abs(day_of_year - winter_solstice) <= tolerance:
            transitions.append(SeasonalTransition(
                location=daylight_patterns.location,
                transition_type="winter_solstice",
                estimated_date=current_date,
                confidence=0.95,
                indicators={
                    "daylight_hours": daylight_patterns.shortest_day.daylight_hours,
                    "daylight_change_rate": "minimum",
                    "astronomical_event": "winter_solstice"
                },
                temperature_trend="stable",
                daylight_trend="stable"
            ))
        
        return transitions
    
    def _analyze_precipitation_transitions(self, climate_data: ClimateData) -> List[SeasonalTransition]:
        """Analyze precipitation patterns for seasonal transitions."""
        transitions = []
        precip = climate_data.precipitation
        dates = climate_data.dates
        
        if len(precip) < 14:
            return transitions
        
        # Calculate weekly precipitation totals
        weekly_precip = []
        weekly_dates = []
        
        for i in range(0, len(precip) - 6, 7):
            week_total = sum(precip[i:i + 7])
            weekly_precip.append(week_total)
            weekly_dates.append(dates[i + 3])  # Middle of week
        
        # Detect significant precipitation changes
        for i in range(1, len(weekly_precip)):
            prev_precip = weekly_precip[i - 1]
            curr_precip = weekly_precip[i]
            
            change_ratio = curr_precip / (prev_precip + 0.1)  # Avoid division by zero
            
            if change_ratio > 2.0:  # Significant increase
                month = weekly_dates[i].month
                if month in [3, 4, 5]:  # Spring rains
                    transitions.append(SeasonalTransition(
                        location=climate_data.location,
                        transition_type="spring_rains_onset",
                        estimated_date=weekly_dates[i],
                        confidence=0.7,
                        indicators={
                            "precipitation_increase": change_ratio,
                            "weekly_precip": curr_precip,
                            "previous_precip": prev_precip
                        },
                        temperature_trend="stable",
                        daylight_trend="stable"
                    ))
            elif change_ratio < 0.5 and curr_precip < 5:  # Significant decrease to dry conditions
                month = weekly_dates[i].month
                if month in [6, 7, 8]:  # Summer dry period
                    transitions.append(SeasonalTransition(
                        location=climate_data.location,
                        transition_type="dry_season_onset",
                        estimated_date=weekly_dates[i],
                        confidence=0.6,
                        indicators={
                            "precipitation_decrease": change_ratio,
                            "weekly_precip": curr_precip,
                            "previous_precip": prev_precip
                        },
                        temperature_trend="stable",
                        daylight_trend="stable"
                    ))
        
        return transitions
    
    async def get_seasonal_pest_data(self, location: Location, plant_species: str) -> PestRiskData:
        """
        Get seasonal pest risk data for a specific plant species and location.
        
        Args:
            location: Geographic location
            plant_species: Plant species name
            
        Returns:
            PestRiskData with risk assessment and recommendations
        """
        cache_key = self._generate_cache_key("pest_risk", location, {"species": plant_species})
        cached_data = await self._get_cached_data(cache_key)
        
        if cached_data:
            logger.info(f"Returning cached pest risk data for {plant_species}")
            return PestRiskData(**cached_data)
        
        # Use the advanced seasonal pattern service for pest risk assessment
        from app.services.seasonal_pattern_service import SeasonalPatternService
        
        pattern_service = SeasonalPatternService()
        pest_data = await pattern_service.assess_seasonal_pest_risks(location, plant_species)
        
        # Cache the result
        await self._cache_data(cache_key, pest_data.model_dump(), self.weather_cache_ttl)
        return pest_data
    
    async def calculate_microclimate_adjustments(
        self, 
        location: Location,
        indoor_conditions: bool = True
    ):
        """
        Calculate microclimate adjustments for indoor vs outdoor conditions.
        
        Args:
            location: Geographic location
            indoor_conditions: Whether to calculate for indoor conditions
            
        Returns:
            MicroclimateAdjustment with calculated factors
        """
        # Use the advanced seasonal pattern service for microclimate calculations
        from app.services.seasonal_pattern_service import SeasonalPatternService
        
        pattern_service = SeasonalPatternService()
        return await pattern_service.calculate_microclimate_adjustments(location, indoor_conditions)
    
    def _assess_pest_risks(
        self, 
        location: Location, 
        plant_species: str, 
        weather_data: WeatherForecast, 
        current_date: date
    ) -> List[PestRiskFactor]:
        """Assess pest risks based on environmental conditions."""
        risk_factors = []
        current = weather_data.current
        month = current_date.month
        
        # Aphid risk assessment
        aphid_risk = 0.3  # Base risk
        if current.temperature > 20 and current.humidity > 60:
            aphid_risk += 0.3
        if month in [4, 5, 6, 9, 10]:  # Peak seasons
            aphid_risk += 0.2
        
        risk_factors.append(PestRiskFactor(
            pest_type="aphids",
            risk_level=self._get_risk_level(aphid_risk),
            risk_score=min(1.0, aphid_risk),
            seasonal_peak="Spring and Fall",
            environmental_triggers=["warm temperatures", "high humidity", "new growth"],
            prevention_measures=["regular inspection", "beneficial insects", "neem oil spray"]
        ))
        
        # Spider mite risk assessment
        mite_risk = 0.2  # Base risk
        if current.temperature > 25 and current.humidity < 40:
            mite_risk += 0.4
        if month in [6, 7, 8]:  # Summer peak
            mite_risk += 0.3
        
        risk_factors.append(PestRiskFactor(
            pest_type="spider_mites",
            risk_level=self._get_risk_level(mite_risk),
            risk_score=min(1.0, mite_risk),
            seasonal_peak="Summer",
            environmental_triggers=["hot dry conditions", "low humidity", "drought stress"],
            prevention_measures=["increase humidity", "regular misting", "predatory mites"]
        ))
        
        # Scale insect risk assessment
        scale_risk = 0.25  # Base risk
        if current.humidity > 70:
            scale_risk += 0.2
        if month in [3, 4, 5, 9, 10]:  # Active seasons
            scale_risk += 0.15
        
        risk_factors.append(PestRiskFactor(
            pest_type="scale_insects",
            risk_level=self._get_risk_level(scale_risk),
            risk_score=min(1.0, scale_risk),
            seasonal_peak="Spring and Fall",
            environmental_triggers=["high humidity", "poor air circulation", "stressed plants"],
            prevention_measures=["improve air circulation", "regular cleaning", "systemic insecticides"]
        ))
        
        # Fungal disease risk (not technically pests, but important)
        fungal_risk = 0.2  # Base risk
        if current.humidity > 80 and current.temperature > 15:
            fungal_risk += 0.4
        if any(day.get("precipitation", 0) > 5 for day in weather_data.forecast_days[:3]):
            fungal_risk += 0.2
        
        risk_factors.append(PestRiskFactor(
            pest_type="fungal_diseases",
            risk_level=self._get_risk_level(fungal_risk),
            risk_score=min(1.0, fungal_risk),
            seasonal_peak="Wet seasons",
            environmental_triggers=["high humidity", "poor ventilation", "wet conditions"],
            prevention_measures=["improve ventilation", "avoid overwatering", "fungicidal sprays"]
        ))
        
        return risk_factors
    
    def _get_risk_level(self, risk_score: float) -> str:
        """Convert risk score to risk level."""
        if risk_score < 0.3:
            return "low"
        elif risk_score < 0.6:
            return "medium"
        elif risk_score < 0.8:
            return "high"
        else:
            return "critical"
    
    def _generate_seasonal_pest_recommendations(self, plant_species: str, current_date: date) -> Dict[str, List[str]]:
        """Generate seasonal pest prevention recommendations."""
        month = current_date.month
        
        recommendations = {
            "current_month": [],
            "next_month": [],
            "general": [
                "Inspect plants weekly for early pest detection",
                "Maintain proper plant spacing for air circulation",
                "Keep plants healthy to improve natural resistance",
                "Remove dead or diseased plant material promptly"
            ]
        }
        
        # Spring recommendations (March-May)
        if month in [3, 4, 5]:
            recommendations["current_month"].extend([
                "Begin regular pest monitoring as temperatures warm",
                "Apply preventive treatments before pest populations establish",
                "Check for overwintering pests on new growth",
                "Introduce beneficial insects early in the season"
            ])
        
        # Summer recommendations (June-August)
        elif month in [6, 7, 8]:
            recommendations["current_month"].extend([
                "Increase watering frequency to prevent drought stress",
                "Monitor for spider mites in hot, dry conditions",
                "Provide shade during extreme heat to reduce plant stress",
                "Maintain higher humidity around plants when possible"
            ])
        
        # Fall recommendations (September-November)
        elif month in [9, 10, 11]:
            recommendations["current_month"].extend([
                "Prepare plants for winter dormancy",
                "Reduce watering as growth slows",
                "Clean up fallen leaves and debris",
                "Apply dormant oil treatments if needed"
            ])
        
        # Winter recommendations (December-February)
        else:
            recommendations["current_month"].extend([
                "Monitor indoor plants for pests in heated environments",
                "Reduce fertilization during dormant period",
                "Maintain proper humidity in dry indoor air",
                "Plan pest management strategy for upcoming growing season"
            ])
        
        return recommendations