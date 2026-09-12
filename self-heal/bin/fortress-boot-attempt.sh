#!/usr/bin/env bash

set -euo pipefail

STATE_DIR="/var/lib/fortress-arch"
COUNTER_FILE="$STATE_DIR/boot-fail-count"
THRESHOLD=2
SNAPPER_CONFIG="root"
LOG_TAG="fortress-boot-attempt"

mkdir -p "$STATE_DIR"

if [[ ! -f "$COUNTER_FILE" ]]; then
    echo 0 > "$COUNTER_FILE"
fi

COUNT=$(cat "$COUNTER_FILE")
COUNT=$((COUNT + 1))
echo "$COUNT" > "$COUNTER_FILE"

logger -t "$LOG_TAG" "trying boot number $COUNT"

if [[ "$COUNT" -lt "$THRESHOLD" ]]; then
    exit 0
fi

logger -t "$LOG_TAG" "failed treshold $THRESHOLD boot touched, trying rollback"

LATEST_SNAPSHOT=$(snapper -c "$SNAPPER_CONFIG" list --columns number,description \
    | grep "fortress-pre-update-" \
    | tail -n 1 \
    | awk '{print $1}')

if [[ -z "$LATEST_SNAPSHOT" ]]; then
    logger -t "$LOG_TAG" "no fortress snaphot found, can't make rollback"
    exit 0
fi

echo "rollback-to-$LATEST_SNAPSHOT-$(date +%Y%m%d-%H%M%S)" > "$STATE_DIR/last-action"

snapper -c "$SNAPPER_CONFIG" rollback "$LATEST_SNAPSHOT"

echo 0 > "$COUNTER_FILE"

logger -t "$LOG_TAG" "rollback la snapshot $LATEST_SNAPSHOT facut, repornesc"
systemctl reboot
