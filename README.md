# 🏰 qBittorrent + ProtonVPN Docker Infrastructure

[![CI/CD](https://github.com/torrentsec/qbittorrent-protonvpn-docker/workflows/CI%2FCD%20Pipeline/badge.svg)](https://github.com/torrentsec/qbittorrent-protonvpn-docker/actions)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

**Production-grade infrastructure for running qBittorrent securely through
ProtonVPN with comprehensive monitoring, automated operations, and
enterprise-level best practices.**

## 🌟 Highlights

This is a **complete infrastructure-as-code** solution featuring:

- 🔒 **Zero-leak VPN enforcement** - qBittorrent physically cannot bypass VPN
- 📊 **Full observability stack** - Prometheus, Grafana, Loki monitoring
- 🤖 **Automated operations** - Makefile, backup/restore, CI/CD
- 🏗️ **Production-ready** - Security hardening, health checks, network segmentation
- 📚 **Comprehensive docs** - Architecture diagrams, ADRs, upgrade guides

---

## 📌 Table of Contents

1. [Features](#-features)
1. [Quick Start](#-quick-start)
1. [Architecture](#-architecture)
1. [Prerequisites](#-prerequisites)
1. [Installation](#-installation)
1. [Operations](#-operations)
1. [Monitoring](#-monitoring)
1. [Security](#-security)
1. [Troubleshooting](#-troubleshooting)
1. [Advanced Topics](#-advanced-topics)
1. [Contributing](#-contributing)
1. [License](#-license)

---

## ✨ Features

### Core Infrastructure

- ✅ **VPN-Enforced Torrenting** - All traffic through ProtonVPN WireGuard
- ✅ **Automatic Port Forwarding** - Synced with ProtonVPN for optimal speeds
- ✅ **Network Segmentation** - Separate VPN and monitoring networks
- ✅ **Health Checks** - Automated service health monitoring
- ✅ **Auto-restart** - Resilient container orchestration
- ✅ **Version Pinning** - Reproducible deployments

### Monitoring & Observability

- 📊 **Prometheus** - Metrics collection and alerting
- 📈 **Grafana** - Beautiful dashboards and visualization
- 📝 **Loki + Promtail** - Centralized log aggregation
- 🐳 **cAdvisor** - Container resource monitoring
- 🔔 **Alerting** - VPN failures, resource usage, container health

### Automation & Operations

- 🔧 **Makefile** - One-command operations (`make up`, `make backup`, etc.)
- 💾 **Backup/Restore** - Automated configuration and data backups
- 🔄 **Watchtower** - Automatic container updates
- 🧪 **CI/CD Pipeline** - GitHub Actions for validation and security scanning
- 🎣 **Pre-commit Hooks** - Prevent errors before they're committed

### Security & Compliance

- 🔒 **Security Hardening** - Minimal capabilities, no-new-privileges
- 🔍 **Vulnerability Scanning** - Trivy security scans in CI/CD
- 🛡️ **DNS over TLS** - Encrypted DNS queries
- 🚫 **Malware Blocking** - Gluetun built-in protection
- 🔐 **Secrets Management** - Environment-based configuration

### Documentation

- 📖 **Architecture Docs** - Comprehensive system design documentation
- 📝 **ADRs** - Architecture Decision Records
- 🔄 **Upgrade Guide** - Step-by-step migration instructions
- 🎓 **Operations Manual** - Complete usage documentation

---

## 🚀 Quick Start

### One-Command Setup

```bash
# Clone the repository
git clone https://github.com/torrentsec/qbittorrent-protonvpn-docker.git
cd qbittorrent-protonvpn-docker

# Initialize (creates .env from template)
make init

# Edit .env with your ProtonVPN credentials
nano .env

# Start everything
make up
```

### Access Services

- **qBittorrent Web UI**: [http://localhost:8080](http://localhost:8080)
- **Grafana Dashboard**: [http://localhost:3000](http://localhost:3000) (admin/admin)
- **Prometheus**: [http://localhost:9090](http://localhost:9090)
- **cAdvisor**: [http://localhost:8081](http://localhost:8081)

---

## 🏗️ Architecture

```text
┌─────────────────────────────────────────────────────────────────┐
│                         Docker Host                              │
│                                                                   │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │           VPN Network (172.20.0.0/16)                       │ │
│  │                                                              │ │
│  │  ┌──────────────┐         ┌──────────────┐                 │ │
│  │  │   Gluetun    │◄────────┤ qBittorrent  │                 │ │
│  │  │ (VPN Exit)   │         │  (Torrent)   │                 │ │
│  │  │ WireGuard    │         │ Shared NS    │                 │ │
│  │  └──────┬───────┘         └──────────────┘                 │ │
│  │         │                                                   │ │
│  │         ▼                                                   │ │
│  │    ProtonVPN                                               │ │
│  └────────────────────────────────────────────────────────────┘ │
│                                                                   │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │      Monitoring Network (172.21.0.0/16)                     │ │
│  │                                                              │ │
│  │  Prometheus │ Grafana │ Loki │ Promtail │ cAdvisor         │ │
│  └────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
```

**Key Design Decisions:**
- qBittorrent shares Gluetun's network namespace (zero-leak guarantee)
- Separate monitoring network for observability isolation
- Named volumes for persistent data
- Security-first approach with minimal privileges

**Detailed documentation**: See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md)

---

## 🛠️ Prerequisites

### Required

- **Docker Engine** 20.10.0+ ([Install Docker](https://docs.docker.com/get-docker/))
- **Docker Compose** 2.0.0+ (bundled with Docker Desktop)
- **ProtonVPN Account** (Plus/Unlimited for WireGuard + port forwarding)

### Optional

- **Make** (pre-installed on macOS/Linux, [install on Windows](https://gnuwin32.sourceforge.net/packages/make.htm))
- **Pre-commit** (`pip install pre-commit`) for development
- **Git** for version control

### System Requirements

- **RAM**: 2GB minimum (4GB recommended with monitoring)
- **Disk**: 5GB free space
- **OS**: Linux, macOS, or Windows with WSL2

---

## 📦 Installation

### Step 1: Clone Repository

```bash
git clone https://github.com/torrentsec/qbittorrent-protonvpn-docker.git
cd qbittorrent-protonvpn-docker
```

### Step 2: Initialize Project

```bash
make init
```

This will:

- Check Docker and Docker Compose are installed
- Create `.env` from `.env.example`
- Create required directories

### Step 3: Configure Environment

Edit `.env` with your credentials:

```bash
nano .env  # or use your preferred editor
```

**Essential variables:**

```ini
# ProtonVPN WireGuard private key
# (get from https://account.protonvpn.com/downloads)
WIREGUARD_PRIVATE_KEY=your_private_key_here

# VPN server location
SERVER_COUNTRIES=Netherlands
SERVER_CITIES=Amsterdam

# User settings
PUID=1000  # Run: id -u
PGID=1000  # Run: id -g
TZ=America/New_York

# API key for port sync (generate: openssl rand -hex 32)
GSP_GTN_API_KEY=your_random_api_key_here

# Monitoring credentials
GRAFANA_USER=admin
GRAFANA_PASSWORD=your_secure_password
```

### Step 4: Validate Configuration

```bash
make validate
```

### Step 5: Start Infrastructure

```bash
make up
```

### Step 6: Verify VPN Connection

```bash
make test-vpn
make test-qbittorrent
```

Both should show your ProtonVPN IP, **not** your real IP.

---

## 🎮 Operations

### Daily Operations

```bash
make status        # Check all services
make logs          # View all logs
make logs-gluetun  # View VPN logs only
make monitoring    # Show monitoring URLs
```

### Lifecycle Management

```bash
make up            # Start all services
make down          # Stop all services
make restart       # Restart all services
make rebuild       # Rebuild and restart
make pull          # Pull latest images
make update        # Update all containers
```

### Backup & Restore

```bash
make backup        # Create timestamped backup
make restore       # Restore from backup (interactive)
```

Backups include:

- All configurations
- Docker volumes
- Environment settings (sanitized)

### Testing & Validation

```bash
make validate      # Validate docker-compose.yml
make test-vpn      # Test VPN connection
make security      # Run security scans (requires Trivy)
make lint          # Lint configurations
```

### Maintenance

```bash
make clean         # Stop and remove volumes (dangerous!)
make clean-logs    # Remove log files
make prune         # Clean up Docker system
```

### Development

```bash
make dev           # Quick start for development
make shell-gluetun      # Shell into Gluetun
make shell-qbittorrent  # Shell into qBittorrent
```

### Help

```bash
make help          # Show all available commands
```

---

## 📊 Monitoring

### Grafana Dashboards

Access Grafana at [http://localhost:3000](http://localhost:3000)

**Default credentials**: admin / admin (change on first login)

**Pre-configured datasources:**

- Prometheus (metrics)
- Loki (logs)

**Recommended dashboards to import:**

- Docker Container Monitoring: ID 893
- cAdvisor Exporter: ID 14282
- Loki Dashboard: ID 13639

### Prometheus Metrics

Access Prometheus at [http://localhost:9090](http://localhost:9090)

**Available metrics:**

- Container CPU/Memory/Network usage
- VPN connection status
- Disk I/O and space usage
- Service health checks

**Pre-configured alerts:**

- VPN connection down
- Container failures
- High resource usage
- Low disk space

### Logs

**View in Grafana:**

1. Go to Explore
1. Select "Loki" datasource
1. Use LogQL queries

**Example queries:**

```logql
{container="gluetun"}
{container="qbittorrent"} |= "error"
{job="docker"} | json | status >= 400
```

### cAdvisor

Access cAdvisor at [http://localhost:8081](http://localhost:8081)

Real-time container resource usage and performance metrics.

---

## 🔒 Security

### VPN Leak Prevention

This setup provides **multiple layers** of leak prevention:

1. **Network Namespace Sharing**: qBittorrent shares Gluetun's network, physically preventing direct internet access
1. **Firewall Rules**: Gluetun's built-in firewall blocks non-VPN traffic
1. **IPv6 Disabled**: Prevents IPv6 leaks
1. **DNS over TLS**: Encrypted DNS queries via Cloudflare
1. **Health Checks**: Automatic VPN connection monitoring

### Container Security

- **No-new-privileges**: Prevents privilege escalation
- **Minimal capabilities**: Only NET_ADMIN for VPN
- **Read-only mounts**: Where possible
- **Non-root users**: Services run as specified PUID/PGID
- **Network isolation**: Segmented networks

### Secrets Management

- **Environment variables**: Sensitive data in `.env`
- **Git-ignored**: `.env` never committed
- **Pre-commit hooks**: Prevent accidental secret commits
- **Validation**: Checks for proper configuration

### Vulnerability Scanning

```bash
make security  # Run Trivy scans
```

CI/CD pipeline automatically scans:

- Docker images for CVEs
- Repository for secrets
- Configuration for issues

### Best Practices

1. **Change default passwords** (Grafana, qBittorrent)
1. **Use strong API keys** (`openssl rand -hex 32`)
1. **Keep containers updated** (Watchtower handles this)
1. **Regular backups** (`make backup`)
1. **Monitor alerts** (check Grafana)

---

## 🔧 Troubleshooting

### VPN Not Connecting

```bash
# Check Gluetun logs
make logs-gluetun

# Common issues:
# - Incorrect WIREGUARD_PRIVATE_KEY
# - Invalid SERVER_COUNTRIES
# - ProtonVPN subscription level (need Plus/Unlimited)
```

### qBittorrent Can't Download

```bash
# Verify VPN routing
make test-qbittorrent

# Should show ProtonVPN IP, not your real IP
# If showing real IP, VPN is not working
```

### Port Not Forwarded

```bash
# Check Gluetun logs for port forwarding
docker logs gluetun | grep "port forward"

# Ensure VPN_PORT_FORWARDING=on in docker-compose.yml
```

### High Resource Usage

```bash
# Check resource usage
make status

# View detailed metrics at cAdvisor
# Open http://localhost:8081
```

**To reduce resource usage:**

- Disable monitoring stack (comment out in docker-compose.yml)
- Reduce Prometheus retention (edit monitoring/prometheus/prometheus.yml)
- Limit container resources (add `deploy.resources.limits`)

### Container Won't Start

```bash
# Check all logs
make logs

# Rebuild containers
make rebuild

# Check Docker resource allocation
docker system df
```

### Lost Grafana Password

```bash
# Reset Grafana admin password
docker exec -it grafana grafana-cli admin reset-admin-password newpassword
```

### Backup Failed

```bash
# Check disk space
df -h

# Check backup directory permissions
ls -la backups/

# Manual backup
./scripts/backup.sh
```

---

## 📚 Advanced Topics

### Custom Grafana Dashboards

1. Create dashboard in Grafana UI
1. Export as JSON
1. Save to `monitoring/grafana/dashboards/`
1. Restart Grafana: `docker-compose restart grafana`

### Adding Alerts

Edit `monitoring/prometheus/alerts.yml`:

```yaml
- alert: HighDownloadSpeed
  expr: rate(container_network_receive_bytes_total{name="qbittorrent"}[5m]) > 100000000
  for: 5m
  labels:
    severity: info
  annotations:
    summary: "High download speed detected"
```

Reload: `docker exec prometheus kill -HUP 1`

### Resource Limits

Add to docker-compose.yml:

```yaml
services:
  qbittorrent:
    deploy:
      resources:
        limits:
          cpus: '2.0'
          memory: 2G
        reservations:
          memory: 512M
```

### Multiple VPN Locations

Create multiple Gluetun services with different server configurations.

### Customizing Networks

Edit subnet ranges in docker-compose.yml:

```yaml
networks:
  vpn_network:
    ipam:
      config:
        - subnet: 172.30.0.0/16  # Custom range
```

### External Access (Advanced)

**Not recommended** for security, but possible via reverse proxy:

- Use Nginx Proxy Manager or Traefik
- Add authentication layer
- Use HTTPS with Let's Encrypt
- Consider VPN + authentication

---

## 📖 Documentation

### Available Documentation

- **[Architecture](docs/ARCHITECTURE.md)** - System design and components
- **[Upgrade Guide](docs/UPGRADE_GUIDE.md)** - Migration from previous versions
- **[ADR 001](docs/adr/001-monitoring-stack.md)** - Monitoring stack decisions
- **[ADR 002](docs/adr/002-network-architecture.md)** - Network design
- **[ADR 003](docs/adr/003-infrastructure-as-code.md)** - IaC approach

### Learning Resources

- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Gluetun Wiki](https://github.com/qdm12/gluetun/wiki)
- [qBittorrent Documentation](https://github.com/qbittorrent/qBittorrent/wiki)
- [Prometheus Documentation](https://prometheus.io/docs/)
- [Grafana Documentation](https://grafana.com/docs/)

---

## 🤝 Contributing

Contributions are welcome! Please:

1. Fork the repository
1. Create a feature branch (`git checkout -b feature/amazing-feature`)
1. Install pre-commit hooks (`pre-commit install`)
1. Make your changes
1. Run tests (`make validate`)
1. Commit (`git commit -m 'Add amazing feature'`)
1. Push (`git push origin feature/amazing-feature`)
1. Open a Pull Request

### Development Setup

```bash
# Install development tools
pip install pre-commit

# Install hooks
pre-commit install

# Run all checks
pre-commit run --all-files
```

---

## 📄 License

This project is licensed under the **MIT License** - see the [LICENSE](LICENSE) file for details.

---

## 🌟 Acknowledgments

- [Gluetun](https://github.com/qdm12/gluetun) by @qdm12 - Excellent VPN client
- [LinuxServer.io](https://www.linuxserver.io/) - qBittorrent container
- [ProtonVPN](https://protonvpn.com/) - Privacy-focused VPN provider
- All contributors and users of this project

---

## 💬 Support & Community

- 🐛 **Issues**: [GitHub Issues](https://github.com/torrentsec/qbittorrent-protonvpn-docker/issues)
- 💬 **Discussions**: [GitHub Discussions](https://github.com/torrentsec/qbittorrent-protonvpn-docker/discussions)
- ⭐ **Star** this repo if you find it helpful!
- 🍴 **Fork** to customize for your needs

---

## 🎯 Project Status

![GitHub last commit](https://img.shields.io/github/last-commit/torrentsec/qbittorrent-protonvpn-docker)
![GitHub issues](https://img.shields.io/github/issues/torrentsec/qbittorrent-protonvpn-docker)
![GitHub pull requests](https://img.shields.io/github/issues-pr/torrentsec/qbittorrent-protonvpn-docker)

- **Maintained**: Actively developed and maintained
- **Production Ready**: Suitable for production use
- **Well Documented**: Comprehensive documentation available

---

Made with ❤️ by the community
