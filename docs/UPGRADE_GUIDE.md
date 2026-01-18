# 🔄 Upgrade Guide

## Overview

This guide helps you upgrade from the basic setup to the advanced infrastructure implementation.

## What's New

### Infrastructure Improvements
- ✅ Production-grade Docker Compose v3.9 configuration
- ✅ Advanced network segmentation (VPN + Monitoring networks)
- ✅ Version pinning for all images (reproducible builds)
- ✅ Enhanced security (capabilities, security-opt, firewalls)

### Monitoring & Observability
- ✅ Full Prometheus metrics stack
- ✅ Grafana dashboards
- ✅ Loki log aggregation
- ✅ cAdvisor container metrics
- ✅ Centralized logging with Promtail

### Operations & Automation
- ✅ Makefile for infrastructure automation
- ✅ Backup and restore scripts
- ✅ Pre-commit hooks for validation
- ✅ GitHub Actions CI/CD pipeline
- ✅ Security scanning (Trivy)

### Documentation
- ✅ Architecture documentation
- ✅ Architecture Decision Records (ADRs)
- ✅ Comprehensive README updates
- ✅ Upgrade guide (this document)

## Prerequisites

Before upgrading:
- Docker Engine 20.10.0+
- Docker Compose 2.0.0+
- At least 2GB free RAM (for monitoring stack)
- At least 5GB free disk space

Check your versions:
```bash
docker --version
docker-compose --version
```

## Backup Current Setup

**CRITICAL**: Always backup before upgrading!

```bash
# Stop containers
docker-compose down

# Backup current configuration
mkdir -p backup_$(date +%Y%m%d)
cp docker-compose.yml backup_$(date +%Y%m%d)/
cp .env backup_$(date +%Y%m%d)/
cp -r qbittorrent backup_$(date +%Y%m%d)/ 2>/dev/null || true

# Backup Docker volumes
docker run --rm \
  -v qbittorrent-protonvpn-docker_gluetun-config:/source \
  -v $(pwd)/backup_$(date +%Y%m%d):/backup \
  alpine tar czf /backup/gluetun-volume.tar.gz -C /source .

docker run --rm \
  -v qbittorrent-protonvpn-docker_qbittorrent-config:/source \
  -v $(pwd)/backup_$(date +%Y%m%d):/backup \
  alpine tar czf /backup/qbittorrent-volume.tar.gz -C /source .

echo "Backup complete in backup_$(date +%Y%m%d)/"
```

## Upgrade Steps

### Step 1: Pull Latest Changes

```bash
git fetch origin
git checkout claude-vibe-dev
git pull origin claude-vibe-dev
```

### Step 2: Review New Configuration

```bash
# Compare your .env with new .env.example
diff .env .env.example

# Review new variables
cat .env.example
```

### Step 3: Update Environment Variables

Add new variables to your `.env`:

```bash
# New monitoring variables
GRAFANA_USER=admin
GRAFANA_PASSWORD=your_secure_password_here
LOG_LEVEL=info

# New storage configuration (optional)
DOWNLOADS_PATH=./downloads
INCOMPLETE_PATH=./incomplete

# New VPN variable
VPN_FORWARDED_PORT=0
```

### Step 4: Create Required Directories

```bash
mkdir -p monitoring/{prometheus,grafana/{provisioning/{datasources,dashboards},dashboards},loki,promtail}
mkdir -p scripts downloads incomplete
```

### Step 5: Validate New Configuration

```bash
# Check if Makefile works
make help

# Validate docker-compose
make validate

# Or manually:
docker-compose config > /dev/null && echo "✓ Valid" || echo "✗ Invalid"
```

### Step 6: Stop Old Setup

```bash
# Stop all containers
docker-compose down

# Optional: Remove old networks
docker network rm qbittorrent-protonvpn-docker_default 2>/dev/null || true
```

### Step 7: Start New Setup

```bash
# Start with new configuration
make up

# Or manually:
docker-compose up -d
```

### Step 8: Verify Services

```bash
# Check service status
make status

# View logs
make logs

# Test VPN connection
make test-vpn

# Test qBittorrent VPN routing
make test-qbittorrent
```

### Step 9: Access New Monitoring

Open in your browser:

- **qBittorrent**: <http://localhost:8080>
- **Grafana**: <http://localhost:3000> (admin/your_password)
- **Prometheus**: <http://localhost:9090>
- **cAdvisor**: <http://localhost:8081>

## Post-Upgrade Configuration

### 1. Configure Grafana Dashboards

