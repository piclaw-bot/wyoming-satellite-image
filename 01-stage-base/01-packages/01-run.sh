#!/bin/bash -e
on_chroot << EOF
apt-get update
apt-get install -y \
  ca-certificates curl wget git vim htop \
  python3 python3-pip python3-venv \
  avahi-daemon \
  i2c-tools alsa-utils libasound2-plugins \
  jq
EOF
