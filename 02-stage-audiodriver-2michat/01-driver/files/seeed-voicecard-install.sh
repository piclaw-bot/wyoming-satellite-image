#!/bin/bash -e
# Installs the ReSpeaker 2-Mic HAT driver (seeed-voicecard via DKMS).
# Runs once on first boot via systemd, then disables itself.
# Requires: build-essential dkms raspberrypi-kernel-headers

set -euo pipefail
LOG=/var/log/seeed-voicecard-install.log
exec >> "$LOG" 2>&1

echo "[$(date)] Starting seeed-voicecard installation"

# Detect running kernel version (e.g. 6.6)
KERNEL=$(uname -r)
KVER=$(echo "$KERNEL" | grep -oP '^\d+\.\d+')
echo "[$(date)] Kernel: $KERNEL  (major.minor: $KVER)"

# Check branch exists in HinTak repo
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

dkms add    -m "$MOD" -v "$VER"
dkms build  -m "$MOD" -v "$VER" -k "$KERNEL"
dkms install --force -m "$MOD" -v "$VER" -k "$KERNEL"

# Copy overlays and config
OVERLAYS=/boot/overlays
[ -d /boot/firmware/overlays ] && OVERLAYS=/boot/firmware/overlays
cp seeed-*-voicecard.dtbo "$OVERLAYS/"

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
grep -q "^dtoverlay=i2s-mmap$" "$CONFIG" || echo "dtoverlay=i2s-mmap" >> "$CONFIG"
grep -q "^dtoverlay=seeed-2mic-voicecard$" "$CONFIG" || \
  echo "dtoverlay=seeed-2mic-voicecard" >> "$CONFIG"

rm -rf "$WORKDIR"

echo "[$(date)] seeed-voicecard installed successfully. Disabling this service."
systemctl disable seeed-voicecard-install.service

echo "[$(date)] Done — reboot to activate the driver."
