#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ISO_PROFILE_DIR="$HOME/fortressarch-iso"
WORK_DIR="/tmp/archiso-work"
OUT_DIR="$HOME/fortressarch-out"

if [[ "$EUID" -eq 0 ]]; then
    echo "Do not run this script with sudo. It calls sudo itself where needed."
    exit 1
fi

sudo pacman -S --needed --noconfirm archiso git base-devel pacman-contrib

echo "Building fortress-guard package..."
cd "$REPO_DIR/fortress-guard"
makepkg -sf --noconfirm

echo "Building fortressarch-selfheal package..."
cd "$REPO_DIR/packaging/fortressarch-selfheal"
makepkg -sf --noconfirm

rm -rf "$ISO_PROFILE_DIR" "$WORK_DIR"
cp -r /usr/share/archiso/configs/releng "$ISO_PROFILE_DIR"
cd "$ISO_PROFILE_DIR"

cat "$REPO_DIR/iso/packages-extra.txt" >> packages.x86_64
cp -r "$REPO_DIR/iso/airootfs-overlay/"* airootfs/
cat "$REPO_DIR/iso/customize-fortress.sh" >> airootfs/root/customize_airootfs.sh

mkdir -p airootfs/root/local-repo
cp "$REPO_DIR/fortress-guard/"*.pkg.tar.zst airootfs/root/local-repo/
cp "$REPO_DIR/packaging/fortressarch-selfheal/"*.pkg.tar.zst airootfs/root/local-repo/
repo-add airootfs/root/local-repo/custom.db.tar.gz airootfs/root/local-repo/*.pkg.tar.zst

if ! grep -q "^\[custom\]" pacman.conf; then
    sed -i '/^\[core\]/i [custom]\nSigLevel = Optional TrustAll\nServer = file:///root/local-repo\n' pacman.conf
fi

echo ""
echo "profiledef.sh still needs a manual edit before continuing:"
echo "  - add file_permissions entries, see iso/BUILD.md step 7"
echo "  - set iso_name / iso_label / iso_publisher"
echo ""
echo "Opening it now. Save and exit (Ctrl+O, Enter, Ctrl+X) when done."
read -p "Press Enter to open profiledef.sh in nano..."
nano profiledef.sh

sudo mkarchiso -v -w "$WORK_DIR" -o "$OUT_DIR" .

echo "Done. ISO is in $OUT_DIR"
