#!/usr/bin/env bash
set -euo pipefail

STATE_DIR="/var/lib/fortress-arch"
PROMPT_FLAG="$STATE_DIR/survival-prompt-needed"
LAST_ACTION_FILE="$STATE_DIR/last-action"
HEALTH_REPORT="$STATE_DIR/health-report"
SEEN_ACTION_FILE="$HOME/.cache/fortress-arch-seen-action"
SEEN_ORPHANS_FILE="$HOME/.cache/fortress-arch-seen-orphans"

mkdir -p "$(dirname "$SEEN_ACTION_FILE")"

while true; do
    inotifywait -q -e create -e modify "$STATE_DIR" 2>/dev/null || true

    if [[ -f "$PROMPT_FLAG" ]]; then
        notify-send -u critical "FortressArch" "System integrity issue detected"
        python3 /usr/local/bin/fortress-warning-dialog.py
    fi

    if [[ -f "$LAST_ACTION_FILE" ]]; then
        CURRENT_ACTION=$(cat "$LAST_ACTION_FILE")
        SEEN_ACTION=""
        [[ -f "$SEEN_ACTION_FILE" ]] && SEEN_ACTION=$(cat "$SEEN_ACTION_FILE")
        if [[ "$CURRENT_ACTION" != "$SEEN_ACTION" ]]; then
            notify-send "FortressArch" "System was automatically rolled back: $CURRENT_ACTION"
            echo "$CURRENT_ACTION" > "$SEEN_ACTION_FILE"
        fi
    fi

    if [[ -f "$HEALTH_REPORT" ]]; then
        ORPHAN_COUNT=$(grep "^orphan_packages_found=" "$HEALTH_REPORT" | cut -d= -f2)
        SEEN_ORPHANS=""
        [[ -f "$SEEN_ORPHANS_FILE" ]] && SEEN_ORPHANS=$(cat "$SEEN_ORPHANS_FILE")
        if [[ -n "$ORPHAN_COUNT" && "$ORPHAN_COUNT" -gt 0 && "$ORPHAN_COUNT" != "$SEEN_ORPHANS" ]]; then
            notify-send "FortressArch" "$ORPHAN_COUNT orphan package(s) found. Review with: pacman -Qtdq"
            echo "$ORPHAN_COUNT" > "$SEEN_ORPHANS_FILE"
        fi
    fi
done
