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
