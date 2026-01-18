#!/usr/bin/env bash
# ──────────────────────────────────────────────────────────────────────
# 🔄 Restore Script for qBittorrent + ProtonVPN Infrastructure
# ──────────────────────────────────────────────────────────────────────
# Restores configurations and data from backup archives
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

echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  qBittorrent + ProtonVPN Restore${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo ""

# List available backups
echo -e "${BLUE}Available backups:${NC}"
echo ""
if [ ! -d "${BACKUP_DIR}" ] || [ -z "$(ls -A ${BACKUP_DIR}/*.tar.gz 2>/dev/null)" ]; then
    echo -e "${RED}No backups found in ${BACKUP_DIR}${NC}"
    exit 1
fi

ls -lht "${BACKUP_DIR}"/*.tar.gz | awk '{print NR")", $9, "("$6, $7, $8")"}'
echo ""

# Get user selection
read -p "Enter backup number to restore (or 'q' to quit): " selection

if [ "$selection" = "q" ]; then
    echo "Restore cancelled"
    exit 0
fi

# Get selected backup file
BACKUP_FILE=$(ls -t "${BACKUP_DIR}"/*.tar.gz | sed -n "${selection}p")

if [ -z "$BACKUP_FILE" ]; then
    echo -e "${RED}Invalid selection${NC}"
    exit 1
fi

echo ""
echo -e "${YELLOW}Selected backup: $(basename $BACKUP_FILE)${NC}"
echo -e "${RED}WARNING: This will overwrite current configurations!${NC}"
read -p "Continue? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    echo "Restore cancelled"
    exit 0
fi

echo ""
echo -e "${BLUE}Starting restore...${NC}"
echo ""

# Stop containers
echo -e "${YELLOW}→${NC} Stopping containers..."
docker-compose down
echo -e "${GREEN}✓${NC} Containers stopped"

# Extract backup
TEMP_DIR=$(mktemp -d)
echo -e "${YELLOW}→${NC} Extracting backup..."
tar xzf "${BACKUP_FILE}" -C "${TEMP_DIR}"
BACKUP_NAME=$(basename "${BACKUP_FILE}" .tar.gz)
RESTORE_PATH="${TEMP_DIR}/${BACKUP_NAME}"
echo -e "${GREEN}✓${NC} Backup extracted"

# Restore configurations
echo -e "${YELLOW}→${NC} Restoring configurations..."
[ -d "${RESTORE_PATH}/monitoring" ] && cp -r "${RESTORE_PATH}/monitoring" ./
[ -f "${RESTORE_PATH}/.env.backup" ] && cp "${RESTORE_PATH}/.env.backup" ./.env
[ -f "${RESTORE_PATH}/docker-compose.yml" ] && cp "${RESTORE_PATH}/docker-compose.yml" ./
echo -e "${GREEN}✓${NC} Configurations restored"

# Restore qBittorrent config
if [ -d "${RESTORE_PATH}/qbittorrent" ]; then
    echo -e "${YELLOW}→${NC} Restoring qBittorrent configuration..."
    cp -r "${RESTORE_PATH}/qbittorrent" ./
    echo -e "${GREEN}✓${NC} qBittorrent config restored"
fi

# Restore Gluetun volume
if [ -f "${RESTORE_PATH}/gluetun-config.tar.gz" ]; then
    echo -e "${YELLOW}→${NC} Restoring Gluetun Docker volume..."
    docker volume create qbittorrent-protonvpn-docker_gluetun-config
    docker run --rm \
        -v qbittorrent-protonvpn-docker_gluetun-config:/target \
        -v "${PWD}/${RESTORE_PATH}:/backup" \
        alpine \
        sh -c "cd /target && tar xzf /backup/gluetun-config.tar.gz"
    echo -e "${GREEN}✓${NC} Gluetun volume restored"
fi

# Restore qBittorrent volume
if [ -f "${RESTORE_PATH}/qbittorrent-docker-config.tar.gz" ]; then
    echo -e "${YELLOW}→${NC} Restoring qBittorrent Docker volume..."
    docker volume create qbittorrent-protonvpn-docker_qbittorrent-config
    docker run --rm \
        -v qbittorrent-protonvpn-docker_qbittorrent-config:/target \
        -v "${PWD}/${RESTORE_PATH}:/backup" \
        alpine \
        sh -c "cd /target && tar xzf /backup/qbittorrent-docker-config.tar.gz"
    echo -e "${GREEN}✓${NC} qBittorrent volume restored"
fi

# Cleanup
rm -rf "${TEMP_DIR}"

echo ""
echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}Restore completed successfully!${NC}"
echo -e "${GREEN}You can now start the containers with: make up${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
