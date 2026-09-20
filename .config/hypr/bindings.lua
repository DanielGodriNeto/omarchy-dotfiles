-- Keep only your personal keybinding overrides here. Add new bindings or
-- unbind defaults before replacing them.

-- See current bindings and descriptions:
--   omarchy menu keybindings --print

-- To disable every Omarchy default binding, set this in
-- ~/.config/hypr/hyprland.lua before require("default.hypr.omarchy"), then add
-- only the bindings you want below:
--   omarchy_default_bindings = false

-- To disable all preinstalled app/webapp bindings, set:
--   omarchy_preinstalled_bindings = false

-- Add a new binding.
-- o.bind("SUPER + SHIFT + R", "SSH", "alacritty -e ssh your-server")

-- Change an existing binding by unbinding it first, then binding the key again.
-- This example changes SUPER+SPACE from the launcher to the Omarchy root menu.
-- hl.unbind("SUPER + SPACE")
-- o.bind("SUPER + SPACE", "Omarchy menu", "omarchy-menu toggle root")

-- Disable a default binding without replacing it.
-- hl.unbind("SUPER + SHIFT + B")

-- Peek at the desktop background (park open windows in a hidden special
-- workspace, then bring them back on the next press).
o.bind("SUPER + D", "Peek desktop", "omarchy-peek-desktop")

-- Toggle the btop + cliamp desktop widgets (system stats + music player)
-- in and out of view. They run persistently in the background (see
-- hypr/autostart.lua) and are tiled side by side like the Cyberpunk
-- Edgerunners preview.
-- (Super+Shift+M is already Omarchy's default "Music" -> Spotify binding,
-- so this uses Super+Shift+V instead to avoid clobbering it.)
-- Uses a dedicated real workspace (9) rather than a Hyprland "special"
-- workspace: the special-workspace toggle dispatcher proved unreliable on
-- this build (API call succeeds but nothing visibly shows/hides).
o.bind("SUPER + SHIFT + V", "Toggle media widgets", "omarchy-toggle-widgets")

-- Switch the cliamp widget's music source between Spotify and local radio.
o.bind("SUPER + SHIFT + T", "Toggle music source (Spotify/Radio)", "omarchy-cliamp-toggle-provider")

-- Toggle the wallpaper vignette effect on/off.
o.bind("SUPER + SHIFT + Z", "Toggle wallpaper effect", "omarchy-wallpaper-effect-toggle")

-- Logitech MX Keys examples:
-- o.bind("SUPER + SHIFT + S", nil, "omarchy-capture-screenshot")
-- o.bind("SUPER + H", nil, "voxtype record toggle")
-- o.bind("SUPER + PERIOD", nil, "omarchy-shell shell toggle omarchy.emojis")
