set -e

g++ -O2 -Wall -o /usr/bin/fortress-guard /root/fortress-guard-src/fortress_guard.cpp
rm -rf /root/fortress-guard-src

systemctl enable fortress-boot-attempt.service
systemctl enable fortress-boot-success.service
systemctl enable fortress-boot-rollback.service
systemctl enable fortress-health-check.timer
systemctl --global enable fortress-notify-daemon.service

systemctl enable gdm.service
systemctl enable NetworkManager.service
systemctl enable bluetooth.service

visudo -c -f /etc/sudoers.d/fortress-survival
