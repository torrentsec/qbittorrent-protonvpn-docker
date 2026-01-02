#!/bin/bash
# ──────────────────────────────────────────────────────────────────────
# 🚀 Start Base + Essential Services (No Arr Stack)
# ──────────────────────────────────────────────────────────────────────

echo "🚀 Starting base + essential services..."
docker-compose \
  -f docker-compose.yml \
  -f docker-compose.homepage.yml \
  -f docker-compose.recyclarr.yml \
  -f docker-compose.unpackerr.yml \
  up -d

echo "✅ Essential services started!"
echo ""
echo "📺 Access your services at:"
echo "   - Homepage:    http://localhost:3000"
echo "   - qBittorrent: http://localhost:8080"
echo ""
echo "🔧 Background services running:"
echo "   - Recyclarr:   Auto-syncing TRaSH Guide profiles"
echo "   - Unpackerr:   Auto-extracting archives"
