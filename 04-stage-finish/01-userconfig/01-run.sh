#!/bin/bash -e
# Ensure the pi user exists and set a default password
on_chroot << EOF
id pi || useradd -m -s /bin/bash pi
echo "pi:raspberry" | chpasswd
usermod -aG sudo,audio,video,spi,i2c pi
EOF
