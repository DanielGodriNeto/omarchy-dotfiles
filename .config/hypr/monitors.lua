-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
-- List current monitors and supported resolutions with: hyprctl monitors all

local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1

hl.env("GDK_SCALE", tostring(omarchy_gdk_scale))
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = omarchy_monitor_scale })
hl.monitor({ output = "eDP-1", mode = "preferred", position = "auto", scale = 1 })

-- Configure a specific monitor.
-- hl.monitor({ output = "DP-2", mode = "2560x1440@144", position = "0x0", scale = 1 })

-- Portrait/rotated secondary monitor (transform: 1 = 90°, 3 = 270°).
-- hl.monitor({ output = "DP-2", mode = "preferred", position = "auto", scale = 1, transform = 1 })

-- The TV on HDMI-A-1 mirrors the laptop screen (default) or extends it, as chosen
-- with `display-mode` (Display panel in the bar): ~/.config/omarchy/display-mode.
local function display_mode()
  local file = io.open(os.getenv("HOME") .. "/.config/omarchy/display-mode", "r")
  if not file then return "mirror" end
  local mode = file:read("*l")
  file:close()
  return mode == "extend" and "extend" or "mirror"
end

if display_mode() == "mirror" then
  hl.monitor({ output = "HDMI-A-1", mode = "1920x1080@60", position = "0x0", scale = 1, mirror = "eDP-1" })
else
  hl.monitor({ output = "HDMI-A-1", mode = "preferred", position = "auto", scale = 1 })
end
