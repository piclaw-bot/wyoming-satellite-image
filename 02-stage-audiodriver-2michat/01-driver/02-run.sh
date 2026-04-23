#!/bin/bash -e
# Install the seeed-voicecard systemd service that builds/installs
# the DKMS driver on first boot (kernel headers must match running kernel).

install -v -m 755 files/seeed-voicecard-install.sh "${ROOTFS_DIR}/usr/local/bin/seeed-voicecard-install.sh"
install -v -m 644 files/seeed-voicecard-install.service "${ROOTFS_DIR}/etc/systemd/system/seeed-voicecard-install.service"

on_chroot << EOF
systemctl daemon-reload
systemctl enable seeed-voicecard-install.service
EOF
