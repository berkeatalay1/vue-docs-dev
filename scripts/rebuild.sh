#!/bin/bash

# Exit on any error
set -e

# Load environment variables
if [ -f .env ]; then
    export $(cat .env | grep -v '#' | xargs)
fi

echo "Rebuilding static files..."

# Run build in the app container and copy to dist
docker-compose exec app bash -c "npm run build && cp -r public/* /app/dist/"

echo "Static files have been rebuilt successfully!"
echo "The changes are automatically reflected in the nginx container."
echo "You can access:"
echo "- Development server at http://localhost:${DEV_PORT}"
echo "- Production build at http://localhost:${NGINX_PORT}" 