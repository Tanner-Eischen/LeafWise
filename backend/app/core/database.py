"""Database configuration and session management.

This module sets up the SQLAlchemy async engine, session factory,
and base model class for the application.
"""

from sqlalchemy import MetaData, text
from sqlalchemy.ext.asyncio import AsyncSession, create_async_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
from sqlalchemy.pool import NullPool

from app.core.config import settings

# Create base model class with naming convention
convention = {
    "ix": "ix_%(column_0_label)s",
    "uq": "uq_%(table_name)s_%(column_0_name)s",
    "ck": "ck_%(table_name)s_%(constraint_name)s",
    "fk": "fk_%(table_name)s_%(column_0_name)s_%(referred_table_name)s",
    "pk": "pk_%(table_name)s"
}

metadata = MetaData(naming_convention=convention)
Base = declarative_base(metadata=metadata)

# Note: Model imports are handled in app/models/__init__.py to avoid circular imports

# Create async engine
engine = create_async_engine(
    str(settings.SQLALCHEMY_DATABASE_URI),
    poolclass=NullPool,
    echo=True,  # Enable SQL query logging for debugging
)

# Create async session factory
AsyncSessionLocal = sessionmaker(
    engine,
    class_=AsyncSession,
    expire_on_commit=False,
)


async def get_db() -> AsyncSession:
    """Dependency to get database session.
    
    Yields:
        AsyncSession: Database session instance
    """
    async with AsyncSessionLocal() as session:
        try:
            yield session
        finally:
            await session.close()


async def init_db() -> None:
    """Initialize database tables.
    
    This function creates all tables defined in the models.
    Should be called during application startup.
    """
    async with engine.begin() as conn:
        # Enable vector extension
        await conn.execute(text('CREATE EXTENSION IF NOT EXISTS vector;'))
        # Create all tables
        await conn.run_sync(Base.metadata.create_all)


async def close_db() -> None:
    """Close database connections.
    
    Should be called during application shutdown.
    """
    await engine.dispose()