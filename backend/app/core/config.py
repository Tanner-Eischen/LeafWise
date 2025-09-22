"""Application configuration settings.

This module defines all configuration settings for the FastAPI application,
including database connections, authentication, and external service settings.
"""

import secrets
from typing import Any, Dict, List, Optional, Union

from pydantic import AnyHttpUrl, EmailStr, HttpUrl, PostgresDsn, field_validator
from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    """Application settings loaded from environment variables."""
    
    # Basic app settings
    PROJECT_NAME: str = "LeafWise API"
    VERSION: str = "1.0.0"
    API_V1_STR: str = "/api/v1"
    SECRET_KEY: str = secrets.token_urlsafe(32)
    
    # Security settings
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60 * 24 * 8  # 8 days
    REFRESH_TOKEN_EXPIRE_MINUTES: int = 60 * 24 * 30  # 30 days
    ALGORITHM: str = "HS256"
    
    # CORS settings
    BACKEND_CORS_ORIGINS: str = "http://localhost:3000,http://localhost:8000,http://localhost:8080,http://127.0.0.1:3000"
    
    ALLOWED_HOSTS: str = "localhost,127.0.0.1"
    
    def get_cors_origins(self) -> List[str]:
        """Parse CORS origins from string."""
        if isinstance(self.BACKEND_CORS_ORIGINS, str):
            return [origin.strip() for origin in self.BACKEND_CORS_ORIGINS.split(",") if origin.strip()]
        return []
    
    def get_allowed_hosts(self) -> List[str]:
        """Parse allowed hosts from string."""
        if isinstance(self.ALLOWED_HOSTS, str):
            return [host.strip() for host in self.ALLOWED_HOSTS.split(",") if host.strip()]
        return []
    
    # Database settings
    POSTGRES_SERVER: str = "postgres"
    POSTGRES_USER: str = "postgres"
    POSTGRES_PASSWORD: str = "admin"
    POSTGRES_DB: str = "leafwise_db"
    POSTGRES_PORT: str = "5432"
    SQLALCHEMY_DATABASE_URI: Optional[PostgresDsn] = None
    
    @field_validator("SQLALCHEMY_DATABASE_URI", mode="before")
    @classmethod
    def assemble_db_connection(cls, v: Optional[str], info) -> Any:
        """Assemble database connection string."""
        if isinstance(v, str):
            return v
        values = info.data if hasattr(info, 'data') else {}
        # Construct URL manually to avoid PostgresDsn issues
        user = values.get("POSTGRES_USER", "postgres")
        password = values.get("POSTGRES_PASSWORD", "admin")
        host = values.get("POSTGRES_SERVER", "localhost")
        port = values.get("POSTGRES_PORT", "5432")
        db = values.get("POSTGRES_DB", "leafwise_db")
        return f"postgresql+asyncpg://{user}:{password}@{host}:{port}/{db}"
    
    # Redis settings
    REDIS_HOST: str = "localhost"
    REDIS_PORT: int = 6379
    REDIS_DB: int = 0
    REDIS_PASSWORD: Optional[str] = None
    
    # AWS S3 settings
    AWS_ACCESS_KEY_ID: Optional[str] = None
    AWS_SECRET_ACCESS_KEY: Optional[str] = None
    AWS_REGION: str = "us-east-1"
    AWS_ENDPOINT_URL: Optional[str] = None
    S3_BUCKET_NAME: Optional[str] = None
    CLOUDFRONT_DOMAIN: Optional[str] = None
    
    # OpenAI settings (for future phases)
    OPENAI_API_KEY: Optional[str] = None
    
    # Weather API settings
    OPENWEATHERMAP_API_KEY: Optional[str] = None
    WEATHERAPI_KEY: Optional[str] = None
    WEATHER_CACHE_TTL: int = 3600  # 1 hour in seconds
    CLIMATE_DATA_CACHE_TTL: int = 86400  # 24 hours in seconds
    
    # Email settings (for future use)
    SMTP_TLS: bool = True
    SMTP_PORT: Optional[int] = None
    SMTP_HOST: Optional[str] = None
    SMTP_USER: Optional[str] = None
    SMTP_PASSWORD: Optional[str] = None
    EMAILS_FROM_EMAIL: Optional[EmailStr] = None
    EMAILS_FROM_NAME: Optional[str] = None
    
    # Testing
    TESTING: bool = False
    
    model_config = {
        "case_sensitive": True,
        "env_file": ".env"
    }


settings = Settings()