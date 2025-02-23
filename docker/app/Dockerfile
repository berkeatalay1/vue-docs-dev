FROM node:18-slim

WORKDIR /app

# Install git for potential npm packages that might need it
RUN apt-get update && \
    apt-get install -y git && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Copy package files
COPY src/package*.json ./

# Install dependencies
RUN npm install

# Copy the rest of the application
COPY src/ .

# Create directory for static files
RUN mkdir -p /app/dist

# Expose dev server port
EXPOSE 4000

# Start script that handles both dev server and static build
COPY docker/app/start.sh /start.sh
RUN chmod +x /start.sh

CMD ["/start.sh"] 