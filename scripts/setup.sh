#!/bin/bash

# Exit on any error
set -e

# Load environment variables
if [ -f .env ]; then
    export $(cat .env | grep -v '#' | xargs)
fi

echo "Starting development environment setup..."

# Detect OS
if [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="linux"
    # Detect Linux distribution
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        DISTRO=$ID
    fi
else
    echo "Unsupported operating system: $OSTYPE"
    exit 1
fi

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Install dependencies for macOS using Homebrew
install_macos_deps() {
    if ! command_exists brew; then
        echo "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi

    if ! command_exists git; then
        echo "Installing Git..."
        brew install git
    fi

    if ! command_exists docker; then
        echo "Installing Docker Desktop for Mac..."
        brew install --cask docker
        echo "Please start Docker Desktop from your Applications folder and run this script again after Docker is running."
        exit 0
    fi
}

# Install dependencies for Ubuntu/Debian
install_debian_deps() {
    # Only update package list if git or docker needs to be installed
    if ! command_exists git || ! command_exists docker; then
        echo "Updating package list..."
        sudo apt-get update
    fi

    if ! command_exists git; then
        echo "Installing Git..."
        sudo apt-get install -y git
    fi

    if ! command_exists docker; then
        echo "Installing Docker..."
        sudo apt-get install -y ca-certificates curl gnupg
        sudo install -m 0755 -d /etc/apt/keyrings
        curl -fsSL https://download.docker.com/linux/$DISTRO/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
        sudo chmod a+r /etc/apt/keyrings/docker.gpg
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/$DISTRO $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
        sudo apt-get update
        sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
        sudo usermod -aG docker $USER
        echo "Docker installed. Please log out and log back in for group changes to take effect."
    fi
}

# Install dependencies based on OS
echo "Detecting and installing dependencies..."
if [ "$OS" == "macos" ]; then
    install_macos_deps
elif [ "$OS" == "linux" ]; then
    if [ "$DISTRO" == "ubuntu" ] || [ "$DISTRO" == "debian" ]; then
        install_debian_deps
    else
        echo "Unsupported Linux distribution. Please install Git, Docker, and Docker Compose manually."
        exit 1
    fi
fi

# Verify installations
echo "Verifying installations..."

if ! command_exists git; then
    echo "Git installation failed"
    exit 1
fi

if ! command_exists docker; then
    echo "Docker installation failed"
    exit 1
fi

# Check Docker is running
if ! docker info >/dev/null 2>&1; then
    echo "Docker is not running. Please start Docker and try again."
    exit 1
fi

# Create necessary directories and clone repository
echo "Setting up Vue.js documentation repository..."
if [ ! -d "src" ]; then
    echo "Cloning Vue.js documentation repository..."
    git clone --depth 1 "$GIT_URL" src
else
    echo "Source directory already exists, skipping clone..."
fi

# Generate SSL certificates if they don't exist
echo "Checking SSL certificates..."
if [ ! -f "docker/nginx/certs/nginx-selfsigned.crt" ]; then
    echo "Generating SSL certificates..."
    mkdir -p docker/nginx/certs
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout docker/nginx/certs/nginx-selfsigned.key \
        -out docker/nginx/certs/nginx-selfsigned.crt \
        -subj "/C=US/ST=State/L=City/O=Organization/CN=localhost"
else
    echo "SSL certificates already exist, skipping generation..."
fi

# Build and start containers
echo "Building and starting containers..."
if command_exists docker-compose; then
    docker-compose up --build -d
    
    # Wait for container to be ready
    echo "Waiting for containers to be ready..."
    sleep 5
    
    # Check if node_modules exists in the container
    if ! docker-compose exec app test -d /app/node_modules; then
        echo "Installing dependencies in the container..."
        docker-compose exec app npm install
    fi
elif command_exists docker && docker compose version >/dev/null 2>&1; then
    docker compose up --build -d
    
    # Wait for container to be ready
    echo "Waiting for containers to be ready..."
    sleep 5
    
    # Check if node_modules exists in the container
    if ! docker compose exec app test -d /app/node_modules; then
        echo "Installing dependencies in the container..."
        docker compose exec app npm install
    fi
else
    echo "Docker Compose not found. Please install Docker Compose and try again."
    exit 1
fi

echo "Setup completed successfully!"
echo "You can access the documentation in multiple ways:"
echo "1. Development Server (Hot Reload):"
echo "   http://localhost:${DEV_PORT}"
echo
echo "2. Production Build:"
echo "   - HTTP:  http://localhost:${NGINX_PORT}"
echo "   - HTTPS: https://localhost:${NGINX_SSL_PORT}"
echo
echo "Note: When accessing via HTTPS, you may see a security warning"
echo "      because we're using a self-signed certificate."
echo "      This is normal for local development."

if [ "$OS" == "linux" ] && [ "$(groups | grep -c docker)" -eq 0 ]; then
    echo
    echo "NOTE: You may need to log out and log back in for Docker permissions to take effect."
fi 