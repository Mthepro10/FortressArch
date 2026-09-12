#!/usr/bin/env bash
# fortress-boot-success.sh
# Ruleaza TARZIU in secventa de boot (dupa multi-user.target/graphical.target).
# Daca am ajuns pana aici, boot-ul a reusit -> resetam contorul de esecuri.

set -euo pipefail

STATE_DIR="/var/lib/fortress-arch"
COUNTER_FILE="$STATE_DIR/boot-fail-count"
LOG_TAG="fortress-boot-success"

mkdir -p "$STATE_DIR"
echo 0 > "$COUNTER_FILE"

logger -t "$LOG_TAG" "boot reusit, contor resetat"
