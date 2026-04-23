#!/bin/bash -e
install -v -m 755 files/seeed-voicecard-install.sh \
  "${ROOTFS_DIR}/usr/local/bin/seeed-voicecard-install.sh"
install -v -m 644 files/seeed-voicecard-install.service \
  "${ROOTFS_DIR}/etc/systemd/system/seeed-voicecard-install.service"

on_chroot << EOF
# Swap via dphys-swapfile
echo "CONF_SWAPSIZE=512" > /etc/dphys-swapfile
systemctl enable dphys-swapfile.service

# WiFi regulatory domain via NetworkManager (crda removed in trixie)
mkdir -p /etc/NetworkManager/conf.d
cat > /etc/NetworkManager/conf.d/wifi-regdom.conf << 'NM'
[main]
[keyfile]
[device]
wifi.backend=wpa_supplicant
[connection]
wifi.cloned-mac-address=preserve
NM

# Set regulatory domain in wpa_supplicant
echo 'country=PT' > /etc/wpa_supplicant/wpa_supplicant.conf

systemctl daemon-reload
systemctl enable seeed-voicecard-install.service
EOF
