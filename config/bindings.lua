-- OmaVeil keybindings for Hyprland.
--
-- Add these lines to ~/.config/hypr/bindings.lua, then run `hyprctl reload`.
-- install.sh appends this block for you automatically.

o.bind("SUPER + H", "Minimize window", "omaveil minimize")
o.bind("SUPER + I", "Browse minimized windows", "omaveil restore")
o.bind("SUPER + U", "Restore last minimized", "omaveil restore-last")
o.bind("SUPER + SHIFT + U", "Restore all minimized", "omaveil restore-all")
