#!/bin/bash

# Exit on any error
set -e

# Variables
REPO_URL="https://github.com/vuejs/v2.vuejs.org.git"
APP_DIR="/tmp/vuejs-docs"
DOCKER_COMPOSE_FILE="/tmp/docker-compose.yml"

# Update package list and install prerequisites
echo "Updating package list and installing prerequisites..."
apt-get update -y
apt-get install -y curl git

# Install Docker
echo "Installing Docker..."
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
rm get-docker.sh

echo "Installing Docker Compose..."
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

echo "Cloning Vue.js v2 documentation repository..."
git clone "$REPO_URL" "$APP_DIR"
cd "$APP_DIR"

# Create Docker Compose file
cat > "$DOCKER_COMPOSE_FILE" <<EOF
services:
  app:
    build:
      context: .
      dockerfile: docker/app/Dockerfile
    volumes:
      - ./src:/app/src
    working_dir: /app
    command: npm run serve
    environment:
      - NODE_ENV=development
  nginx:
    build:
      context: .
      dockerfile: docker/nginx/Dockerfile
    ports:
      - "80:80"
    volumes:
      - ./dist:/usr/share/nginx/html
    depends_on:
      - app
EOF

echo "Setting up Docker environment..."
cp -r /app/docker .

echo "Building and starting Docker containers..."
docker-compose up -d --build
echo "Development environment is ready! Access it at http://localhost"