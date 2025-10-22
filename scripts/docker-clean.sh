#!/bin/bash

# Docker Cleanup Script
# Clean Docker resources (containers, volumes, images)

set -e

echo "=========================================="
echo "Docker Cleanup Utility"
echo "=========================================="
echo ""

# Check if Docker is running
if ! docker info &> /dev/null; then
    echo "❌ Docker daemon is not running."
    exit 1
fi

# Step 1: Stop all containers
echo "🛑 Stopping all containers..."
docker-compose down

echo "✓ Containers stopped"
echo ""

# Step 2: Ask about volumes
read -p "Remove database volumes (DELETE ALL DATA)? (y/N): " -n 1 -r confirm
echo ""
if [[ $confirm =~ ^[Yy]$ ]]; then
    echo "🗑️  Removing volumes..."
    docker-compose down -v
    echo "✓ Volumes removed"
else
    echo "⏭️  Skipping volume removal"
fi

echo ""

# Step 3: Ask about images
read -p "Remove Docker images? (y/N): " -n 1 -r confirm
echo ""
if [[ $confirm =~ ^[Yy]$ ]]; then
    echo "🗑️  Removing images..."
    docker-compose down --rmi all
    echo "✓ Images removed"
else
    echo "⏭️  Skipping image removal"
fi

echo ""

# Step 4: Ask about full prune
read -p "Run full Docker system prune? (y/N): " -n 1 -r confirm
echo ""
if [[ $confirm =~ ^[Yy]$ ]]; then
    echo "🧹 Pruning Docker system..."
    docker system prune -f --volumes
    echo "✓ System pruned"
else
    echo "⏭️  Skipping system prune"
fi

echo ""
echo "=========================================="
echo "✓ Cleanup complete!"
echo "=========================================="
echo ""
echo "To rebuild: make dev"
echo ""
