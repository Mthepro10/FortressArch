#!/usr/bin/env bash
set -euo pipefail

if [[ "$EUID" -ne 0 ]]; then
    echo "Run this as root (sudo ./install.sh)"
    exit 1
fi

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

install -Dm755 "$REPO_DIR"/self-heal/bin/*.sh -t /usr/local/bin/
install -Dm755 "$REPO_DIR"/self-heal/notify/fortress-notify-daemon.sh -t /usr/local/bin/
install -Dm755 "$REPO_DIR"/self-heal/notify/fortress-warning-dialog.py -t /usr/local/bin/
install -Dm644 "$REPO_DIR"/self-heal/pacman-hooks/*.hook -t /etc/pacman.d/hooks/
install -Dm644 "$REPO_DIR"/self-heal/systemd/*.service -t /etc/systemd/system/
install -Dm644 "$REPO_DIR"/self-heal/systemd/*.timer -t /etc/systemd/system/
install -Dm644 "$REPO_DIR"/self-heal/systemd/10-fortress-limits.conf -t /etc/systemd/system.conf.d/
install -Dm644 "$REPO_DIR"/self-heal/systemd-user/fortress-notify-daemon.service -t /usr/lib/systemd/user/
install -Dm440 "$REPO_DIR"/self-heal/sudoers/fortress-survival /etc/sudoers.d/fortress-survival
visudo -c -f /etc/sudoers.d/fortress-survival

systemctl daemon-reload
systemctl enable fortress-boot-attempt.service
systemctl enable fortress-boot-success.service
systemctl enable fortress-boot-rollback.service
systemctl enable fortress-health-check.timer

/usr/local/bin/fortress-state-setup.sh

if ! snapper -c root list &> /dev/null; then
    echo "snapper config 'root' not found."
    echo "Run manually: snapper -c root create-config /"
fi

echo "Install complete. Reboot to activate boot-tracking services."
echo "As your normal user (not root), also run:"
echo "  systemctl --user enable --now fortress-notify-daemon.service"
