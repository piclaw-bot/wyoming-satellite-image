#!/bin/bash -e
# Install the seeed-voicecard systemd service.
# Runs on first boot — DKMS kernel module compile is slow on Pi Zero 2W,
# so we run it at idle priority (nice 19, ionice idle) and reboot when done.

install -v -m 755 files/seeed-voicecard-install.sh        "${ROOTFS_DIR}/usr/local/bin/seeed-voicecard-install.sh"
install -v -m 644 files/seeed-voicecard-install.service   "${ROOTFS_DIR}/etc/systemd/system/seeed-voicecard-install.service"

# Add 512MB swap file to help DKMS compile on 512MB RAM devices
on_chroot << EOF
# Create swap
dd if=/dev/zero of=/swapfile bs=1M count=512 status=progress
chmod 600 /swapfile
mkswap /swapfile
echo '/swapfile none swap sw 0 0' >> /etc/fstab

# Enable services
systemctl daemon-reload
systemctl enable seeed-voicecard-install.service
EOF
