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

sync

REMOUNT_OK=0
for attempt in 1 2 3; do
    if mount -o remount,ro / 2>/dev/null; then
        REMOUNT_OK=1
        break
    fi
    sleep 2
    sync
done

if [[ "$REMOUNT_OK" -eq 0 ]]; then
    logger -t "$LOG_TAG" "could not remount root read-only after 3 attempts, continuing with service isolation only"
fi

systemctl isolate multi-user.target

logger -t "$LOG_TAG" "survival mode active, waiting for user input"