1. Login to Grafana (<http://localhost:3000>)
1. Go to Dashboards → Browse
1. Import community dashboards:
   - Docker monitoring: Dashboard ID 893
   - cAdvisor: Dashboard ID 14282

### 2. Setup Pre-commit Hooks (Optional)

```bash
# Install pre-commit
pip install pre-commit

# Install hooks
pre-commit install

# Run once to verify
pre-commit run --all-files
```

### 3. Configure Alerts (Optional)

Edit `monitoring/prometheus/alerts.yml` to customize alert thresholds.

### 4. Test Backup System

```bash
# Create test backup
make backup

# Verify backup created
ls -lh backups/
```

## Troubleshooting

### Containers Not Starting

```bash
# Check logs
docker-compose logs

# Check specific service
docker-compose logs gluetun
docker-compose logs qbittorrent
```

### Port Conflicts

If ports 3000, 8080, 8081, 9090, or 3100 are in use:

```bash
# Find what's using the port
sudo lsof -i :3000

# Modify docker-compose.yml to use different ports
# Example: "3001:3000" instead of "3000:3000"
```

### Network Issues

```bash
# Recreate networks
docker network prune
docker-compose up -d
```

### VPN Not Connecting

```bash
# Check Gluetun logs
docker-compose logs -f gluetun

# Verify .env has correct WIREGUARD_PRIVATE_KEY
cat .env | grep WIREGUARD
```

### qBittorrent Can't Access Internet

This is expected! qBittorrent should ONLY access internet through VPN.

```bash
# Verify VPN routing
docker exec qbittorrent curl -s https://ipinfo.io/json

# Should show ProtonVPN IP, not your real IP
```

### Monitoring Stack Using Too Much RAM

Reduce resource usage:

1. Edit `docker-compose.yml`
2. Add resource limits:

```yaml
services:
  prometheus:
    deploy:
      resources:
        limits:
          memory: 512M
```

3. Restart: `make restart`

### Prometheus Storage Full

Reduce retention:

```yaml
command:
  - '--storage.tsdb.retention.time=7d'  # Reduce from 30d
```

## Rollback Procedure

If you need to rollback:

```bash
# Stop new setup
docker-compose down

# Restore old docker-compose.yml
cp backup_YYYYMMDD/docker-compose.yml .

# Restore .env
cp backup_YYYYMMDD/.env .

# Restore volumes (if needed)
docker volume create qbittorrent-protonvpn-docker_gluetun-config
docker run --rm \
  -v qbittorrent-protonvpn-docker_gluetun-config:/target \
  -v $(pwd)/backup_YYYYMMDD:/backup \
  alpine tar xzf /backup/gluetun-volume.tar.gz -C /target

# Start old setup
docker-compose up -d
```

## Performance Considerations

### Resource Usage

New setup requires additional resources:

| Component | RAM | CPU | Disk |
|-----------|-----|-----|------|
| Gluetun | ~50MB | <5% | <100MB |
| qBittorrent | ~100MB | Varies | Varies |
| Prometheus | ~200MB | <10% | ~1GB/month |
| Grafana | ~100MB | <5% | ~100MB |
| Loki | ~50MB | <5% | ~500MB/month |
| Promtail | ~30MB | <5% | <50MB |
| cAdvisor | ~50MB | <5% | <50MB |
| Watchtower | ~20MB | <1% | <50MB |

**Total Additional**: ~500MB RAM, ~2GB disk

### Optimization Tips

1. **Disable monitoring** if not needed:
   ```bash
   # Comment out monitoring services in docker-compose.yml
   ```

2. **Reduce retention**:
   - Prometheus: 7 days instead of 30
   - Loki: 7 days instead of 31

3. **Disable Watchtower** for manual updates:
   ```yaml
   # Comment out watchtower service
   ```

## Feature Comparison

| Feature | Before | After |
|---------|--------|-------|
| Docker Compose Version | 3.x | 3.9 |
| Network Segmentation | No | Yes (2 networks) |
| Monitoring | No | Full stack |
| Logging | Docker only | Centralized (Loki) |
| Metrics | No | Prometheus + Grafana |
| Automation | Manual | Makefile |
| Backup/Restore | Manual | Automated scripts |
| CI/CD | No | GitHub Actions |
| Security Scanning | No | Trivy + pre-commit |
| Health Checks | Basic | Comprehensive |
| Documentation | Basic | Complete |

## Support

If you encounter issues:

1. Check troubleshooting section above
2. Review logs: `make logs`
3. Check GitHub Issues
4. Join community discussions

## Next Steps

After successful upgrade:

1. ✅ Explore Grafana dashboards
2. ✅ Setup regular backups: `crontab -e` → `0 2 * * * cd /path/to/project && make backup`
3. ✅ Configure alerts in Prometheus
4. ✅ Review security settings
5. ✅ Star the repository if helpful!

## Questions?

Check the documentation:
- `docs/ARCHITECTURE.md` - System design
- `docs/adr/` - Architecture decisions
- `make help` - Available commands
- GitHub Issues - Community support
