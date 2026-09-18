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

COUNT=$(cat "$COUNTER_FILE" 2>/dev/null || echo 0)
[[ "$COUNT" =~ ^[0-9]+$ ]] || COUNT=0
COUNT=$((COUNT + 1))
echo "$COUNT" > "$COUNTER_FILE"

logger -t "$LOG_TAG" "boot attempt number $COUNT"

if [[ "$COUNT" -lt "$THRESHOLD" ]]; then
    exit 0
fi

logger -t "$LOG_TAG" "$THRESHOLD failed boots reached, marking rollback as pending"
touch "$STATE_DIR/rollback-pending"
