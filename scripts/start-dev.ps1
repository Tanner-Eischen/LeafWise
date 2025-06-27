#!/usr/bin/env pwsh
# Development startup script for Plant Social platform

Write-Host "🌱 Starting Plant Social Development Environment" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Green

# Check if Docker is running
try {
    docker info | Out-Null
    Write-Host "✅ Docker is running" -ForegroundColor Green
} catch {
    Write-Host "❌ Docker is not running. Please start Docker Desktop." -ForegroundColor Red
    exit 1
}

# Navigate to project root
$projectRoot = Split-Path -Parent $PSScriptRoot
Set-Location $projectRoot

Write-Host "📁 Project directory: $projectRoot" -ForegroundColor Cyan

# Start infrastructure services
Write-Host "🚀 Starting infrastructure services (PostgreSQL, Redis, LocalStack)..." -ForegroundColor Yellow
try {
    docker-compose up -d postgres redis localstack
    Write-Host "✅ Infrastructure services started" -ForegroundColor Green
} catch {
    Write-Host "❌ Failed to start infrastructure services" -ForegroundColor Red
    exit 1
}

# Wait for services to be ready
Write-Host "⏳ Waiting for services to be ready..." -ForegroundColor Yellow
Start-Sleep -Seconds 10

# Check service health
Write-Host "🔍 Checking service health..." -ForegroundColor Yellow

# Check PostgreSQL
try {
    $pgResult = docker-compose exec -T postgres pg_isready -U postgres
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ PostgreSQL is ready" -ForegroundColor Green
    } else {
        Write-Host "⚠️  PostgreSQL is not ready yet" -ForegroundColor Yellow
    }
} catch {
    Write-Host "⚠️  Could not check PostgreSQL status" -ForegroundColor Yellow
}

# Check Redis
try {
    $redisResult = docker-compose exec -T redis redis-cli ping
    if ($redisResult -eq "PONG") {
        Write-Host "✅ Redis is ready" -ForegroundColor Green
    } else {
        Write-Host "⚠️  Redis is not ready yet" -ForegroundColor Yellow
    }
} catch {
    Write-Host "⚠️  Could not check Redis status" -ForegroundColor Yellow
}

# Navigate to backend directory
Set-Location "backend"

# Check if virtual environment exists
if (Test-Path "venv") {
    Write-Host "✅ Virtual environment found" -ForegroundColor Green
} else {
    Write-Host "📦 Creating virtual environment..." -ForegroundColor Yellow
    python -m venv venv
    Write-Host "✅ Virtual environment created" -ForegroundColor Green
}

# Activate virtual environment
Write-Host "🔧 Activating virtual environment..." -ForegroundColor Yellow
if ($IsWindows -or $env:OS -eq "Windows_NT") {
    & ".\venv\Scripts\Activate.ps1"
} else {
    & "./venv/bin/activate"
}

# Install dependencies
Write-Host "📦 Installing Python dependencies..." -ForegroundColor Yellow
try {
    pip install -r requirements.txt
    Write-Host "✅ Dependencies installed" -ForegroundColor Green
} catch {
    Write-Host "❌ Failed to install dependencies" -ForegroundColor Red
    exit 1
}

# Run database migrations
Write-Host "🗃️  Setting up database..." -ForegroundColor Yellow
try {
    # Check if migrations directory exists
    if (!(Test-Path "alembic\versions")) {
        Write-Host "📝 Creating initial migration..." -ForegroundColor Yellow
        alembic revision --autogenerate -m "Initial migration"
    }
    
    # Apply migrations
    Write-Host "🔄 Applying database migrations..." -ForegroundColor Yellow
    alembic upgrade head
    Write-Host "✅ Database migrations applied" -ForegroundColor Green
} catch {
    Write-Host "⚠️  Database migration failed, but continuing..." -ForegroundColor Yellow
    Write-Host "You may need to run migrations manually: alembic upgrade head" -ForegroundColor Yellow
}

# Create S3 bucket in LocalStack
Write-Host "🪣 Setting up S3 bucket in LocalStack..." -ForegroundColor Yellow
try {
    Start-Sleep -Seconds 5  # Wait for LocalStack to be ready
    $env:AWS_ACCESS_KEY_ID = "test"
    $env:AWS_SECRET_ACCESS_KEY = "test"
    $env:AWS_DEFAULT_REGION = "us-east-1"
    
    aws --endpoint-url=http://localhost:4566 s3 mb s3://plant-social-media 2>$null
    Write-Host "✅ S3 bucket created in LocalStack" -ForegroundColor Green
} catch {
    Write-Host "⚠️  Could not create S3 bucket (LocalStack may not be ready)" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "🎉 Development environment is ready!" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Green
Write-Host "📊 Service URLs:" -ForegroundColor Cyan
Write-Host "   • API Documentation: http://localhost:8000/docs" -ForegroundColor White
Write-Host "   • API ReDoc: http://localhost:8000/redoc" -ForegroundColor White
Write-Host "   • PostgreSQL: localhost:5432" -ForegroundColor White
Write-Host "   • Redis: localhost:6379" -ForegroundColor White
Write-Host "   • LocalStack S3: http://localhost:4566" -ForegroundColor White
Write-Host ""
Write-Host "🚀 To start the API server, run:" -ForegroundColor Yellow
Write-Host "   uvicorn app.main:app --reload --host 0.0.0.0 --port 8000" -ForegroundColor White
Write-Host ""
Write-Host "🛑 To stop services, run:" -ForegroundColor Yellow
Write-Host "   docker-compose down" -ForegroundColor White
Write-Host ""