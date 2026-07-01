#!/bin/bash
set -e

echo "Starting cache cleanup..."

# 1. Clear APT cache
echo "Cleaning APT cache..."
apt-get clean

# 2. Clear systemd journal logs older than 2 days
echo "Vacuuming systemd journal logs older than 2 days..."
journalctl --vacuum-time=2d

# 3. Clear thumbnail cache (~/.cache/thumbnails)
echo "Removing user thumbnail caches..."
rm -rf ~/.cache/thumbnails/*

# 4. Clear /tmp directory files older than 1 day
echo "Cleaning /tmp directory..."
find /tmp -type f -mtime +1 -exec rm -f {} \; 2>/dev/null || true

# 5. Clear DNS cache (systemd-resolved)
if systemctl is-active --quiet systemd-resolved; then
    echo "Flushing systemd-resolved DNS cache..."
    resolvectl flush-caches
fi

# 6. Clear memory caches (pagecache, dentries, and inodes)
echo "Clearing memory cache..."
sync
echo 3 > /proc/sys/vm/drop_caches

echo "Cache cleanup completed."
