#!/bin/bash
# ──────────────────────────────────────────────────────────────────────
# 🛑 Stop All Services
# ──────────────────────────────────────────────────────────────────────

echo "🛑 Stopping all services..."
docker-compose \
  -f docker-compose.yml \
  -f docker-compose.sonarr.yml \
  -f docker-compose.radarr.yml \
  -f docker-compose.lidarr.yml \
  -f docker-compose.prowlarr.yml \
  -f docker-compose.readarr.yml \
  -f docker-compose.bazarr.yml \
  -f docker-compose.homepage.yml \
  -f docker-compose.recyclarr.yml \
  -f docker-compose.unpackerr.yml \
  down

echo "✅ All services stopped!"
