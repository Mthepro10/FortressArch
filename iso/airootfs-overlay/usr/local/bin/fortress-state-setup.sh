#!/usr/bin/env bash
set -euo pipefail

STATE_DIR="/var/lib/fortress-arch"
SUBVOL_NAME="@fortress-state"

if [[ "$EUID" -ne 0 ]]; then
    echo "Run this as root"
    exit 1
fi

if ! findmnt -t btrfs / &> /dev/null; then
    echo "Root filesystem is not btrfs, skipping state isolation"
    exit 0
fi

if mountpoint -q "$STATE_DIR"; then
    echo "State directory is already isolated"
    exit 0
fi

ROOT_DEVICE=$(findmnt -no SOURCE / | sed 's/\[.*//')
ROOT_UUID=$(findmnt -no UUID /)

MOUNT_TMP=$(mktemp -d)
mount -o subvolid=5 "$ROOT_DEVICE" "$MOUNT_TMP"

if [[ ! -d "$MOUNT_TMP/$SUBVOL_NAME" ]]; then
    btrfs subvolume create "$MOUNT_TMP/$SUBVOL_NAME"
fi

umount "$MOUNT_TMP"
rmdir "$MOUNT_TMP"

mkdir -p "$STATE_DIR"

if ! grep -q "$SUBVOL_NAME" /etc/fstab; then
    echo "UUID=$ROOT_UUID $STATE_DIR btrfs subvol=$SUBVOL_NAME,defaults 0 0" >> /etc/fstab
fi

if [[ -n "$(ls -A "$STATE_DIR" 2>/dev/null)" ]]; then
    BACKUP_DIR=$(mktemp -d)
    cp -a "$STATE_DIR"/. "$BACKUP_DIR"/
    mount "$STATE_DIR"
    cp -a "$BACKUP_DIR"/. "$STATE_DIR"/
    rm -rf "$BACKUP_DIR"
else
    mount "$STATE_DIR"
fi

echo "State directory is now isolated on $SUBVOL_NAME, safe across rollbacks"
