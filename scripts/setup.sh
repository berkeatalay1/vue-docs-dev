#!/bin/bash

# Exit on any error
set -e

# Source the .env file
if [ -f "/app/.env" ]; then
  source "/app/.env"
else
  echo "Error: .env file not found in /app"
  exit 1
fi

DOCKER_COMPOSE_FILE="$APP_DIR/docker-compose.yml"

# Update package list and install prerequisites
echo "Updating package list and installing prerequisites..."
apt-get update -y
apt-get install -y curl git

# Install Docker
echo "Installing Docker..."
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
rm get-docker.sh

# Install Docker Compose
echo "Installing Docker Compose..."
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Clone the Vue.js v2 docs repository
echo "Cloning Vue.js v2 documentation repository..."
git clone "$GIT_URL" "$APP_DIR"
cd "$APP_DIR"

# Copy Docker files from the project repo
echo "Setting up Docker environment..."
cp -r /app/docker .

# Create Docker Compose file
cat > "$DOCKER_COMPOSE_FILE" <<EOF
services:
  app:
    build:
      context: $APP_DIR
      dockerfile: docker/app/Dockerfile
    volumes:
      - ./src:/app/src
    working_dir: /app
    ports:
      - "$DEV_PORT:$DEV_PORT"
    environment:
      - NODE_ENV=development
  nginx:
    build:
      context: $APP_DIR
      dockerfile: docker/nginx/Dockerfile
      args:
        NGINX_PORT: $NGINX_PORT
        DEV_PORT: $DEV_PORT
    ports:
      - "$NGINX_PORT:$NGINX_PORT"
    depends_on:
      - app
EOF

# Build and start the containers
echo "Building and starting Docker containers..."
docker-compose up -d --build
echo "Development environment is ready! Access it at http://localhost:$NGINX_PORT"