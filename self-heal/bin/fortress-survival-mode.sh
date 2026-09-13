#!/usr/bin/env bash
set -euo pipefail

STATE_DIR="/var/lib/fortress-arch"
FLAG_FILE="$STATE_DIR/survival-mode"
LOG_TAG="fortress-survival-mode"

mkdir -p "$STATE_DIR"

if [[ -f "$FLAG_FILE" ]]; then
    exit 0
fi

logger -t "$LOG_TAG" "entering survival mode"

echo "$(date --iso-8601=seconds)" > "$FLAG_FILE"

mount -o remount,ro /

systemctl isolate multi-user.target

logger -t "$LOG_TAG" "survival mode active, waiting for user input"
