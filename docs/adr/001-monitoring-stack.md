# ADR 001: Monitoring Stack Implementation

## Status
Accepted

## Context
The qBittorrent + ProtonVPN infrastructure requires comprehensive monitoring and observability to ensure:
- VPN connection reliability
- Container health and performance
- Resource utilization tracking
- Log aggregation and analysis
- Alerting on critical failures

## Decision
Implement a full monitoring stack using:
- **Prometheus** for metrics collection
- **Grafana** for visualization
- **Loki** for log aggregation
- **Promtail** for log shipping
- **cAdvisor** for container metrics

## Rationale

### Why Prometheus?
- Industry standard for container monitoring
- Excellent Docker integration
- Powerful query language (PromQL)
- Active community and extensive exporters
- Time-series database optimized for metrics

### Why Grafana?
- Best-in-class visualization platform
- Native Prometheus and Loki integration
- Rich dashboard ecosystem
- Alerting capabilities
- Familiar to DevOps teams

### Why Loki + Promtail?
- Designed for cloud-native environments
- Label-based log aggregation (like Prometheus for logs)
- Efficient storage (indexes labels, not full text)
- Native Grafana integration
- Lower resource usage than ELK stack

### Why cAdvisor?
- Purpose-built for container metrics
- Comprehensive resource usage data
- Zero configuration for Docker
- Lightweight and efficient

## Consequences

### Positive
- Complete observability stack
- Historical metrics for analysis
- Centralized logging
- Early problem detection via alerts
- Better understanding of resource usage
- Troubleshooting capabilities

### Negative
- Additional resource overhead (~500MB RAM)
- More complex infrastructure
- Additional containers to manage
- Learning curve for operators

### Neutral
- Separate monitoring network for isolation
- Configuration files require maintenance
- Grafana dashboards need creation

## Alternatives Considered

### ELK Stack (Elasticsearch, Logstash, Kibana)
- **Rejected**: Too resource-intensive for this use case
- Requires Java (high memory usage)
- Complex configuration
- Overkill for single-host deployment

### Datadog / New Relic
- **Rejected**: Commercial solutions
- Requires internet connectivity (defeats VPN privacy)
- Recurring costs
- Data leaves infrastructure

### Simple logging (docker logs)
- **Rejected**: No persistence
- No search capabilities
- No visualization
- Limited to CLI access

## Implementation Notes

### Network Segmentation
Monitoring services on separate network (172.21.0.0/16) for:
- Security isolation
- Traffic separation
- Resource allocation

### Storage Strategy
- Prometheus: 30-day retention
- Loki: 31-day retention
- Named volumes for persistence

### Security
- No external exposure (localhost only)
- Authentication on Grafana
- Read-only Docker socket access where possible

## References
- [Prometheus Documentation](https://prometheus.io/docs/)
- [Grafana Documentation](https://grafana.com/docs/)
- [Loki Documentation](https://grafana.com/docs/loki/)
- [cAdvisor GitHub](https://github.com/google/cadvisor)
