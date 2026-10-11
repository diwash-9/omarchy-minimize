#!/usr/bin/env bash
# install.sh - per-user install of omarchy-minimize (no package manager needed).
#
# Installs the `omaveil` command to ~/.local/bin and adds the Super+H / Super+I
# / Super+U / Super+Shift+U Hyprland bindings to ~/.config/hypr/bindings.lua.
#
# Usage: ./install.sh [--no-bind] [--help]

set -euo pipefail

REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="${HOME}/.local/bin"
BINDINGS="${HOME}/.config/hypr/bindings.lua"

ADD_BIND=true
while (($# > 0)); do
  case "$1" in
    --no-bind) ADD_BIND=false; shift ;;
    -h|--help)
      printf 'Usage: %s [--no-bind]\n' "$0"
      printf '  --no-bind   do not touch ~/.config/hypr/bindings.lua\n'
      exit 0 ;;
    *) printf 'error: unknown option: %s\n' "$1" >&2; exit 2 ;;
  esac
done

mkdir -p "$BIN_DIR"
install -m 755 "$REPO_DIR/bin/omaveil" "$BIN_DIR/omaveil"

if $ADD_BIND; then
  if [[ -f "$BINDINGS" ]] && grep -q 'omaveil' "$BINDINGS"; then
    echo "Keybinds already present in $BINDINGS"
  else
    mkdir -p "$(dirname "$BINDINGS")"
    cat >>"$BINDINGS" <<'EOF'

-- OmaVeil - window minimizer (added by omarchy-minimize install.sh)
o.bind("SUPER + H", "Minimize window", "omaveil minimize")
o.bind("SUPER + I", "Browse minimized windows", "omaveil restore")
o.bind("SUPER + U", "Restore last minimized", "omaveil restore-last")
o.bind("SUPER + SHIFT + U", "Restore all minimized", "omaveil restore-all")
EOF
    echo "Added Super+H / Super+I / Super+U / Super+Shift+U to $BINDINGS"
  fi
fi

echo "Checking dependencies..."
for cmd in hyprctl jq omarchy-menu-select; do
  if command -v "$cmd" >/dev/null 2>&1; then
    echo "  ok: $cmd"
  else
    echo "  MISSING: $cmd"
  fi
done

# Warn if an older `omaveil` earlier in PATH would shadow this install.
resolved=$(command -v omaveil 2>/dev/null || true)
if [ -n "$resolved" ] && [ "$resolved" != "$BIN_DIR/omaveil" ]; then
  echo
  echo "WARNING: 'omaveil' currently resolves to $resolved,"
  echo "         which shadows $BIN_DIR/omaveil."
  echo "         Remove the old one (e.g. sudo rm $resolved) to use this version."
fi

cat <<'EOF'

Done. Usage:
  Super+H          minimize the focused window
  Super+I          browse and restore a minimized window
  Super+U          restore the most recently minimized window
  Super+Shift+U    restore every minimized window

If the binds are new, apply them with:
  hyprctl reload

Make sure ~/.local/bin is on your PATH.
EOF
