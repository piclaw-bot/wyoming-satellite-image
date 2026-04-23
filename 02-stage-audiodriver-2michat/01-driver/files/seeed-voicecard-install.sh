#!/bin/bash -e
# Installs the ReSpeaker 2-Mic HAT driver (seeed-voicecard via DKMS) on first boot.
# Runs at idle priority to keep the system responsive during compile.
# Self-disables after success.

set -euo pipefail
LOG=/var/log/seeed-voicecard-install.log
exec >> "$LOG" 2>&1

echo "[$(date)] Starting seeed-voicecard installation (idle priority)"

# Detect running kernel version (e.g. 6.6)
KERNEL=$(uname -r)
KVER=$(echo "$KERNEL" | grep -oP '^\d+\.\d+')
echo "[$(date)] Kernel: $KERNEL  (major.minor: $KVER)"

# Ensure headers are installed for this kernel
apt-get update -qq
apt-get install -y --no-install-recommends \
  raspberrypi-kernel-headers \
  dkms build-essential 2>&1 || \
apt-get install -y --no-install-recommends \
  linux-headers-"$KERNEL" \
  dkms build-essential 2>&1 || true

# Check branch exists
BRANCH="v${KVER}"
STATUS=$(curl -s -o /dev/null -w "%{http_code}" \
  "https://github.com/HinTak/seeed-voicecard/archive/refs/heads/${BRANCH}.tar.gz")
if [ "$STATUS" != "200" ]; then
  echo "[$(date)] ERROR: no seeed-voicecard branch for kernel $KVER (HTTP $STATUS)"
  exit 1
fi

WORKDIR=$(mktemp -d)
cd "$WORKDIR"

echo "[$(date)] Downloading seeed-voicecard $BRANCH"
curl -fsSL "https://github.com/HinTak/seeed-voicecard/archive/refs/heads/${BRANCH}.tar.gz" \
  | tar -xz --strip-components=1

MOD=seeed-voicecard
VER="$KVER"

mkdir -p "/usr/src/${MOD}-${VER}"
cp -a ./ "/usr/src/${MOD}-${VER}/"

# Build at idle priority
nice -n 19 ionice -c3 dkms add    -m "$MOD" -v "$VER"
nice -n 19 ionice -c3 dkms build  -m "$MOD" -v "$VER" -k "$KERNEL"
nice -n 19 ionice -c3 dkms install --force -m "$MOD" -v "$VER" -k "$KERNEL"

# Copy overlays and config
OVERLAYS=/boot/overlays
[ -d /boot/firmware/overlays ] && OVERLAYS=/boot/firmware/overlays
cp seeed-*-voicecard.dtbo "$OVERLAYS/" 2>/dev/null || true

mkdir -p /etc/voicecard
cp *.conf /etc/voicecard/ 2>/dev/null || true
cp *.state /etc/voicecard/ 2>/dev/null || true

# Kernel modules
grep -qx "snd-soc-seeed-voicecard" /etc/modules || echo "snd-soc-seeed-voicecard" >> /etc/modules
grep -qx "snd-soc-wm8960"          /etc/modules || echo "snd-soc-wm8960"          >> /etc/modules

# boot config
CONFIG=/boot/config.txt
[ -f /boot/firmware/config.txt ] && CONFIG=/boot/firmware/config.txt
sed -i 's/#dtparam=i2c_arm=on/dtparam=i2c_arm=on/' "$CONFIG" || true
sed -i 's/#dtparam=i2s=on/dtparam=i2s=on/'         "$CONFIG" || true
grep -q "^dtoverlay=i2s-mmap$"               "$CONFIG" || echo "dtoverlay=i2s-mmap"               >> "$CONFIG"
grep -q "^dtoverlay=seeed-2mic-voicecard$"    "$CONFIG" || echo "dtoverlay=seeed-2mic-voicecard"    >> "$CONFIG"

rm -rf "$WORKDIR"

echo "[$(date)] seeed-voicecard installed — disabling service and rebooting"
systemctl disable seeed-voicecard-install.service
touch /var/lib/seeed-voicecard-installed

# Reboot to load the new driver
reboot
