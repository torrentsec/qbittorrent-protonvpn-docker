# 🏗️ Architecture Documentation

## Overview

This document describes the architecture of the qBittorrent + ProtonVPN
Docker infrastructure.

## System Architecture

```text
┌─────────────────────────────────────────────────────────────────┐
│                        Docker Host                               │
│                                                                   │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │              VPN Network (172.20.0.0/16)                    │ │
│  │                                                              │ │
│  │  ┌──────────────┐         ┌──────────────┐                 │ │
│  │  │   Gluetun    │◄────────┤ qBittorrent  │                 │ │
│  │  │  (VPN Exit)  │         │  (Torrent)   │                 │ │
│  │  │              │         │              │                 │ │
│  │  │  :8000       │         │  :8080       │                 │ │
│  │  └──────┬───────┘         └──────────────┘                 │ │
│  │         │                                                   │ │
│  │         │ WireGuard                                        │ │
│  │         ▼                                                   │ │
│  │    ProtonVPN                                               │ │
│  └────────────────────────────────────────────────────────────┘ │
│                                                                   │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │          Monitoring Network (172.21.0.0/16)                 │ │
│  │                                                              │ │
│  │  ┌────────────┐  ┌──────────┐  ┌────────┐  ┌────────────┐ │ │
│  │  │ Prometheus │  │ Grafana  │  │  Loki  │  │  Promtail  │ │ │
│  │  │   :9090    │  │  :3000   │  │ :3100  │  │            │ │ │
│  │  └────────────┘  └──────────┘  └────────┘  └────────────┘ │ │
│  │                                                              │ │
│  │  ┌────────────┐  ┌──────────────┐                          │ │
│  │  │  cAdvisor  │  │  Watchtower  │                          │ │
│  │  │   :8081    │  │              │                          │ │
│  │  └────────────┘  └──────────────┘                          │ │
│  └────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
```

## Component Details

### Core Services

#### Gluetun (VPN)

- **Purpose**: Provides secure VPN tunnel via ProtonVPN
- **Technology**: WireGuard protocol
- **Key Features**:
  - Automatic port forwarding
  - DNS over TLS (DoT)
  - Kill switch via firewall rules
  - Malicious content blocking
- **Network**: Bridge to VPN provider, local bridge for qBittorrent

#### qBittorrent

- **Purpose**: BitTorrent client
- **Technology**: LinuxServer.io container with VueTorrent UI
- **Key Features**:
  - Network shares Gluetun container (no direct internet access)
  - Automatic port synchronization with Gluetun
  - Web UI on port 8080
- **Security**: All traffic forced through VPN

### Monitoring Stack

#### Prometheus

- **Purpose**: Metrics collection and storage
- **Scrape Targets**:
  - cAdvisor (container metrics)
  - Gluetun (VPN metrics)
  - Self-monitoring
- **Retention**: 30 days
- **Port**: 9090

#### Grafana

- **Purpose**: Visualization and dashboards
- **Data Sources**:
  - Prometheus (metrics)
  - Loki (logs)
- **Port**: 3000

#### Loki + Promtail

- **Purpose**: Log aggregation
- **Technology**: Grafana Loki stack
- **Features**:
  - Centralized logging
  - 31-day retention
  - Label-based querying
- **Ports**: 3100 (Loki)

#### cAdvisor

- **Purpose**: Container resource usage monitoring
- **Metrics**: CPU, memory, network, disk I/O
- **Port**: 8081

### Supporting Services

#### Watchtower

- **Purpose**: Automatic container updates
- **Schedule**: Daily checks
- **Features**:
  - Label-based updates
  - Rolling restarts
  - Cleanup old images

## Network Architecture

### Network Segmentation

```text
VPN Network (172.20.0.0/16)
├── Gluetun (172.20.0.10)
└── qBittorrent (shares Gluetun network namespace)

Monitoring Network (172.21.0.0/16)
├── Prometheus
├── Grafana
├── Loki
├── Promtail
├── cAdvisor
└── Watchtower
```

