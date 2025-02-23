#!/bin/bash

# Create certificates directory
mkdir -p docker/nginx/certs

# Generate self-signed certificate
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout docker/nginx/certs/server.key \
    -out docker/nginx/certs/server.crt \
    -subj "/C=US/ST=State/L=City/O=Organization/CN=localhost"

# Set proper permissions
chmod 644 docker/nginx/certs/server.crt
chmod 600 docker/nginx/certs/server.key 