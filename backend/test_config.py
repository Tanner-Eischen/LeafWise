#!/usr/bin/env python3
"""
Simple test script to verify configuration loading.
"""

try:
    from app.core.config import settings
    print("✓ Configuration loaded successfully")
    print(f"Project: {settings.PROJECT_NAME}")
    print(f"CORS Origins: {settings.BACKEND_CORS_ORIGINS}")
    print(f"Database URI: {settings.SQLALCHEMY_DATABASE_URI}")
except Exception as e:
    print(f"✗ Configuration failed: {e}")
    import traceback
    traceback.print_exc()