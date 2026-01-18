# ──────────────────────────────────────────────────────────────────────
# 🏗️  Makefile for qBittorrent + ProtonVPN Docker Infrastructure
# ──────────────────────────────────────────────────────────────────────
# Infrastructure as Code automation for development and operations
# ──────────────────────────────────────────────────────────────────────

.PHONY: help init up down restart logs status clean validate security backup restore test monitoring

# Color output
BLUE := \033[0;34m
GREEN := \033[0;32m
YELLOW := \033[1;33m
RED := \033[0;31m
NC := \033[0m # No Color

# Default target
.DEFAULT_GOAL := help

# ──────────────────────────────────────────────────────────────────────
# 📚 Help & Documentation
# ──────────────────────────────────────────────────────────────────────

help: ## Show this help message
	@echo "$(BLUE)═══════════════════════════════════════════════════════════════$(NC)"
	@echo "$(BLUE)  qBittorrent + ProtonVPN Infrastructure Management$(NC)"
	@echo "$(BLUE)═══════════════════════════════════════════════════════════════$(NC)"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "$(GREEN)%-20s$(NC) %s\n", $$1, $$2}'
	@echo ""

# ──────────────────────────────────────────────────────────────────────
# 🚀 Initialization & Setup
# ──────────────────────────────────────────────────────────────────────

init: ## Initialize the project (check dependencies, create .env)
	@echo "$(BLUE)Initializing project...$(NC)"
	@command -v docker >/dev/null 2>&1 || { echo "$(RED)Docker is not installed$(NC)"; exit 1; }
	@command -v docker-compose >/dev/null 2>&1 || { echo "$(RED)Docker Compose is not installed$(NC)"; exit 1; }
	@if [ ! -f .env ]; then \
		echo "$(YELLOW)Creating .env from .env.example...$(NC)"; \
		cp .env.example .env; \
		echo "$(GREEN)✓ .env file created. Please edit it with your credentials.$(NC)"; \
	else \
		echo "$(GREEN)✓ .env file already exists$(NC)"; \
	fi
	@mkdir -p downloads incomplete qbittorrent gluetun
	@echo "$(GREEN)✓ Initialization complete$(NC)"

# ──────────────────────────────────────────────────────────────────────
# 🐳 Docker Operations
# ──────────────────────────────────────────────────────────────────────

up: validate ## Start all containers
	@echo "$(BLUE)Starting containers...$(NC)"
	docker-compose up -d
	@echo "$(GREEN)✓ Containers started$(NC)"
	@make status

down: ## Stop all containers
	@echo "$(BLUE)Stopping containers...$(NC)"
	docker-compose down
	@echo "$(GREEN)✓ Containers stopped$(NC)"

restart: ## Restart all containers
	@echo "$(BLUE)Restarting containers...$(NC)"
	docker-compose restart
	@echo "$(GREEN)✓ Containers restarted$(NC)"

rebuild: ## Rebuild and restart all containers
	@echo "$(BLUE)Rebuilding containers...$(NC)"
	docker-compose down
	docker-compose build --no-cache
	docker-compose up -d
	@echo "$(GREEN)✓ Containers rebuilt$(NC)"

pull: ## Pull latest images
	@echo "$(BLUE)Pulling latest images...$(NC)"
	docker-compose pull
	@echo "$(GREEN)✓ Images updated$(NC)"

# ──────────────────────────────────────────────────────────────────────
# 📊 Monitoring & Logs
# ──────────────────────────────────────────────────────────────────────

logs: ## Show logs for all containers
	docker-compose logs -f --tail=100

logs-gluetun: ## Show Gluetun VPN logs
	docker-compose logs -f --tail=100 gluetun

logs-qbittorrent: ## Show qBittorrent logs
	docker-compose logs -f --tail=100 qbittorrent

status: ## Show status of all containers
	@echo "$(BLUE)Container Status:$(NC)"
	@docker-compose ps
	@echo ""
	@echo "$(BLUE)Health Status:$(NC)"
	@docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

monitoring: ## Open monitoring dashboards
	@echo "$(BLUE)Opening monitoring dashboards...$(NC)"
	@echo "$(GREEN)Grafana:    http://localhost:3000$(NC) (admin/admin)"
	@echo "$(GREEN)Prometheus: http://localhost:9090$(NC)"
	@echo "$(GREEN)cAdvisor:   http://localhost:8081$(NC)"
	@echo "$(GREEN)qBittorrent: http://localhost:8080$(NC)"

# ──────────────────────────────────────────────────────────────────────
# 🔍 Validation & Testing
# ──────────────────────────────────────────────────────────────────────

validate: ## Validate docker-compose configuration
	@echo "$(BLUE)Validating configuration...$(NC)"
	@docker-compose config > /dev/null && echo "$(GREEN)✓ docker-compose.yml is valid$(NC)" || echo "$(RED)✗ docker-compose.yml is invalid$(NC)"
	@if [ -f .env ]; then \
		echo "$(GREEN)✓ .env file exists$(NC)"; \
	else \
		echo "$(RED)✗ .env file missing$(NC)"; \
		exit 1; \
	fi

test-vpn: ## Test VPN connection
	@echo "$(BLUE)Testing VPN connection...$(NC)"
	@docker exec gluetun wget -qO- https://ipinfo.io/json | jq -r '.country + " - " + .org'
	@echo "$(GREEN)✓ VPN test complete$(NC)"

test-qbittorrent: ## Test qBittorrent connection through VPN
	@echo "$(BLUE)Testing qBittorrent VPN routing...$(NC)"
	@docker exec qbittorrent curl -s https://ipinfo.io/json | jq -r '.country + " - " + .org'
	@echo "$(GREEN)✓ qBittorrent VPN test complete$(NC)"

# ──────────────────────────────────────────────────────────────────────
# 🔒 Security
# ──────────────────────────────────────────────────────────────────────

security: ## Run security scans on Docker images
	@echo "$(BLUE)Running security scans...$(NC)"
	@command -v trivy >/dev/null 2>&1 || { echo "$(YELLOW)Trivy not installed. Install with: brew install trivy$(NC)"; exit 0; }
	@echo "$(BLUE)Scanning Gluetun...$(NC)"
	@trivy image --severity HIGH,CRITICAL ghcr.io/qdm12/gluetun:v3.39.1
	@echo "$(BLUE)Scanning qBittorrent...$(NC)"
	@trivy image --severity HIGH,CRITICAL lscr.io/linuxserver/qbittorrent:4.6.7
	@echo "$(GREEN)✓ Security scan complete$(NC)"

lint: ## Lint docker-compose file
	@echo "$(BLUE)Linting docker-compose.yml...$(NC)"
	@command -v docker-compose >/dev/null 2>&1 && docker-compose config -q && echo "$(GREEN)✓ Lint passed$(NC)" || echo "$(RED)✗ Lint failed$(NC)"

# ──────────────────────────────────────────────────────────────────────
# 💾 Backup & Restore
# ──────────────────────────────────────────────────────────────────────

backup: ## Backup configurations and data
	@echo "$(BLUE)Creating backup...$(NC)"
	@./scripts/backup.sh
	@echo "$(GREEN)✓ Backup complete$(NC)"

restore: ## Restore from backup
	@echo "$(BLUE)Restoring from backup...$(NC)"
	@./scripts/restore.sh
	@echo "$(GREEN)✓ Restore complete$(NC)"

# ──────────────────────────────────────────────────────────────────────
# 🧹 Cleanup
# ──────────────────────────────────────────────────────────────────────

clean: ## Stop containers and remove volumes
	@echo "$(RED)Warning: This will remove all data!$(NC)"
	@read -p "Are you sure? [y/N] " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		docker-compose down -v; \
		echo "$(GREEN)✓ Cleanup complete$(NC)"; \
	else \
		echo "$(YELLOW)Cleanup cancelled$(NC)"; \
	fi

clean-logs: ## Remove all log files
	@echo "$(BLUE)Cleaning log files...$(NC)"
	@find . -name "*.log" -type f -delete
	@echo "$(GREEN)✓ Log files cleaned$(NC)"

prune: ## Prune unused Docker resources
	@echo "$(BLUE)Pruning Docker resources...$(NC)"
	docker system prune -af --volumes
	@echo "$(GREEN)✓ Prune complete$(NC)"

# ──────────────────────────────────────────────────────────────────────
# 🔧 Development
# ──────────────────────────────────────────────────────────────────────

dev: init up ## Quick start for development

shell-gluetun: ## Open shell in Gluetun container
	docker exec -it gluetun /bin/sh

shell-qbittorrent: ## Open shell in qBittorrent container
	docker exec -it qbittorrent /bin/bash

update: pull rebuild ## Update all containers to latest versions
	@echo "$(GREEN)✓ All containers updated$(NC)"
