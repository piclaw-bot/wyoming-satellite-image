#!/bin/bash -e
# Pre-install wyoming-satellite only — openwakeword needs tflite which won't
# cross-compile cleanly; use --vad mode instead (voice activity detection)
on_chroot << EOF
python3 -m venv /opt/wyoming-satellite
/opt/wyoming-satellite/bin/pip install --upgrade pip --quiet
/opt/wyoming-satellite/bin/pip install wyoming-satellite --quiet
EOF

# Config and services
install -v -d -m 755 "${ROOTFS_DIR}/etc/wyoming-satellite"
install -v -m 644 files/config.env \
  "${ROOTFS_DIR}/etc/wyoming-satellite/config.env"
install -v -m 644 files/wyoming-satellite.service \
  "${ROOTFS_DIR}/etc/systemd/system/wyoming-satellite.service"

# Boot templates (user edits SSID/password before first boot)
install -v -m 644 files/boot/network-config \
  "${ROOTFS_DIR}/boot/firmware/network-config"
install -v -m 644 files/boot/user-data \
  "${ROOTFS_DIR}/boot/firmware/user-data"

on_chroot << EOF
touch /boot/firmware/meta-data
systemctl daemon-reload
systemctl enable wyoming-satellite.service
EOF
