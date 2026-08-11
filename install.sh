#!/usr/bin/env bash
# © Mayanktaker Computers & Web Development | https://mayanktaker.com
# Installation and upgrade script for OpenCode Go KDE Plasmoid & CLI Utility

set -e

PLASMOID_ID="com.mayanktaker.opencodego-usage"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Installing OpenCode Go Usage Plasmoid ($PLASMOID_ID)..."

# Check if kpackagetool6 is available
if ! command -v kpackagetool6 &> /dev/null; then
    echo "Error: kpackagetool6 not found. Make sure KDE Plasma 6 development tools are installed."
    exit 1
fi

# Try upgrading first, if fails try installing
if kpackagetool6 -t Plasma/Applet --list | grep -q "$PLASMOID_ID"; then
    echo "Upgrading existing plasmoid..."
    kpackagetool6 -t Plasma/Applet -u "$SCRIPT_DIR"
else
    echo "Installing new plasmoid..."
    kpackagetool6 -t Plasma/Applet -i "$SCRIPT_DIR"
fi

# Install custom MT OpenCode Go branding icon to user system icon theme
echo "Installing custom MT branding icons to hicolor icon theme..."
mkdir -p "$HOME/.local/share/icons/hicolor/scalable/apps/"
mkdir -p "$HOME/.local/share/icons/hicolor/128x128/apps/"
mkdir -p "$HOME/.local/share/icons/hicolor/48x48/apps/"

if [ -f "$SCRIPT_DIR/assets/icon.svg" ]; then
    cp "$SCRIPT_DIR/assets/icon.svg" "$HOME/.local/share/icons/hicolor/scalable/apps/$PLASMOID_ID.svg"
fi

python3 -c "
from PIL import Image
try:
    img = Image.open('$SCRIPT_DIR/assets/branding-icon.jpg')
    img.resize((128, 128)).save('$HOME/.local/share/icons/hicolor/128x128/apps/$PLASMOID_ID.png')
    img.resize((48, 48)).save('$HOME/.local/share/icons/hicolor/48x48/apps/$PLASMOID_ID.png')
except Exception as e:
    pass
" 2>/dev/null || true

# Rebuild system icon cache
kbuildsycoca6 &>/dev/null || true

# Clear Qt QML bytecode cache so plasmashell reads fresh files
echo "Clearing Plasma QML bytecode cache..."
rm -rf "$HOME/.cache/plasmashell/qmlcache/" "$HOME/.cache/plasmawindowed/qmlcache/" 2>/dev/null || true

# Install CLI tool globally
"$SCRIPT_DIR/install-cli.sh"

echo "Setup Complete! Plasmoid updated, custom MT icon installed to system theme, cache cleared, and 'opencode-usage' CLI tool added to PATH."
