#!/bin/bash
# ──────────────────────────────────────────────────────────────────────
# 🚀 Start All Services (Base + Full Arr Stack)
# ──────────────────────────────────────────────────────────────────────

echo "🚀 Starting all services..."
docker-compose \
  -f docker-compose.yml \
  -f docker-compose.sonarr.yml \
  -f docker-compose.radarr.yml \
  -f docker-compose.lidarr.yml \
  -f docker-compose.prowlarr.yml \
  -f docker-compose.readarr.yml \
  -f docker-compose.bazarr.yml \
  up -d

echo "✅ All services started!"
echo ""
echo "📺 Access your services at:"
echo "   - qBittorrent: http://localhost:8080"
echo "   - Sonarr:      http://localhost:8989"
echo "   - Radarr:      http://localhost:7878"
echo "   - Lidarr:      http://localhost:8686"
echo "   - Prowlarr:    http://localhost:9696"
echo "   - Readarr:     http://localhost:8787"
echo "   - Bazarr:      http://localhost:6767"
