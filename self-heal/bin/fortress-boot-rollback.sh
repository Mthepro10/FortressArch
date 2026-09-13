#!/usr/bin/env bash
set -euo pipefail

STATE_DIR="/var/lib/fortress-arch"
PENDING_FLAG="$STATE_DIR/rollback-pending"
COUNTER_FILE="$STATE_DIR/boot-fail-count"
SNAPPER_CONFIG="root"
LOG_TAG="fortress-boot-rollback"

mkdir -p "$STATE_DIR"

if [[ ! -f "$PENDING_FLAG" ]]; then
    exit 0
fi

logger -t "$LOG_TAG" "pending rollback found, searching for snapshot"

LATEST_SNAPSHOT=$(snapper -c "$SNAPPER_CONFIG" list --columns number,description \
    | grep "fortress-pre-update-" \
    | tail -n 1 \
    | awk '{print $1}')

if [[ -z "$LATEST_SNAPSHOT" ]]; then
    logger -t "$LOG_TAG" "no fortress snapshot found, cannot roll back automatically"
    rm -f "$PENDING_FLAG"
    exit 0
fi

echo "rollback-to-$LATEST_SNAPSHOT-$(date +%Y%m%d-%H%M%S)" > "$STATE_DIR/last-action"

snapper -c "$SNAPPER_CONFIG" rollback "$LATEST_SNAPSHOT"

echo 0 > "$COUNTER_FILE"
rm -f "$PENDING_FLAG"

logger -t "$LOG_TAG" "rolled back to snapshot $LATEST_SNAPSHOT, rebooting"
reboot -f
