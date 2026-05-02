#!/usr/bin/env bash
set -e

echo "[*] Hyprland Fish installer starting..."

REPO="https://github.com/lukas0173/Hyprland-dotfiles.git"
DIR="$HOME/.hyprland-dotfiles"

# --- Check system ---
if ! command -v pacman &>/dev/null; then
  echo "[!] Only supports Arch/Artix"
  exit 1
fi

# --- Install dependencies ---
echo "[*] Installing packages..."
sudo pacman -S --needed --noconfirm \
  git hyprland waybar wofi foot \
  grim slurp wl-clipboard \
  networkmanager \
  fish starship fzf eza bat \
  ttf-dejavu ttf-font-awesome

# --- Clone repo ---
echo "[*] Cloning dotfiles..."
if [ ! -d "$DIR" ]; then
  git clone "$REPO" "$DIR"
else
  git -C "$DIR" pull
fi

cd "$DIR"

# --- Remove Zsh configs ---
echo "[*] Removing Zsh configs..."
rm -rf .zshrc .zprofile system/zsh 2>/dev/null || true

# --- Patch scripts (zsh → sh) ---
echo "[*] Patching scripts..."
grep -rl '#!/bin/zsh' . | while read -r file; do
  sed -i '1s|/bin/zsh|/usr/bin/env sh|' "$file"
done

# --- Backup old configs ---
echo "[*] Backing up configs..."
mkdir -p "$HOME/.config-backup"
for dir in hypr waybar wofi; do
  [ -d "$HOME/.config/$dir" ] && mv "$HOME/.config/$dir" "$HOME/.config-backup/$dir-$(date +%s)"
done

# --- Install configs ---
echo "[*] Installing configs..."
mkdir -p "$HOME/.config"
cp -r "$DIR/.config/hypr" "$HOME/.config/" 2>/dev/null || true
cp -r "$DIR/.config/waybar" "$HOME/.config/" 2>/dev/null || true
cp -r "$DIR/.config/wofi" "$HOME/.config/" 2>/dev/null || true

# --- Setup Fish ---
echo "[*] Configuring Fish..."
mkdir -p "$HOME/.config/fish"

cat > "$HOME/.config/fish/config.fish" << 'EOF'
# Starship prompt
starship init fish | source

# Aliases
alias ls="eza"
alias cat="bat"
alias update="sudo pacman -Syu"

# PATH
set -gx PATH $HOME/.local/bin $PATH

# Auto start Hyprland on tty1
if test -z "$WAYLAND_DISPLAY"; and test (tty) = "/dev/tty1"
    exec dbus-run-session Hyprland
end
EOF

# --- Set Fish as default shell ---
if [ "$SHELL" != "/usr/bin/fish" ]; then
  echo "[*] Setting Fish as default shell..."
  chsh -s /usr/bin/fish
fi

# --- Enable seatd (Artix) ---
if [ -d /etc/runit/sv/seatd ]; then
  echo "[*] Enabling seatd..."
  sudo ln -sf /etc/runit/sv/seatd /run/runit/service/
fi

echo "[✓] Done!"
echo "👉 Reboot or login on tty1 to start Hyprland"