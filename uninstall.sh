#!/usr/bin/env bash
set -euo pipefail

INSTALL_DIR="$HOME/.config/quickshell-stickynotes"
HYPR_CONF="$HOME/.config/hypr/hyprland.conf"

echo "Uninstalling quickshell-stickynotes..."

if [ -d "$INSTALL_DIR" ]; then
    rm -rf "$INSTALL_DIR"
    echo "Removed $INSTALL_DIR"
fi

if [ -f "$HYPR_CONF" ]; then
    # Remove the marker comment and the exec-once line that follows it
    sed -i '/# quickshell-stickynotes autostart/,+1d' "$HYPR_CONF"
    echo "Removed autostart line from $HYPR_CONF"
fi

read -p "Also delete saved notes data (~/.local/share/quickshell-stickynotes)? [y/N] " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    rm -rf "$HOME/.local/share/quickshell-stickynotes"
    echo "Removed notes data."
fi

echo "Done."
