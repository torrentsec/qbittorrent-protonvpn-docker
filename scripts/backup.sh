#!/usr/bin/env bash
# ──────────────────────────────────────────────────────────────────────
# 💾 Backup Script for qBittorrent + ProtonVPN Infrastructure
# ──────────────────────────────────────────────────────────────────────
# Creates timestamped backups of configurations and important data
# ──────────────────────────────────────────────────────────────────────

set -euo pipefail

# Colors
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Configuration
BACKUP_DIR="./backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_NAME="qbittorrent-vpn-backup_${TIMESTAMP}"
BACKUP_PATH="${BACKUP_DIR}/${BACKUP_NAME}"

echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  qBittorrent + ProtonVPN Backup${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo ""

# Create backup directory
mkdir -p "${BACKUP_PATH}"

echo -e "${BLUE}Creating backup: ${BACKUP_NAME}${NC}"
echo ""

# Backup configurations
echo -e "${YELLOW}→${NC} Backing up configurations..."
cp -r ./monitoring "${BACKUP_PATH}/"
[ -f .env ] && cp .env "${BACKUP_PATH}/.env.backup"
cp docker-compose.yml "${BACKUP_PATH}/"
cp Makefile "${BACKUP_PATH}/"
echo -e "${GREEN}✓${NC} Configurations backed up"

# Backup qBittorrent config
if [ -d "./qbittorrent" ]; then
    echo -e "${YELLOW}→${NC} Backing up qBittorrent configuration..."
    cp -r ./qbittorrent "${BACKUP_PATH}/"
    echo -e "${GREEN}✓${NC} qBittorrent config backed up"
fi

# Backup Gluetun config
echo -e "${YELLOW}→${NC} Backing up Gluetun configuration..."
docker run --rm \
    -v qbittorrent-protonvpn-docker_gluetun-config:/source \
    -v "${PWD}/${BACKUP_PATH}:/backup" \
    alpine \
    sh -c "cd /source && tar czf /backup/gluetun-config.tar.gz ."
echo -e "${GREEN}✓${NC} Gluetun config backed up"

# Backup qBittorrent Docker volume
echo -e "${YELLOW}→${NC} Backing up qBittorrent Docker volume..."
docker run --rm \
    -v qbittorrent-protonvpn-docker_qbittorrent-config:/source \
    -v "${PWD}/${BACKUP_PATH}:/backup" \
    alpine \
    sh -c "cd /source && tar czf /backup/qbittorrent-docker-config.tar.gz ."
echo -e "${GREEN}✓${NC} qBittorrent volume backed up"

# Create metadata file
echo -e "${YELLOW}→${NC} Creating backup metadata..."
cat > "${BACKUP_PATH}/backup-info.txt" << EOF
Backup Created: $(date)
Hostname: $(hostname)
Docker Version: $(docker --version)
Docker Compose Version: $(docker-compose --version)
Backup Contents:
  - Configuration files
  - qBittorrent settings
  - Gluetun VPN config
  - Monitoring configurations
EOF
echo -e "${GREEN}✓${NC} Metadata created"

# Create compressed archive
echo -e "${YELLOW}→${NC} Compressing backup..."
cd "${BACKUP_DIR}"
tar czf "${BACKUP_NAME}.tar.gz" "${BACKUP_NAME}"
rm -rf "${BACKUP_NAME}"
cd - > /dev/null
echo -e "${GREEN}✓${NC} Backup compressed"

# Cleanup old backups (keep last 7)
echo -e "${YELLOW}→${NC} Cleaning up old backups..."
cd "${BACKUP_DIR}"
ls -t *.tar.gz 2>/dev/null | tail -n +8 | xargs -r rm --
cd - > /dev/null
echo -e "${GREEN}✓${NC} Old backups cleaned"

echo ""
echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}Backup completed successfully!${NC}"
echo -e "${GREEN}Location: ${BACKUP_DIR}/${BACKUP_NAME}.tar.gz${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
