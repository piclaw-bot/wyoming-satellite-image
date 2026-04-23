#!/bin/bash -e

on_chroot << EOF
apt-get clean
rm -rf /var/cache/apt/archives/* /var/cache/apt/*.bin /var/lib/apt/lists/*
rm -rf /tmp/*
# Regenerate SSH host keys on first boot
rm -f /etc/ssh/ssh_host_*
touch /etc/ssh/reconfigure
EOF
