# ADR 002: Network Architecture & Segmentation

## Status

Accepted

## Context

The infrastructure requires secure network design to:

- Ensure all torrent traffic goes through VPN
- Prevent IP leaks
- Isolate monitoring from core services
- Enable inter-container communication
- Maintain security boundaries

## Decision

Implement two separate Docker bridge networks:

1. **VPN Network** (172.20.0.0/16) - For VPN and torrent traffic
1. **Monitoring Network** (172.21.0.0/16) - For observability stack

qBittorrent uses `network_mode: service:gluetun` to share Gluetun's
network namespace.

## Rationale

### Network Segmentation Benefits

- **Security**: Isolation between core and monitoring services
- **Traffic Management**: Separate subnets for different purposes
- **Compliance**: Clear network boundaries
- **Troubleshooting**: Easier to diagnose network issues

### Shared Network Namespace

Using `network_mode: service:gluetun`:

- **Zero Leak Guarantee**: qBittorrent cannot access network without VPN
- **Simplified Configuration**: No need for complex routing rules
- **Performance**: No additional network hops
- **Reliability**: If VPN fails, qBittorrent loses all connectivity

## Network Topology

```text
┌─────────────────────────────────────────────┐
│           Docker Host                        │
│                                              │
│  ┌────────────────────────────────────────┐ │
│  │   VPN Network (172.20.0.0/16)          │ │
│  │                                         │ │
│  │   ┌──────────┐                         │ │
│  │   │ Gluetun  │                         │ │
│  │   │ + qBit   │ (shared namespace)      │ │
│  │   └────┬─────┘                         │ │
│  │        │                                │ │
│  │        └─► ProtonVPN (WireGuard)       │ │
│  └────────────────────────────────────────┘ │
│                                              │
│  ┌────────────────────────────────────────┐ │
│  │  Monitoring Net (172.21.0.0/16)        │ │
│  │                                         │ │
│  │  Prometheus | Grafana | Loki | ...     │ │
│  └────────────────────────────────────────┘ │
└─────────────────────────────────────────────┘
```

## Consequences

### Positive

- **Guaranteed VPN enforcement**: Physical impossibility of leaks
- **Clean separation**: Monitoring isolated from VPN traffic
- **Simplified firewall rules**: Network namespace handles isolation
- **Better security**: Multiple network boundaries
- **Scalability**: Can add services to appropriate network

### Negative

- **Complex debugging**: Shared namespace harder to troubleshoot
- **Service coupling**: qBittorrent tightly coupled to Gluetun
- **Port conflicts**: Both services share port space
- **Restart dependencies**: qBittorrent requires Gluetun restart

### Neutral

- Static IP for Gluetun (172.20.0.10) for predictability
- Gluetun must connect to both networks for monitoring
- Firewall rules configured in Gluetun for both subnets

## Security Considerations

### Firewall Rules

Gluetun configured with:

```yaml
FIREWALL_OUTBOUND_SUBNETS: 172.20.0.0/16,172.21.0.0/16
```

Allows communication with monitoring while maintaining VPN enforcement.

### IPv6 Disabled

```yaml
sysctls:
  - net.ipv6.conf.all.disable_ipv6=1
```

Prevents IPv6 leaks (ProtonVPN uses IPv4 only).

### No Direct Internet Access

qBittorrent has zero direct internet access - all traffic through VPN tunnel.

## Alternatives Considered

### Single Network

- **Rejected**: No isolation between services
- All services in same broadcast domain
- Harder to apply network policies

### iptables Routing

- **Rejected**: More complex configuration
- Higher risk of misconfiguration
- Requires careful rule management
- Shared namespace is simpler and safer

### Macvlan Networks

- **Rejected**: Requires host network mode
- More complex setup
- Compatibility issues with some Docker hosts
- Overkill for this use case

### Overlay Networks (Swarm/K8s)

- **Rejected**: Unnecessary complexity
- Designed for multi-host
- This is single-host deployment

## Implementation Details

### Network Configuration

```yaml
networks:
  vpn_network:
    driver: bridge
    ipam:
      config:
        - subnet: 172.20.0.0/16
  monitoring_network:
    driver: bridge
    ipam:
      config:
        - subnet: 172.21.0.0/16
```

### Service Assignment

- **VPN Network**: Gluetun (with qBittorrent sharing)
- **Monitoring Network**: Prometheus, Grafana, Loki, Promtail, cAdvisor, Watchtower
- **Both Networks**: Gluetun (bridge between networks)

## Migration Path

For users upgrading from previous versions:

1. Stop all containers
1. Remove old networks
1. Pull new docker-compose.yml
1. Recreate with new network configuration
1. Verify VPN routing: `docker exec qbittorrent curl ipinfo.io`

## References

- [Docker Networking Overview](https://docs.docker.com/network/)
- [Gluetun Wiki - Network Mode](https://github.com/qdm12/gluetun/wiki/Container-network-namespace)
- [Container Network Security](https://docs.docker.com/engine/security/security/)
