#!/bin/bash -e
# Pre-install wyoming-satellite and wyoming-openwakeword into Python venvs
# during image build. No first-boot pip install needed.

on_chroot << EOF
# Install wyoming-satellite
python3 -m venv /opt/wyoming-satellite
/opt/wyoming-satellite/bin/pip install --upgrade pip --quiet
/opt/wyoming-satellite/bin/pip install wyoming-satellite --quiet

# Install wyoming-openwakeword
python3 -m venv /opt/wyoming-openwakeword
/opt/wyoming-openwakeword/bin/pip install --upgrade pip --quiet
/opt/wyoming-openwakeword/bin/pip install wyoming-openwakeword --quiet
EOF

# Config directory
install -v -d -m 755                              "${ROOTFS_DIR}/etc/wyoming-satellite"
install -v -m 644 files/config.env                "${ROOTFS_DIR}/etc/wyoming-satellite/config.env"

# Systemd services (satellite is ready to run immediately after first boot)
install -v -m 644 files/wyoming-satellite.service    "${ROOTFS_DIR}/etc/systemd/system/wyoming-satellite.service"
install -v -m 644 files/wyoming-openwakeword.service "${ROOTFS_DIR}/etc/systemd/system/wyoming-openwakeword.service"

on_chroot << EOF
systemctl daemon-reload
systemctl enable wyoming-openwakeword.service
systemctl enable wyoming-satellite.service
EOF
