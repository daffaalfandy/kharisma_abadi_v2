#!/bin/bash

# Docker Production Environment Script
# Start Kharisma Abadi production environment

set -e

echo "=========================================="
echo "Kharisma Abadi - Production Environment"
echo "=========================================="
echo ""

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker."
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose is not installed."
    exit 1
fi

# Load environment variables
if [ ! -f .env.production ]; then
    echo "❌ .env.production file not found!"
    echo "💡 Create .env.production with production configuration."
    exit 1
fi

echo "📝 Loading environment from .env.production"
export $(cat .env.production | grep -v '^#' | xargs)

# Verify required environment variables
if [ -z "$DB_ROOT_PASSWORD" ] || [ -z "$JWT_SECRET" ]; then
    echo "❌ Missing required environment variables in .env.production"
    echo "💡 Ensure DB_ROOT_PASSWORD and JWT_SECRET are set."
    exit 1
fi

# Create necessary directories
echo "📁 Creating necessary directories..."
mkdir -p backend/uploads
mkdir -p nginx/ssl

# Verify SSL certificates exist
if [ ! -f "nginx/ssl/cert.pem" ] || [ ! -f "nginx/ssl/key.pem" ]; then
    echo "⚠️  SSL certificates not found in nginx/ssl/"
    echo "💡 For HTTPS in production, place cert.pem and key.pem in nginx/ssl/"
fi

# Build images
echo "🔨 Building Docker images for production..."
docker-compose build

# Start services in detached mode
echo "🚀 Starting production services..."
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d

echo ""
echo "=========================================="
echo "✅ Production environment started!"
echo "=========================================="
echo "📍 Frontend: http://localhost"
echo "📍 Backend API: http://localhost/api"
echo "📍 API Documentation: http://localhost/docs"
echo ""
echo "💡 View logs: docker-compose logs -f [service]"
echo "💡 Stop services: docker-compose down"
echo "=========================================="

# Check health
echo ""
echo "Checking service health..."
sleep 5

echo ""
echo "Service Status:"
docker-compose ps

echo ""
echo "✨ Production environment ready!"
