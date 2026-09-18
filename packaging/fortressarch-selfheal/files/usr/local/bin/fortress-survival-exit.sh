#!/usr/bin/env bash
set -euo pipefail

STATE_DIR="/var/lib/fortress-arch"
FLAG_FILE="$STATE_DIR/survival-mode"
LOG_TAG="fortress-survival-mode"

if [[ "$EUID" -ne 0 ]]; then
    echo "Run this as root (sudo fortress-survival-exit.sh)"
    exit 1
fi

mount -o remount,rw /
rm -f "$FLAG_FILE"
systemctl isolate graphical.target

logger -t "$LOG_TAG" "survival mode exited"
echo "Survival mode exited."
