#!/usr/bin/env bash
set -euo pipefail

STATE_DIR="/var/lib/fortress-arch"
REPORT_FILE="$STATE_DIR/health-report"
LOG_TAG="fortress-health-check"

mkdir -p "$STATE_DIR"

FAILED_UNITS=$(systemctl --failed --no-legend --plain | awk '{print $1}')

if [[ -n "$FAILED_UNITS" ]]; then
    while IFS= read -r unit; do
        [[ -z "$unit" ]] && continue
        logger -t "$LOG_TAG" "restarting failed unit: $unit"
        systemctl restart "$unit" || logger -t "$LOG_TAG" "failed to restart: $unit"
    done <<< "$FAILED_UNITS"
fi

INTEGRITY_ISSUES=$(pacman -Qkk 2>/dev/null | grep -c "warning" || true)
INTEGRITY_THRESHOLD=5

if [[ "$INTEGRITY_ISSUES" -ge "$INTEGRITY_THRESHOLD" ]]; then
    logger -t "$LOG_TAG" "integrity issues found: $INTEGRITY_ISSUES, entering survival mode"
    /usr/local/bin/fortress-survival-mode.sh
fi

ORPHANS=$(pacman -Qtdq 2>/dev/null || true)

BROKEN_LINKS=$(find /etc /usr -xtype l 2>/dev/null || true)

{
    echo "timestamp=$(date --iso-8601=seconds)"
    echo "failed_units_restarted=$(echo "$FAILED_UNITS" | grep -c . || true)"
    echo "orphan_packages_found=$(echo "$ORPHANS" | grep -c . || true)"
    echo "broken_symlinks_found=$(echo "$BROKEN_LINKS" | grep -c . || true)"
} > "$REPORT_FILE"

if [[ -n "$ORPHANS" ]]; then
    logger -t "$LOG_TAG" "orphan packages detected, no automatic action taken"
fi

if [[ -n "$BROKEN_LINKS" ]]; then
    logger -t "$LOG_TAG" "broken symlinks detected, no automatic action taken"
fi

logger -t "$LOG_TAG" "health check complete"
