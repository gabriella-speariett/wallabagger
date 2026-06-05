# Wallabagger

A self-hosted [Wallabag](https://www.wallabag.it/) instance with a Docker Compose setup, automated database initialization, and secure remote access via Cloudflare Tunnel.

## Overview

Wallabag is an open-source, self-hosted read-it-later application similar to Pocket or Instapaper. This repository provides a complete containerized deployment stack that includes:

- **Wallabag** - The main read-it-later application
- **PostgreSQL** - Database backend
- **Caddy** - Reverse proxy
- **Cloudflare Tunnel** - Secure remote access without exposing ports

## Architecture

```
┌─────────────────┐
│  Cloudflare     │
│  Tunnel         │
└────────┬────────┘
         │
┌────────▼────────┐
│  Caddy          │  (Port 80/443)
│  (Reverse Proxy)│
└────────┬────────┘
         │
┌────────▼────────────────┐
│  Wallabag               │  (Port 8080)
│  (Read-it-later app)    │
└────────┬────────────────┘
         │
┌────────▼────────────────┐
│  PostgreSQL             │
│  (Database)             │
└─────────────────────────┘
```

## Key Features & Tweaks

### Custom Setup Script
The `services/wallabag/setup.sh` handles several important initialization tasks:
- Waits for database to be healthy before starting Wallabag
- Automatically runs database migrations on startup
- Creates the default admin user if it doesn't exist
- Ensures proper file permissions for the `var` directory

## Prerequisites

- Docker and Docker Compose
- A domain name (for Caddy HTTP and Wallabag URL)
- (Optional) Cloudflare Tunnel token for remote access

## Quick Start

1. **Clone the repository:**
   ```bash
   git clone <repository-url>
   cd wallabagger
   ```

2. **Set up environment variables:**
   ```bash
   cp .env.example .env
   # Edit .env with your configuration (see below)
   ```

3. **Start the services:**
   ```bash
   docker compose up -d
   ```

4. **Access Wallabag:**
   Navigate to your configured `WALLABAG_URL` in a browser.

## Configuration

### Environment Variables

Copy `.env.example` to `.env` and configure the following variables:

| Variable | Description | Example |
|----------|-------------|---------|
| `WALLABAG_URL` | Public domain for Wallabag | `https://wallabag.example.com` |
| `WALLABAG_USER` | Admin username | `admin` |
| `WALLABAG_PASSWORD` | Admin password | (strong password) |
| `WALLABAG_DB_USER` | Wallabag database user | `wallabag` |
| `WALLABAG_DB_PASS` | Wallabag database password | (strong password) |
| `POSTGRES_PASSWORD` | PostgreSQL root password | (strong password) |
| `CLOUDFLARE_TUNNEL_TOKEN` | Cloudflare Tunnel authentication token | (from Cloudflare dashboard) |

### Domain Configuration

Update the `Caddyfile` at `infrastructure/caddy/conf/Caddyfile` with your domain:

```
http://your-domain.com {
  reverse_proxy wallabag
}
```

### Cloudflare Tunnel Setup

1. Create a tunnel in the [Cloudflare Dashboard](https://dash.cloudflare.com/)
2. Copy the tunnel token
3. Set `CLOUDFLARE_TUNNEL_TOKEN` in your `.env` file

## Volumes

- `db_data` - PostgreSQL database files
- `caddy_data` - Caddy data (certificates, etc.)
- `caddy_config` - Caddy configuration
- `wallabag_images` - Wallabag image assets
