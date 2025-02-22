#!/bin/bash

# Exit on any error
set -e

# Variables
REPO_URL="https://github.com/vuejs/v2.vuejs.org.git"

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
