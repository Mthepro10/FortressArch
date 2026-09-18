#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REPO_PAGES_DIR="$REPO_DIR/docs/repo"

echo "Building fortressarch-selfheal..."
cd "$REPO_DIR/packaging/fortressarch-selfheal"
makepkg -sf --noconfirm

echo "Building fortress-guard..."
cd "$REPO_DIR/fortress-guard"
makepkg -sf --noconfirm

mkdir -p "$REPO_PAGES_DIR"
cp "$REPO_DIR/packaging/fortressarch-selfheal/"*.pkg.tar.zst "$REPO_PAGES_DIR/"
cp "$REPO_DIR/fortress-guard/"*.pkg.tar.zst "$REPO_PAGES_DIR/"

cd "$REPO_PAGES_DIR"
repo-add fortressarch.db.tar.gz *.pkg.tar.zst

echo ""
echo "New package version staged in docs/repo/."
echo "Now commit and push this repo (git add, git commit, git push) to"
echo "publish it. Installed systems will get it on their next"
echo "'sudo pacman -Syu'."
