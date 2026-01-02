# 🏰 Modular Media Stack with ProtonVPN (WireGuard)

**A fully modular Docker-based media automation stack secured with ProtonVPN. Choose only the services you need.**

---

## 📌 Table of Contents

1. [Overview](#overview)
2. [Features](#features)
3. [Architecture](#architecture)
4. [Prerequisites](#prerequisites)
5. [Quick Start](#quick-start)
6. [Modular Service Selection](#modular-service-selection)
7. [Configuration](#configuration)
8. [Accessing Services](#accessing-services)
9. [Directory Structure](#directory-structure)
10. [Security Best Practices](#security-best-practices)
11. [Troubleshooting](#troubleshooting)
12. [Advanced Usage](#advanced-usage)
13. [Contributing](#contributing)
14. [License](#license)

---

## 🔹 Overview

This project provides a **fully modular media automation stack** running securely behind **ProtonVPN (WireGuard)** using **Gluetun**.

**Key Innovation**: Each service is completely modular - enable only what you need, when you need it.

### Core Services (Always Available)
- **Gluetun** - VPN container ensuring all traffic is routed securely
- **qBittorrent** - Torrent client with automatic port forwarding
- **Watchtower** - Automatic container updates

### Optional Arr Stack (Modular)
- **Sonarr** - TV series automation
- **Radarr** - Movie automation
- **Lidarr** - Music automation
- **Prowlarr** - Indexer management for all *arr apps
- **Readarr** - Book and audiobook automation
- **Bazarr** - Subtitle automation

---

## ✅ Features

- **🔒 VPN-Enforced Security** - All services route through ProtonVPN (WireGuard)
- **🧩 Fully Modular** - Each Arr app is independent - use what you need
- **⚡ Auto Port Forwarding** - Automatic qBittorrent port configuration
- **🌐 Web UI Access** - Easy browser-based management
- **📦 Containerized** - Docker ensures isolation and easy deployment
- **🔄 Auto-Updates** - Watchtower keeps containers current
- **📂 Organized Storage** - Separate directories for different media types
- **🛡️ Privacy-First** - All torrent traffic encrypted through VPN

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                        Gluetun (VPN)                        │
│                     ProtonVPN WireGuard                     │
│                                                             │
│  ┌──────────────┐  ┌──────────┐  ┌─────────────────────┐  │
│  │ qBittorrent  │  │  Sonarr  │  │      Prowlarr       │  │
│  │   :8080      │  │  :8989   │  │       :9696         │  │
│  └──────────────┘  └──────────┘  └─────────────────────┘  │
│                                                             │
│  ┌──────────────┐  ┌──────────┐  ┌──────────┐            │
│  │   Radarr     │  │  Lidarr  │  │  Readarr │            │
│  │   :7878      │  │  :8686   │  │  :8787   │            │
│  └──────────────┘  └──────────┘  └──────────┘            │
│                                                             │
│  ┌──────────────┐                                          │
│  │   Bazarr     │                                          │
│  │   :6767      │                                          │
│  └──────────────┘                                          │
└─────────────────────────────────────────────────────────────┘
         │
         ├─── All traffic encrypted through VPN
         └─── No IP leaks possible
```

**How It Works:**
- Gluetun establishes VPN connection
- All other services use `network_mode: "service:gluetun"`
- Services cannot access the internet without VPN
- Ports are exposed through Gluetun's network namespace

---

## 🛠️ Prerequisites

- **Docker Desktop** (macOS/Windows/Linux) - [Download here](https://www.docker.com/products/docker-desktop/)
- **Docker Compose** (included with Docker Desktop)
- **ProtonVPN Account** (Plus or Visionary for WireGuard support)
- **Basic terminal knowledge**

---

## 🚀 Quick Start

### 1️⃣ Clone the Repository

```bash
git clone https://github.com/torrentsec/qbittorrent-protonvpn-docker.git
cd qbittorrent-protonvpn-docker
```

### 2️⃣ Create Your Environment File

```bash
cp .env.example .env
nano .env  # or use your preferred editor
```

Fill in your ProtonVPN credentials and settings:

```ini
# ProtonVPN Configuration
WIREGUARD_PRIVATE_KEY=your_private_key_here
SERVER_COUNTRIES="United Kingdom"
SERVER_CITIES="London"

# User Settings
PUID=1000  # Run 'id $USER' to find yours
PGID=1000
TZ=Europe/London

# Gluetun API
GLUETUN_USER=admin
GLUETUN_PASS=your_secure_password

# Port Forwarding
GSP_GTN_API_KEY=your_random_api_key
GSP_QBITTORRENT_PORT=53764
```

### 3️⃣ Choose Your Services

**Option A: Base Services Only (Gluetun + qBittorrent)**
```bash
./start-base.sh
# OR manually:
docker-compose -f docker-compose.yml up -d
```

**Option B: Full Media Stack (Everything)**
```bash
./start-all.sh
# OR manually:
docker-compose -f docker-compose.yml \
  -f docker-compose.sonarr.yml \
  -f docker-compose.radarr.yml \
  -f docker-compose.lidarr.yml \
  -f docker-compose.prowlarr.yml \
  -f docker-compose.readarr.yml \
  -f docker-compose.bazarr.yml \
  up -d
```

**Option C: Media Essentials (TV + Movies + Indexer)**
```bash
./start-media.sh
# OR manually:
docker-compose -f docker-compose.yml \
  -f docker-compose.sonarr.yml \
  -f docker-compose.radarr.yml \
  -f docker-compose.prowlarr.yml \
  -f docker-compose.bazarr.yml \
  up -d
```

---

## 🧩 Modular Service Selection

Each Arr service is in its own compose file. Mix and match as needed:

### Available Modules

| Service | File | Description | Web UI |
|---------|------|-------------|--------|
| **Sonarr** | `docker-compose.sonarr.yml` | TV series automation | `:8989` |
| **Radarr** | `docker-compose.radarr.yml` | Movie automation | `:7878` |
| **Lidarr** | `docker-compose.lidarr.yml` | Music automation | `:8686` |
| **Prowlarr** | `docker-compose.prowlarr.yml` | Indexer manager | `:9696` |
| **Readarr** | `docker-compose.readarr.yml` | Book automation | `:8787` |
| **Bazarr** | `docker-compose.bazarr.yml` | Subtitle automation | `:6767` |

### Custom Combinations

**Example: TV Shows Only**
```bash
docker-compose -f docker-compose.yml -f docker-compose.sonarr.yml -f docker-compose.prowlarr.yml up -d
```

**Example: Movies + Music**
```bash
docker-compose -f docker-compose.yml -f docker-compose.radarr.yml -f docker-compose.lidarr.yml -f docker-compose.prowlarr.yml up -d
```

**Example: Add a Single Service to Running Stack**
```bash
docker-compose -f docker-compose.yml -f docker-compose.bazarr.yml up -d
```

**Example: Remove a Service**
```bash
docker-compose -f docker-compose.yml -f docker-compose.radarr.yml down
```

---

## ⚙️ Configuration

### Getting ProtonVPN WireGuard Credentials

1. Log into [ProtonVPN Account](https://account.protonvpn.com/)
2. Go to **Downloads** → **WireGuard configuration**
3. Select a server and download the config
4. Extract your **private key** from the config file
5. Add it to your `.env` file

### Setting PUID and PGID

```bash
id $USER
```

This shows your user ID (PUID) and group ID (PGID). Update `.env` accordingly.

### Custom Port Configuration

All ports are exposed through Gluetun in `docker-compose.yml:51-58`. The default ports are:

- qBittorrent: `8080`
- Sonarr: `8989`
- Radarr: `7878`
- Lidarr: `8686`
- Prowlarr: `9696`
- Readarr: `8787`
- Bazarr: `6767`

To change a port, edit the port mapping in `docker-compose.yml`:
```yaml
ports:
  - "9090:8080"  # Change qBittorrent to port 9090
```

---

## 📺 Accessing Services

Once running, access your services at:

| Service | URL | Default Credentials |
|---------|-----|---------------------|
| **qBittorrent** | http://localhost:8080 | admin / *check logs* |
| **Sonarr** | http://localhost:8989 | *Set during first launch* |
| **Radarr** | http://localhost:7878 | *Set during first launch* |
| **Lidarr** | http://localhost:8686 | *Set during first launch* |
| **Prowlarr** | http://localhost:9696 | *Set during first launch* |
| **Readarr** | http://localhost:8787 | *Set during first launch* |
| **Bazarr** | http://localhost:6767 | *Set during first launch* |

### First-Time qBittorrent Login

The password is randomly generated. View it with:
```bash
docker logs qbittorrent 2>&1 | grep "temporary password"
```

**⚠️ Important**: Change the password immediately after first login, or it will regenerate on every restart.

---

## 📂 Directory Structure

```
qbittorrent-protonvpn-docker/
├── docker-compose.yml              # Base services
├── docker-compose.sonarr.yml       # Sonarr module
├── docker-compose.radarr.yml       # Radarr module
├── docker-compose.lidarr.yml       # Lidarr module
├── docker-compose.prowlarr.yml     # Prowlarr module
├── docker-compose.readarr.yml      # Readarr module
├── docker-compose.bazarr.yml       # Bazarr module
├── .env                            # Your credentials (gitignored)
├── .env.example                    # Template for .env
├── start-all.sh                    # Start all services
├── start-base.sh                   # Start base services only
├── start-media.sh                  # Start media essentials
├── stop-all.sh                     # Stop all services
├── gluetun/                        # VPN config (auto-created)
├── qbittorrent/                    # qBittorrent config
├── sonarr/                         # Sonarr config (if enabled)
├── radarr/                         # Radarr config (if enabled)
├── lidarr/                         # Lidarr config (if enabled)
├── prowlarr/                       # Prowlarr config (if enabled)
├── readarr/                        # Readarr config (if enabled)
├── bazarr/                         # Bazarr config (if enabled)
├── downloads/                      # Completed downloads
├── incomplete/                     # In-progress downloads
└── media/
    ├── tv/                         # TV shows
    ├── movies/                     # Movies
    ├── music/                      # Music
    └── books/                      # Books & audiobooks
```

---

## 🛡️ Security Best Practices

### 1. Verify VPN Connection

Always verify traffic is routed through VPN:

```bash
docker exec -it qbittorrent curl ifconfig.me
```

✅ Should show ProtonVPN IP, **not** your real IP.

### 2. Secure Your Environment File

```bash
chmod 600 .env  # Only you can read/write
```

Never commit `.env` to git (already in `.gitignore`).

### 3. Use Strong Passwords

Set strong passwords for:
- Gluetun API (`GLUETUN_PASS`)
- All Arr service Web UIs
- qBittorrent Web UI

### 4. Enable Authentication

All services should require login. Configure authentication in each service's settings.

### 5. Keep Containers Updated

Watchtower handles this automatically, but you can manually update:

```bash
docker-compose pull
docker-compose up -d
```

---

## 🛠️ Troubleshooting

### VPN Not Connecting

**Check Gluetun logs:**
```bash
docker logs -f gluetun
```

**Common issues:**
- Invalid `WIREGUARD_PRIVATE_KEY`
- ProtonVPN subscription doesn't support WireGuard
- Server country/city doesn't exist

**Fix:** Verify credentials in `.env` and ensure you have ProtonVPN Plus or higher.

---

### Service Not Accessible

**Check if container is running:**
```bash
docker ps
```

**Check if ports are exposed:**
```bash
docker port gluetun
```

**Check service logs:**
```bash
docker logs <container_name>
```

---

### IP Leak Detection

**Test from within qBittorrent:**
```bash
docker exec -it qbittorrent curl ifconfig.me
```

**Test from Sonarr:**
```bash
docker exec -it sonarr curl ifconfig.me
```

Both should show your VPN IP, not your real IP.

---

### Permission Issues

If you see permission denied errors:

```bash
# Find your IDs
id $USER

# Update .env with correct PUID and PGID
# Then recreate containers
docker-compose down
docker-compose up -d
```

---

### Port Forwarding Not Working

**Check if port forwarding is enabled:**
```bash
docker logs gluetun | grep -i "port forwarding"
```

**Verify qBittorrent is using the forwarded port:**
1. Open qBittorrent Web UI
2. Go to **Settings** → **Connection**
3. Check if port matches `GSP_QBITTORRENT_PORT`

---

### Containers Keep Restarting

**Check health status:**
```bash
docker ps -a
```

**View logs for errors:**
```bash
docker logs <failing_container>
```

**Common fix - restart everything:**
```bash
./stop-all.sh
./start-all.sh  # or your preferred combo
```

---

## 🎯 Advanced Usage

### Using Docker Compose Manually

**Start specific services:**
```bash
docker-compose -f docker-compose.yml -f docker-compose.sonarr.yml up -d
```

**Stop all services:**
```bash
docker-compose -f docker-compose.yml -f docker-compose.sonarr.yml -f docker-compose.radarr.yml down
```

**View logs:**
```bash
docker-compose logs -f sonarr
```

**Rebuild containers:**
```bash
docker-compose up -d --force-recreate
```

---

### Setting Up Prowlarr with Other Services

1. Start Prowlarr and your desired Arr apps
2. Access Prowlarr at http://localhost:9696
3. Go to **Settings** → **Apps**
4. Add Sonarr/Radarr/Lidarr/Readarr
   - **Name:** Service name
   - **Sync Level:** Full Sync
   - **Prowlarr Server:** http://localhost:9696
   - **App Server:** http://localhost:8989 (for Sonarr)
   - **API Key:** Found in each service's settings

---

### Configuring Download Paths

In each Arr service:

1. Go to **Settings** → **Media Management**
2. Set **Root Folder:**
   - Sonarr: `/tv`
   - Radarr: `/movies`
   - Lidarr: `/music`
   - Readarr: `/books`

3. Add qBittorrent as download client:
   - **Settings** → **Download Clients** → **Add** → **qBittorrent**
   - **Host:** `localhost`
   - **Port:** `8080`
   - **Username/Password:** Your qBittorrent credentials
   - **Category:** (e.g., "tv", "movies", etc.)

---

### Resource Management

To limit container resources, uncomment the `deploy` sections in each compose file:

```yaml
deploy:
  resources:
    limits:
      memory: 1G
      cpus: '0.5'
```

---

### Backup Configuration

**Backup all configs:**
```bash
tar -czf backup-$(date +%Y%m%d).tar.gz \
  qbittorrent/ sonarr/ radarr/ lidarr/ \
  prowlarr/ readarr/ bazarr/ gluetun/ .env
```

**Restore:**
```bash
tar -xzf backup-20260102.tar.gz
```

---

## 💪 Contributing

Contributions are welcome!

**Ideas for contributions:**
- Additional Arr services (Whisparr, Mylar, etc.)
- Alternative VPN providers
- Reverse proxy integration (Traefik/Nginx Proxy Manager)
- Monitoring stack (Prometheus/Grafana)
- Notification services

**To contribute:**
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

---

## 💎 License

This project is licensed under the **MIT License**.

---

## 🌟 Support

- ⭐ **Star this repo** if you find it useful!
- 🐛 **Report issues** on GitHub
- 💡 **Suggest features** via Issues
- 📖 **Improve docs** via Pull Requests

---

## 📚 Related Projects

- [Gluetun](https://github.com/qdm12/gluetun) - VPN client in a thin Docker container
- [qBittorrent](https://www.qbittorrent.org/) - Free and open-source torrent client
- [Servarr](https://wiki.servarr.com/) - Official wiki for all *arr applications
- [TRaSH Guides](https://trash-guides.info/) - Comprehensive guides for the Arr stack

---

**Built with ❤️ by the community**
