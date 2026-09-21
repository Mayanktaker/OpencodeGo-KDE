#!/usr/bin/env bash
# © Mayanktaker Computers & Web Development | https://mayanktaker.com
# Installs the GNOME Shell extension into the user extension directory and enables it
set -euo pipefail

# Extension identity must match metadata.json
UUID="com.mayanktaker.opencodego-usage"
# Install target inside the user's home
DEST="$HOME/.local/share/gnome-shell/extensions/$UUID"
# This script's directory (the repo's gnome-extension folder)
SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Copy extension files except dev-only artifacts and this script
mkdir -p "$DEST"
rsync -a --delete --exclude 'install.sh' --exclude 'tests' --exclude '.git' "$SRC/" "$DEST/"

# Compile the gsettings schema into the installed copy
glib-compile-schemas "$DEST/schemas/"

# Enable live; on Wayland a first install may still need logout/login
gnome-extensions enable "$UUID" 2>/dev/null || true

echo "Installed $UUID -> $DEST"
echo "If the panel icon does not appear, log out and back in (Wayland requirement for first install)."
