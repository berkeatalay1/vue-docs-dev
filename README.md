# Vue.js Documentation Development Environment

This repository contains a containerized development environment for the Vue.js v2 documentation site.

## Prerequisites

- Docker
- Docker Compose
- Git

## Quick Start

1. Clone this repository:
```bash
git clone <your-repo-url>
cd <repo-name>
```

2. Run the automated setup script:
```bash
./scripts/setup.sh
```

The setup script will:
- Clone the Vue.js v2 documentation repository
- Set up Docker containers
- Install all dependencies
- Configure Docker permissions (on Linux, you may need to log out and back in)
- Start the development environment

## Architecture

The development environment consists of two Docker containers:
1. **App Container**: Node.js 18 container running the Vue.js documentation application
2. **Web Server Container**: Nginx container serving the application

## Development

The `setup.sh` script is used for initial setup only. After the initial setup:

To start the environment:
```bash
docker-compose up -d
```

To stop the environment:
```bash
docker-compose down
```

To rebuild the static files after making changes:
```bash
./scripts/rebuild.sh
```

You can access the documentation in multiple ways:

1. Development Server (Hot Reload):
   - http://localhost:4000

2. Production Build:
   - HTTP: http://localhost:8080
   - HTTPS: https://localhost:8443

Note: When accessing via HTTPS, you may see a security warning because we're using a self-signed certificate. This is normal for local development.

## Directory Structure

```
.
├── docker/
│   ├── app/
│   │   └── Dockerfile
│   └── nginx/
│       ├── Dockerfile
│       └── nginx.conf
├── scripts/
│   └── setup.sh
├── docker-compose.yml
└── README.md
```

## Scripts

- `scripts/setup.sh`: Main setup script that initializes the development environment
- `scripts/rebuild.sh`: Rebuilds the static files and updates the production build
