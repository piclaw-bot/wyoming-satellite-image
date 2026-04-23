#!/bin/bash -e
on_chroot << EOF
apt-get update
apt-get install -y --no-install-recommends \
  ca-certificates curl wget git vim htop \
  python3 python3-pip python3-venv \
  avahi-daemon jq
EOF
