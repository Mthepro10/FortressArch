#!/usr/bin/env bash
set -euo pipefail

STATE_DIR="/var/lib/fortress-arch"
PROMPT_FLAG="$STATE_DIR/survival-prompt-needed"
LAST_ACTION_FILE="$STATE_DIR/last-action"
SEEN_ACTION_FILE="$HOME/.cache/fortress-arch-seen-action"

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
done

