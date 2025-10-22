#!/bin/bash

# Docker Development Environment Script
# Start Kharisma Abadi development environment

set -e

echo "=========================================="
echo "Kharisma Abadi - Development Environment"
echo "=========================================="
echo ""

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker Desktop."
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose is not installed. Please install Docker Desktop."
    exit 1
fi

# Load environment variables
if [ -f .env ]; then
    echo "📝 Loading environment from .env"
    export $(cat .env | grep -v '^#' | xargs)
else
    echo "⚠️  .env file not found. Using defaults."
    echo "💡 Copy .env.example to .env and customize values if needed."
fi

# Create necessary directories
echo "📁 Creating necessary directories..."
mkdir -p backend/uploads
mkdir -p scripts
mkdir -p nginx/ssl

# Build images if needed
echo "🔨 Building Docker images..."
docker-compose build

# Start services
echo "🚀 Starting development services..."
echo ""
docker-compose -f docker-compose.yml -f docker-compose.dev.yml up

echo ""
echo "=========================================="
echo "Development environment started!"
echo "=========================================="
echo "📍 Frontend: http://localhost:3000"
echo "📍 Backend API: http://localhost:8000"
echo "📍 API Documentation: http://localhost:8000/docs"
echo "📍 Database: localhost:3306"
echo ""
echo "💡 To stop: Press Ctrl+C"
echo "💡 To view logs: docker-compose logs -f [service]"
echo "==========================================="
