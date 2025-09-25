"""
Datetime utilities for timezone-aware datetime operations.

This module provides timezone-aware alternatives to deprecated datetime.utcnow()
and other datetime operations to ensure consistency across the application.
"""

from datetime import datetime, timezone, timedelta
from typing import Optional


def utc_now() -> datetime:
    """
    Get current UTC datetime with timezone information.
    
    Replacement for deprecated datetime.utcnow().
    
    Returns:
        datetime: Current UTC datetime with timezone info
    """
    return datetime.now(timezone.utc)


def utc_timestamp() -> float:
    """
    Get current UTC timestamp.
    
    Returns:
        float: Current UTC timestamp
    """
    return utc_now().timestamp()


def utc_from_timestamp(timestamp: float) -> datetime:
    """
    Create timezone-aware datetime from timestamp.
    
    Args:
        timestamp: Unix timestamp
        
    Returns:
        datetime: Timezone-aware datetime in UTC
    """
    return datetime.fromtimestamp(timestamp, tz=timezone.utc)


def add_timezone_utc(dt: datetime) -> datetime:
    """
    Add UTC timezone to naive datetime.
    
    Args:
        dt: Naive datetime object
        
    Returns:
        datetime: Timezone-aware datetime in UTC
    """
    if dt.tzinfo is None:
        return dt.replace(tzinfo=timezone.utc)
    return dt


def format_iso_utc(dt: Optional[datetime] = None) -> str:
    """
    Format datetime as ISO string in UTC.
    
    Args:
        dt: Datetime to format, defaults to current UTC time
        
    Returns:
        str: ISO formatted datetime string
    """
    if dt is None:
        dt = utc_now()
    return dt.isoformat()


def days_ago(days: int) -> datetime:
    """
    Get datetime N days ago from now in UTC.
    
    Args:
        days: Number of days ago
        
    Returns:
        datetime: UTC datetime N days ago
    """
    return utc_now() - timedelta(days=days)


def hours_ago(hours: int) -> datetime:
    """
    Get datetime N hours ago from now in UTC.
    
    Args:
        hours: Number of hours ago
        
    Returns:
        datetime: UTC datetime N hours ago
    """
    return utc_now() - timedelta(hours=hours)


def minutes_ago(minutes: int) -> datetime:
    """
    Get datetime N minutes ago from now in UTC.
    
    Args:
        minutes: Number of minutes ago
        
    Returns:
        datetime: UTC datetime N minutes ago
    """
    return utc_now() - timedelta(minutes=minutes)


def days_from_now(days: int) -> datetime:
    """
    Get datetime N days from now in UTC.
    
    Args:
        days: Number of days from now
        
    Returns:
        datetime: UTC datetime N days from now
    """
    return utc_now() + timedelta(days=days)


def hours_from_now(hours: int) -> datetime:
    """
    Get datetime N hours from now in UTC.
    
    Args:
        hours: Number of hours from now
        
    Returns:
        datetime: UTC datetime N hours from now
    """
    return utc_now() + timedelta(hours=hours)