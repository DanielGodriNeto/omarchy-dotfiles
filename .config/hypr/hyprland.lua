-- Learn how to configure Hyprland: https://wiki.hypr.land/Configuring/Start/

-- Omarchy's bootstrap keeps path setup out of this user config.
dofile((os.getenv("OMARCHY_PATH") or "/usr/share/omarchy") .. "/default/hypr/bootstrap.lua")

-- Disable all Omarchy default bindings. Add your own in hypr/bindings.lua.
-- omarchy_default_bindings = false
--
-- Or disable only bindings for Omarchy's preinstalled apps/web apps while
-- keeping core window-manager bindings:
-- omarchy_preinstalled_bindings = false

-- Load Omarchy defaults.
require("default.hypr.omarchy")

-- Put your personal overrides in these files. They're loaded after Omarchy's
-- defaults so package updates can improve the defaults without rewriting your
-- ~/.config/hypr files.
require("hypr.monitors")
require("hypr.input")
require("hypr.bindings")
require("hypr.looknfeel")
require("hypr.autostart")

-- Toggle config flags dynamically.
require("default.hypr.toggles")

-- Add any other personal Hyprland configuration below.
-- o.window("qemu", { workspace = "5" })

-- Steam's main window ships floated by default; force it back into the tiling grid.
o.window({ class = "steam", title = "Steam" }, { tile = true })

-- btop + cliamp "desktop widgets": route them into a dedicated workspace
-- (9) on launch so they run persistently in the background and are a
-- keypress away with Super+Shift+V (see hypr/autostart.lua and
-- hypr/bindings.lua). A Hyprland "special" workspace was tried first but
-- its toggle dispatcher proved unreliable on this build.
o.window({ class = "^(omarchy-widget-btop)$" }, { workspace = "9 silent" })
o.window({ class = "^(omarchy-widget-cliamp)$" }, { workspace = "9 silent" })

-- Terminais ficam sem blur para o lago de carpas por trás continuar nítido (mancato.lake).
o.window({ class = "^(foot)$" }, { no_blur = true })

-- Browser fullscreen (e.g. YouTube) only fills the tile: the page believes it is
-- fullscreen (client state 2) while Hyprland keeps the window in its layout (internal 0).
o.window({ class = "^(brave-origin)$" }, { fullscreen_state = "0 2" })
