# 🚀 qBittorrent Setup & Troubleshooting Guide

## Initial Setup After First Start

### Step 1: Get Your Temporary Password

When qBittorrent starts for the first time, it generates a temporary admin password. You need this to log in.

**Get the password with this command:**

```bash
docker logs qbittorrent 2>&1 | grep "temporary password" -A 1
```

Or use this one-liner to get just the password:

```bash
docker logs qbittorrent 2>&1 | grep -oP '(?<=password is: ).*'
```

**What you'll see:**

```text
******** Information ********
To control qBittorrent, access the WebUI at: <http://localhost:8080>

The WebUI administrator username is: admin
The WebUI administrator password was not set. A temporary password is provided for this session: Ab3dEfG9hI
```

### Step 2: Access qBittorrent

1. Open your browser to: <http://localhost:8080>
1. Username: **admin**
1. Password: **[the temporary password from above]**

### Step 3: Set a Permanent Password

**IMPORTANT**: Change your password immediately!

1. Go to **Tools** → **Options** → **Web UI**
1. Under "Authentication":
   - Username: Keep as `admin` or change it
   - Password: Enter a NEW strong password
   - Confirm password
1. **Click "Save"**

**Why this is critical:**
- Temporary password changes every time the container restarts
- If you don't set a permanent password, you'll be locked out after restarts

### Step 4: Enable Port Sync (CRITICAL!)

For the port forwarding sync mod to work, you MUST enable localhost bypass:

1. Still in **Tools** → **Options** → **Web UI**
1. Scroll to "**Security**" section
1. Find "**Bypass authentication for clients on localhost**"
1. ✅ **CHECK THIS BOX** (enable it)
1. Click "**Save**"

**Why this is needed:**
The port sync mod runs on localhost and needs to communicate with qBittorrent's API without authentication. If this isn't enabled, port forwarding won't sync automatically.

## Common Issues & Solutions

### ❌ Issue: "Unauthorized" Error on Web UI

**Symptoms:**

- Can't access <http://localhost:8080>
- Getting "Unauthorized" error
- No login prompt

**Solution 1 - Disable Header Validation:**

1. Stop containers: `make down`
1. Edit qBittorrent config:

   ```bash
   # Location varies - try both:
   nano ./qbittorrent/qBittorrent/qBittorrent.conf
   # OR
   nano ./qbittorrent/config/qBittorrent.conf
   ```

1. Find or add these lines under `[Preferences]`:

   ```ini
   WebUI\HostHeaderValidation=false
   WebUI\CSRFProtection=false
   ```

1. Save and restart: `make up`

**Solution 2 - Access via Container IP:**

```bash
# Get qBittorrent IP (it shares Gluetun's network)
docker inspect gluetun | grep IPAddress

# Access using that IP
# Example: <http://172.20.0.10:8080>
```

### ❌ Issue: Port Sync Mod Errors

**Symptoms:**

```text
[GSP] - [ERROR] The "Bypass authentication for clients on localhost" setting is not set.
[GSP] - Init checks failed, exiting the mod.
```

**Solution:**

1. Log into qBittorrent Web UI
1. Go to **Tools** → **Options** → **Web UI**
1. Enable "**Bypass authentication for clients on localhost**"
1. Save settings
1. Restart qBittorrent: `docker restart qbittorrent`

**Verify it worked:**

```bash
docker logs qbittorrent 2>&1 | grep GSP | tail -20
```

You should see successful port updates instead of errors.

### ❌ Issue: Port Forwarding Not Working

**Symptoms:**

```text
[GSP] - Error retrieving port from Qbittorrent API.
curl: (22) The requested URL returned error: 403
```

**Root Cause:** Authentication blocking the API

**Complete Fix:**

1. **Enable localhost bypass** (see Step 4 above)

1. **Verify Gluetun has a forwarded port:**

   ```bash
   docker logs gluetun | grep "port forward"
   ```

   Should show something like: `port forwarded is 12345`

1. **Check the sync mod is running:**

   ```bash
   docker logs qbittorrent 2>&1 | grep GSP
   ```

1. **Manual verification:**

   ```bash
   # Check Gluetun's forwarded port
   curl <http://localhost:8000/v1/openvpn/portforwarded>

   # Should return something like: {"port":12345}
   ```

1. **If still failing, add skip flag (temporary):**

   Add to qBittorrent environment in docker-compose.yml:

   ```yaml
   - GSP_SKIP_INIT_CHECKS=warning
   ```

   Then restart: `docker restart qbittorrent`

### ❌ Issue: Can't Find qBittorrent Config File

**Config file location varies by setup:**

Try these locations in order:

```bash
# Location 1 (most common)
ls -la ./qbittorrent/qBittorrent/qBittorrent.conf

# Location 2
ls -la ./qbittorrent/config/qBittorrent.conf

# Location 3 (inside Docker volume)
docker exec qbittorrent cat /config/qBittorrent/qBittorrent.conf
```

**To edit inside Docker volume:**

```bash
docker exec -it qbittorrent nano /config/qBittorrent/qBittorrent.conf
```

### ✅ Verify Everything is Working

Run these commands to check:

```bash
# 1. Check VPN is connected
make test-vpn

# 2. Check qBittorrent is using VPN
make test-qbittorrent

# 3. Check port forwarding
docker logs gluetun | grep "port forward" | tail -1

# 4. Check port sync is working
docker logs qbittorrent | grep GSP | tail -10

# 5. View all service status
make status
```

## Best Practices

### Security Checklist
- [ ] Changed default Grafana password
- [ ] Set permanent qBittorrent password
- [ ] Enabled localhost bypass for port sync
- [ ] Verified VPN is routing all traffic
- [ ] Tested IP leak protection

### Backup Checklist
- [ ] Created initial backup: `make backup`
- [ ] Stored backup in safe location
- [ ] Tested restore procedure: `make restore`
- [ ] Set up automated backups (cron job)

### Monitoring Checklist
- [ ] Grafana dashboards accessible
- [ ] Prometheus collecting metrics
- [ ] Loki receiving logs
- [ ] Alerts configured for VPN failures

## Quick Reference

| Task | Command |
|------|---------|
| Get qBittorrent password | `docker logs qbittorrent 2>&1 \| grep "temporary password"` |
| Access Web UI | <http://localhost:8080> |
| Access Grafana | <http://localhost:3000> |
| Test VPN | `make test-vpn` |
| View logs | `make logs` |
| Restart services | `make restart` |
| Create backup | `make backup` |
| Check status | `make status` |

## Need More Help?

- **Documentation**: See `docs/` folder
- **Architecture**: See `docs/ARCHITECTURE.md`
- **Commands**: Run `make help`
- **Issues**: <https://github.com/torrentsec/qbittorrent-protonvpn-docker/issues>
