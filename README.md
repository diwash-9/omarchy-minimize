# omarchy-minimize (OmaVeil)

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Checks](https://github.com/diwash-9/omarchy-minimize/actions/workflows/checks.yml/badge.svg)](https://github.com/diwash-9/omarchy-minimize/actions/workflows/checks.yml)

A real **minimize / restore** workflow for [Omarchy](https://omarchy.org/) (Hyprland) — the feature Hyprland doesn't ship with.

Hyprland has no concept of "minimizing": a window is either on a workspace or hidden on a *special* workspace. **OmaVeil** turns a dedicated `special:minimum` workspace into a proper minimize stack. Press `Super+H` to hide the focused window, `Super+I` to browse everything you've hidden (a compact icon + title list in Omarchy's own native menu), and restore with one key. No daemon, no build step, no dependencies beyond what Omarchy already ships.

```
        Super+H                 Super+I                          Super+U
 ┌───────────────┐      ┌────────────────────────┐      ┌──────────────────────┐
 │ focused window│      │  Brave — YouTube       │      │  most recent window  │
 │  → hidden     │  →   │  Code — omaveil        │  →   │  → back on screen    │
 │ on special:   │      │  Ghostty — ~/dev       │      │                      │
 │   minimum     │      │  compact icon+title    │      │  Super+Shift+U = all │
 └───────────────┘      └────────────────────────┘      └──────────────────────┘
```

## Features

- **`Super+H` — minimize** the focused window into the `minimum` special workspace.
- **`Super+I` — browse & restore** every minimized window from a compact
  icon + title list rendered by Omarchy's own native menu
  (`omarchy-menu-select`). Filters as you type.
- **`Super+U` — restore the last** window you minimized.
- **`Super+Shift+U` — restore all** minimized windows at once.
- **Omarchy-native** — uses `omarchy-menu-select` for the picker and Hyprland's
  Lua dispatch (`hl.dsp.window.move`) with an automatic fallback to the legacy
  `movetoworkspacesilent` / `movetoworkspace` / `focuswindow` dispatchers.
- **Bar-widget friendly** — `omaveil show` prints status JSON (text/class/tooltip)
  for a custom bar module.
- **Pure Bash** — one small, auditable script. No compilation, no background
  process.

## Requirements

- **Omarchy** on Arch Linux (Hyprland + the Omarchy shell).
- `bash`, `hyprctl`, `jq`.
- `omarchy-menu-select` (ships with Omarchy) — the picker.

Everything is already present on an Omarchy install.

## Installation

### From source

```bash
git clone https://github.com/diwash-9/omarchy-minimize
cd omarchy-minimize
./install.sh
```

`install.sh` copies `omaveil` to `~/.local/bin`, appends the keybindings to
`~/.config/hypr/bindings.lua`, and reports any missing dependencies. Pass
`--no-bind` to skip the keybindings. Ensure `~/.local/bin` is on your `PATH`.

Apply the new bindings:

```bash
hyprctl reload
```

### Manual

```bash
install -Dm755 bin/omaveil ~/.local/bin/omaveil
cat config/bindings.lua >> ~/.config/hypr/bindings.lua
hyprctl reload
```

> Use `hyprctl reload`, **not** `omarchy refresh hyprland` — the latter resets
> `~/.config/hypr/bindings.lua` and would wipe these binds.

## Usage

### Keybindings

| Key | Action |
| --- | --- |
| `Super+H` | Minimize the focused window |
| `Super+I` | Browse minimized windows and restore one |
| `Super+U` | Restore the most recently minimized window |
| `Super+Shift+U` | Restore all minimized windows |

### Command line

```bash
omaveil minimize                 # hide the focused window
omaveil restore                  # open the picker
omaveil restore 0x606e8cbcb1b0   # restore one window by its Hyprland address
omaveil restore-last             # restore the most recent
omaveil restore-all              # restore everything
omaveil show                     # status JSON for a bar widget
omaveil --version
```

## Configuration

| Variable | Default | Meaning |
| --- | --- | --- |
| `OMAVEIL_WORKSPACE` | `minimum` | Name of the special workspace used for the stack. |
| `OMAVEIL_STATE_DIR` | `/tmp/minimize-state` | Where `windows.json` is kept. |
| `OMAVEIL_LOG` | `/tmp/omaveil.log` | Error log. |

Because minimized windows don't survive a reboot, the state is intentionally
kept under `/tmp` and is cleared on reboot. Override the variables if you'd
rather use `$XDG_RUNTIME_DIR`.

### Icons

Window icons come from a small class → [Nerd Font](https://www.nerdfonts.com/)
glyph map at the top of `bin/omaveil` (`ICON_*`). Edit `icon_for_class()` to add
your own apps.

### Bar widget

`omaveil show` prints JSON that a bar module can poll:

```json
{"text":"󰘸 2","class":"has-windows","tooltip":"2 minimized windows"}
{"text":"󰘸","class":"empty","tooltip":"No minimized windows"}
```

## How it works

1. **Minimize** — `omaveil` reads the focused window with
   `hyprctl activewindow -j`, records the window (address, title, class, icon)
   in `windows.json`, then moves it to `special:minimum` with
   `hl.dsp.window.move`.
2. **Restore** — it looks up the current workspace with
   `hyprctl activeworkspace -j`, moves the window out of the special workspace
   onto it, focuses it, and drops it from the state file.
3. **Picker** — `Super+I` opens Omarchy's native menu
   (`omarchy-menu-select`) listing each minimized window as `<icon>` + title;
   the chosen index maps back to the window address.

If a Hyprland Lua dispatch isn't available, every operation falls back to the
equally-capable legacy dispatchers, so the tool keeps working across Hyprland
versions.

## Project layout

```
bin/omaveil              the whole tool (installed as `omaveil`)
config/bindings.lua      Hyprland keybinding snippet
install.sh               per-user installer
uninstall.sh             per-user uninstaller
.github/workflows/       shellcheck + syntax checks
```

## Uninstall

```bash
./uninstall.sh
```

This removes `~/.local/bin/omaveil` and the runtime state. The entries in
`~/.config/hypr/bindings.lua` are left in place — remove them by hand and run
`hyprctl reload`.

## Troubleshooting

- **`Super+I` does nothing / "omarchy-menu-select not found"** — the picker is
  required; make sure the Omarchy shell is running.
- **Wrong window gets minimized** — `omaveil` acts on Hyprland's *active*
  window. If a keybinding runs before focus settles, try again.
- **Wrong window gets minimized** — `omaveil` acts on Hyprland's *active*
  window. If a keybinding runs before focus settles, try again.
- **Nothing appears after a reboot** — expected: minimized state lives in `/tmp`.
- **`omaveil: command not found`** — add `~/.local/bin` to your `PATH`.

## Credits

Made for [Omarchy](https://omarchy.org/) on Hyprland by [Diwash](https://github.com/diwash-9). The idea grew out of a personal Rust `omaveil` binary; this project is the portable, script-only version.

## License

[MIT](LICENSE) © 2026 Diwash
