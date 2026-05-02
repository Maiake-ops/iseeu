#!/usr/bin/env bash
set -e

echo "[*] Sway dotfiles installer starting..."

REPO="https://github.com/mbrc12/dotfiles-sway.git"
DIR="$HOME/.dotfiles-sway"

# --- Install deps ---
echo "[*] Installing packages..."
sudo pacman -S --needed --noconfirm \
  sway swaybg swayidle swaylock \
  foot wofi waybar \
  grim slurp wl-clipboard \
  network-manager-applet \
  ttf-dejavu ttf-font-awesome \
  git

# --- Clone repo ---
if [ ! -d "$DIR" ]; then
  git clone "$REPO" "$DIR"
else
  git -C "$DIR" pull
fi

# --- Backup old configs ---
mkdir -p "$HOME/.config-backup"
[ -d "$HOME/.config/sway" ] && mv "$HOME/.config/sway" "$HOME/.config-backup/sway-$(date +%s)"

# --- Install configs ---
mkdir -p "$HOME/.config"
cp -r "$DIR/sway" "$HOME/.config/"
cp -r "$DIR/waybar" "$HOME/.config/" 2>/dev/null || true
cp -r "$DIR/wofi" "$HOME/.config/" 2>/dev/null || true

echo "[✓] Done. Run: sway"