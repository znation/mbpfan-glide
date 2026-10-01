#!/bin/sh
# Remove mbpfan-glide; the fans return to the SMC's automatic control.
# Leaves /etc/mbpfan-glide.conf in place. Run as root.
set -e
[ "$(id -u)" = 0 ] || { echo "run as root: sudo ./uninstall.sh" >&2; exit 1; }

systemctl disable --now mbpfan-glide 2>/dev/null || true
rm -f /etc/systemd/system/mbpfan-glide.service /usr/local/bin/mbpfan-glide
systemctl daemon-reload
echo "removed mbpfan-glide; /etc/mbpfan-glide.conf kept"
