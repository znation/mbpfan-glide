#!/bin/sh
# Install mbpfan-glide as a systemd service. Run as root.
set -e
cd "$(dirname "$0")"
[ "$(id -u)" = 0 ] || { echo "run as root: sudo ./install.sh" >&2; exit 1; }

install -m 755 mbpfan-glide /usr/local/bin/mbpfan-glide
if [ -e /etc/mbpfan-glide.conf ]; then
    echo "keeping existing /etc/mbpfan-glide.conf"
else
    install -m 644 mbpfan-glide.conf /etc/mbpfan-glide.conf
fi
install -m 644 mbpfan-glide.service /etc/systemd/system/mbpfan-glide.service

if systemctl is-enabled --quiet mbpfan 2>/dev/null; then
    systemctl disable --now mbpfan
    echo "disabled mbpfan (re-enable with: systemctl enable --now mbpfan)"
fi
systemctl daemon-reload
systemctl enable --now mbpfan-glide
systemctl --no-pager status mbpfan-glide | head -5
