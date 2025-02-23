#!/bin/bash

# Function to build static files
build_static() {
    echo "Building static files..."
    npm run build
    # Copy the built files to dist directory
    cp -r public/* /app/dist/
    echo "Static files built and copied to dist"
}

# Initial build
build_static

# Start dev server
echo "Starting development server..."
npm run dev &

# Keep container running and handle rebuilds
while true; do
    sleep 1
done