#!/bin/bash -e
install -v -m 755 files/seeed-voicecard-install.sh \
  "${ROOTFS_DIR}/usr/local/bin/seeed-voicecard-install.sh"
install -v -m 644 files/seeed-voicecard-install.service \
  "${ROOTFS_DIR}/etc/systemd/system/seeed-voicecard-install.service"

on_chroot << EOF
# Swap via dphys-swapfile (auto-sized, no mkswap issues)
echo "CONF_SWAPSIZE=512" > /etc/dphys-swapfile
systemctl enable dphys-swapfile.service

# WiFi regulatory domain — default PT, overrideable via cloud-init
echo 'REGDOMAIN=PT' > /etc/default/crda

systemctl daemon-reload
systemctl enable seeed-voicecard-install.service
EOF
