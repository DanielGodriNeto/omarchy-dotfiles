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

-- Vicinae launcher (Spotlight style: apps, files, calculator, clipboard history).
-- SUPER+SPACE stays as the Omarchy menu; the daemon runs as a user service.
o.bind("SUPER + R", "Vicinae launcher", "vicinae toggle")

-- Peek at the desktop background (park open windows in a hidden special
-- workspace, then bring them back on the next press).
o.bind("SUPER + D", "Peek desktop", "omarchy-peek-desktop")

-- Open the Dead Cells interactive biome map (click a biome to apply it as
-- the desktop theme).
o.bind("SUPER + SHIFT + D", "Dead Cells biome map", "omarchy-deadcells-map")

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

-- Dictation keys from before Alt + Space and Right Alt became the defaults.
-- Remove these lines to give the keys back to applications.
if o.dictation_installed and o.dictation_installed() then
  o.bind("SUPER + CTRL + X", "Toggle dictation", "omarchy-dictation toggle")
  o.bind_hold("F9", "Start dictation (push-to-talk)", "omarchy-dictation start", "Stop dictation (push-to-talk)", "omarchy-dictation stop")
end

-- Alternar o layout do workspace (dwindle/rolagem/flutuante) desligado: sair do layout em rolagem derruba
-- o Hyprland 0.56.2. Religar quando o Hyprland for atualizado (0.57+): apague estas duas linhas.
-- SUPER + L bloqueia a tela, como no Windows (o antigo "alternar layout" estava desligado por causa do crash).
o.rebind("SUPER + L", "Lock system", "omarchy-system-lock")
hl.unbind("SUPER + ALT + L")
o.bind("SUPER + grave", "Workspaces overview", { panel = "mancato.overview" })
o.bind("SUPER + SHIFT + grave", "All windows", { panel = "mancato.expose" })
o.bind("SUPER + ALT + N", "Notification history", { panel = "mancato.notifcenter" })
o.bind("SUPER + ALT + Z", "Focus mode", "focus-mode")
