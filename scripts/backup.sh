#!/usr/bin/env bash
# ══════════════════════════════════════════════════════════════════════
# 💾 BACKUP SCRIPT
# ══════════════════════════════════════════════════════════════════════
#
# WHAT THIS DOES:
# Creates a complete backup of your qBittorrent + VPN setup including:
# - All configuration files
# - Docker volumes (settings, VPN config)
# - qBittorrent torrent state
# - Monitoring configurations
#
# WHAT IT DOESN'T BACKUP:
# - Downloaded files (too large, backup these separately)
# - Temporary/incomplete downloads
#
# HOW TO USE:
# 1. Run: ./scripts/backup.sh
# 2. Or: make backup
# 3. Find backup in: ./backups/qbittorrent-vpn-backup_YYYYMMDD_HHMMSS.tar.gz
#
# AUTOMATIC CLEANUP:
# Keeps only the 7 most recent backups (deletes older ones)
#
# ══════════════════════════════════════════════════════════════════════

# ──────────────────────────────────────────────────────────────────────
# SCRIPT SAFETY SETTINGS
# ──────────────────────────────────────────────────────────────────────
# -e: Exit immediately if any command fails
# -u: Treat unset variables as errors
# -o pipefail: Catch errors in pipes
set -euo pipefail

# ──────────────────────────────────────────────────────────────────────
# COLOR CODES (Makes output pretty and easier to read)
# ──────────────────────────────────────────────────────────────────────
BLUE='\033[0;34m'      # For informational messages
GREEN='\033[0;32m'     # For success messages
YELLOW='\033[1;33m'    # For progress messages
RED='\033[0;31m'       # For error messages
NC='\033[0m'           # No Color (reset to default)

# ──────────────────────────────────────────────────────────────────────
# CONFIGURATION
# ──────────────────────────────────────────────────────────────────────

# Where to store backups (creates ./backups folder)
BACKUP_DIR="./backups"

# Create a timestamp for the backup filename
# Format: YYYYMMDD_HHMMSS (e.g., 20250101_143025)
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Full backup name with timestamp
BACKUP_NAME="qbittorrent-vpn-backup_${TIMESTAMP}"

# Full path to this specific backup
BACKUP_PATH="${BACKUP_DIR}/${BACKUP_NAME}"

