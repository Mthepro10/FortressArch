#!/usr/bin/env bash
set -euo pipefail

STATE_DIR="/var/lib/fortress-arch"
COUNTER_FILE="$STATE_DIR/boot-fail-count"
LOG_TAG="fortress-boot-success"

mkdir -p "$STATE_DIR"
echo 0 > "$COUNTER_FILE"

logger -t "$LOG_TAG" "boot successful, counter reset"
