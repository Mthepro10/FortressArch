#!/usr/bin/env bash
set -euo pipefail

SNAPPER_CONFIG="root"
LOG_TAG="fortress-snapshot"

if ! command -v snapper &> /dev/null; then
    logger -t "$LOG_TAG" "snapper not installed, skipping snapshot"
    exit 0
fi

if ! snapper -c "$SNAPPER_CONFIG" list &> /dev/null; then
    logger -t "$LOG_TAG" "snapper config '$SNAPPER_CONFIG' not found, skipping snapshot"
    exit 0
fi

DESCRIPTION="fortress-pre-update-$(date +%Y%m%d-%H%M%S)"

snapper -c "$SNAPPER_CONFIG" create \
    --description "$DESCRIPTION" \
    --cleanup-algorithm number

logger -t "$LOG_TAG" "snapshot created: $DESCRIPTION"
