# qBittorrent Setup Guide

## 🔐 First-Time Authentication

### Getting Your Initial Password

qBittorrent generates a temporary admin password on first startup.

**Retrieve it with:**

```bash
docker logs qbittorrent 2>&1 | grep "temporary password"
```

**Or get just the password:**

```bash
docker logs qbittorrent 2>&1 | grep -oP '(?<=password is: ).*'
```

### Login

1. Open <http://localhost:8080>
1. Username: `admin`
1. Password: `[temporary password from above]`

### ⚠️ CRITICAL: Set Permanent Password

1. Go to **Tools** → **Options** → **Web UI**
1. Set a new password under "Authentication"
1. Click **Save**

**If you skip this:** You'll need to retrieve the temp password after
every container restart!

## 🔧 Enable Port Sync (Required!)

For automatic port forwarding to work, you MUST enable localhost bypass:

1. **Tools** → **Options** → **Web UI**
1. Scroll to "**Security**" section
1. ✅ **Enable** "Bypass authentication for clients on localhost"
1. Click **Save**
1. Restart qBittorrent: `docker restart qbittorrent`

**Without this:** Port sync mod will fail with authentication errors!

## 🐛 Troubleshooting

### "Unauthorized" Error

**Fix 1 - Disable Header Validation:**

Edit `./qbittorrent/qBittorrent/qBittorrent.conf`:

```ini
[Preferences]
WebUI\HostHeaderValidation=false
WebUI\CSRFProtection=false
```

Restart: `make restart`

**Fix 2 - Use Container IP:**

```bash
docker inspect gluetun | grep IPAddress

# Access via: <http://[IP]:8080>

```

### Port Sync Errors

**Error:**

```text
[GSP] - [ERROR] The "Bypass authentication for clients on
localhost" setting is not set.
```

**Fix:**
- Enable "Bypass authentication for localhost" (see above)
- Restart qBittorrent
- Verify: `docker logs qbittorrent | grep GSP`

### Config File Locations

Try these in order:

```bash
./qbittorrent/qBittorrent/qBittorrent.conf
./qbittorrent/config/qBittorrent.conf

# Or edit inside container:

docker exec -it qbittorrent nano /config/qBittorrent/qBittorrent.conf
```

## ✅ Verification

```bash

# Check VPN

make test-vpn

# Check port forwarding

docker logs gluetun | grep "port forward"

# Check sync mod

docker logs qbittorrent | grep GSP | tail -10
```

## Quick Reference

| Action | Command |
|--------|---------|
| Get temp password | `docker logs qbittorrent 2>&1 \| grep "temporary password"` |
| Access Web UI | <http://localhost:8080> |
| Restart qBittorrent | `docker restart qbittorrent` |
| View logs | `docker logs qbittorrent` |
| Edit config | `docker exec -it qbittorrent nano /config/qBittorrent/qBittorrent.conf` |

For more detailed troubleshooting, see [SETUP_GUIDE.md](../SETUP_GUIDE.md)
