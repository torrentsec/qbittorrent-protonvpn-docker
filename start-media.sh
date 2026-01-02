#!/bin/bash
# ──────────────────────────────────────────────────────────────────────
# 🚀 Start Media Stack (Base + Sonarr + Radarr + Prowlarr + Bazarr)
# ──────────────────────────────────────────────────────────────────────

echo "🚀 Starting media stack..."
docker-compose \
  -f docker-compose.yml \
  -f docker-compose.sonarr.yml \
  -f docker-compose.radarr.yml \
  -f docker-compose.prowlarr.yml \
  -f docker-compose.bazarr.yml \
  up -d

echo "✅ Media stack started!"
echo ""
echo "📺 Access your services at:"
echo "   - qBittorrent: http://localhost:8080"
echo "   - Sonarr:      http://localhost:8989"
echo "   - Radarr:      http://localhost:7878"
echo "   - Prowlarr:    http://localhost:9696"
echo "   - Bazarr:      http://localhost:6767"
