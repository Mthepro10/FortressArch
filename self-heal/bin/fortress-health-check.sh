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

INTEGRITY_THRESHOLD=5
STALE_LOCK="/var/lib/pacman/db.lck"

if [[ -f "$STALE_LOCK" ]] && ! pgrep -x pacman &> /dev/null; then
    logger -t "$LOG_TAG" "removing stale pacman lock from an interrupted transaction"
    rm -f "$STALE_LOCK"
fi

INTEGRITY_LINES=$(pacman -Qkk 2>/dev/null | grep -oE "/(usr/(bin|lib)|boot)/[^ ]+" || true)
INTEGRITY_ISSUES=$(echo "$INTEGRITY_LINES" | grep -c "." || true)

if [[ "$INTEGRITY_ISSUES" -ge "$INTEGRITY_THRESHOLD" ]]; then
    AFFECTED_PACKAGES=$(echo "$INTEGRITY_LINES" | sort -u | while read -r f; do pacman -Qoq "$f" 2>/dev/null; done | sort -u)
    for pkg in $AFFECTED_PACKAGES; do
        logger -t "$LOG_TAG" "reinstalling $pkg to repair corrupted files"
        pacman -S --noconfirm --overwrite '*' "$pkg" || logger -t "$LOG_TAG" "failed to repair $pkg"
    done

    REMAINING=$(pacman -Qkk 2>/dev/null | grep -oE "/(usr/(bin|lib)|boot)/[^ ]+" | grep -c "." || true)
    if [[ "$REMAINING" -ge "$INTEGRITY_THRESHOLD" ]]; then
        logger -t "$LOG_TAG" "repair did not resolve all issues, requesting user confirmation"
        touch "$STATE_DIR/survival-prompt-needed"
    fi
    INTEGRITY_ISSUES="$REMAINING"
fi

ORPHANS=$(pacman -Qtdq 2>/dev/null || true)

BROKEN_LINKS=$(find /usr -xtype l 2>/dev/null || true)

if [[ -n "$BROKEN_LINKS" ]]; then
    while IFS= read -r link; do
        [[ -z "$link" ]] && continue
        OWNER=$(pacman -Qoq "$link" 2>/dev/null || true)
        if [[ -n "$OWNER" ]]; then
            logger -t "$LOG_TAG" "reinstalling $OWNER to fix broken symlink $link"
            pacman -S --noconfirm --overwrite '*' "$OWNER" || true
        fi
    done <<< "$BROKEN_LINKS"
fi

BROKEN_LINKS_REMAINING=$(find /usr -xtype l 2>/dev/null || true)

{
    echo "timestamp=$(date --iso-8601=seconds)"
    echo "failed_units_restarted=$(echo "$FAILED_UNITS" | grep -c . || true)"
    echo "orphan_packages_found=$(echo "$ORPHANS" | grep -c . || true)"
    echo "integrity_issues_remaining=$INTEGRITY_ISSUES"
    echo "broken_symlinks_remaining=$(echo "$BROKEN_LINKS_REMAINING" | grep -c . || true)"
} > "$REPORT_FILE"

if [[ -n "$ORPHANS" ]]; then
    logger -t "$LOG_TAG" "orphan packages detected, no automatic action taken"
fi

logger -t "$LOG_TAG" "health check complete"
