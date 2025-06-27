#!/bin/bash
# Development startup script for Plant Social platform

echo "🌱 Starting Plant Social Development Environment"
echo "========================================="

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker."
    exit 1
fi
echo "✅ Docker is running"

# Navigate to project root
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"
echo "📁 Project directory: $PROJECT_ROOT"

# Start infrastructure services
echo "🚀 Starting infrastructure services (PostgreSQL, Redis, LocalStack)..."
if ! docker-compose up -d postgres redis localstack; then
    echo "❌ Failed to start infrastructure services"
    exit 1
fi
echo "✅ Infrastructure services started"

# Wait for services to be ready
echo "⏳ Waiting for services to be ready..."
sleep 10

# Check service health
echo "🔍 Checking service health..."

# Check PostgreSQL
if docker-compose exec -T postgres pg_isready -U postgres > /dev/null 2>&1; then
    echo "✅ PostgreSQL is ready"
else
    echo "⚠️  PostgreSQL is not ready yet"
fi

# Check Redis
if [ "$(docker-compose exec -T redis redis-cli ping 2>/dev/null)" = "PONG" ]; then
    echo "✅ Redis is ready"
else
    echo "⚠️  Redis is not ready yet"
fi

# Navigate to backend directory
cd backend

# Check if virtual environment exists
if [ -d "venv" ]; then
    echo "✅ Virtual environment found"
else
    echo "📦 Creating virtual environment..."
    python3 -m venv venv
    echo "✅ Virtual environment created"
fi

# Activate virtual environment
echo "🔧 Activating virtual environment..."
source venv/bin/activate

# Install dependencies
echo "📦 Installing Python dependencies..."
if ! pip install -r requirements.txt; then
    echo "❌ Failed to install dependencies"
    exit 1
fi
echo "✅ Dependencies installed"

# Run database migrations
echo "🗃️  Setting up database..."
if [ ! -d "alembic/versions" ] || [ -z "$(ls -A alembic/versions)" ]; then
    echo "📝 Creating initial migration..."
    alembic revision --autogenerate -m "Initial migration"
fi

echo "🔄 Applying database migrations..."
if alembic upgrade head; then
    echo "✅ Database migrations applied"
else
    echo "⚠️  Database migration failed, but continuing..."
    echo "You may need to run migrations manually: alembic upgrade head"
fi

# Create S3 bucket in LocalStack
echo "🪣 Setting up S3 bucket in LocalStack..."
sleep 5  # Wait for LocalStack to be ready
export AWS_ACCESS_KEY_ID="test"
export AWS_SECRET_ACCESS_KEY="test"
export AWS_DEFAULT_REGION="us-east-1"

if aws --endpoint-url=http://localhost:4566 s3 mb s3://plant-social-media 2>/dev/null; then
    echo "✅ S3 bucket created in LocalStack"
else
    echo "⚠️  Could not create S3 bucket (LocalStack may not be ready)"
fi

echo ""
echo "🎉 Development environment is ready!"
echo "========================================="
echo "📊 Service URLs:"
echo "   • API Documentation: http://localhost:8000/docs"
echo "   • API ReDoc: http://localhost:8000/redoc"
echo "   • PostgreSQL: localhost:5432"
echo "   • Redis: localhost:6379"
echo "   • LocalStack S3: http://localhost:4566"
echo ""
echo "🚀 To start the API server, run:"
echo "   uvicorn app.main:app --reload --host 0.0.0.0 --port 8000"
echo ""
echo "🛑 To stop services, run:"
echo "   docker-compose down"
echo ""