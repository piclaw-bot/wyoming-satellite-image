#!/bin/bash -e
# Installs wyoming-satellite and wyoming-openwakeword into Python venvs.
# Runs once on first boot via systemd, then enables the satellite services.

set -euo pipefail
LOG=/var/log/wyoming-install.log
exec >> "$LOG" 2>&1

echo "[$(date)] Installing wyoming-satellite and wyoming-openwakeword"

# wyoming-satellite
python3 -m venv /opt/wyoming-satellite
/opt/wyoming-satellite/bin/pip install --upgrade pip
/opt/wyoming-satellite/bin/pip install wyoming-satellite

# wyoming-openwakeword
python3 -m venv /opt/wyoming-openwakeword
/opt/wyoming-openwakeword/bin/pip install --upgrade pip
/opt/wyoming-openwakeword/bin/pip install wyoming-openwakeword

echo "[$(date)] Installation complete. Enabling services."

systemctl enable wyoming-openwakeword.service
systemctl enable wyoming-satellite.service
systemctl start  wyoming-openwakeword.service
systemctl start  wyoming-satellite.service

systemctl disable wyoming-install.service
echo "[$(date)] Done."
