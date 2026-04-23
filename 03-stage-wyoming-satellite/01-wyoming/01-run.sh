#!/bin/bash -e
# Install wyoming-satellite + openWakeWord as native systemd services.
# No Docker required.

# Config directory
install -v -d -m 755                              "${ROOTFS_DIR}/etc/wyoming-satellite"
install -v -m 644 files/config.env                "${ROOTFS_DIR}/etc/wyoming-satellite/config.env"

# Install scripts
install -v -m 755 files/wyoming-install.sh        "${ROOTFS_DIR}/usr/local/bin/wyoming-install.sh"

# Systemd services
install -v -m 644 files/wyoming-install.service   "${ROOTFS_DIR}/etc/systemd/system/wyoming-install.service"
install -v -m 644 files/wyoming-satellite.service "${ROOTFS_DIR}/etc/systemd/system/wyoming-satellite.service"
install -v -m 644 files/wyoming-openwakeword.service "${ROOTFS_DIR}/etc/systemd/system/wyoming-openwakeword.service"

on_chroot << EOF
systemctl daemon-reload
systemctl enable wyoming-install.service
# wyoming-satellite and wyoming-openwakeword are enabled by wyoming-install.sh after install
EOF
