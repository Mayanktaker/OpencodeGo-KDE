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

# Enable live when the running shell already knows the extension
if gnome-extensions enable "$UUID" 2>/dev/null; then
    echo "Enabled $UUID in the running shell."
else
    # A shell that started before this install has never seen the directory, and
    # GNOME offers no rescan: queue the extension in dconf so it comes up enabled.
    CURRENT="$(dconf read /org/gnome/shell/enabled-extensions 2>/dev/null || true)"
    case "$CURRENT" in
        *"$UUID"*) ;;
        *)
            if [ -z "$CURRENT" ] || [ "$CURRENT" = "@a[]" ]; then
                dconf write /org/gnome/shell/enabled-extensions "['$UUID']"
            else
                UPDATED="${CURRENT%\]]}, '$UUID']"
                dconf write /org/gnome/shell/enabled-extensions "${UPDATED//\'/\'}"
            fi
            ;;
    esac
    echo "Queued $UUID for next login (the running shell cannot pick up new extensions)."
fi

echo "Installed $UUID -> $DEST"
echo "Log out and back in, then: hover the panel icon. Settings: gnome-extensions prefs $UUID"
