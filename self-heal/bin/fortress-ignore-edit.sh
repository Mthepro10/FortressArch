#!/usr/bin/env bash
# fortress-ignore-edit.sh — safely unlock, edit, and re-lock the ignore file
set -euo pipefail

IGNORE_FILE="/etc/fortress-arch/ignore"
LOG_TAG="fortress-ignore-lock"

if [[ "$EUID" -ne 0 ]]; then
    echo "Run this as root (sudo fortress-ignore-edit.sh)" >&2
    exit 1
fi

if [[ ! -f "$IGNORE_FILE" ]]; then
    echo "Ignore file not found — run fortress-ignore-lock.sh first" >&2
    exit 1
fi

if command -v chattr &> /dev/null; then
    chattr -i "$IGNORE_FILE" 2>/dev/null || true
fi
logger -t "$LOG_TAG" "ignore file temporarily unlocked for edit by uid=${SUDO_UID:-$EUID}"

"${EDITOR:-nano}" "$IGNORE_FILE"

chown root:root "$IGNORE_FILE"
chmod 600 "$IGNORE_FILE"
if command -v chattr &> /dev/null; then
    chattr +i "$IGNORE_FILE" 2>/dev/null || true
fi
logger -t "$LOG_TAG" "ignore file re-locked after edit"
echo "Re-locked: $IGNORE_FILE"