# ──────────────────────────────────────────────────────────────────────
# DISPLAY HEADER
# ──────────────────────────────────────────────────────────────────────
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  qBittorrent + ProtonVPN Backup${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo ""

# ──────────────────────────────────────────────────────────────────────
# STEP 1: CREATE BACKUP DIRECTORY
# ──────────────────────────────────────────────────────────────────────
# Create the main backups folder if it doesn't exist
# -p flag: Create parent directories if needed, don't error if exists
mkdir -p "${BACKUP_PATH}"

echo -e "${BLUE}Creating backup: ${BACKUP_NAME}${NC}"
echo ""

# ──────────────────────────────────────────────────────────────────────
# STEP 2: BACKUP CONFIGURATION FILES
# ──────────────────────────────────────────────────────────────────────
# These are the text files that define how everything runs
echo -e "${YELLOW}→${NC} Backing up configurations..."

# Copy monitoring config folder
cp -r ./monitoring "${BACKUP_PATH}/"

# Copy .env file if it exists (contains your passwords/keys)
# Note: We rename it to .env.backup for safety
[ -f .env ] && cp .env "${BACKUP_PATH}/.env.backup"

# Copy main files
cp docker-compose.yml "${BACKUP_PATH}/"
cp Makefile "${BACKUP_PATH}/"

echo -e "${GREEN}✓${NC} Configurations backed up"

# ──────────────────────────────────────────────────────────────────────
# STEP 3: BACKUP QBITTORRENT LOCAL CONFIG (if exists)
# ──────────────────────────────────────────────────────────────────────
# This folder contains qBittorrent settings if stored locally
if [ -d "./qbittorrent" ]; then
    echo -e "${YELLOW}→${NC} Backing up qBittorrent configuration..."
    cp -r ./qbittorrent "${BACKUP_PATH}/"
    echo -e "${GREEN}✓${NC} qBittorrent config backed up"
fi

# ──────────────────────────────────────────────────────────────────────
# STEP 4: BACKUP GLUETUN DOCKER VOLUME
# ──────────────────────────────────────────────────────────────────────
# VPN settings are stored in a Docker volume
# We need to use Docker to access and backup this data
echo -e "${YELLOW}→${NC} Backing up Gluetun configuration..."

# How this works:
# 1. Create temporary Alpine Linux container
# 2. Mount the Gluetun volume as /source
# 3. Mount our backup folder as /backup
# 4. Use tar to compress /source into /backup
# 5. Container auto-deletes when done (--rm flag)
docker run --rm \
    -v qbittorrent-protonvpn-docker_gluetun-config:/source \
    -v "${PWD}/${BACKUP_PATH}:/backup" \
    alpine \
    sh -c "cd /source && tar czf /backup/gluetun-config.tar.gz ."

echo -e "${GREEN}✓${NC} Gluetun config backed up"

# ──────────────────────────────────────────────────────────────────────
# STEP 5: BACKUP QBITTORRENT DOCKER VOLUME
# ──────────────────────────────────────────────────────────────────────
# qBittorrent stores settings and torrent state in a Docker volume
echo -e "${YELLOW}→${NC} Backing up qBittorrent Docker volume..."

# Same process as Gluetun above
docker run --rm \
    -v qbittorrent-protonvpn-docker_qbittorrent-config:/source \
    -v "${PWD}/${BACKUP_PATH}:/backup" \
    alpine \
    sh -c "cd /source && tar czf /backup/qbittorrent-docker-config.tar.gz ."

echo -e "${GREEN}✓${NC} qBittorrent volume backed up"

# ──────────────────────────────────────────────────────────────────────
# STEP 6: CREATE BACKUP METADATA
# ──────────────────────────────────────────────────────────────────────
# Save information about when and where this backup was created
echo -e "${YELLOW}→${NC} Creating backup metadata..."

cat > "${BACKUP_PATH}/backup-info.txt" << EOF
Backup Created: $(date)
Hostname: $(hostname)
Docker Version: $(docker --version)
Docker Compose Version: $(docker-compose --version)
Backup Contents:
  - Configuration files (docker-compose.yml, Makefile, .env)
  - qBittorrent settings (local folder and Docker volume)
  - Gluetun VPN configuration (Docker volume)
  - Monitoring configurations (Prometheus, Grafana, Loki)
EOF

echo -e "${GREEN}✓${NC} Metadata created"

# ──────────────────────────────────────────────────────────────────────
# STEP 7: COMPRESS EVERYTHING INTO A SINGLE FILE
# ──────────────────────────────────────────────────────────────────────
# Combine all backed up files into one compressed archive
echo -e "${YELLOW}→${NC} Compressing backup..."

# Go into the backups directory
cd "${BACKUP_DIR}"

# Create compressed archive (.tar.gz)
# c = create, z = compress with gzip, f = filename
tar czf "${BACKUP_NAME}.tar.gz" "${BACKUP_NAME}"

# Delete the uncompressed folder (we have the .tar.gz now)
rm -rf "${BACKUP_NAME}"

# Go back to original directory
cd - > /dev/null

echo -e "${GREEN}✓${NC} Backup compressed"

# ──────────────────────────────────────────────────────────────────────
# STEP 8: CLEANUP OLD BACKUPS
# ──────────────────────────────────────────────────────────────────────
# Keep only the 7 most recent backups to save disk space
echo -e "${YELLOW}→${NC} Cleaning up old backups..."

cd "${BACKUP_DIR}"

# How this works:
# 1. ls -t: List files sorted by modification time (newest first)
# 2. tail -n +8: Skip first 7 files, show rest
# 3. xargs -r rm: Delete remaining files (if any exist)
ls -t *.tar.gz 2>/dev/null | tail -n +8 | xargs -r rm --

cd - > /dev/null

echo -e "${GREEN}✓${NC} Old backups cleaned"

# ──────────────────────────────────────────────────────────────────────
# SUCCESS MESSAGE
# ──────────────────────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}Backup completed successfully!${NC}"
echo -e "${GREEN}Location: ${BACKUP_DIR}/${BACKUP_NAME}.tar.gz${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"

# ──────────────────────────────────────────────────────────────────────
# TIPS
# ──────────────────────────────────────────────────────────────────────
echo ""
echo "💡 Tips:"
echo "  - Store backups in a safe location (external drive, cloud storage)"
echo "  - Test restoration periodically to ensure backups work"
echo "  - Run 'make restore' to restore from a backup"
echo ""
