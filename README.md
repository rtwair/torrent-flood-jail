# torrent-flood-jail
# FreeBSD rtorrent + Flood Auto-Startup

Automatically start rtorrent and Flood web interface in FreeBSD jails using screen sessions.

## Overview

This setup provides:
- **rtorrent** running as a dedicated `admin` user in a screen session
- **Flood** web interface for managing rtorrent
- Automatic startup when the FreeBSD jail boots
- Proper service management with rc.d scripts

## Features

- ✅ Auto-starts both services on jail boot
- ✅ Runs each service as appropriate users (rtorrent as `admin`, Flood as `root`)
- ✅ Uses timestamped screen sessions for easy management
- ✅ Includes proper service start/stop functionality
- ✅ Logging for troubleshooting

## Prerequisites

- FreeBSD jail or system
- rtorrent installed (`pkg install rtorrent`)
- Flood installed (`npm install -g flood` or via npm)
- screen installed (`pkg install screen`)
- User `admin` created for running rtorrent

## Installation

### 1. Create the startup script

Save the main startup script as `/usr/local/bin/rtorrent-flood-setup.sh`:

```bash
# Copy the rtorrent-flood-setup.sh script to this location
chmod +x /usr/local/bin/rtorrent-flood-setup.sh
```

### 2. Create the rc.d service script

Save the service script as `/usr/local/etc/rc.d/rtorrent_flood`:

```bash
# Copy the rtorrent_flood rc.d script to this location
chmod +x /usr/local/etc/rc.d/rtorrent_flood
```

### 3. Enable the service

Add to `/etc/rc.conf`:
```
rtorrent_flood_enable="YES"
```

### 4. Configure rtorrent

Ensure your `/usr/home/admin/.rtorrent.rc` includes:

```
# Basic settings
directory = /usr/home/admin/downloads
session = /usr/home/admin/.session

# SCGI interface for Flood (required)
scgi_port = 127.0.0.10:5000

# Create necessary directories
execute.throw = sh, -c, (cat, "mkdir -p ", "/usr/home/admin/downloads")
execute.throw = sh, -c, (cat, "mkdir -p ", "/usr/home/admin/.session")
```

### 5. Set proper permissions

```bash
# Create and set permissions for rtorrent directories
mkdir -p /usr/home/admin/{downloads,.session}
chown -R admin:admin /usr/home/admin/{downloads,.session}
chmod -R 755 /usr/home/admin/{downloads,.session}

# Ensure temp directories are accessible
chmod 1777 /tmp /var/tmp
```

## Usage

### Starting the services
```bash
service rtorrent_flood start
```

### Stopping the services
```bash
service rtorrent_flood stop
```

### Accessing the services

- **Flood Web Interface**: `http://flood.rtp.lan` 
- **Screen Sessions**: `screen -ls` to list, `screen -r rtorrent-[timestamp]` to attach

### Managing screen sessions

```bash
# List all screen sessions
screen -ls

# Attach to the rtorrent/flood session
screen -r rtorrent-20250530_143025

# Switch between windows in screen
# Ctrl+A then 0 (rtorrent window)
# Ctrl+A then 1 (flood window)

# Detach from screen session
# Ctrl+A then d
```

## Configuration

### Flood Connection Settings

When first accessing Flood's web interface, configure the rtorrent connection:

- **Connection Type**: TCP
- **Hostname**: 127.0.0.10
- **Port**: 5000
- **Username**: (leave blank unless configured)
- **Password**: (leave blank unless configured)

### Customization

Edit `/usr/local/bin/rtorrent-flood-setup.sh` to modify:
- User accounts
- Directory paths  
- Flood bind address/port
- Startup delays

## Troubleshooting

### Check service status
```bash
service rtorrent_flood status
```

### View logs
```bash
tail -f /var/log/flood.log
tail -f /var/log/rtorrent-flood.log
```

### Common issues

**Flood can't connect to rtorrent:**
- Verify rtorrent is running: `screen -ls`
- Check SCGI port is listening: `sockstat -l | grep 5000`
- Ensure rtorrent config has `scgi_port = 127.0.0.10:5000`

**Permission errors when adding torrents:**
- Check temp directory permissions: `ls -la /tmp`
- Verify download directory ownership: `ls -la /usr/home/admin/downloads`

**Services don't start on boot:**
- Confirm `rtorrent_flood_enable="YES"` in `/etc/rc.conf`
- Check script permissions: `ls -la /usr/local/etc/rc.d/rtorrent_flood`

### Manual debugging

Run the startup script manually to test:
```bash
/usr/local/bin/rtorrent-flood-setup.sh
```

## File Structure

```
/usr/local/bin/rtorrent-flood-setup.sh    # Main startup script
/usr/local/etc/rc.d/rtorrent_flood         # Service script
/usr/home/admin/.rtorrent.rc               # rtorrent configuration
/usr/home/admin/downloads/                 # Download directory
/usr/home/admin/.session/                  # rtorrent session files
/var/log/flood.log                         # Flood logs
/var/log/rtorrent-flood.log               # Service logs
```

**Note**: This setup is designed for FreeBSD jails but can be adapted for regular FreeBSD systems with minor modifications.
