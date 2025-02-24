# Vue.js Documentation Development Environment

This repository contains a containerized development environment for the Vue.js v2 documentation site.

## Prerequisites

- Git
- Sudo rights (for Linux users)

## Quick Start

1. Clone this repository:
```bash
git clone https://github.com/berkeatalay1/vue-docs-dev.git
cd vue-docs-dev
```

2. (Optional) If you plan to make changes to the documentation, fork the Vue.js documentation repository and update the GIT_URL in `.env`:

3. Run the automated setup script:
```bash
./scripts/setup.sh
```

The setup script will:
- Clone the Vue.js v2 documentation repository
- Generate self-signed SSL certificates
- Set up Docker containers
- Install all dependencies
- Configure Docker permissions (on Linux, you may need to log out and back in)
- Start the development environment

> ⚠️ **Important Note for Linux Users**: After running the setup script, you will need to **log out and log back in** to your system for Docker permissions to take effect. Without this step, you may encounter permission errors when running Docker commands.

## Architecture

The development environment consists of two Docker containers:

1. **App Container (Vue.js)**
   - Node.js 18 environment
   - Runs Vue.js development server
   - Handles hot-reload functionality
   - Builds static files to shared volume

2. **Nginx Container**
   - Serves static content
   - Handles SSL termination
   - Provides reverse proxy to development server
   - Manages both HTTP and HTTPS traffic

### Port Configuration

| Service | HTTP Port | HTTPS Port | Purpose |
|---------|-----------|------------|----------|
| Development Server | 4000 | 4443 | Hot-reload development |
| Static Content | 8080 | 8443 | Production build |

### Architecture Diagram

![Architecture Diagram](/docs/architecture.drawio.png)

## Development Workflow

### Starting/Stopping Environment

```bash
# Start containers
docker-compose up -d

# View logs
docker-compose logs -f

# Stop containers
docker-compose down
```

### Rebuilding Static Content

After making changes to the documentation:
```bash
./scripts/rebuild.sh
```

### Access Points

1. Development Server (with Hot Reload):
   - HTTP: http://localhost:4000
   - HTTPS: https://localhost:4443 

2. Static Content (Production Build):
   - HTTP: http://localhost:8080
   - HTTPS: https://localhost:8443

Note: Browser security warnings for HTTPS are normal due to self-signed certificates in development.

## Project Structure

```
.
├── docker/
│   ├── app/                 # App container configuration
│   │   ├── Dockerfile      # Node.js container setup
│   │   └── start.sh        # Container startup script
│   └── nginx/              # Nginx container configuration
│       ├── Dockerfile      # Nginx container setup
│       ├── nginx.conf      # Nginx server configuration
│       └── certs/          # SSL certificates
├── scripts/
│   ├── setup.sh            # Initial environment setup
│   ├── rebuild.sh          # Static content rebuild
│   └── update-deps.sh      # Dependency updates
├── src/                    # Documentation source code
├── .env                    # Environment configuration
├── docker-compose.yml      # Container orchestration
└── README.md
```

## Configuration

### Environment Variables (.env)

- `GIT_URL`: Vue.js documentation repository URL
- `NGINX_PORT`: HTTP port for static content (default: 8080)
- `NGINX_SSL_PORT`: HTTPS port for static content (default: 8443)
- `DEV_PORT`: Development server port (default: 4000)
- `APP_SSL_PORT`: HTTPS development port (default: 4443)

## Utility Scripts

- `scripts/setup.sh`: One-time setup script
  - Initializes development environment
  - Generates SSL certificates
  - Sets up Docker containers

- `scripts/rebuild.sh`: Rebuilds static content
  - Compiles documentation
  - Updates production build

- `scripts/update-deps.sh`: Updates project dependencies

## SSL Certificates

Development SSL certificates are automatically generated in `docker/nginx/certs/`:
- `nginx-selfsigned.crt`: Self-signed certificate
- `nginx-selfsigned.key`: Private key

For production deployment, replace these with valid SSL certificates.

## Troubleshooting

### Common Issues

1. Port conflicts:
```bash
# Check port usage
sudo lsof -i :<port>
# Adjust ports in .env if needed
```

2. SSL certificate issues:
```bash
# Regenerate certificates
./scripts/setup.sh
docker-compose restart nginx
```

3. Permission problems (Linux):
```bash
# Fix source directory permissions
sudo chown -R $USER:$USER src/
```