### Traffic Flow

1. **Torrent Traffic**:
   - qBittorrent → Gluetun → WireGuard → ProtonVPN → Internet

1. **Monitoring Traffic**:
   - All containers → Promtail → Loki
   - Prometheus scrapes → cAdvisor, Gluetun
   - Grafana queries → Prometheus, Loki

1. **Web UI Access**:
   - User → localhost:8080 → Gluetun → qBittorrent
   - User → localhost:3000 → Grafana
   - User → localhost:9090 → Prometheus

## Security Architecture

### Defense in Depth

1. **Network Isolation**:
   - VPN network separated from monitoring
   - qBittorrent has NO direct internet access
   - All traffic through VPN tunnel

1. **Container Security**:
   - `no-new-privileges` security option
   - Minimal capabilities (CAP_NET_ADMIN only for Gluetun)
   - Read-only mounts where possible

1. **VPN Security**:
   - WireGuard encryption
   - DNS over TLS
   - IPv6 disabled (leak prevention)
   - Firewall rules enforce VPN-only traffic

1. **Secrets Management**:
   - Environment variables for sensitive data
   - .env file excluded from version control
   - Docker secrets for production

### Security Scanning

- Trivy scans for vulnerabilities
- Automated daily security checks via GitHub Actions
- SARIF reports uploaded to GitHub Security tab

## Data Architecture

### Persistent Storage

```text
Named Volumes:
├── gluetun-config         (VPN configurations)
├── qbittorrent-config     (qBittorrent settings)
├── prometheus-data        (Metrics storage)
├── grafana-data          (Dashboards & settings)
└── loki-data             (Log storage)

Bind Mounts:
├── ./downloads           (Completed torrents)
├── ./incomplete          (In-progress downloads)
└── ./monitoring          (Configuration files)
```

### Backup Strategy

- Automated backups via `scripts/backup.sh`
- Includes:
  - Configuration files
  - Docker volumes
  - Environment settings (sanitized)
- Retention: 7 most recent backups
- Compressed archives for efficiency

## Deployment Architecture

### Infrastructure as Code

```text
Project Structure:
├── docker-compose.yml          (Service definitions)
├── Makefile                    (Operations automation)
├── .env.example                (Configuration template)
├── monitoring/                 (Observability configs)
│   ├── prometheus/
│   ├── grafana/
│   ├── loki/
│   └── promtail/
├── scripts/                    (Automation scripts)
│   ├── backup.sh
│   └── restore.sh
└── .github/workflows/          (CI/CD pipelines)
```

### CI/CD Pipeline

1. **Validation**:
   - YAML syntax
   - Docker Compose validation
   - Required files check

1. **Security**:
   - Trivy vulnerability scanning
   - Secret detection
   - Security advisories

1. **Testing**:
   - Configuration testing
   - Shell script linting
   - Markdown linting

1. **Quality Gates**:
   - All checks must pass
   - Security vulnerabilities reviewed
   - Code quality maintained

## Observability

### Metrics

- Container resource usage (CPU, memory, network, disk)
- VPN connection status
- Service health checks
- Network throughput

### Logs

- Structured logging via Loki
- Log aggregation from all containers
- Queryable via LogQL
- Integrated with Grafana

### Alerts

- VPN connection down
- Container failures
- High resource usage
- Disk space warnings

## Scalability Considerations

### Current Limitations

- Single-host deployment
- No horizontal scaling
- Local storage only

### Future Enhancements

- Docker Swarm or Kubernetes deployment
- Distributed storage (NFS, Ceph)
- Load balancing
- Multi-region VPN failover
- External secrets management (Vault)

## Compliance & Best Practices

### Infrastructure as Code

- Version controlled configurations
- Declarative service definitions
- Immutable infrastructure
- Automated deployments

### DevOps Best Practices

- CI/CD pipelines
- Automated testing
- Security scanning
- Monitoring & observability
- Disaster recovery procedures

### Container Best Practices

- Minimal base images
- Security hardening
- Health checks
- Resource limits
- Proper logging
