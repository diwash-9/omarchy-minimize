#!/usr/bin/env bash
# uninstall.sh - remove a per-user omarchy-minimize install.
#
# Removes the `omaveil` command and its runtime state. The Hyprland bindings in
# ~/.config/hypr/bindings.lua are left in place so you can remove them by hand.
#
# Usage: ./uninstall.sh

set -euo pipefail

BIN_DIR="${HOME}/.local/bin"

rm -f "$BIN_DIR/omaveil"
rm -rf "${OMAVEIL_STATE_DIR:-/tmp/minimize-state}"
rm -f "${OMAVEIL_LOG:-/tmp/omaveil.log}"
rmdir "$BIN_DIR" 2>/dev/null || true

echo "Removed omaveil and its runtime state."
echo "Note: the omaveil entries in ~/.config/hypr/bindings.lua were left in place."
