# ADR 003: Infrastructure as Code Approach

## Status
Accepted

## Context
The project requires:
- Reproducible deployments
- Automated operations
- Version-controlled infrastructure
- Simplified maintenance
- Clear documentation
- Easy onboarding for new users

## Decision
Implement comprehensive Infrastructure as Code using:
- **Docker Compose** (v3.9) for service orchestration
- **Makefile** for operations automation
- **Shell scripts** for backup/restore procedures
- **Pre-commit hooks** for validation
- **GitHub Actions** for CI/CD
- **Environment variables** for configuration

## Rationale

### Why Docker Compose v3.9?
- Latest stable version with modern features
- Native health check support
- Advanced networking capabilities
- Service dependency management
- Widely adopted and well-documented

### Why Makefile?
- **Universal**: Available on all Unix-like systems
- **Simple**: Easy to read and understand
- **Powerful**: Can orchestrate complex operations
- **Documented**: `make help` provides usage
- **IDE Support**: Syntax highlighting, completion

### Why Shell Scripts?
- **Portable**: Works on any Docker host
- **Flexible**: Can handle complex logic
- **Integrated**: Easy Docker command execution
- **Standard**: No additional dependencies

### Why Pre-commit Hooks?
- **Early Validation**: Catch issues before commit
- **Consistency**: Enforce standards automatically
- **Quality**: Automated linting and checking
- **Prevention**: Stop secrets from being committed

### Why GitHub Actions?
- **Native Integration**: Built into GitHub
- **Free**: For public repositories
- **Powerful**: Comprehensive workflow capabilities
- **Ecosystem**: Large marketplace of actions

## Infrastructure Components

### Service Definitions (docker-compose.yml)
```yaml
version: '3.9'
networks: [defined networks]
volumes: [named volumes]
services: [all services with full config]
```

### Operations (Makefile)

```makefile
make init      # Initialize project
make up        # Start services
make down      # Stop services
make backup    # Create backup
make restore   # Restore from backup
make test-vpn  # Verify VPN
make monitoring # Open dashboards
```

### Automation (scripts/)

```text
scripts/
├── backup.sh   # Backup procedure
└── restore.sh  # Restore procedure
```

### Validation (.pre-commit-config.yaml)
- YAML syntax validation
- Shell script linting
- Markdown formatting
- Docker Compose validation
- Secret detection

### CI/CD (.github/workflows/ci.yml)
- Configuration validation
- Security scanning (Trivy)
- Docker Compose testing
- Automated quality checks

## Consequences

### Positive
- **Reproducible**: Same deployment every time
- **Documented**: Infrastructure is self-documenting
- **Automated**: Less manual work
- **Tested**: CI/CD ensures quality
- **Version Controlled**: Track all changes
- **Portable**: Works on any Docker host
- **Onboarding**: New users get started faster

### Negative
- **Learning Curve**: Users need to learn tools
- **Complexity**: More files to manage
- **Dependencies**: Requires Docker, Make, etc.
- **Maintenance**: IaC files need updates

### Neutral
- Configuration drift prevented by IaC
- Changes must go through version control
- Manual operations discouraged

## Best Practices Implemented

### Configuration Management
- Environment variables for all config
- `.env.example` as template
- `.env` excluded from git
- Validation before deployment

### Security
- Secrets never in version control
- Pre-commit hooks prevent leaks
- Security scanning in CI/CD
- Read-only mounts where possible

### Documentation
- README.md for overview
- ARCHITECTURE.md for design
- ADRs for decisions
- Inline comments in configs

### Testing
- Docker Compose validation
- VPN connectivity tests
- Health check verification
- Automated CI/CD testing

### Automation
- Makefile for common operations
- Backup/restore scripts
- Watchtower for updates
- Pre-commit validation

## File Structure

```text
qbittorrent-protonvpn-docker/
├── docker-compose.yml          # Service definitions
├── Makefile                    # Operations automation
├── .env.example                # Configuration template
├── .pre-commit-config.yaml     # Validation hooks
├── monitoring/                 # Observability configs
│   ├── prometheus/
│   ├── grafana/
│   ├── loki/
│   └── promtail/
├── scripts/                    # Automation scripts
│   ├── backup.sh
│   └── restore.sh
├── docs/                       # Documentation
│   ├── ARCHITECTURE.md
│   └── adr/
└── .github/                    # CI/CD
    └── workflows/
        └── ci.yml
```

## Workflow

### Initial Setup
```bash
git clone <repo>
cd qbittorrent-protonvpn-docker
make init
# Edit .env with credentials
make up
```

### Daily Operations
```bash
make status        # Check services
make logs          # View logs
make test-vpn      # Verify VPN
make monitoring    # Open dashboards
```

### Maintenance
```bash
make backup        # Before changes
make update        # Update containers
make restore       # If needed
```

### Development
```bash
pre-commit install          # Setup hooks
# Make changes
git add .
git commit -m "..."        # Hooks run automatically
git push                   # CI/CD runs
```

## Alternatives Considered

### Terraform
- **Rejected**: Overkill for local Docker
- Better for cloud infrastructure
- Requires state management
- More complex for this use case

### Ansible
- **Rejected**: Unnecessary complexity
- Better for multi-host deployments
- Requires Python dependencies
- Docker Compose sufficient here

### Kubernetes
- **Rejected**: Too complex
- Designed for multi-host clusters
- High operational overhead
- Single-host Docker Compose is simpler

### Custom Scripts Only
- **Rejected**: Reinventing the wheel
- Docker Compose provides standard approach
- Harder to maintain
- Less portable

## Migration Guide

For existing users:
1. Pull latest changes
2. Review `.env.example`
3. Update `.env` with new variables
4. Run `make init` to setup
5. Run `make validate` to check config
6. Run `make up` to start with new architecture

## References
- [Docker Compose File Reference](https://docs.docker.com/compose/compose-file/)
- [GNU Make Manual](https://www.gnu.org/software/make/manual/)
- [Pre-commit Framework](https://pre-commit.com/)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
