#!/usr/bin/env bash
# fortress-boot-attempt.sh
# Ruleaza FOARTE devreme la fiecare boot. Incrementeaza un contor.
# Daca sistemul ajunge sa porneasca cu bine, fortress-boot-success.sh
# reseteaza contorul la 0 mai tarziu in secventa de boot.
#
# Daca boot-ul eueaza de 2 ori la rand fara ca success sa se fi rulat,
# la a treia incercare acest script face rollback automat la ultimul
# snapshot "fortress-pre-update-*" si reporneste sistemul.
#
# Prerechizite: aceleasi ca la fortress-snapshot.sh (btrfs + snapper).

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

logger -t "$LOG_TAG" "incercare de boot numarul $COUNT"

if [[ "$COUNT" -lt "$THRESHOLD" ]]; then
    # Inca nu am atins pragul, boot-ul continua normal.
    exit 0
fi

logger -t "$LOG_TAG" "prag de $THRESHOLD boot-uri esuate atins, incerc rollback"

# Gaseste cel mai recent snapshot marcat "fortress-pre-update-*"
LATEST_SNAPSHOT=$(snapper -c "$SNAPPER_CONFIG" list --columns number,description \
    | grep "fortress-pre-update-" \
    | tail -n 1 \
    | awk '{print $1}')

if [[ -z "$LATEST_SNAPSHOT" ]]; then
    logger -t "$LOG_TAG" "niciun snapshot fortress gasit, nu pot face rollback automat"
    exit 0
fi

# Marcheaza in stare ca s-a facut rollback, ca UI-ul/notificarile
# sa poata informa userul dupa ce reporneste sistemul cu bine.
echo "rollback-to-$LATEST_SNAPSHOT-$(date +%Y%m%d-%H%M%S)" > "$STATE_DIR/last-action"

snapper -c "$SNAPPER_CONFIG" rollback "$LATEST_SNAPSHOT"

echo 0 > "$COUNTER_FILE"

logger -t "$LOG_TAG" "rollback la snapshot $LATEST_SNAPSHOT facut, repornesc"
systemctl reboot
