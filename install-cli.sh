#!/usr/bin/env bash
# © Mayanktaker Computers & Web Development | https://mayanktaker.com
# Script to install opencode-usage CLI executable and shell tab completions

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="$HOME/.local/bin"
TARGET_PATH="$TARGET_DIR/opencode-usage"

# Ensure target bin directory exists
mkdir -p "$TARGET_DIR"

# Create symlink to CLI script
ln -sf "$SCRIPT_DIR/bin/opencode-usage" "$TARGET_PATH"
chmod +x "$TARGET_PATH"

# Install Bash shell completions
BASH_COMP_DIR="$HOME/.local/share/bash-completion/completions"
mkdir -p "$BASH_COMP_DIR"
ln -sf "$SCRIPT_DIR/bin/opencode-usage-completion.bash" "$BASH_COMP_DIR/opencode-usage"

echo "Successfully installed opencode-usage to $TARGET_PATH"
echo "Bash tab completion installed to $BASH_COMP_DIR/opencode-usage"
