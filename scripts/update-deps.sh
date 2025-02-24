#!/bin/bash

# Exit on any error
set -e

# Load environment variables
if [ -f .env ]; then
    export $(cat .env | grep -v '#' | xargs)
fi

echo "Updating dependencies..."

# Function to check if docker/docker-compose is available
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check if Docker is running
if ! docker info >/dev/null 2>&1; then
    echo "Docker is not running. Please start Docker and try again."
    exit 1
fi

# Update dependencies in the running container
if command_exists docker-compose; then
    echo "Installing/updating dependencies..."
    docker-compose exec app npm install
elif command_exists docker && docker compose version >/dev/null 2>&1; then
    echo "Installing/updating dependencies..."
    docker compose exec app npm install
else
    echo "Docker Compose not found. Please install Docker Compose and try again."
    exit 1
fi

echo "Dependencies updated successfully!"
echo "You can access:"
echo "- Development server at http://localhost:${DEV_PORT}"
echo "- Production build at http://localhost:${NGINX_PORT}" 