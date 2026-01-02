#!/bin/bash
# ──────────────────────────────────────────────────────────────────────
# 🚀 Start Base Services Only (Gluetun + qBittorrent + Watchtower)
# ──────────────────────────────────────────────────────────────────────

echo "🚀 Starting base services..."
docker-compose -f docker-compose.yml up -d

echo "✅ Base services started!"
echo ""
echo "📺 Access qBittorrent at: http://localhost:8080"
