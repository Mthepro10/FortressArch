#!/usr/bin/env bash
# fortress-ignore-lock.sh — creates/locks the integrity-check ignore file
set -euo pipefail

IGNORE_FILE="/etc/fortress-arch/ignore"
IGNORE_DIR="$(dirname "$IGNORE_FILE")"
LOG_TAG="fortress-ignore-lock"

if [[ "$EUID" -ne 0 ]]; then
    echo "Run this as root" >&2
    exit 1
fi

mkdir -p "$IGNORE_DIR"
[[ -f "$IGNORE_FILE" ]] || touch "$IGNORE_FILE"

chown root:root "$IGNORE_FILE"
chmod 600 "$IGNORE_FILE"

# immutable: even root must explicitly `chattr -i` before writing/deleting
if command -v chattr &> /dev/null; then
    chattr +i "$IGNORE_FILE" 2>/dev/null || \
        logger -t "$LOG_TAG" "chattr +i not supported on this filesystem for $IGNORE_FILE"
fi

logger -t "$LOG_TAG" "ignore file locked: $IGNORE_FILE"
echo "Locked: $IGNORE_FILE (chattr +i, 600, root:root)"
