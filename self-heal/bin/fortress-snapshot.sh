#!/usr/bin/env bash

set -euo pipefail

SNAPPER_CONFIG="root"
LOG_TAG="fortress-snapshot"

# Verificare simpla: snapper si config-ul exista?
if ! command -v snapper &> /dev/null; then
    logger -t "$LOG_TAG" "snapper nu e instalat, sar peste snapshot"
    exit 0
fi

if ! snapper -c "$SNAPPER_CONFIG" list &> /dev/null; then
    logger -t "$LOG_TAG" "configuratia snapper '$SNAPPER_CONFIG' nu exista, sar peste snapshot"
    exit 0
fi

# Creeaza snapshot-ul, cu descriere care marcheaza ca e "pre-update"
# (asa il gaseste scriptul de rollback mai tarziu, cautand dupa tag).
DESCRIPTION="fortress-pre-update-$(date +%Y%m%d-%H%M%S)"

snapper -c "$SNAPPER_CONFIG" create \
    --description "$DESCRIPTION" \
    --cleanup-algorithm number

logger -t "$LOG_TAG" "snapshot creat: $DESCRIPTION"
